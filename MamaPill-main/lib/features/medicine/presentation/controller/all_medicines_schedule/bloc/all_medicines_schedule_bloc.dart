import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/domain/usecases/get_all_medicines_stream_usecase.dart';

part 'all_medicines_schedule_event.dart';
part 'all_medicines_schedule_state.dart';

class AllMedicinesScheduleBloc
    extends Bloc<AllMedicinesScheduleEvent, AllMedicinesScheduleState> {
  final AuthBloc authBloc;
  late StreamSubscription<AuthState> authSubscription;
  final GetDispenserStreamUseCase getDispenserStreamUseCase;
  StreamSubscription<List<MedicineSchedule>>? patientSubscription;
  
  AllMedicinesScheduleBloc(
    this.authBloc,
    this.getDispenserStreamUseCase,
  ) : super(const AllMedicinesScheduleState()) {
    on<AllDispensersFetched>(_onAllDispensersFetched);

    // Start listening to current user's medicines immediately
    final currentUser = authBloc.state.user;
    if (currentUser.id != null && currentUser.id!.isNotEmpty) {
      _startListeningToMedicines(currentUser.id!);
    }

    // Listen for auth state changes
    authSubscription = authBloc.stream.listen((authState) {
      if (authState.user.id != null && authState.user.id!.isNotEmpty) {
        _startListeningToMedicines(authState.user.id!);
      }
    });
  }

  void _startListeningToMedicines(String patientId) {
    // Cancel existing subscription if any
    patientSubscription?.cancel();
    
    // Start new subscription
    patientSubscription = getDispenserStreamUseCase(patientId).listen(
      (dispensers) {
        add(AllDispensersFetched(dispensers: dispensers));
      },
      onError: (error) {
        add(AllDispensersFetched(dispensers: [], hasError: true));
      },
    );
  }
  FutureOr<void> _onAllDispensersFetched(
    AllDispensersFetched event,
    Emitter<AllMedicinesScheduleState> emit,
  ) async {
    if (event.hasError) {
      emit(state.copyWith(status: RequestStatus.failure));
      return;
    }

    emit(state.copyWith(
        status: RequestStatus.success, dispensers: event.dispensers));
  }

  @override
  Future<void> close() {
    authSubscription.cancel();
    patientSubscription?.cancel();
    return super.close();
  }
}
