import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/features/medicine/data/models/schedule_model.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine_schedule/bloc/medicine_schedule_bloc.dart';

import 'package:mama_pill/core/presentation/widgets/custom_button.dart';
import 'package:mama_pill/core/presentation/widgets/custom_input_card.dart';
import 'package:mama_pill/core/presentation/widgets/custom_progress_indicator.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/core/services/service_locator.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/core/utils/extensions.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine_form/cubit/medicine_form_cubit.dart';
import 'package:mama_pill/features/notifications/presentation/controller/bloc/notification_bloc.dart';
import 'package:mama_pill/features/notifications/domain/entities/notification.dart';
import 'package:mama_pill/features/medicine/data/models/schedule_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditDispenserForm extends StatefulWidget {
  const EditDispenserForm({
    super.key,
    required this.medicine,
    required this.index,
  });
  final MedicineSchedule medicine;
  final int index;

  @override
  State<EditDispenserForm> createState() => _EditDispenserFormState();
}

class _EditDispenserFormState extends State<EditDispenserForm> {
  late MedicineFormCubit _medicineFormCubit;

  @override
  void initState() {
    super.initState();
    _medicineFormCubit = sl<MedicineFormCubit>();
    // Initialize cubit state only once
    _medicineFormCubit.medicineNameController.text = widget.medicine.medicine;
    _medicineFormCubit.emit(_medicineFormCubit.state.copyWith(
      type: widget.medicine.type,
      dose: widget.medicine.dose,
      selectedDays: widget.medicine.schedule.days,
      selectedTimes: widget.medicine.schedule.times,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MedicineFormCubit>.value(value: _medicineFormCubit),
        BlocProvider(create: (context) => sl<MedicineScheduleBloc>()),
        BlocProvider(create: (context) => sl<NotificationBloc>())
      ],
      child: BlocListener<MedicineScheduleBloc, MedicineScheduleState>(
        listener: (context, state) {
          if (state.saveStatus == RequestStatus.success ||
              state.deleteStatus == RequestStatus.success) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<MedicineFormCubit, MedicineFormState>(
          builder: (context, medicineFormState) {
            return BlocBuilder<MedicineScheduleBloc, MedicineScheduleState>(
                builder: (context, medicineScheduleState) {
              final screenWidth = MediaQuery.of(context).size.width;
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.95),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 8.w,
                      right: 8.w,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _dragLable(),
                        SizedBox(height: 8.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _medicineNameTextField(context),
                            SizedBox(height: 8.h),
                            _doseCounter(context),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        _scheduleTextField(context),
                        SizedBox(height: 8.h),
                        _timeIntervalsWidget(
                            context, _medicineFormCubit, medicineFormState),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: medicineScheduleState.saveStatus ==
                                        RequestStatus.loading
                                    ? const CustomProgressIndicator()
                                    : CustomButton(
                                        height: AppHeight.h40.h,
                                        lable: 'Save Changes',
                                        backgroundColor: AppColors.primary,
                                        onTap: () {
                                          // Get the current cubit and bloc
                                          final medicineFormCubit =
                                              context.read<MedicineFormCubit>();
                                          final medicineScheduleBloc = context
                                              .read<MedicineScheduleBloc>();

                                          // Create updated medicine schedule
                                          final updatedMedicine =
                                              MedicineSchedule(
                                            id: widget.medicine.id,
                                            index: widget.medicine.index,
                                            userId: widget.medicine.userId,
                                            medicine: medicineFormCubit
                                                .medicineNameController.text,
                                            type: medicineFormCubit.state.type,
                                            dose: medicineFormCubit.state.dose,
                                            schedule: ScheduleModel(
                                              days: medicineFormCubit
                                                  .state.selectedDays,
                                              times: medicineFormCubit
                                                  .state.selectedTimes,
                                            ),
                                          );

                                          // Cancel existing notification
                                          final notificationBloc =
                                              context.read<NotificationBloc>();
                                          notificationBloc.add(
                                            NotificationCanceled(
                                              id: widget.medicine.index,
                                              schedule:
                                                  widget.medicine.schedule,
                                            ),
                                          );

                                          // Dispatch update event
                                          medicineScheduleBloc.add(
                                              MedicineScheduleAdded(
                                                  medicineSchedule:
                                                      updatedMedicine));

                                          // Check if notifications are enabled before scheduling new ones
                                          final prefs =
                                              SharedPreferences.getInstance();
                                          final notificationsEnabled =
                                              prefs.then((prefs) =>
                                                  prefs.getBool(
                                                      'notifications_enabled') ??
                                                  true);

                                          notificationsEnabled.then((enabled) {
                                            if (enabled) {
                                              // Schedule new notification
                                              notificationBloc.add(
                                                WeeklyNotificationScheduled(
                                                  notification:
                                                      NotificationData(
                                                    id: widget.medicine.index,
                                                    title: 'Medicine Time',
                                                    body:
                                                        'Take ${medicineFormCubit.medicineNameController.text} - ${medicineFormCubit.state.dose} ${medicineFormCubit.state.type.name}',
                                                    schedule: ScheduleModel(
                                                      days: medicineFormCubit
                                                          .state.selectedDays,
                                                      times: medicineFormCubit
                                                          .state.selectedTimes,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          });
                                        },
                                      ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: medicineScheduleState.deleteStatus ==
                                        RequestStatus.loading
                                    ? const CustomProgressIndicator()
                                    : CustomButton(
                                        height: 36.h,
                                        lable: 'Delete Medicine',
                                        margin: EdgeInsets.zero,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        onTap: () {
                                          final notificationBloc =
                                              context.read<NotificationBloc>();
                                          final MedicineScheduleBloc
                                              medicineScheduleBloc = context
                                                  .read<MedicineScheduleBloc>();
                                          notificationBloc.add(
                                            NotificationCanceled(
                                              id: widget.medicine.index,
                                              schedule:
                                                  widget.medicine.schedule,
                                            ),
                                          );
                                          medicineScheduleBloc.add(
                                              MedicineScheduleDeleted(
                                                  medicineId:
                                                      widget.medicine.id));
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Center _dragLable() {
    return Center(
      child: Container(
        width: AppWidth.w48.w,
        height: AppHeight.h4.h,
        margin: const EdgeInsets.only(top: 14).w,
        decoration: BoxDecoration(
          color: AppColors.divider.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10).r,
        ),
      ),
    );
  }

  CustomInputCard _medicineNameTextField(BuildContext context) {
    final medcineFormCubit = context.read<MedicineFormCubit>();
    return CustomInputCard(
      label: 'Medicine Name',
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0).w,
      width: AppWidth.w200.w,
      content: Padding(
        padding: const EdgeInsets.all(12.0).w,
        child: TextField(
          controller: medcineFormCubit.medicineNameController,
          style: TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: medcineFormCubit.medicineNameController.text,
            border: InputBorder.none,
          ),
        ),
      ),
      leading: GestureDetector(
        onTap: () => medcineFormCubit.toggleMedicineType(),
        child: Container(
          padding: const EdgeInsets.all(AppPadding.p14).w,
          child: ImageIcon(AssetImage(medcineFormCubit.state.type.icon),
              size: 10.h, color: AppColors.primary),
        ),
      ),
    );
  }

  CustomInputCard _doseCounter(BuildContext context) {
    final medcineFormCubit = context.read<MedicineFormCubit>();
    final TextTheme textTheme = Theme.of(context).textTheme;

    return CustomInputCard(
      label: 'Dose',
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      width: AppWidth.w200.w,
      content: LayoutBuilder(
        builder: (context, constraints) {
          return BlocBuilder<MedicineFormCubit, MedicineFormState>(
            builder: (context, state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 1,
                    child: IconButton(
                      constraints:
                          BoxConstraints(minWidth: 40.w, minHeight: 40.h),
                      icon: Icon(Icons.remove,
                          color:
                              state.dose > 1 ? AppColors.primary : Colors.grey,
                          size: 20.sp),
                      onPressed: state.dose > 1
                          ? () {
                              medcineFormCubit.decrementDose();
                            }
                          : null,
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Text(
                      '${state.dose} ${medcineFormCubit.state.type.name}',
                      style: textTheme.bodyMedium?.copyWith(
                          fontSize: 16.sp, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: IconButton(
                      constraints:
                          BoxConstraints(minWidth: 40.w, minHeight: 40.h),
                      icon: Icon(Icons.add,
                          color: AppColors.primary, size: 20.sp),
                      onPressed: () {
                        medcineFormCubit.incrementDose();
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  CustomInputCard _scheduleTextField(BuildContext context) {
    final medcineFormCubit = context.read<MedicineFormCubit>();
    return CustomInputCard(
      label: 'Schedule',
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1.sw - 64.w),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: medcineFormCubit.weekdays.map((day) {
              final weekdayName = medcineFormCubit
                  .weekdaysNames[medcineFormCubit.weekdays.indexOf(day)];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: FilterChip(
                  label: Text(
                    weekdayName,
                    style: TextStyle(
                        fontSize: 12.sp, overflow: TextOverflow.ellipsis),
                    maxLines: 1,
                  ),
                  selected: medcineFormCubit.state.selectedDays.contains(day),
                  onSelected: (bool selected) {
                    medcineFormCubit.toggleDaySelection(day);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppPadding.p14).w,
        child: Icon(Icons.calendar_month_outlined,
            size: 20.h, color: AppColors.primary),
      ),
    );
  }

  Widget _timeIntervalsWidget(
    BuildContext context,
    MedicineFormCubit medcineFormCubit,
    MedicineFormState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            'Times',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _showTimePicker(context, medcineFormCubit),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_alarm, color: AppColors.white, size: 24.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'Add Time',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (state.selectedTimes.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: state.selectedTimes.map((time) {
                return Chip(
                  label: Text(time, style: TextStyle(fontSize: 12.sp)),
                  onDeleted: () => medcineFormCubit.removeTime(time),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _showTimePicker(
      BuildContext context, MedicineFormCubit medcineFormCubit) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.backgroundPrimary,
              onSurface: AppColors.primary,
            ),
            textTheme: Theme.of(context).textTheme.copyWith(
                  bodyLarge: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  bodyMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final formattedTime = pickedTime.format(context);
      medcineFormCubit.addTime(formattedTime);
    }
  }
}
