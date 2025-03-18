import 'package:firebase_core/firebase_core.dart';
import 'package:flora_guardian/controllers/auth_wrapper.dart';
import 'package:flora_guardian/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart'; // Add this import
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flora_guardian/services/notification_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize time zones for notifications
  tz.initializeTimeZones();

  // Request necessary permissions
  await Permission.camera.request();
  await Permission.notification.request();
  await Permission.scheduleExactAlarm.request();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize NotificationService after Firebase
  await NotificationService().initNotification();

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global( // Wrap your app with OverlaySupport
      child: MaterialApp(
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 26,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}