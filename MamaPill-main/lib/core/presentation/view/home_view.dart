import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mama_pill/core/presentation/view/header_widget.dart';
import 'package:mama_pill/core/services/service_locator.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/calendar/presentation/widgets/calendar_widget.dart';
import 'package:mama_pill/features/medicine/presentation/widgets/medicine_schedule_widget.dart';
import 'package:mama_pill/features/medicine/presentation/widgets/medicine_widget.dart';
import 'package:mama_pill/features/medicine/presentation/controller/all_medicines_schedule/bloc/all_medicines_schedule_bloc.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine_schedule/bloc/medicine_schedule_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.authBloc});
  final AuthBloc authBloc;
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider(
          create: (context) => sl<AllMedicinesScheduleBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<MedicineScheduleBloc>(),
        ),
      ],
      child: BlocListener<MedicineScheduleBloc, MedicineScheduleState>(
        listener: (context, state) {
          if (state.saveStatus == RequestStatus.success) {
            // Force a refresh of the medicines list by triggering a new fetch
            final allMedicinesBloc = context.read<AllMedicinesScheduleBloc>();
            final userId = authBloc.state.user.id;
            if (userId != null && userId.isNotEmpty) {
              // Add an event to trigger a refresh
              allMedicinesBloc.add(AllDispensersFetched(dispensers: []));
            }
          }
        },
        child: Scaffold(
          body: SafeArea(
            minimum: const EdgeInsets.only(top: 42).h,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  HeaderWidget(authBloc: authBloc),
                  const CalendarWidget(),
                  const SizedBox(height: 20),
                  const MedicineWidget(),
                  const SizedBox(height: 20),
                  DispenserWidget(patientId: authBloc.state.user.id!),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
