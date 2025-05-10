import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/helpers/id_generator.dart';
import 'package:mama_pill/core/presentation/widgets/custom_button.dart';
import 'package:mama_pill/core/presentation/widgets/custom_input_card.dart';
import 'package:mama_pill/core/presentation/widgets/custom_progress_indicator.dart';
import 'package:mama_pill/core/presentation/widgets/day_time_card_tile.dart';
import 'package:mama_pill/core/presentation/widgets/day_time_list.dart';
import 'package:mama_pill/core/presentation/widgets/medicine_text_field.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/messages.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/core/services/service_locator.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/core/utils/extensions.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/domain/entities/schedule.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine_form/cubit/medicine_form_cubit.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine_schedule/bloc/medicine_schedule_bloc.dart';
import 'package:mama_pill/features/notifications/domain/entities/notification.dart';
import 'package:mama_pill/features/notifications/presentation/controller/bloc/notification_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicineForm extends StatelessWidget {
  const MedicineForm({
    super.key,
    required this.patientId,
    required this.index,
  });
  final String patientId;
  final int index;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<MedicineFormCubit>()),
        BlocProvider(create: (context) => sl<MedicineScheduleBloc>()),
        BlocProvider(create: (context) => sl<NotificationBloc>())
      ],
      child: BlocListener<MedicineScheduleBloc, MedicineScheduleState>(
        listener: (context, state) {
          if (state.saveStatus == RequestStatus.success) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<MedicineFormCubit, MedicineFormState>(
          builder: (context, medicineFormState) {
            final MedicineFormCubit medicineFormCubit =
                context.read<MedicineFormCubit>();
            return BlocBuilder<MedicineScheduleBloc, MedicineScheduleState>(
                builder: (context, medicineScheduleState) {
              final MedicineScheduleBloc medicineScheduleBloc =
                  context.read<MedicineScheduleBloc>();
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _dragLable(),
                  Row(
                    children: [
                      Expanded(child: _medicineNameTextField(context)),
                      Flexible(child: _doseCounter(context)),
                    ],
                  ),
                  _weekdaysWidget(context),
                  _timeIntervalsWidget(
                      context, medicineFormCubit, medicineFormState),
                  medicineScheduleBloc.state.saveStatus == RequestStatus.loading
                      ? const CustomProgressIndicator()
                      : _addMedcineButton(context, patientId),
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
    final medcineFormState = medcineFormCubit.state;
    return CustomInputCard(
      label: 'Medicine Name',
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0).w,
      content: MedicineTextField(
        controller: medcineFormCubit.medicineNameController,
        hintText: 'Enter medicine name',
      ),
      leading: GestureDetector(
        onTap: () => medcineFormCubit.toggleMedicineType(),
        child: Container(
          padding: const EdgeInsets.all(AppPadding.p14).w,
          child: ImageIcon(AssetImage(medcineFormState.type.icon),
              size: 10.h, color: AppColors.primary),
        ),
      ),
    );
  }

  CustomInputCard _doseCounter(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final medcineFormCubit = context.read<MedicineFormCubit>();
    final medcineFormState = medcineFormCubit.state;

    if (medcineFormState.type == MedicineType.liquid) {
      // Liquid UI
      return CustomInputCard(
        label: 'Dose',
        margin: const EdgeInsets.fromLTRB(8, 8, 16, 8).w,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => medcineFormCubit.toggleUnit(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  medcineFormState.isML ? 'ml' : 'cm',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Center(
              child: Text(
                '${medcineFormState.dose}',
                style: textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        leading: GestureDetector(
          onTap: () => medcineFormCubit.decrementDose(),
          child: const Icon(Icons.remove, color: AppColors.primary),
        ),
        trailing: GestureDetector(
          onTap: () => medcineFormCubit.incrementDose(),
          child: const Icon(Icons.add, color: AppColors.primary),
        ),
      );
    } else if (medcineFormState.type == MedicineType.injection) {
      // Injection UI (default color, only 'units' bold)
      return CustomInputCard(
        label: 'Dose',
        margin: const EdgeInsets.fromLTRB(8, 8, 16, 8).w,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${medcineFormState.dose}',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'units',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        leading: GestureDetector(
          onTap: () => medcineFormCubit.decrementDose(),
          child: const Icon(Icons.remove, color: AppColors.primary),
        ),
        trailing: GestureDetector(
          onTap: () => medcineFormCubit.incrementDose(),
          child: const Icon(Icons.add, color: AppColors.primary),
        ),
      );
    } else {
      // Capsule/Tablet UI
      return CustomInputCard(
        label: 'Dose',
        margin: const EdgeInsets.fromLTRB(8, 8, 16, 8).w,
        content: Center(
          child: Text(
            '${medcineFormState.dose}',
            style: textTheme.bodyMedium,
          ),
        ),
        leading: GestureDetector(
          onTap: () => medcineFormCubit.decrementDose(),
          child: const Icon(Icons.remove, color: AppColors.primary),
        ),
        trailing: GestureDetector(
          onTap: () => medcineFormCubit.incrementDose(),
          child: const Icon(Icons.add, color: AppColors.primary),
        ),
      );
    }
  }

  Widget _weekdaysWidget(BuildContext context) {
    final medcineFormCubit = context.read<MedicineFormCubit>();
    final medcineFormState = medcineFormCubit.state;
    return DayTimeList(
      title: 'Weekdays',
      dayTime: medcineFormCubit.weekdays,
      height: AppHeight.h72.h,
      itemBuilder: (context, index) {
        final int day = medcineFormCubit.weekdays[index];
        return DayTimeCardTile(
          showIcon: true,
          selectedTextColor: AppColors.black,
          title: medcineFormCubit.weekdaysNames[index].toUpperCase(),
          onTap: () => medcineFormCubit.toggleDaySelection(day),
          isSelected: medcineFormState.selectedDays.contains(day),
        );
      },
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

  CustomButton _addMedcineButton(BuildContext context, String patientId) {
    final medcineFormCubit = context.read<MedicineFormCubit>();
    final medcineFormState = medcineFormCubit.state;
    final medicineBloc = context.read<MedicineScheduleBloc>();
    final notificationBloc = context.read<NotificationBloc>();
    return CustomButton(
      height: AppHeight.h40.h,
      lable: 'Add Medcine',
      margin: AppMargin.medium.w,
      backgroundColor: AppColors.accent,
      onTap: () async {
        final Schedule schedule = Schedule(
          days: medcineFormState.selectedDays,
          times: medcineFormState.selectedTimes,
        );

        // Add medicine schedule
        medicineBloc.add(
          MedicineScheduleAdded(
            medicineSchedule: MedicineSchedule(
              id: IdGenerator.generateMedicineId(patientId, index),
              index: index,
              userId: patientId,
              medicine: medcineFormCubit.medicineNameController.text,
              dose: medcineFormState.dose,
              type: medcineFormState.type,
              schedule: schedule,
            ),
          ),
        );

        // Check if notifications are enabled before scheduling
        final prefs = await SharedPreferences.getInstance();
        final notificationsEnabled =
            prefs.getBool('notifications_enabled') ?? true;

        if (notificationsEnabled) {
          notificationBloc.add(
            WeeklyNotificationScheduled(
              notification: NotificationData(
                id: index,
                title: 'Medicine Time',
                body: AppMessages.getMedicineNotificationMessage(
                  medcineFormState.dose,
                  medcineFormCubit.medicineNameController.text,
                  medcineFormState.type.name,
                ),
                schedule: schedule,
              ),
            ),
          );
        }
      },
    );
  }
}
