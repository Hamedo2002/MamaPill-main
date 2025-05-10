import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mama_pill/core/helpers/date_time_formatter.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine.dart';
import 'package:mama_pill/features/medicine/presentation/controller/all_medicines_schedule/bloc/all_medicines_schedule_bloc.dart';
import 'package:mama_pill/features/calendar/presentation/controller/cubit/calendar_cubit.dart';

part 'medicine_state.dart';

class MedicineCubit extends Cubit<MedicineState> {
  final AllMedicinesScheduleBloc allDispensersBloc;
  late StreamSubscription<AllMedicinesScheduleState> allDispensersSubscription;

  final CalendarCubit calendarCubit;
  late StreamSubscription<DateTime> calendarSubscription;
  MedicineCubit(
    this.allDispensersBloc,
    this.calendarCubit,
  ) : super(const MedicineState()) {
    allDispensersSubscription = allDispensersBloc.stream.listen((state) {
      getMedicinesForCurrentWeekday(
          state.dispensers, calendarCubit.state.weekday);
    });
    calendarSubscription = calendarCubit.stream.listen((state) {
      getMedicinesForCurrentWeekday(
          allDispensersBloc.state.dispensers, state.weekday);
    });
  }

  void getMedicinesForCurrentWeekday(
      List<MedicineSchedule> dispensers, int currentWeekday) {
    List<Medicine> medicines = [];

    for (final MedicineSchedule dispenser in dispensers) {
      if (dispenser.schedule.days.contains(currentWeekday)) {
        for (final time in dispenser.schedule.times) {
          medicines.add(
            Medicine(
              id: dispenser.id,
              name: dispenser.medicine,
              type: dispenser.type,
              dose: dispenser.dose,
              time: time,
            ),
          );
        }
      }
    }
    // Remove duplicates by id
    final Map<String, Medicine> uniqueMap = {};
    for (final med in medicines) {
      uniqueMap[med.id] = med;
    }
    final uniqueMedicines = uniqueMap.values.toList();
    uniqueMedicines.sort((a, b) {
      final aTime = DateTimeFormatter.extractTime(a.time);
      final bTime = DateTimeFormatter.extractTime(b.time);
      return aTime.compareTo(bTime);
    });
    emit(state.copyWith(
        medicines: uniqueMedicines, currentWeekday: currentWeekday));
  }

  @override
  Future<void> close() {
    allDispensersSubscription.cancel();
    calendarSubscription.cancel();
    return super.close();
  }
}
