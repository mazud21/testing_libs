import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize FCM
  initialize() async {
    // Request permission on iOS
    //await requestPermission();

    // Get the FCM token (used for sending push notifications to the device)
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Handle messages while the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground: ${message.notification?.title}');
    });

    // Handle messages when the app is in the background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Opened the app from a notification: ${message.notification?.title}');
    });

    // Handle background messages (Android and iOS)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.notification?.title}');
  }
}
