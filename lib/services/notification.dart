// ignore_for_file: empty_catches

import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth.dart' as auth;

class NotificationService {
  String? mtoken = " ";
  NotificationDetails? notificationDetails;
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    if (Platform.isIOS) {
    } else if (Platform.isAndroid) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'default',
        'Default Channel',
        channelDescription: 'Default Channel',
        importance: Importance.high,
      );
      notificationDetails =
          const NotificationDetails(android: androidPlatformChannelSpecifics);
    }
  }

void sendNotification(String token) async {
  try {
    final String serverKey = 'AAAAoxklK00:APA91bEvHZ27JhEznFnx8uGRvOBPyIuD6CuuxGPnrbteTvarTFiqLHYpY7LoZdSyhjlRiZqWqiMw4S2kUqOj7bYnrOD7R5YvJu6rFLKhjWmPbC_PHpJmIhTrTlEYP_SmOVn1RaRMAAW1'; // Replace with your server key
    final String projectId = 'jritev4'; // Replace with your Firebase project ID
    final String apiUrl = 'https://fcm.googleapis.com/fcm/send';

    final Map<String, dynamic> notification = {
      'title': 'Job Completed',
      'body': 'Job has been completed',
    };

    final Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
    };

    final Map<String, dynamic> message = {
      'notification': notification,
      'data': data,
      'to': token,
    };

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Error: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification: $e');
  }
}

  Future<String?> getFirebaseMessagingToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      mtoken = token;
    });
    return mtoken;
  }
}
