import 'package:flora_guardian/services/notification_service.dart';
import 'package:flora_guardian/views/custom_widgets/notification_list.dart';
import 'package:flutter/material.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = NotificationService().scheduledNotifications;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NotificationService().showNotification(
            body: "Test body",
            title: "Test title",
            id: 1,
          );
        },
      ),
      appBar: AppBar(title: Text("Flora Guardian")),
      body: SafeArea(
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return NotificationList(notification: notifications[index]);
          },
        ),
      ),
    );
  }
}
