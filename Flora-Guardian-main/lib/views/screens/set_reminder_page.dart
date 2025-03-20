import 'package:flutter/material.dart';
import 'package:flora_guardian/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:overlay_support/overlay_support.dart';

class SetReminderPage extends StatefulWidget {
  const SetReminderPage({super.key});

  @override
  _SetReminderPageState createState() => _SetReminderPageState();
}

class _SetReminderPageState extends State<SetReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay.now();
  final NotificationService _notificationService = NotificationService();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        toolbarHeight: 80, // Explicitly set the height of the app bar
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
            icon: Icon(Icons.save, color: Colors.green.shade800),
            onPressed: _saveReminder,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 130), // Match the toolbarHeight
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'Create a New Reminder',
                    //   style: TextStyle(
                    //     fontSize: 24,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.green.shade900,
                    //   ),
                    // ),
                    const SizedBox(height: 10),
                    Text(
                      'Set up reminders to take care of your plants',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Reminder Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Reminder Title',
                    hintText: 'e.g., Water the roses',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.title, color: Colors.green.shade700),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Reminder Description
                TextFormField(
                  controller: _bodyController,
                  decoration: InputDecoration(
                    labelText: 'Reminder Description',
                    hintText: 'e.g., Don\'t forget to check soil moisture',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.description, color: Colors.green.shade700),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Time Picker
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  title: Text(
                    'Set Reminder Time',
                    style: TextStyle(fontSize: 16, color: Colors.green.shade900),
                  ),
                  subtitle: Text(
                    '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.access_time, color: Colors.green.shade700),
                  onTap: () => _selectTime(context),
                ),
                const SizedBox(height: 24),

                // Quick Templates
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Templates',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _reminderTemplate('Water Plants', 'Time to water your plants!'),
                          _reminderTemplate('Fertilize', 'Add fertilizer to your plants today'),
                          _reminderTemplate('Check Soil', 'Check if soil needs to be changed'),
                          _reminderTemplate('Prune Plants', 'Time to trim those leaves'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Save Reminder',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reminderTemplate(String title, String body) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _titleController.text = title;
          _bodyController.text = body;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Generate a unique ID based on current timestamp
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Create the reminder
      final reminder = ScheduledNotification(
        id: id,
        title: _titleController.text,
        body: _bodyController.text,
        time: _selectedTime,
      );

      // Save to Firestore
      await _notificationService.saveReminderToFirestore(
        userId: user.uid,
        reminder: reminder,
      );

      // Schedule the notification
      await _notificationService.scheduleNotification(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        time: reminder.time,
      );

      if (!mounted) return;

      // Show confirmation
      showSimpleNotification(
        Text("Reminder set for ${reminder.time.hour}:${reminder.time.minute.toString().padLeft(2, '0')}"),
        background: Colors.green.shade700,
        duration: const Duration(seconds: 2),
      );

      Navigator.pop(context);
    }
  }
}