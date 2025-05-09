import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mama_pill/core/helpers/validator.dart';
import 'package:mama_pill/core/presentation/widgets/custom_button.dart';
import 'package:mama_pill/core/presentation/widgets/custom_input_field.dart';
import 'package:mama_pill/core/presentation/widgets/custom_progress_indicator.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/routes.dart';
import 'package:mama_pill/core/resources/strings.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/presentation/controller/sign_up/cubit/sign_up_cubit.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    super.key,
    required this.cubit,
    required this.state,
  });

  final SignUpCubit cubit;
  final SignUpState state;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Form(
          key: widget.cubit.formKey,
          child: Container(
            margin: AppMargin.largeH.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _loginHeaderTitle(textTheme),
                SizedBox(height: AppHeight.h40.h),
                _usernameTextField(widget.cubit),
                SizedBox(height: AppHeight.h16.h),
                _emailTextField(widget.cubit),
                SizedBox(height: AppHeight.h16.h),
                _passwordTextField(widget.cubit, widget.state),
                SizedBox(height: AppHeight.h16.h),
                _confirmPasswordTextField(widget.cubit, widget.state),
                SizedBox(height: AppHeight.h40.h),
                widget.state.status == AuthStatus.submiting
                    ? const Center(child: CustomProgressIndicator())
                    : _loginButton(widget.cubit),
                _loginNow(context, textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

CustomButton _loginButton(SignUpCubit cubit) {
  return CustomButton(
    onTap: () => cubit.signUp(),
    lable: AppStrings.signUp,
    backgroundColor: AppColors.primary,
    margin: AppMargin.mediumH.w,
  );
}

CustomInputField _passwordTextField(SignUpCubit cubit, SignUpState state) {
  return CustomInputField(
    obscureText: true,
    hint: AppStrings.passwordHint,
    prefixIcon: Icons.lock,
    controller: cubit.passwordController,
    isPasswordVisible: state.isPasswordVisible,
    validator: (value) => Validator.validatePassword(value!),
    toggelPasswordVisibility: () => cubit.togglePasswordVisibility(),
  );
}

CustomInputField _confirmPasswordTextField(
    SignUpCubit cubit, SignUpState state) {
  return CustomInputField(
    obscureText: true,
    prefixIcon: Icons.lock,
    hint: AppStrings.confirmPasswordHint,
    controller: cubit.confirmPasswordController,
    isPasswordVisible: state.isPasswordVisible,
    validator: (value) => Validator.validateConfirmPassword(
        value!, cubit.passwordController.text),
    toggelPasswordVisibility: () => cubit.togglePasswordVisibility(),
  );
}

CustomInputField _emailTextField(SignUpCubit cubit) {
  return CustomInputField(
    hint: AppStrings.emailHint,
    prefixIcon: Icons.email_rounded,
    controller: cubit.emailController,
    keyboardType: TextInputType.emailAddress,
    validator: (value) => Validator.validateEmail(value!),
  );
}

CustomInputField _usernameTextField(SignUpCubit cubit) {
  return CustomInputField(
    hint: AppStrings.usernameHint,
    prefixIcon: Icons.person,
    controller: cubit.usernameController,
    textCapitalization: TextCapitalization.words,
    keyboardType: TextInputType.emailAddress,
    validator: (value) => Validator.validateField(value!),
  );
}

Column _loginHeaderTitle(TextTheme textTheme) {
  return Column(
    children: [
      Text(
        AppStrings.registerTitle,
        style: textTheme.titleLarge?.copyWith(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              color: AppColors.primary.withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      SizedBox(height: AppHeight.h6.h),
      Text(
        AppStrings.registerDescription,
        style: textTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 16.sp,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Row _loginNow(BuildContext context, TextTheme textTheme) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        AppStrings.alreadyHaveAcc,
        style: textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14.sp,
        ),
      ),
      TextButton(
        onPressed: () => context.pushNamed(AppRoutes.login.name),
        child: Text(
          AppStrings.loginNow,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    ],
  );
}
