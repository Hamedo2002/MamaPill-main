import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:mama_pill/features/medicine/data/models/medicne_schedule_model.dart';
import 'package:mama_pill/features/medicine/data/models/schedule_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';

abstract class MedicineRemoteDataSource {
  Future<Unit> addMedicineSchedule(MedicineSchedule dispenser);
  Future<Unit> deleteMedicineSchedule(String id);
  Stream<List<MedicineSchedule>> getAllMedicinesStream(String patientId);
}

class MedicineRemoteDataSourceImpl extends MedicineRemoteDataSource {
  MedicineRemoteDataSourceImpl();

  final CollectionReference medicinesCollection =
      FirebaseFirestore.instance.collection('medicines');

  @override
  Stream<List<MedicineSchedule>> getAllMedicinesStream(String patientId) {
    try {
      return medicinesCollection
          .where('userId', isEqualTo: patientId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            // Add the document ID to the data if it's not already present
            if (!data.containsKey('id')) {
              data['id'] = doc.id;
            }
            return MedicineScheduleModel.fromJson(data);
          } catch (e) {
            print('Error converting document ${doc.id}: $e');
            rethrow;
          }
        }).toList();
      });
    } catch (e) {
      print('Error setting up medicines stream: $e');
      rethrow;
    }
  }

  @override
  Future<Unit> addMedicineSchedule(MedicineSchedule dispenser) async {
    try {
      // Convert to MedicineScheduleModel if not already
      MedicineScheduleModel model = dispenser is MedicineScheduleModel
          ? dispenser
          : MedicineScheduleModel(
              id: dispenser.id,
              index: dispenser.index,
              userId: dispenser.userId,
              medicine: dispenser.medicine,
              type: dispenser.type,
              dose: dispenser.dose,
              schedule: ScheduleModel(
                days: dispenser.schedule.days,
                times: dispenser.schedule.times,
              ),
            );

      // If the id is empty or null, generate a new doc and assign its id
      if (model.id.isEmpty) {
        final docRef = medicinesCollection.doc();
        model = MedicineScheduleModel(
          id: docRef.id,
          index: model.index,
          userId: model.userId,
          medicine: model.medicine,
          type: model.type,
          dose: model.dose,
          schedule: model.schedule as ScheduleModel,
        );
        await docRef.set(model.toJson());
      } else {
        await medicinesCollection.doc(model.id).set(model.toJson());
      }
      return unit;
    } catch (e) {
      print('Error adding medicine schedule: $e');
      rethrow;
    }
  }

  @override
  Future<Unit> deleteMedicineSchedule(String id) async {
    try {
      await medicinesCollection.doc(id).delete();
      return unit;
    } catch (e) {
      print('Error deleting medicine schedule: $e');
      rethrow;
    }
  }
}
