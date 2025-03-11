import 'package:firebase_core/firebase_core.dart';
import 'package:flora_guardian/controllers/auth_wrapper.dart';
import 'package:flora_guardian/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flora_guardian/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Permission.camera.request();
  await Permission.notification.request();
  await Permission.scheduleExactAlarm.request();
  await NotificationService().initNotification();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 26,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}
