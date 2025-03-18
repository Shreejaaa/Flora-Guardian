import 'package:flutter/material.dart';
import 'package:flora_guardian/services/notification_service.dart';

class NotificationList extends StatelessWidget {
  final ScheduledNotification notification;

  const NotificationList({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(notification.title),
        subtitle: Text(notification.body),
        trailing: IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () async {
            final notificationService = NotificationService();
            await notificationService.deleteReminder(notification.id.toString());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reminder marked as completed')),
            );
          },
        ),
      ),
    );
  }
}