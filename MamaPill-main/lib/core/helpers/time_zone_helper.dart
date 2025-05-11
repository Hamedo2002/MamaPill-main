import 'package:flutter/material.dart' show TimeOfDay;
import 'package:mama_pill/core/helpers/date_time_formatter.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class TimeZoneHelper {
  static Future<void> init() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Set local timezone
      final String timeZoneName = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      print('Timezone initialized: ${tz.local.name}');
    } catch (e) {
      print('Error initializing timezone: $e');
      rethrow;
    }
  }

  static tz.TZDateTime convertDateTimeToTimeZone(
      DateTime dateTime, String timeZone) {
    final location = tz.getLocation(timeZone);
    final convertedDateTime = tz.TZDateTime.from(dateTime, location);
    return convertedDateTime;
  }

  static tz.TZDateTime scheduleDaily(TimeOfDay timeOfDay) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return scheduledDate.isBefore(now)
        ? tz.TZDateTime.from(
            scheduledDate.add(const Duration(days: 1)), tz.local)
        : tz.TZDateTime.from(scheduledDate, tz.local);
  }

  static tz.TZDateTime scheduleWeekly(TimeOfDay timeOfDay,
      {required List<int> weekday}) {
    tz.TZDateTime scheduledDate = scheduleDaily(timeOfDay);
    while (!weekday.contains(scheduledDate.weekday)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static List<tz.TZDateTime> scheduleMultipleWeekly(
    List<String> times,
    List<int> weekdays,
  ) {
    final scheduledDates = <tz.TZDateTime>[];
    for (final time in times) {
      final formattedTime = DateTimeFormatter.formatTimeOfDay(time);
      final scheduledTime =
          TimeOfDay(hour: formattedTime.hour, minute: formattedTime.minute);
      final scheduledDate = scheduleWeekly(scheduledTime, weekday: weekdays);
      scheduledDates.add(scheduledDate);
    }
    return scheduledDates;
  }
}
