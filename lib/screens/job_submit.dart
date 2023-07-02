import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:jritev4/models/bid.dart';
import 'package:jritev4/models/category.dart';
import 'package:jritev4/services/database.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';

class JobSubmissionActivity extends StatefulWidget {
  String role;
  String email;
  JobSubmissionActivity({super.key, required this.role, required this.email});

  @override
  _JobSubmissionActivityState createState() => _JobSubmissionActivityState();
}

class _JobSubmissionActivityState extends State<JobSubmissionActivity> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController jobDescriptionController =
      TextEditingController();
  final TextEditingController jobRequirementsController =
      TextEditingController();
  final TextEditingController jobPriceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  String date = "";
  String time = "";
  String formattedDate = "";
  String formattedTime = "";
  List<Category> category = [];
  String selectedCategory = '';
  @override
  void initState() {
    // TODO: implement initState
    getCategories();
    super.initState();
  }

  void getCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("category").get();
    category = snapshot.docs
        .map((doc) => Category.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    setState(() {
      selectedCategory = category[0].name!;
    });
    // Perform further actions with the retrieved companies
    // For example, you can print the company names:
    category.forEach((company) {
      print(company.name);
    });
  }

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Submit Job',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              Container(
                  height: 50,
                  width: 300,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: CupertinoTextField(
                    key: const Key("username"),
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: jobTitleController,
                    placeholder: 'Title',
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
                    controller: jobDescriptionController,
                    placeholder: 'Description',
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
                    controller: jobRequirementsController,
                    placeholder: 'Requirements',
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
                    controller: jobPriceController,
                    placeholder: 'Price',
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
                                    "Date and Time",
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
               Padding(
              padding:
                              const EdgeInsets.only(left: 1,right:25),
                 child: Container(
                 
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color.fromARGB(255, 225, 225, 225))
                      ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Row(
                              children: [
                                Text(
                                  "Category",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 212, 212, 212),
                                      fontSize: 13,
                                    ),
                                ),
                                SizedBox(
                                  width: 100,
                                ),
                                Material(
                                   color: Colors.white,
                                  child: DropdownButton<String>(
                                    value: selectedCategory,
                                    items: category.map((Category category) {
                                      return DropdownMenuItem<String>(
                                        value: category.name,
                                        child: Text(category.name ?? ''),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCategory = value!;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
               ),
              SizedBox(height: 16),
              Center(
                child: Container(
                margin: const EdgeInsets.only(top: 15,right: 18),
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
                  child: const Text('Submit',
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
      ),
    );
  }

  void submitBid() {
    DatabaseService().createJob(
        jobTitleController.text,
        jobDescriptionController.text,
        jobRequirementsController.text,
        jobPriceController.text,
        selectedCategory,
        date,
        time,
        widget.email);
  }
}
