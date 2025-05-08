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
          if (state.status == RequestStatus.success) {
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
                  _timeIntervalsWidget(context, medicineFormCubit, medicineFormState),
                  medicineScheduleBloc.state.status == RequestStatus.loading
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
    return CustomInputCard(
      label: 'Dose',
      margin: const EdgeInsets.fromLTRB(8, 8, 16, 8).w,
      content: Center(
          child: Text('${medcineFormState.dose}', style: textTheme.bodyMedium)),
      leading: GestureDetector(
          onTap: () => medcineFormCubit.decrementDose(),
          child: const Icon(Icons.remove, color: AppColors.primary)),
      trailing: GestureDetector(
          onTap: () => medcineFormCubit.incrementDose(),
          child: const Icon(Icons.add, color: AppColors.primary)),
    );
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

  void _showTimePicker(BuildContext context, MedicineFormCubit medcineFormCubit) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
      onTap: () {
        final Schedule schedule = Schedule(
          days: medcineFormState.selectedDays,
          times: medcineFormState.selectedTimes,
        );
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
      },
    );
  }
}
