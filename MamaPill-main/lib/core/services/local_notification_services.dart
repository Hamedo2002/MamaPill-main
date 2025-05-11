import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mama_pill/core/helpers/id_generator.dart';
import 'package:mama_pill/core/helpers/time_zone_helper.dart';
import 'package:mama_pill/features/notifications/presentation/pages/full_screen_notification_page.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;

class LocalNotificationServices {
  static FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();

  static Future<bool> init({required bool initSchedule}) async {
    try {
      // Initialize timezone
      if (initSchedule) {
        await TimeZoneHelper.init();
      }

      // Initialize notifications
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const setting = InitializationSettings(android: android, iOS: ios);

      await notification.initialize(
        setting,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap
          print('Notification tapped: ${response.payload}');
        },
      );

      // Request permissions explicitly
      bool? permissionGranted;

      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            notification.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        permissionGranted =
            await androidImplementation?.requestNotificationsPermission();
      } else if (Platform.isIOS) {
        final IOSFlutterLocalNotificationsPlugin? iOSImplementation =
            notification.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        permissionGranted = await iOSImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      return permissionGranted ?? false;
    } catch (e) {
      print('Error initializing notifications: $e');
      return false;
    }
  }

  static Future<NotificationDetails> getNotificationDetails() async {
    const androidPlatformChannel = AndroidNotificationDetails(
      "medicine_reminder_channel",
      "Medicine Reminders",
      channelDescription: "Notifications for medicine reminders",
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.reminder,
    );
    const iOSPlatformChannel = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(
        android: androidPlatformChannel, iOS: iOSPlatformChannel);
  }

  static Future<void> showFullScreenNotification(
    BuildContext context, {
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
    try {
      final notificationDetails = await getNotificationDetails();

      for (final date in scheduledDates) {
        if (date.isBefore(tz.TZDateTime.now(tz.local))) {
          print('Skipping past date: $date');
          continue;
        }

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
        print('Scheduled notification $notificationId for $date');
      }
    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
    }
  }

  static Future<void> cancelNotification(
    int id,
    List<tz.TZDateTime> scheduledDates,
  ) async {
    try {
      for (final date in scheduledDates) {
        final notificationId = IdGenerator.generateNotificationId(id, date);
        await notification.cancel(notificationId);
        print('Cancelled notification $notificationId');
      }
    } catch (e) {
      print('Error cancelling notification: $e');
      rethrow;
    }
  }
}
