import 'package:dartz/dartz.dart';
import 'package:mama_pill/core/data/error/failure.dart';
import 'package:mama_pill/core/domain/usecase/usecase.dart';
import 'package:mama_pill/features/medicine/domain/repositories/medicine_repository.dart';

class DeleteDispenserUseCase extends UseCase<Unit, String> {
  final MedicineRepository dispenserRepository;

  DeleteDispenserUseCase(this.dispenserRepository);

  @override
  Future<Either<Failure, Unit>> call(String params) async {
    return await dispenserRepository.deleteMedicineSchedule(params);
  }
}
