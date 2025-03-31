import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  static Future<void> showAquariumCreatedNotification(String aquariumName) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'aquarium_channel',
      'Aquarium Notifications',
      channelDescription: 'Notification when aquarium is created',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'New Aquarium Added',
      'Aquarium "$aquariumName" has been created!',
      platformDetails,
    );
  }

  /// Schedule a daily notification for feeding fish
  static Future<void> scheduleFeedFishNotification(int hour, int minute) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    print('Scheduling notification for: $scheduledTime');

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      hour * 60 + minute, // Unique ID per time
      'Feeding Reminder',
      'Time to feed your fish!',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'feeding_channel',
          'Feeding Notifications',
          channelDescription: 'Reminders to feed your aquarium fish',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'feed_fish',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
} 