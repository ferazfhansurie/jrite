import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jritev4/home.dart';
import 'package:jritev4/screens/login_before.dart';
import 'package:jritev4/screens/splash.dart';
import 'package:jritev4/services/notification.dart';
import 'screens/login.dart';
import 'package:jritev4/firebase_options.dart';



Future<void> main() async {
  debugPaintSizeEnabled = false;

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  ));

  // TODO: Push Notification
  // // Firebase Cloud Messaging (FCM)


 WidgetsFlutterBinding.ensureInitialized();
 await NotificationService().init();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true, provisional: false);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true,badge: true,sound: true,);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    

    return  CupertinoApp(
      title: 'jritev4',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ],
        theme: const CupertinoThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor:Color.fromARGB(255, 52, 51, 65),
        primaryColor: Colors.black,
        textTheme: CupertinoTextThemeData(
          primaryColor: Colors.green,
          textStyle: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Color.fromARGB(255, 26, 25, 32),
              fontWeight: FontWeight.normal),
        ),
      ),
      initialRoute: '/',
      routes: {
                        '/': (context) => const SplashScreen(),
        '/home': (context) =>  const Home(),
        '/login': (context) =>  LoginPage(),
        '/mode': (context) =>  ModeScreen(),
      },
    );
    
  }
  
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
}