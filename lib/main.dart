import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:testing_libs/sqlite_page.dart';
import 'package:testing_libs/test_bg_services.dart';

import 'firebase/NotificationServices.dart';
import 'firebase_options.dart';
import 'get_notification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  //await FirebaseMessaging.instance.setAutoInitEnabled(true);
  /*await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );*/
  //await PushNotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: TestBGServices(),
    );
  }
}
