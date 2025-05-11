part of 'all_medicines_schedule_bloc.dart';

abstract class AllMedicinesScheduleEvent extends Equatable {
  const AllMedicinesScheduleEvent();

  @override
  List<Object> get props => [];
}

class AllDispensersFetched extends AllMedicinesScheduleEvent {
  const AllDispensersFetched({required this.dispensers, this.hasError = false});
  final List<MedicineSchedule> dispensers;
  final bool hasError;

  @override
  List<Object> get props => [dispensers, hasError];
}
