part of 'medicine_schedule_bloc.dart';

class MedicineScheduleState extends Equatable {
  const MedicineScheduleState({
    this.saveStatus = RequestStatus.initial,
    this.deleteStatus = RequestStatus.initial,
    this.status = RequestStatus.initial,
    this.message = '',
  });

  final RequestStatus saveStatus;
  final RequestStatus deleteStatus;
  final RequestStatus status;
  final String message;

  MedicineScheduleState copyWith({
    RequestStatus? saveStatus,
    RequestStatus? deleteStatus,
    RequestStatus? status,
    String? message,
  }) {
    return MedicineScheduleState(
      saveStatus: saveStatus ?? this.saveStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [saveStatus, deleteStatus, status, message];
}
