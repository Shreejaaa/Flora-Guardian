import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flora_guardian/services/notification_service.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:audioplayers/audioplayers.dart';

class NotificationHandler {
  static final NotificationHandler _instance = NotificationHandler._();
  factory NotificationHandler() => _instance;
  NotificationHandler._();

  final NotificationService _notificationService = NotificationService();
  StreamSubscription<ScheduledNotification>? _reminderSubscription;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Initialize
  Future<void> initialize(BuildContext context) async {
    // Request notification permissions if not already granted
    if (!_notificationService.isInitialized) {
      await _notificationService.initNotification();
    }
    
    // Set up handlers for foreground notifications
    _setupForegroundNotificationHandler(context);
  }

  // Set up handler for when app is in foreground
  void _setupForegroundNotificationHandler(BuildContext context) {
    _reminderSubscription = _notificationService.reminderStream.listen((reminder) {
      _showOverlayNotification(context, reminder);
    });
  }
  
  // Show an overlay notification that pops up on screen
  void _showOverlayNotification(BuildContext context, ScheduledNotification reminder) {
    // Play notification sound
    _playNotificationSound();
    
    showOverlayNotification(
      (context) {
        return GestureDetector(
          onTap: () {
            OverlaySupportEntry.of(context)!.dismiss();
            _showReminderDetailsDialog(context, reminder);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            elevation: 4,
            child: SafeArea(
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.spa, color: Colors.white),
                ),
                title: Text(
                  reminder.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(reminder.body),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    OverlaySupportEntry.of(context)!.dismiss();
                  },
                ),
              ),
            ),
          ),
        );
      },
      duration: const Duration(seconds: 5),
      position: NotificationPosition.top,
    );
    
    // Vibrate device (optional)
    HapticFeedback.vibrate();
  }
  
  // Show a full dialog with more details and actions
  void _showReminderDetailsDialog(BuildContext context, ScheduledNotification reminder) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must interact with dialog
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.alarm, color: Colors.green.shade700),
            const SizedBox(width: 10),
            Text(reminder.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                reminder.body,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Time: ${reminder.time.hour}:${reminder.time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Schedule reminder for later (snooze)
              _snoozeReminder(context, reminder);
            },
            child: const Text('Snooze'),
          ),
          ElevatedButton(
            onPressed: () {
              // Mark as done and dismiss
              _markReminderAsDone(reminder.id.toString());
              Navigator.pop(context);
              
              // Show confirmation
              showSimpleNotification(
                const Text("Reminder completed! 🌱"),
                background: Colors.green.shade700,
                duration: const Duration(seconds: 2),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
  
  // Snooze a reminder
  void _snoozeReminder(BuildContext context, ScheduledNotification reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Snooze Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('When would you like to be reminded again?'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _snoozeButton(context, reminder, 15, 'minutes'),
                _snoozeButton(context, reminder, 1, 'hour'),
                _snoozeButton(context, reminder, 3, 'hours'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  // Snooze button widget
  Widget _snoozeButton(BuildContext context, ScheduledNotification reminder, int value, String unit) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _scheduleSnooze(reminder, value, unit);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          unit == 'minutes' ? '$value min' : '$value $unit',
          style: TextStyle(color: Colors.green.shade700),
        ),
      ),
    );
  }
  
  // Schedule a snoozed reminder
  Future<void> _scheduleSnooze(ScheduledNotification reminder, int value, String unit) async {
    final now = DateTime.now();
    late DateTime snoozeTime;
    
    if (unit == 'minutes') {
      snoozeTime = now.add(Duration(minutes: value));
    } else if (unit == 'hour') {
      snoozeTime = now.add(Duration(hours: value));
    } else {
      snoozeTime = now.add(Duration(hours: value));
    }
    
    // Create a new notification ID based on the current time
    final snoozeId = now.millisecondsSinceEpoch ~/ 1000;
    
    await _notificationService.scheduleNotification(
      id: snoozeId,
      title: "Snoozed: ${reminder.title}",
      body: reminder.body,
      time: TimeOfDay(hour: snoozeTime.hour, minute: snoozeTime.minute),
    );
    
    // Show confirmation
    showSimpleNotification(
      Text("Reminder snoozed for $value $unit"),
      background: Colors.green.shade700,
      duration: const Duration(seconds: 2),
    );
  }
  
  // Mark a reminder as done
  Future<void> _markReminderAsDone(String reminderId) async {
    await _notificationService.deleteReminder(reminderId);
  }
  
  // Play a notification sound
  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      // Fallback to system sound
      debugPrint('Error playing notification sound: $e');
    }
  }
  
  // Clean up resources
  void dispose() {
    _reminderSubscription?.cancel();
    _audioPlayer.dispose();
  }
}