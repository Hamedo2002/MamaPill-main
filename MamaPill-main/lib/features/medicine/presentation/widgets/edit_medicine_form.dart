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
import 'package:mama_pill/core/utils/top_notification_utils.dart';
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
    final theme = Theme.of(context);
    final medicineTypeColor = _medicineFormCubit.state.type.color;
    final medicineTypeIcon = _medicineFormCubit.state.type.icon;
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
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header bar
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            color: medicineTypeColor.withOpacity(0.15),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(28)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: medicineTypeColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: ImageIcon(
                                    AssetImage(medicineTypeIcon),
                                    size: 22,
                                    color: medicineTypeColor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Edit Medicine',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: medicineTypeColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Form sections
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _medicineNameTextField(context),
                              Divider(height: 16),
                              _doseCounter(context),
                              Divider(height: 16),
                              _scheduleTextField(context),
                              Divider(height: 16),
                              _timeIntervalsWidget(context, _medicineFormCubit,
                                  medicineFormState),
                              SizedBox(height: 36), // space for floating button
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Floating Save button
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: medicineScheduleState.saveStatus ==
                                RequestStatus.loading
                            ? const CustomProgressIndicator()
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: medicineTypeColor,
                                  shape: StadiumBorder(),
                                  elevation: 2,
                                ),
                                onPressed: () async {
                                  final medicineFormCubit =
                                      context.read<MedicineFormCubit>();
                                  final medicineScheduleBloc =
                                      context.read<MedicineScheduleBloc>();
                                  final updatedMedicine = MedicineSchedule(
                                    id: widget.medicine.id,
                                    index: widget.medicine.index,
                                    userId: widget.medicine.userId,
                                    medicine: medicineFormCubit
                                        .medicineNameController.text,
                                    type: medicineFormCubit.state.type,
                                    dose: medicineFormCubit.state.dose,
                                    schedule: ScheduleModel(
                                      days:
                                          medicineFormCubit.state.selectedDays,
                                      times:
                                          medicineFormCubit.state.selectedTimes,
                                    ),
                                  );
                                  final notificationBloc =
                                      context.read<NotificationBloc>();
                                  notificationBloc.add(
                                    NotificationCanceled(
                                      id: widget.medicine.index,
                                      schedule: widget.medicine.schedule,
                                    ),
                                  );
                                  medicineScheduleBloc.add(
                                    MedicineScheduleAdded(
                                        medicineSchedule: updatedMedicine),
                                  );

                                  // Show success notification
                                  TopNotificationUtils.showSuccessNotification(
                                    context,
                                    title: 'Medicine Updated',
                                    message:
                                        '${medicineFormCubit.medicineNameController.text} has been updated successfully!',
                                  );

                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final notificationsEnabled =
                                      prefs.getBool('notifications_enabled') ??
                                          true;
                                  if (notificationsEnabled) {
                                    notificationBloc.add(
                                      WeeklyNotificationScheduled(
                                        notification: NotificationData(
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
                                },
                                child: Text(
                                  'Save Changes',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
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
