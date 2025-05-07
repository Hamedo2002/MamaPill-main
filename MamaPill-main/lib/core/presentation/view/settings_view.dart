import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/presentation/widgets/custom_back_button.dart';
import 'package:mama_pill/core/presentation/widgets/setting_item.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/features/authentication/domain/entities/user_profile.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.authBloc,
  });
  final AuthBloc authBloc;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleMedium!.copyWith(fontSize: 16.sp);
    final UserProfile user = authBloc.state.user;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: AppHeight.h50.h,
        title: Text('settings', style: titleStyle),
        centerTitle: true,
        leading: const CustomBackButton(),
        backgroundColor: AppColors.backgroundSecondary,
      ),
      body: ListView(
        children: [
          SizedBox(height: AppHeight.h24.h),
          _accountSettings(user, context),
          SizedBox(height: AppHeight.h24.h),
          _settingsList(context),
        ],
      ),
    );
  }

  Container _accountSettings(UserProfile user, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final username = user.username ?? 'User';
    final email = user.email ?? 'No email';
    
    return Container(
      color: AppColors.backgroundPrimary,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSize.s24.r,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: AppWidth.w20.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(username, style: textTheme.titleMedium),
              Text(email, style: textTheme.titleSmall),
            ],
          ),
        ],
      ),
    );
  }

  Container _settingsList(BuildContext context) {
    return Container(
      color: AppColors.backgroundPrimary,
      child: Column(
        children: [
          SettingItem(
            label: 'Notifications',
            icon: Icons.notifications_outlined,
            onTap: () {},
          ),
          SettingItem(
            label: 'Logout',
            icon: Icons.logout_outlined,
            onTap: () => authBloc.add(AuthLogoutRequested()),
            color: Colors.red,
            isLast: true,
          ),
        ],
      ),
    );
  }
}
