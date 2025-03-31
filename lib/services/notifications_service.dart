import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
class NotificationsService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the notifications service
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Make this method static so it can be called from static methods
  static Future<void> requestExactAlarmPermission() async {
    final notificationStatus = await Permission.notification.request();
    final permissionStatus = await Permission.scheduleExactAlarm.request();

    if (permissionStatus.isGranted) {
      print("Exact alarm permission granted");
    } else {
      print("Exact alarm permission denied");
    }
  }

  // Schedule a notification to feed fish at the specified time, repeating daily
  static Future<void> scheduleFeedFishNotification(int hour, int minute) async {
  // Request permission first
  await requestExactAlarmPermission();

  final now = DateTime.now();
  print("Current time: $now");  // Log current time for debugging

  // Create the scheduled date for feeding time today in local timezone
  tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  print("Scheduled time before checking: $scheduledDate");

  // If the scheduled time is before the current time, set it for the next day
  if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));  // Schedule for the next day
  }

  print("Scheduled time after checking: $scheduledDate");

  // Scheduling the notification using the zonedSchedule method
  await _flutterLocalNotificationsPlugin.zonedSchedule(
    0,  // Notification ID
    'Fish Feeding Reminder',  // Title
    'It\'s time to feed your fish!',  // Content
    scheduledDate,  // Scheduled time
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'feed_fish_channel', // Channel ID
        'Fish Feeding Reminders', // Channel name
        channelDescription: 'Daily reminders to feed your fish', // Description
        importance: Importance.max, // Max importance
        priority: Priority.high, // High priority
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // Inexact scheduling
    matchDateTimeComponents: DateTimeComponents.time, // Match time (hour and minute)
  );
}

}
