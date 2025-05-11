import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mama_pill/core/presentation/widgets/card_section.dart';
import 'package:mama_pill/core/presentation/widgets/custom_progress_indicator.dart';
import 'package:mama_pill/core/resources/messages.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/presentation/components/add_medicine_tile.dart';
import 'package:mama_pill/features/medicine/presentation/components/medicine_schedule_tile.dart';
import 'package:mama_pill/core/presentation/widgets/empty_tile.dart';
import 'package:mama_pill/features/medicine/presentation/controller/all_medicines_schedule/bloc/all_medicines_schedule_bloc.dart';

class MedicineScheduleSection extends StatelessWidget {
  const MedicineScheduleSection({
    super.key,
    required this.patientId,
  });

  final String patientId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllMedicinesScheduleBloc, AllMedicinesScheduleState>(
      builder: (context, state) {
        final medicines = state.dispensers;

        return CardSection(
          title: 'Medicines',
          itemCount: state.status == RequestStatus.loading
              ? 2 // Show loading indicator + add button
              : medicines.length + 1, // Show medicines + add button
          itemBuilder: (context, index) {
            // Always show the Add Medicine button as the last item
            if (index ==
                (state.status == RequestStatus.loading
                    ? 1
                    : medicines.length)) {
              return AddMedicineTile(
                  patientId: patientId, index: medicines.length + 1);
            }

            // Show loading indicator
            if (state.status == RequestStatus.loading && index == 0) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CustomProgressIndicator(),
                ),
              );
            }

            // Show error message
            if (state.status == RequestStatus.failure && index == 0) {
              return const EmptyTile(
                  message: AppMessages.failedToLoadMedicines);
            }

            // Show medicines
            if (index < medicines.length) {
              return MedicineScheduleTile(medicineSchedule: medicines[index]);
            }

            // Show empty state if no medicines
            return const EmptyTile(message: 'No medicines added yet');
          },
        );
      },
    );
  }
}
