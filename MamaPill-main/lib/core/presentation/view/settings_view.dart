import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mama_pill/core/presentation/widgets/custom_back_button.dart';
import 'package:mama_pill/core/presentation/widgets/setting_item.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/core/services/local_notification_services.dart';
import 'package:mama_pill/features/authentication/domain/entities/user_profile.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/notifications/presentation/controller/bloc/notification_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mama_pill/core/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
    required this.authBloc,
  });
  final AuthBloc authBloc;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;
  late NotificationBloc _notificationBloc;
  static const String _notificationsKey = 'notifications_enabled';

  @override
  void initState() {
    super.initState();
    _notificationBloc = sl<NotificationBloc>();
    _loadNotificationState();
  }

  Future<void> _loadNotificationState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedState = prefs.getBool(_notificationsKey) ?? true;
    setState(() {
      _notificationsEnabled = savedState;
    });
    if (!savedState) {
      await LocalNotificationServices.notification.cancelAll();
    }
  }

  Future<void> _saveNotificationState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  Future<void> _checkNotificationStatus() async {
    final bool? permission = await LocalNotificationServices.notification
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    setState(() {
      _notificationsEnabled = permission ?? false;
    });
    await _saveNotificationState(_notificationsEnabled);
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final bool? permission = await LocalNotificationServices.notification
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      setState(() {
        _notificationsEnabled = permission ?? false;
      });

      if (permission == true) {
        // Reinitialize notifications
        await LocalNotificationServices.init(initSchedule: true);
      }
    } else {
      // Cancel all notifications
      await LocalNotificationServices.notification.cancelAll();
      setState(() {
        _notificationsEnabled = false;
      });
    }
    await _saveNotificationState(_notificationsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleMedium!.copyWith(fontSize: 16.sp);
    final UserProfile user = widget.authBloc.state.user;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: AppHeight.h50.h,
        title: Text('settings', style: titleStyle),
        centerTitle: true,
        leading: const CustomBackButton(),
        backgroundColor: AppColors.backgroundSecondary,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            _accountSettings(user, context),
            SizedBox(height: 32.h),
            Text(
              'Preferences',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _settingsList(context),
          ],
        ),
      ),
    );
  }

  Container _accountSettings(UserProfile user, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final username = user.username ?? 'User';
    final email = user.email ?? 'No email';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.5),
              inactiveThumbColor: Colors.transparent,
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
            ),
          ),
          Divider(
            height: 0,
            thickness: 1,
            indent: AppWidth.w52.w,
            color: AppColors.divider.withOpacity(0.2),
          ),
          SettingItem(
            label: 'Logout',
            icon: Icons.logout_outlined,
            onTap: () => widget.authBloc.add(AuthLogoutRequested()),
            color: Colors.red,
            isLast: true,
          ),
        ],
      ),
    );
  }
}
