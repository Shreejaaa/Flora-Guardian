import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // Added for StreamController

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // StreamController to broadcast reminder events
  final StreamController<ScheduledNotification> _reminderStreamController =
      StreamController<ScheduledNotification>.broadcast();
  Stream<ScheduledNotification> get reminderStream => _reminderStreamController.stream;

  // Notification channel ID and name (required for Android 8.0+)
  static const String _channelId = 'flora_guardian_channel';
  static const String _channelName = 'Flora Guardian Notifications';
  static const String _channelDescription = 'Notifications for plant care reminders';

  // Notification details for Android and iOS
  final NotificationDetails _notificationDetails = const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      showWhen: true,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  Future<void> initNotification() async {
    // Initialize Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize iOS settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combine settings for both platforms
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await notificationPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        ('Notification tapped: ${response.payload}');
        // Open the app and mark the reminder as completed
        _handleNotificationTap(response.payload);
      },
    );

    // Create a notification channel for Android 8.0+
    await _createNotificationChannel();

    _isInitialized = true;

    // Schedule system notifications (e.g., twice a day)
    await _scheduleSystemNotifications();

    // Fetch and schedule user-set reminders
    await _fetchAndScheduleReminders();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      showBadge: true,
    );

    await notificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _scheduleSystemNotifications() async {
    // Schedule a notification at 8 AM
    await _scheduleDailyNotification(
      id: 1,
      title: 'Water your plants',
      body: 'It\'s time to water your plants!',
      hour: 8,
      minute: 0,
    );

    // Schedule a notification at 6 PM
    await _scheduleDailyNotification(
      id: 2,
      title: 'Check your plants',
      body: 'Don\'t forget to check your plants!',
      hour: 18,
      minute: 0,
    );
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time has already passed today, schedule it for the next day
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'system_$id', // Optional: Add a payload for handling taps
    );
  }

  Future<void> _fetchAndScheduleReminders() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('reminders')
        .get();

    for (var doc in snapshot.docs) {
      final timeParts = doc['time'].split(':');
      final reminder = ScheduledNotification(
        id: int.parse(doc.id),
        title: doc['title'],
        body: doc['body'],
        time: TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        ),
      );

      await scheduleNotification(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        time: reminder.time,
      );
    }
  }

  Future<void> saveReminderToFirestore({
    required String userId,
    required ScheduledNotification reminder,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc(reminder.id.toString())
        .set({
      'title': reminder.title,
      'body': reminder.body,
      'time': '${reminder.time.hour}:${reminder.time.minute}',
    });
  }

  Future<List<ScheduledNotification>> fetchRemindersFromFirestore(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .get();

    return snapshot.docs.map((doc) {
      final timeParts = doc['time'].split(':');
      return ScheduledNotification(
        id: int.parse(doc.id),
        title: doc['title'],
        body: doc['body'],
        time: TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        ),
      );
    }).toList();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
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
        time.hour,
        time.minute,
      );

      // If the scheduled time has already passed today, schedule it for the next day
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'reminder_$id', // Optional: Add a payload for handling taps
      );
    } catch (e) {
      ('Error scheduling notification: $e');
    }
  }

  Future<void> _handleNotificationTap(String? payload) async {
    if (payload == null) return;

    if (payload.startsWith('reminder_')) {
      final reminderId = payload.replaceFirst('reminder_', '');
      final user = _auth.currentUser;
      if (user == null) return;

      final reminderDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .doc(reminderId)
          .get();

      if (reminderDoc.exists) {
        final timeParts = reminderDoc['time'].split(':');
        final reminder = ScheduledNotification(
          id: int.parse(reminderId),
          title: reminderDoc['title'],
          body: reminderDoc['body'],
          time: TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          ),
        );

        // Broadcast the reminder event
        _reminderStreamController.add(reminder);
      }

      await deleteReminder(reminderId);
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('reminders')
        .doc(reminderId)
        .delete();
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

  // Dispose the StreamController when no longer needed
  void dispose() {
    _reminderStreamController.close();
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