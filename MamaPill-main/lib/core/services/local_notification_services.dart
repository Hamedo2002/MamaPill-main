import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mama_pill/core/helpers/id_generator.dart';
import 'package:mama_pill/core/helpers/time_zone_helper.dart';
import 'package:mama_pill/features/notifications/presentation/pages/full_screen_notification_page.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationServices {
  static FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();

  static Future<void> init({required bool initSchedule}) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const setting = InitializationSettings(android: android, iOS: ios);
    await notification.initialize(setting);
    if (initSchedule) {
      await TimeZoneHelper.init();
    }
  }

  static Future<NotificationDetails> getNotificationDetails() async {
    const androidPlatformChannel = AndroidNotificationDetails(
      "channel id",
      "channel name",
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
    );
    const iOSPlatformChannel = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(
        android: androidPlatformChannel, iOS: iOSPlatformChannel);
  }

  static Future<void> showFullScreenNotification(BuildContext context, {
    required String medicineName,
    required String dosage,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullScreenNotificationPage(
          medicineName: medicineName,
          dosage: dosage,
        ),
      ),
    );
  }

  static Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    List<tz.TZDateTime> scheduledDates,
  ) async {
    final notificationDetails = await getNotificationDetails();
    for (final date in scheduledDates) {
      final notificationId = IdGenerator.generateNotificationId(id, date);
      await notification.zonedSchedule(
        notificationId,
        title,
        body,
        date,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static Future<void> cancelNotification(
    int id,
    List<tz.TZDateTime> scheduledDates,
  ) async {
    for (final date in scheduledDates) {
      final notificationId = IdGenerator.generateNotificationId(id, date);
      await notification.cancel(notificationId);
    }
  }
}
