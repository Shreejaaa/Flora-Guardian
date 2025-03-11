import 'package:flutter/material.dart';
import 'package:flora_guardian/services/notification_service.dart';

class NotificationList extends StatelessWidget {
  final ScheduledNotification notification;

  const NotificationList({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      margin: EdgeInsets.only(bottom: 8, left: 14, right: 14),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(
          Icons.notifications_active_rounded,
          color: Colors.black,
          size: 32,
        ),
        title: Text(notification.title, style: TextStyle(fontSize: 20)),
        subtitle: Text(
          "${notification.body}\nTime: ${notification.time.format(context)}",
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
