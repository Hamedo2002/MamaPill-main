import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mama_pill/core/resources/assets.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/routes.dart';
import 'package:mama_pill/core/resources/values.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  AnimationController? _logoController;
  AnimationController? _buttonController;

  Animation<double>? _logoScale;
  Animation<double>? _logoOpacity;
  Animation<double>? _buttonScale;
  Animation<double>? _buttonOpacity;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Initialize controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize animations
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController!,
        curve: Curves.easeOutBack,
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController!,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _buttonScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController!,
        curve: Curves.easeOutBack,
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController!,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Start animations in sequence
    _logoController!.forward().then((_) {
      _buttonController!.forward();
    });
  }

  @override
  void dispose() {
    _logoController?.dispose();
    _buttonController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_logoController == null || _buttonController == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with scale and fade animation
                AnimatedBuilder(
                  animation: _logoController!,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale!.value,
                      child: Opacity(
                        opacity: _logoOpacity!.value,
                        child: Image.asset(
                          AppAssets.logo,
                          width: 180.w,
                          height: 180.h,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 80.h),
                // Animated start button
                AnimatedBuilder(
                  animation: _buttonController!,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _buttonScale!.value,
                      child: Opacity(
                        opacity: _buttonOpacity!.value,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () =>
                                context.goNamed(AppRoutes.welcome.name),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 50.w,
                                vertical: 18.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
