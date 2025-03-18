import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flora_guardian/services/notification_service.dart';
import 'package:flora_guardian/views/custom_widgets/notification_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'set_reminder_page.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  _AlertScreenState createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final notificationService = NotificationService();
  StreamSubscription<ScheduledNotification>? _reminderSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for reminder events
    _reminderSubscription = notificationService.reminderStream.listen((reminder) {
      _showInAppAlert(reminder);
    });
  }

  @override
  void dispose() {
    _reminderSubscription?.cancel();
    notificationService.dispose();
    super.dispose();
  }

  void _showInAppAlert(ScheduledNotification reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reminder.title),
        content: Text(reminder.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SetReminderPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ScheduledNotification>>(
        future: notificationService.fetchRemindersFromFirestore(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No reminders set.',
                style: TextStyle(fontSize: 18),
              ),
            );
          } else {
            final reminders = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                return NotificationList(notification: reminders[index]);
              },
            );
          }
        },
      ),
    );
  }
}