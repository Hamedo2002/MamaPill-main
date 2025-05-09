import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mama_pill/core/presentation/widgets/custom_button.dart';
import 'package:mama_pill/core/presentation/widgets/svg_image.dart';
import 'package:mama_pill/core/resources/assets.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/routes.dart';
import 'package:mama_pill/core/resources/strings.dart';
import 'package:mama_pill/core/resources/values.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

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

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.backgroundSecondary,
            ],
          ),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(vertical: 36, horizontal: 14).w,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: SvgImage(
                      radius: AppRadius.large,
                      assetName: AppAssets.welcome,
                      width: AppWidth.screenWidth,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        AppStrings.welcomeTitle,
                        textAlign: TextAlign.center,
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
                      Padding(
                        padding: AppPadding.smallH.w,
                        child: Text(
                          AppStrings.welcomeDescription,
                          textAlign: TextAlign.center,
                          style: textTheme.titleSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _authButtonRow(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _authButtonRow(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(30.r),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(
          child: CustomButton(
            lable: AppStrings.registerTitle,
            onTap: () => context.pushNamed(AppRoutes.register.name),
            backgroundColor: AppColors.primary,
            textColor: AppColors.white,
            margin: EdgeInsets.zero,
          ),
        ),
        Flexible(
          child: CustomButton(
            lable: AppStrings.login,
            onTap: () => context.pushNamed(AppRoutes.login.name),
            backgroundColor: AppColors.white,
            textColor: AppColors.primary,
            margin: EdgeInsets.zero,
          ),
        ),
      ],
    ),
  );
}
