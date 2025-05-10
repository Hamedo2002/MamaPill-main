part of 'medicine_form_cubit.dart';

class MedicineFormState extends Equatable {
  const MedicineFormState({
    this.id = '',
    this.medicine = '',
    this.dose = 0,
    this.selectedTimes = const [],
    this.selectedDays = const [],
    this.type = MedicineType.capsule,
    this.selectedDay = 0,
    this.isML = true,
    required this.selectedTime,
  });

  final String id;
  final String medicine;
  final int dose;
  final List<String> selectedTimes;
  final List<int> selectedDays;
  final MedicineType type;
  final DateTime selectedTime;
  final int selectedDay;
  final bool isML;

  MedicineFormState copyWith({
    String? id,
    String? medicine,
    int? dose,
    List<String>? selectedTimes,
    List<int>? selectedDays,
    MedicineType? type,
    DateTime? selectedTime,
    int? selectedDay,
    bool? isML,
  }) {
    return MedicineFormState(
      id: id ?? this.id,
      medicine: medicine ?? this.medicine,
      dose: dose ?? this.dose,
      selectedTimes: selectedTimes ?? this.selectedTimes,
      selectedDays: selectedDays ?? this.selectedDays,
      type: type ?? this.type,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedDay: selectedDay ?? this.selectedDay,
      isML: isML ?? this.isML,
    );
  }

  @override
  List<Object> get props => [
        id,
        medicine,
        dose,
        selectedTimes,
        selectedDays,
        type,
        selectedTime,
        selectedDay,
        isML,
      ];
}
