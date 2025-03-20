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
    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
        // insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Add padding
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       title: Text(
  //         reminder.title,
  //         style: TextStyle(
  //           fontSize: 18,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.green.shade900,
  //         ),
  //       ),
  //       content: Text(
  //         reminder.body,
  //         style: TextStyle(
  //           fontSize: 16,
  //           color: Colors.grey.shade700,
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'OK',
  //             style: TextStyle(
  //               color: Colors.green.shade700,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Row(
          children: [
            Icon(
              Icons.local_florist,
              color: Colors.green.shade800,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              "Flora Guardian",
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.green.shade800),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SetReminderPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
     body: FutureBuilder<List<ScheduledNotification>>(
  future: notificationService.fetchRemindersFromFirestore(user!.uid),
  builder: (context, snapshot) {
    return Padding(
      padding: const EdgeInsets.only(top: 100), // Add this line to push content below the app bar
      child: snapshot.connectionState == ConnectionState.waiting
          ? Center(
              child: CircularProgressIndicator(color: Colors.green.shade700),
            )
          : snapshot.hasError
              ? Center(
                  child: Text('Error: ${snapshot.error}'),
                )
              : !snapshot.hasData || snapshot.data!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 70,
                            color: Colors.green.shade300,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No reminders set.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Tap the + button to add a reminder',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final reminders = snapshot.data!;
                        return NotificationList(notification: reminders[index]);
                      },
                    ),
    );
  },
),
    );
  }
}
  