import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
// import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

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

  final StreamController<ScheduledNotification> _reminderStreamController =
      StreamController<ScheduledNotification>.broadcast();
  Stream<ScheduledNotification> get reminderStream => _reminderStreamController.stream;

  // iOS-specific notification details
  final DarwinNotificationDetails _iosNotificationDetails = 
      const DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    sound: 'default',
  );

  Future<void> initNotification() async {
    // Initialize timezone database
    tzdata.initializeTimeZones();
    
    // Request iOS notification permissions
    final bool? permissionsGranted = await notificationPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    if (permissionsGranted != true) {
      debugPrint('iOS notification permissions not granted');
      return;
    }

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      iOS: initializationSettingsIOS,
    );

    await notificationPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    _isInitialized = true;

    
    await _scheduleDailyNotification(
      id: 3,
      title: '🌱 Morning Plant Care',
      body: 'Good morning! Time to water your plants.',
      hour: 10,
      minute: 30,
      timeZone: 'Asia/Kathmandu',
    );

    await _fetchAndScheduleReminders();
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String timeZone = 'UTC',
  }) async {
    try {
      final location = tz.getLocation(timeZone);
      final now = tz.TZDateTime.now(location);
      var scheduledTime = tz.TZDateTime(
        location,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        NotificationDetails(iOS: _iosNotificationDetails),
        payload: 'system_$id', androidScheduleMode: AndroidScheduleMode.exact,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
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
    try {
      final location = tz.getLocation('Asia/Kathmandu');
      final now = tz.TZDateTime.now(location);
      var scheduledTime = tz.TZDateTime(
        location,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        NotificationDetails(iOS: _iosNotificationDetails),
        payload: 'reminder_$id',
        androidScheduleMode: AndroidScheduleMode.exact,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
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