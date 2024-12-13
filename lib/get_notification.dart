import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class GetNotificationPage extends StatefulWidget {
  const GetNotificationPage({super.key});

  @override
  State<GetNotificationPage> createState() => _GetNotificationPageState();
}

class _GetNotificationPageState extends State<GetNotificationPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getFcm();
  }

  getFcm() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint("FCMToken $fcmToken");
    FirebaseMessaging.instance.subscribeToTopic("topicName");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Center(
            child: Text("data")
        ),
      ),
    );
  }
}
