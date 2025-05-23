import 'package:dartz/dartz.dart';
import 'package:mama_pill/core/data/error/failure.dart';
import 'package:mama_pill/core/domain/usecase/usecase.dart';
import 'package:mama_pill/features/authentication/domain/repositories/auth_repository.dart';

class LogoutUseCase extends UseCase<Unit, NoParams> {
  LogoutUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await repository.signOut();
  }
}
