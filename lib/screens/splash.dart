import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();

    _initFirebaseMessaging();
    Future.delayed(const Duration(milliseconds: 500), () {
      _autoLogin(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color.fromARGB(255, 236, 186, 147) ,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Center(
          child: Image.asset('assets/images/jrite-logo.png'),
        ),
      ),
    );
  }

  void _initFirebaseMessaging() {
    // TODO: Firebase messaging
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    //   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    //   if (NotificationService().notificationDetails != null) {
    //     await flutterLocalNotificationsPlugin.show(
    //       (DateTime.now().millisecondsSinceEpoch /1000).floor(),
    //       message.notification!.title,
    //       message.notification!.body,
    //       NotificationService().notificationDetails,
    //       payload: jsonEncode(message.data),
    //     );
    //   }
    // });
    //
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    //   NotificationService().gotoNotification(message.data);
    // });
  }

  Future<void> _autoLogin(context) async {
    if (_auth != null) {
      User? user = _auth.currentUser;
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/mode');
      }
    }
  }
}
