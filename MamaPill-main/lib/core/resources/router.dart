import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import 'package:mama_pill/core/presentation/view/home_view.dart';
import 'package:mama_pill/core/presentation/view/settings_view.dart';
import 'package:mama_pill/core/presentation/view/splash_view.dart';
import 'package:mama_pill/core/presentation/view/welcome_view.dart';
import 'package:mama_pill/core/resources/routes.dart';
import 'package:mama_pill/core/utils/route_utils.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/authentication/presentation/view/login_view.dart';
import 'package:mama_pill/features/authentication/presentation/view/register_view.dart';

class AppRouter {
  final AuthBloc authBloc;
  late GoRouter router;

  AppRouter(this.authBloc) {
    router = GoRouter(
      debugLogDiagnostics: true,
      initialLocation: AppRoutes.splash.path,
      routes: [
        GoRoute(
          path: AppRoutes.splash.path,
          name: AppRoutes.splash.name,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SplashView()),
        ),
        GoRoute(
          path: AppRoutes.welcome.path,
          name: AppRoutes.welcome.name,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: WelcomeView()),
        ),
        GoRoute(
          path: AppRoutes.login.path,
          name: AppRoutes.login.name,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: LoginView()),
        ),
        GoRoute(
          path: AppRoutes.register.path,
          name: AppRoutes.register.name,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: RegisterView()),
        ),
        GoRoute(
          path: AppRoutes.home.path,
          name: AppRoutes.home.name,
          pageBuilder: (context, state) =>
              NoTransitionPage(child: HomeView(authBloc: authBloc)),
          routes: [
            GoRoute(
              path: AppRoutes.setting.path,
              name: AppRoutes.setting.name,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: SettingsView(authBloc: state.extra as AuthBloc),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.elasticOut;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  var scaleAnimation = Tween<double>(
                    begin: 0.8,
                    end: 1.0,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ));

                  return SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: scaleAnimation,
                        child: child,
                      ),
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 800),
                reverseTransitionDuration: const Duration(milliseconds: 600),
              ),
            ),
          ],
        ),
      ],
      redirect: (context, state) =>
          RouteUtils.handleRedirect(authBloc, context, state),
      refreshListenable: GoRouterRefreshStream(authBloc),
    );
  }
}
