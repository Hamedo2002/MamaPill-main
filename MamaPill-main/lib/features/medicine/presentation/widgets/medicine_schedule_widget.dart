import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mama_pill/core/presentation/widgets/custom_progress_indicator.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/medicine/presentation/components/medicine_schedule_section.dart';
import 'package:mama_pill/features/medicine/presentation/controller/all_medicines_schedule/bloc/all_medicines_schedule_bloc.dart';

class DispenserWidget extends StatelessWidget {
  const DispenserWidget({
    super.key,
    required this.patientId,
  });
  final String patientId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllMedicinesScheduleBloc, AllMedicinesScheduleState>(
      builder: (context, state) {
        // Always show the MedicineScheduleSection, which includes the "Add Medicine" button
        return MedicineScheduleSection(
          patientId: patientId,
        );
      },
    );
  }
}
