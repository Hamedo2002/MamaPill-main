import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mama_pill/core/helpers/date_time_formatter.dart';
import 'package:mama_pill/core/utils/enums.dart';

part 'medicine_form_state.dart';

class MedicineFormCubit extends Cubit<MedicineFormState> {
  final TextEditingController medicineNameController = TextEditingController();
  final List<int> weekdays = [
    DateTime.saturday,
    DateTime.sunday,
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday
  ];

  final List<String> weekdaysNames = [
    'Sat',
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
  ];

  final List<String> timeIntervals = [
    for (int hour = 0; hour < 24; hour++)
      for (int minute = 0; minute < 60; minute += 5)
        '${(hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${hour < 12 ? 'AM' : 'PM'}',
  ];

  MedicineFormCubit() : super(MedicineFormState(selectedTime: DateTime.now()));

  void setMedicine() {
    emit(state.copyWith(medicine: medicineNameController.text));
  }

  void incrementDose() {
    emit(state.copyWith(dose: state.dose + 1));
  }

  void decrementDose() {
    if (state.dose > 1) {
      emit(state.copyWith(dose: state.dose - 1));
    }
  }

  void toggleMedicineType() {
    if (state.type == MedicineType.capsule) {
      emit(state.copyWith(type: MedicineType.tablet));
    } else {
      emit(state.copyWith(type: MedicineType.capsule));
    }
  }

  void toggleDaySelection(int weekday) {
    List<int> currentSelection = List.from(state.selectedDays);
    if (currentSelection.contains(weekday)) {
      currentSelection.remove(weekday);
    } else {
      currentSelection.add(weekday);
    }
    emit(state.copyWith(selectedDays: List.from(currentSelection)));
  }

  void toggleTimeSelection(String time) {
    List<String> currentSelection = List.from(state.selectedTimes);
    if (currentSelection.contains(time)) {
      currentSelection.remove(time);
    } else {
      currentSelection.add(time);
    }
    emit(state.copyWith(selectedTimes: List.from(currentSelection)));
  }

  void onDateTimeChanged(DateTime dateTime) {
    emit(state.copyWith(
      selectedTime: dateTime,
      selectedTimes: [DateTimeFormatter.formatDateTime(dateTime)],
    ));
  }

  void addTime(String time) {
    List<String> currentTimes = List.from(state.selectedTimes);
    if (!currentTimes.contains(time)) {
      currentTimes.add(time);
      emit(state.copyWith(selectedTimes: currentTimes));
    }
  }

  void removeTime(String time) {
    List<String> currentTimes = List.from(state.selectedTimes);
    currentTimes.remove(time);
    emit(state.copyWith(selectedTimes: currentTimes));
  }
}
