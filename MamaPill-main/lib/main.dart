import 'package:mama_pill/core/resources/router.dart';
import 'package:mama_pill/core/resources/theme.dart';
import 'package:mama_pill/core/services/bloc_observer.dart';
import 'package:mama_pill/core/services/local_notification_services.dart';
import 'package:mama_pill/core/services/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define missing enum
enum DeviceScreenType {
  mobile,
  tablet,
  desktop,
}

// Define missing class
class ResponsiveWrapper {
  static DeviceScreenType getDeviceType(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    if (deviceWidth >= 1100) {
      return DeviceScreenType.desktop;
    }

    if (deviceWidth >= 650) {
      return DeviceScreenType.tablet;
    }

    return DeviceScreenType.mobile;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    Bloc.observer = MyBlocObserver();
    ServiceLocator.init();

    // Initialize notifications and store the result
    final notificationsEnabled =
        await LocalNotificationServices.init(initSchedule: true);

    // Store the notification permission status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', notificationsEnabled);

    runApp(const MyApp());
  } catch (e) {
    print('Error during app initialization: $e');
    // Show error UI instead of crashing
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize app: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Use more adaptive design sizes
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: sl<AppRouter>().router,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getThemeData(),
          builder: (context, widget) {
            ScreenUtil.init(context);
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: MediaQuery.of(context).textScaleFactor > 1.2
                    ? 1.2
                    : MediaQuery.of(context).textScaleFactor,
              ),
              child: widget!,
            );
          },
        );
      },
    );
  }
}

class AppResponsive {
  // Responsive padding values
  static EdgeInsets responsivePadding(BuildContext context) {
    final deviceType = ResponsiveWrapper.getDeviceType(context);
    switch (deviceType) {
      case DeviceScreenType.desktop:
        return const EdgeInsets.all(24);
      case DeviceScreenType.tablet:
        return const EdgeInsets.all(16);
      case DeviceScreenType.mobile:
        return const EdgeInsets.all(12);
    }
  }

  // Responsive horizontal spacing
  static double responsiveHorizontalSpacing(BuildContext context) {
    final deviceType = ResponsiveWrapper.getDeviceType(context);
    switch (deviceType) {
      case DeviceScreenType.desktop:
        return 24.0;
      case DeviceScreenType.tablet:
        return 16.0;
      case DeviceScreenType.mobile:
        return 10.0;
    }
  }

  // Responsive vertical spacing
  static double responsiveVerticalSpacing(BuildContext context) {
    final deviceType = ResponsiveWrapper.getDeviceType(context);
    switch (deviceType) {
      case DeviceScreenType.desktop:
        return 32.0;
      case DeviceScreenType.tablet:
        return 24.0;
      case DeviceScreenType.mobile:
        return 16.0;
    }
  }

  // Responsive font size multiplier
  static double responsiveFontSizeMultiplier(BuildContext context) {
    final deviceType = ResponsiveWrapper.getDeviceType(context);
    switch (deviceType) {
      case DeviceScreenType.desktop:
        return 1.2;
      case DeviceScreenType.tablet:
        return 1.1;
      case DeviceScreenType.mobile:
        return 1.0;
    }
  }
}

class OrientationLayout extends StatelessWidget {
  final Widget portrait;
  final Widget? landscape;

  const OrientationLayout({
    Key? key,
    required this.portrait,
    this.landscape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.landscape && landscape != null) {
      return landscape!;
    }

    return portrait;
  }
}

final List<String> timeIntervals = [
  for (int hour = 0; hour < 24; hour++)
    for (int minute = 0; minute < 60; minute += 5)
      '${(hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${hour < 12 ? 'AM' : 'PM'}',
];
