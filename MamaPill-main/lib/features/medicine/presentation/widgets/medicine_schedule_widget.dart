import 'package:flutter/material.dart';
import 'package:mama_pill/features/medicine/presentation/components/medicine_schedule_section.dart';

class DispenserWidget extends StatelessWidget {
  const DispenserWidget({
    super.key,
    required this.patientId,
  });
  final String patientId;

  @override
  Widget build(BuildContext context) {
    return MedicineScheduleSection(
      medicineSchedules: const [], // Start with empty list
      patientId: patientId,
    );
  }
}
