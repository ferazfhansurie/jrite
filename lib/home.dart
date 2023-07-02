import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jritev4/screens/dashboard.dart';
import 'package:jritev4/screens/profile.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? mtoken = " ";
    String firstName = '';
  String uid = '';
  String email = "";
   final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    final User user = _auth.currentUser!;
    uid = user.email!;
    print(uid);
    getUser();
    super.initState();
  }
void getUser() {
    FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          firstName = snapshot.get("name");

          print(firstName);
        });
      } else {
        print("Snapshot not found");
      }
    });

  
  
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            iconSize: 30,
            inactiveColor: Colors.grey,
            activeColor: Color.fromARGB(255, 208, 80, 21),
            backgroundColor: Colors.white,
            onTap: (index) {},
            items: const [
                        BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
          ),

             BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_circle),
          ),
            ],
          ),
          tabBuilder: (context, index) {
            // TODO
            switch (index) {
             
                 case 0:
                return HomepageActivity();
              default:
                return ProfilePage(
                );
            }
          });
   
  }
}
