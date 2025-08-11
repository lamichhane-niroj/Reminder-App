import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Call this once (e.g. in main or SplashScreen)
  void initializeNotifications() {
    tz.initializeTimeZones();
    initNotification();
    requestPermissions();
  }

  // Initialize the notifications plugin
  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          debugPrint("Notification payload: ${response.payload}");
        }
      },
    );
  }

  // Request permissions (iOS & Android 13+)
  Future<void> requestPermissions() async {
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    if (await Permission.notification.isDenied) {
      PermissionStatus status = await Permission.notification.request();
      if (status.isGranted) {
        debugPrint("Notification permissions granted");
      } else {
        debugPrint("Notification permissions denied");
      }
    }
  }

  // Common notification details
  Future<NotificationDetails> notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
          'task_channel_id', 'Task Notifications',
          channelDescription: 'Reminders for scheduled tasks',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound("noti_2"),
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000])),
      iOS: const DarwinNotificationDetails(),
    );
  }

  // Show immediate notification (for testing/debugging)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await notificationsPlugin.show(
        id,
        title,
        body,
        await notificationDetails(),
        payload: id.toString(),
      );
    } catch (e) {
      debugPrint("Error showing notification: $e");
    }
  }

  // Schedule a notification at a specific DateTime
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    required String repeat,
  }) async {
    try {
      final tz.TZDateTime scheduledTZDateTime =
          tz.TZDateTime.from(scheduledDateTime, tz.local);

      if (scheduledTZDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint("Scheduled time is in the past. Skipping notification.");
        return;
      }

      DateTimeComponents? repeatComponent;

      switch (repeat) {
        case "Daily":
          repeatComponent = DateTimeComponents.time;
          break;
        case "Weekly":
          repeatComponent = DateTimeComponents.dayOfWeekAndTime;
          break;
        case "Monthly":
          repeatComponent = DateTimeComponents.dayOfMonthAndTime;
          break;
        case "Yearly":
          repeatComponent = DateTimeComponents.dateAndTime;
          break;
        default:
          repeatComponent = null;
      }

      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDateTime,
        await notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exact,
        matchDateTimeComponents: repeatComponent,
        payload: id.toString(),
      );
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  // Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }
}
