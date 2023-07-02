import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:jritev4/models/bid.dart';
import 'package:jritev4/services/database.dart';

import '../models/job.dart';

class BidSubmissionActivity extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> jobModel;

  BidSubmissionActivity({required this.jobModel});

  @override
  _BidSubmissionActivityState createState() => _BidSubmissionActivityState();
}

class _BidSubmissionActivityState extends State<BidSubmissionActivity> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final TextEditingController bidOfferController = TextEditingController();
  final TextEditingController completionTimeController =
      TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  String uid = "";
  String username = "";
  int rating = 0;
    String date = "";
  String time = "";
  String formattedDate = "";
  String formattedTime = "";
  @override
  void initState() {
    // TODO: implement initState
    getUser();
    super.initState();
  }

  Future<void> getUser() async {
    final User user = firebaseAuth.currentUser!;
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
        username = value.get("name") ?? "";

        rating = value.get("rating") ?? "";
         print(rating);
      });
    }).catchError((error) {
          print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/jrite-logo.png',
          height: 100,
          width: 100,
          alignment: Alignment.bottomLeft,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Job Title: ${widget.jobModel['jobTitle']}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
                  height: 50,
                  width: 300,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: CupertinoTextField(
                    key: const Key("username"),
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: bidOfferController,
                    placeholder: 'Offer',
                  ),
                ),
           
            SizedBox(height: 8),
             Padding(
              padding:
                              const EdgeInsets.only(left: 1,right:25),
                 child: GestureDetector(
                  onTap: () async {
                     await DatePicker.showDateTimePicker(context,
                          showTitleActions: true,
                          onChanged: (dateTemp) {}, onConfirm: (dateTemp) {
                        setState(() {
                          date = dateTemp.toString();
                          var arr2 = date.split(' ');
                          date = arr2[0];
                          time = arr2[1];
                          var arr3 = time.split('.');
                          time = arr3[0];
                          String temp = date + " " + time;
                          DateTime? datetime = DateTime.now();
                          if (date != 'N/A' || time != 'N/A') {
                            try {
                              datetime = DateTime.parse(temp);
                            } catch (error) {
                              datetime = null;
                            }
                          }
                          formattedDate =
                              DateFormat.MMMEd().format(datetime!).toString();
                          formattedTime =
                              DateFormat.Hm().format(datetime).toString();
                        });
                      }, currentTime: DateTime.now(), locale: LocaleType.en);
                  },
                   child: Container(
                   
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color.fromARGB(255, 225, 225, 225))
                        ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3,vertical: 10),
                              child: Row(
                                children: [
                                  Text(
                                    "Completion Time",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 212, 212, 212),
                                        fontSize: 13,
                                      ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                  ),
                                    Container(
                                      alignment: Alignment.bottomLeft,
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 249, 249, 249),
                                          borderRadius: BorderRadius.circular(8)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: (formattedDate != "")
                                            ? Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    formattedDate,
                                                    style: const TextStyle(fontSize: 15),
                                                  ),
                                                  Text(
                                                    formattedTime,
                                                    style: const TextStyle(fontSize: 15),
                                                  ),
                                                ],
                                              )
                                            : Container(
                                                height: 15,
                                              ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                 ),
               ),

            SizedBox(height: 8),
              Container(
                  height: 50,
                  width: 300,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: CupertinoTextField(
                    key: const Key("username"),
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: commentsController,
                    placeholder: 'Comments',
                  ),
                ),
           
            SizedBox(height: 16),
             Center(
                child: Container(
                margin: const EdgeInsets.only(top: 15,right: 22),
                width: 300,
                height: 40,
                child: CupertinoButton(
                  borderRadius: BorderRadius.circular(0),
                  color: Color.fromARGB(255, 208, 80, 21),
                  disabledColor: CupertinoColors.inactiveGray,
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                         submitBid();
                    Navigator.pop(context,true);
                  },
                  child: const Text('Submit Bid',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      )),
                ),
            ),
              ),
          
          ],
        ),
      ),
    );
  }

  void submitBid() {
    String bidOffer = bidOfferController.text.trim();
    String completionTime = completionTimeController.text.trim();
    String comments = commentsController.text.trim();

    DatabaseService().addBid(uid, double.parse(bidOffer),formattedDate ,formattedTime,
        comments, rating, widget.jobModel.id, username);
  }
}
