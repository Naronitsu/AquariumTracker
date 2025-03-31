import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  // Existing method for feeding reminders...
  static Future<void> scheduleFeedFishNotification(int hour, int minute) async {
    // Your scheduled notification logic
  }
}
