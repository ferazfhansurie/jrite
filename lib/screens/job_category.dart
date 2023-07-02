import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:jritev4/models/job.dart';
import 'package:jritev4/screens/job_detail.dart';
import 'package:jritev4/screens/job_submit.dart';
import 'package:jritev4/widgets/search_bar.dart';

class JobCategoryActivity extends StatefulWidget {
  String category;
  JobCategoryActivity({required this.category});
  @override
  _JobCategoryActivityState createState() => _JobCategoryActivityState();
}

class _JobCategoryActivityState extends State<JobCategoryActivity> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<Job> jobList = [];
  String uid = '';
  String name = '';
  String role = 'Freelancer';
  List<String> popular = ['Articles', 'Youtube', 'Twitter'];
  List<Color> popularColor = [
    Colors.grey,
    Color.fromARGB(255, 187, 32, 21),
    Colors.blue
  ];
  @override
  void initState() {
    super.initState();
    getUser();
    loadDummyJobs();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
           
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 15),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  widget.category,
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
    );
  }

  Widget buildJobList() {
    return Container(
      child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection("job").where("category",isEqualTo:widget.category).get(),
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
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data!.docs.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var job = snapshot.data!.docs;
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

  Future<void> _refreshContent() async {}
  void loadDummyJobs() {
    setState(() {
      jobList.add(Job(
          jobId: "01",
          jobTitle: "Job 1",
          jobDescription: "Description 1",
          jobRequirements: "Requirement 1",
          jobPrice: 100.0));
      jobList.add(Job(
          jobId: "02",
          jobTitle: "Job 2",
          jobDescription: "Description 2",
          jobRequirements: "Requirement 2",
          jobPrice: 200.0));
      jobList.add(Job(
          jobId: "03",
          jobTitle: "Job 3",
          jobDescription: "Description 3",
          jobRequirements: "Requirement 3",
          jobPrice: 300.0));
    });
  }
}
