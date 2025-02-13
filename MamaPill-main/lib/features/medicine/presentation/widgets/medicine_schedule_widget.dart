import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mama_pill/core/presentation/widgets/custom_progress_indicator.dart';
import 'package:mama_pill/core/services/service_locator.dart';
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
    return BlocProvider<AllMedicinesScheduleBloc>(
      create: (context) => sl<AllMedicinesScheduleBloc>(),
      child: BlocBuilder<AllMedicinesScheduleBloc, AllMedicinesScheduleState>(
        builder: (context, state) {
          switch (state.status) {
            case RequestStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case RequestStatus.success:
              return MedicineScheduleSection(
                  medicineSchedules: state.dispensers, patientId: patientId);
            case RequestStatus.failure:
              return const Center(child: Text('Failed to load data'));
            default:
              return const Center(child: CustomProgressIndicator());
          }
        },
      ),
    );
  }
}
