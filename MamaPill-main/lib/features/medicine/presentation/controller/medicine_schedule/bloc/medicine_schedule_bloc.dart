import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/domain/usecases/add_medicine_schedule_usecase.dart';
import 'package:mama_pill/features/medicine/domain/usecases/delete_medicine_schedule_usecase.dart';

part 'medicine_schedule_event.dart';
part 'medicine_schedule_state.dart';

class MedicineScheduleBloc
    extends Bloc<MedicineScheduleEvent, MedicineScheduleState> {
  final AddPatientDataUseCase addPatientDataUseCase;
  final DeleteDispenserUseCase deleteDispenserUseCase;
  MedicineScheduleBloc(
    this.addPatientDataUseCase,
    this.deleteDispenserUseCase,
  ) : super(const MedicineScheduleState()) {
    on<MedicineScheduleAdded>(_onMedicineScheduleAdded);
    on<MedicineScheduleDeleted>(_onMedicineScheduleDeleted);
  }

  FutureOr<void> _onMedicineScheduleAdded(
      MedicineScheduleAdded event, Emitter<MedicineScheduleState> emit) async {
    emit(state.copyWith(saveStatus: RequestStatus.loading));
    final result = await addPatientDataUseCase(event.medicineSchedule);
    result.fold(
      (failure) => emit(state.copyWith(saveStatus: RequestStatus.failure)),
      (_) => emit(state.copyWith(saveStatus: RequestStatus.success)),
    );
  }

  FutureOr<void> _onMedicineScheduleDeleted(MedicineScheduleDeleted event,
      Emitter<MedicineScheduleState> emit) async {
    emit(state.copyWith(deleteStatus: RequestStatus.loading));
    final result = await deleteDispenserUseCase(event.medicineId);
    result.fold(
      (failure) => emit(state.copyWith(deleteStatus: RequestStatus.failure)),
      (_) => emit(state.copyWith(deleteStatus: RequestStatus.success)),
    );
  }
}
