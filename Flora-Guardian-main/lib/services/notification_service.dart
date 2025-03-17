import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final NotificationDetails _notificationDetails = const NotificationDetails(
    android: AndroidNotificationDetails(
      'daily_channel_id',
      'Daily Notification',
      channelDescription: 'Daily Notification Channel',
      importance: Importance.max,
      priority: Priority.max,
    ),
    iOS: DarwinNotificationDetails(),
  );

  final List<ScheduledNotification> _scheduledNotifications = [
    ScheduledNotification(
      id: 1,
      title: 'Water Plant',
      body: 'Don\'t forget to water your plant',
      time: TimeOfDay(hour: 16, minute: 0),
    ),
    ScheduledNotification(
      id: 2,
      title: 'Check your plant',
      body: 'Don\'t forget to check the plant health condition',
      time: TimeOfDay(hour: 6, minute: 0),
    ),
  ];

  List<ScheduledNotification> get scheduledNotifications =>
      _scheduledNotifications;

  Future<void> initNotification() async {
    const initSettingAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettingIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSetting = InitializationSettings(
      android: initSettingAndroid,
      iOS: initSettingIOS,
    );

    await notificationPlugin.initialize(initSetting).then((_) async {
      _isInitialized = true;
      // Cancel all existing notifications before scheduling new ones
      await notificationPlugin.cancelAll();
      await _scheduleWaterPlantNotification();
      await _scheduleCheckPlantNotification();
    });
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    if (!_isInitialized) {
      return;
    }
    await notificationPlugin.show(id, title, body, _notificationDetails);
  }

  Future<bool> _checkAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isPermanentlyDenied) {
      return false;
    }
    if (await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.request();
      return status.isGranted;
    }
    return true;
  }

  Future<void> _scheduleWaterPlantNotification() async {
    if (!await _checkAlarmPermission()) {
      return;
    }

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        16, // 4:00 PM
        0,
      );

      // If time has passed for today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await notificationPlugin.zonedSchedule(
        1,
        'Water Plant',
        'Don\'t forget to water your plant',
        scheduledTime,
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // ✅ Updated
      );
    } catch (e) {
      ('Error scheduling water plant notification: $e');
    }
  }

  Future<void> _scheduleCheckPlantNotification() async {
    if (!await _checkAlarmPermission()) {
      return;
    }

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        6, // 6:00 AM
        0,
      );

      // If time has passed for today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await notificationPlugin.zonedSchedule(
        2,
        'Check your plant',
        'Don\'t forget to check the plant health condition',
        scheduledTime,
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // ✅ Updated
      );
    } catch (e) {
      ('Error scheduling check plant notification: $e');
    }
  }
}

class ScheduledNotification {
  final int id;
  final String title;
  final String body;
  final TimeOfDay time;

  ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
  });
}
