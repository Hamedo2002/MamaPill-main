import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/domain/entities/user_profile.dart';
import 'package:mama_pill/features/authentication/domain/usecases/sign_up_usecase.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this.signUpUseCase) : super(const SignUpState());

  final SignUpUseCase signUpUseCase;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> signUp() async {
    formKey.currentState!.save();
    if (formKey.currentState!.validate()) {
      if (state.status == AuthStatus.submiting) return;
      try {
        emit(state.copyWith(status: AuthStatus.submiting));
        
        // Add delay to show loading screen
        await Future.delayed(const Duration(milliseconds: 500));
        
        final result = await signUpUseCase(
          UserProfile(
            email: emailController.text,
            password: passwordController.text,
            username: usernameController.text,
          ),
        );
        result.fold(
          (failure) => emit(
              state.copyWith(status: AuthStatus.failure, message: failure.message)),
          (user) => emit(state.copyWith(status: AuthStatus.success)),
        );
      } catch (e) {
        emit(state.copyWith(
            status: AuthStatus.failure, message: 'An error occurred'));
      }
    }
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }
}
