import 'package:dartz/dartz.dart';
import 'package:mama_pill/core/data/error/failure.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';

abstract class MedicineRepository {
  Future<Either<Failure, Unit>> addMedicineSchedule(MedicineSchedule dispenser);
  Future<Either<Failure, Unit>> deleteMedicineSchedule(String dispenserId);
  Stream<List<MedicineSchedule>> getAllMedicinesStream(String patientId);
}
