import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jritev4/screens/job_detail.dart';
import 'package:jritev4/screens/job_submit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String uid = '';
  String role = 'Freelancer';
  String name = '';
  List<QueryDocumentSnapshot<Object?>>? jobData;
  List<QueryDocumentSnapshot<Object?>>? jobData2;
  @override
  void initState() {
    // TODO: implement initState
    getUser();
    _refreshJobs();
    _refreshJobs2();
    super.initState();
  }

  Future<void> getUser() async {
    final User user = _firebaseAuth.currentUser!;
    if (user == null) {
      return;
    } else {
      uid = user.email!;

      await FirebaseFirestore.instance
          .collection("user")
          .doc(uid)
          .get()
          .then((value) {
        setState(() {
          name = value.get("name") ?? "";
          role = value.get("role") ?? "";
        });
      }).catchError((error) {
        print(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          children: [
            Container(
              height: 82,
              color: Color.fromARGB(255, 230, 230, 230),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.person_circle,
                      color: Colors.white,
                      size: 55,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        Text(role,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 15),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Your Jobs',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (role == "Freelancer")
              Column(children: [buildJobListFreelance()]),
            if (role == "Employer")
              Column(
                children: [
                  buildJobList(),
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    width: 250,
                    height: 40,
                    child: CupertinoButton(
                      borderRadius: BorderRadius.circular(0),
                      color: Color.fromARGB(255, 208, 80, 21),
                      disabledColor: CupertinoColors.inactiveGray,
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        var job = Navigator.of(context)
                            .push(CupertinoPageRoute(builder: (context) {
                          return JobSubmissionActivity(role: role, email: uid);
                        }));
                        if (job == true) {
                          await _refreshContent();
                        }
                      },
                      child: const Text('Create Job',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          )),
                    ),
                  ),
                ],
              ),
            Container(
              margin: const EdgeInsets.only(top: 15),
              width: 250,
              height: 40,
              child: CupertinoButton(
                borderRadius: BorderRadius.circular(0),
                color: Color.fromARGB(255, 209, 3, 3),
                disabledColor: CupertinoColors.inactiveGray,
                padding: EdgeInsets.zero,
                onPressed: () async {
                  await _firebaseAuth.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Log Out',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshContent() async {
    _refreshJobs();
    _refreshJobs2();
  }

  Widget buildJobListFreelance() {
    return Container(
      child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection("job")
              .where("winningBid", isEqualTo: uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              );
            } else {
              final List<QueryDocumentSnapshot> jobData2 = snapshot.data!.docs;
              return RefreshIndicator(
                color: CupertinoTheme.of(context).primaryColor,
                onRefresh: _refreshContent,
                child: Container(
                  height: MediaQuery.of(context).size.height * 50/109,
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      itemCount: jobData2.length,
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
                                                  fontSize: 10)),
                                        ),
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

  Widget buildJobList() {
    return Container(
   
      child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection("job")
              .where("employerEmail", isEqualTo: uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              );
            } else {
              final List<QueryDocumentSnapshot> jobData = snapshot.data!.docs;
              return RefreshIndicator(
                color: CupertinoTheme.of(context).primaryColor,
                onRefresh: _refreshContent,
                child: Container(
                     height: MediaQuery.of(context).size.height * 50/109,
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      itemCount: jobData.length,
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
                                                  fontSize: 10)),
                                        ),
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

  _refreshJobs2() async {
    setState(() {
      // Clear the current activity data or update the loading state
      // based on your requirements
      jobData2 =
          null; // Assuming you have a variable named activityData that holds the activity data
    });

    try {
      QuerySnapshot snapshot;

      snapshot = await FirebaseFirestore.instance
          .collection("job")
          .where("winningBid", isEqualTo: uid)
          .get();

      setState(() {
        // Update the activity data with the new snapshot
        jobData2 = snapshot.docs;
      });
    } catch (e) {
      // Handle any error that occurred during the refresh
      print("Error refreshing activities: $e");
    }
  }

  _refreshJobs() async {
    setState(() {
      // Clear the current activity data or update the loading state
      // based on your requirements
      jobData2 =
          null; // Assuming you have a variable named activityData that holds the activity data
    });

    try {
      QuerySnapshot snapshot;

      snapshot = await FirebaseFirestore.instance
          .collection("activities")
          .where("employerEmail", isEqualTo: uid)
          .get();

      setState(() {
        // Update the activity data with the new snapshot
        jobData = snapshot.docs;
      });
    } catch (e) {
      // Handle any error that occurred during the refresh
      print("Error refreshing activities: $e");
    }
  }
}
