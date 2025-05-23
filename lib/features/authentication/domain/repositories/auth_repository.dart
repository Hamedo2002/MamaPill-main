import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mama_pill/core/data/error/failure.dart';
import 'package:mama_pill/features/authentication/domain/entities/user_profile.dart';

abstract class AuthRepository {
  Future<User> getUserProfile();
  Stream<User?> userStateChange();
  Future<Either<Failure, Unit>> signInWithEmailAndPassword(UserProfile user);
  Future<Either<Failure, Unit>> createUserWithEmailAndPassword(
      UserProfile user);
  Future<Either<Failure, Unit>> signOut();
}
