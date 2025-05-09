import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/resources/assets.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/core/presentation/view/settings_view.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({
    super.key,
    required this.authBloc,
  });
  final AuthBloc authBloc;

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: AppPadding.mediumH,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.only(left: AppPadding.p6),
                child: Image.asset(
                  AppAssets.logo,
                  fit: BoxFit.fitWidth,
                  height: 35,
                  width: AppWidth.w126.w,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => SettingsView(authBloc: widget.authBloc),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
