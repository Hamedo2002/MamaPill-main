import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mama_pill/core/resources/assets.dart';
import 'package:mama_pill/core/resources/routes.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';

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
        Padding(
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
                  context.pushNamed(
                    AppRoutes.setting.name,
                    extra: widget.authBloc,
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
