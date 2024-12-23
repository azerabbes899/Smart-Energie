import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:energie_project/pages/first.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization
  await Firebase.initializeApp();

  // Initialize Awesome Notifications
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'alerts', // Changed from 'basic_channel'
        channelName: 'Energy Alerts',
        channelDescription: 'Notification channel for energy usage alerts',
        defaultColor: Color(0xFF9D50b8),
        ledColor: Colors.white,
      )
    ],
  );

  // Request notification permissions
  await AwesomeNotifications().requestPermissionToSendNotifications();

  runApp(const SmartEnergyApp());
}

class SmartEnergyApp extends StatelessWidget {
  const SmartEnergyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartEnergy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FirstPage(), // Set FirstPage as the initial screen
    );
  }
}
