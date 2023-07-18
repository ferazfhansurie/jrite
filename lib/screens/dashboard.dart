import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:jritev4/models/category.dart';
import 'package:jritev4/models/job.dart';
import 'package:jritev4/screens/job_category.dart';
import 'package:jritev4/screens/job_detail.dart';
import 'package:jritev4/screens/job_submit.dart';
import 'package:jritev4/services/notification.dart';
import 'package:jritev4/widgets/search_bar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomepageActivity extends StatefulWidget {
  @override
  _HomepageActivityState createState() => _HomepageActivityState();
}

class _HomepageActivityState extends State<HomepageActivity> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<Job> jobList = [];
  String uid = '';
  String name = '';
  String role = 'Freelancer';
  List<Category> category = [];
  List<String> popular = ['Articles', 'Youtube', 'Twitter'];
  List<QueryDocumentSnapshot<Object?>>? job;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;

  @override
  void initState() {
    super.initState();
    requestPermission();
    getUser();
    getCategories();
    _refreshContent();
    loadFCM();
    listenFCM();
  }

  void getCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("category").get();
    category = snapshot.docs
        .map((doc) => Category.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // Perform further actions with the retrieved companies
    // For example, you can print the company names:
    category.forEach((company) {
      print(company.name);
    });
  }

  Future<void> getUser() async {
    final User user = _firebaseAuth.currentUser!;
    if (user == null) {
      return;
    }
    uid = user.email!;
    print(uid);
    await FirebaseFirestore.instance
        .collection("user")
        .doc(user.email!)
        .get()
        .then((value) {
      setState(() {
        role = value.get("role") ?? "";
        name = value.get("name") ?? "";
        print(name);
      });
    }).catchError((error) {
      print(error);
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
    } else {}
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                icon: 'ic_notification', subText: "Buds"),
          ),
        );
      }
    });
  }

  void loadFCM() async {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
      enableVibration: true,
    );
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/jrite-logo.png',
          height: 100,
          width: 100,
          alignment: Alignment.bottomLeft,
        ),
      ),
      body: RefreshIndicator(
        color: CupertinoTheme.of(context).primaryColor,
        onRefresh: _refreshContent,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchBarWidget(
                  onSubmitted: (value) {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 15),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Categories',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (category.isNotEmpty) popularJobList(),
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 15),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Jobs',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              buildJobList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget popularJobList() {
    return Container(
      height: 200,
      child: ListView.builder(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          itemCount: popular.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            List<Color> popularColor = [
              Colors.grey,
              Color.fromARGB(255, 187, 32, 21),
              Colors.blue
            ];
            Color getColorForIndex(int index) {
              return popularColor[index % popularColor.length];
            }

            return Padding(
              padding: const EdgeInsets.all(4),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GestureDetector(
                    onTap: () async {
                      /*Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return JobCategoryActivity(
                          category: category[index].name!,
                        );
                      }));*/
                      //send Notifcation
                      /* String? messagingToken = await NotificationService()
                          .getFirebaseMessagingToken();
                      print(messagingToken);
                      NotificationService().sendNotification(
                        messagingToken!,
                      );*/
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles();
                      print(result);
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: 160,
                          width: 155,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: getColorForIndex(index),
                          ),
                        ),
                        Positioned(
                          top: 123,
                          child: Container(
                            height: 60,
                            width: 155,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(0),
                                topLeft: Radius.circular(0),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    category[index].name!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            );
          }),
    );
  }

  Widget buildJobList() {
    return Container(
      child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection("job").get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              );
            } else {
              return RefreshIndicator(
                color: CupertinoTheme.of(context).primaryColor,
                onRefresh: _refreshContent,
                child: Container(
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data!.docs.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final List<QueryDocumentSnapshot> job =
                            snapshot.data!.docs;
                        final List<Color> colors = [
                          const Color.fromARGB(255, 0, 170, 235),
                          const Color.fromARGB(255, 27, 117, 184),
                          const Color.fromARGB(255, 83, 212, 169),
                        ];

                        Color getColorForIndex(int index) {
                          return colors[index % colors.length];
                        }

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            child: Card(
                                child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(0),
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    color: getColorForIndex(index),
                                  ),
                                  width: 120,
                                  height: 100,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(job[index]['jobTitle'].toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Container(
                                            width: 150,
                                            child: Text(
                                                job[index]['jobDescription'],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 10))),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              SizedBox(
                                                width: 80,
                                              ),
                                              Text("MYR ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.grey)),
                                              Text(job[index]['jobPrice'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 26)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )),
                            onTap: () {
                              Navigator.of(context)
                                  .push(CupertinoPageRoute(builder: (context) {
                                return JobDetailsActivity(
                                  jobModel: job[index],
                                  role: role,
                                  uid: uid,
                                );
                              }));
                            },
                          ),
                        );
                      }),
                ),
              );
            }
          }),
    );
  }

  Future<void> _refreshContent() async {
    _refreshJobs();
  }

  _refreshJobs() async {
    setState(() {
      // Clear the current activity data or update the loading state
      // based on your requirements
      job =
          null; // Assuming you have a variable named activityData that holds the activity data
    });

    try {
      QuerySnapshot snapshot;

      snapshot = await FirebaseFirestore.instance.collection("job").get();

      setState(() {
        // Update the activity data with the new snapshot
        job = snapshot.docs;
      });
    } catch (e) {
      // Handle any error that occurred during the refresh
      print("Error refreshing activities: $e");
    }
  }
}
