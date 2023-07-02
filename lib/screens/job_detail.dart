import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:jritev4/models/bid.dart';
import 'package:jritev4/models/job.dart';
import 'package:jritev4/screens/bid_submit.dart';
import 'package:jritev4/services/database.dart';

class JobDetailsActivity extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> jobModel;
  String role;
  String uid;
  JobDetailsActivity(
      {super.key,
      required this.jobModel,
      required this.role,
      required this.uid});

  @override
  _JobDetailsActivityState createState() => _JobDetailsActivityState();
}

class _JobDetailsActivityState extends State<JobDetailsActivity> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String leadingId = "";
  String leadingValue = "";
  List<Bid> bids = [];
  Future? futureBids;
  String winningBid = "";
  String leadingBid = "";
  @override
  void initState() {
    futureBids = getJob();

    super.initState();
  }

  showRate(BuildContext mcontext, int star) {
    Widget cancelButton = CupertinoButton(
      child: const Text(
        'Back',
        style: TextStyle(
          fontWeight: FontWeight.w300,
        ),
      ),
      onPressed: () {
        Navigator.pop(mcontext);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Center(
        child: Text(
          "Rate Freelancer",
          style: TextStyle(
            fontWeight: FontWeight.w300,
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
      ),
      content: Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(left: 15),
              alignment: Alignment.center,
              height: 100,
              child: ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    Color color =
                        (index + 1 <= star) ? Colors.yellow : Colors.grey;
                    return GestureDetector(
                        onTap: (() {
                          Navigator.pop(mcontext);
                          showRate(mcontext, (index + 1));
                        }),
                        child: Icon(
                          Icons.star,
                          size: 40,
                          color: color,
                        ));
                  }),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  int rating = 0;
                  if (star == 1) {
                    setState(() {
                      rating = 10;
                    });
                  } else if (star == 2) {
                    setState(() {
                      rating = 20;
                    });
                  } else if (star == 3) {
                    setState(() {
                      rating = 30;
                    });
                  } else if (star == 4) {
                    setState(() {
                      rating = 40;
                    });
                  } else if (star == 5) {
                    setState(() {
                      rating = 50;
                    });
                  }
                  print(rating);
                  DatabaseService().updateRating(findBestBidId(bids), rating);
                  DatabaseService().rateJob(widget.jobModel.id);
                  Navigator.pop(mcontext);
                },
                child: Text("Submit"),
              ),
            ),
          ],
        ),
      ),
      actions: [
        cancelButton,
      ],
    );

    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () => Future.value(true),
          child: Builder(
            builder: (context) {
              return alert;
            },
          ),
        );
      },
    );
  }

  Future<void> getJob() async {
    await FirebaseFirestore.instance
        .collection("job")
        .doc(widget.jobModel.id)
        .get()
        .then((value) {
      var bidList = value.get("bid");
      List<Bid> _bidinfo =
          bidList.map<Bid>((json) => Bid.fromJson(json)).toList();
      setState(() {
        bids = _bidinfo;
      });
      
      leadingValue = findBestBidOffer(_bidinfo);
      if (isJobExpired() &&
          bids.isNotEmpty &&
          widget.jobModel['rateStatus'] == 'no' &&
          widget.role == "Employer") {
        showRate(context, 0);
      }
    

      if (isJobExpired() && winningBid == "" && leadingBid != "") {
        DatabaseService().updateJob(widget.jobModel.id, leadingBid);
      }
      setState(() {
         winningBid = value.get("winningBid") ?? "";
      });
       
      print("Leading Value: $leadingValue");
    }).catchError((error) {
      print(error);
    });
  }

  String findBestBidId(List<Bid> bidList) {
    if (bidList.isEmpty) {
      return ''; // No bids available
    }

    Bid bestBid = bidList.first;
    for (var bid in bidList) {
      double currentBid = bid.bidOffer ?? 0;
      double bestBidValue = bestBid.bidOffer ?? 0;
      int currentRating = bid.profileRating!;
      int bestRating = bestBid.profileRating!;

      // Compare bid offers and profile ratings with more importance on the rating
      if ((currentRating > bestRating) ||
          (currentRating == bestRating && currentBid > bestBidValue) ||
          (currentRating == bestRating &&
              currentBid == bestBidValue &&
              currentRating > 0 &&
              bestRating > 0)) {
        bestBid = bid;
      }
    }

    return bestBid.userId.toString();
  }

  String findBestBidOffer(List<Bid> bidList) {
    if (bidList.isEmpty) {
      return ''; // No bids available
    }

    Bid bestBid = bidList.first;
    for (var bid in bidList) {
      double currentBid = bid.bidOffer ?? 0;
      double bestBidValue = bestBid.bidOffer ?? 0;
      int currentRating = bid.profileRating!;
      int bestRating = bestBid.profileRating!;

      // Compare bid offers and profile ratings with more importance on the rating
      if ((currentRating > bestRating) ||
          (currentRating == bestRating && currentBid > bestBidValue) ||
          (currentRating == bestRating &&
              currentBid == bestBidValue &&
              currentRating > 0 &&
              bestRating > 0)) {
                setState(() {
                          bestBid = bid;
        leadingBid = bestBid.userId!;
                }); 
  
      }
    }

    return bestBid.bidOffer.toString();
  }

  bool isJobExpired() {
    DateTime currentDateTime = DateTime.now();
    DateTime jobExpirationDateTime = DateTime.parse(
        "${widget.jobModel['expiredDate']!} ${widget.jobModel['expiredTime']!}");

    return currentDateTime.isAfter(jobExpirationDateTime);
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
              "${widget.jobModel['jobTitle']!}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Description: ${widget.jobModel['jobDescription']!}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Requirements: ${widget.jobModel['jobRequirements']!}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Price: \$${widget.jobModel['jobPrice']!}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Expired Time: ${widget.jobModel['expiredTime']!}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Expired Date: ${widget.jobModel['expiredDate']!}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Leading Offer: $leadingValue",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Divider(),
            Text("Bids"),
            Flexible(
              child: FutureBuilder(
                  future: futureBids,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        height: MediaQuery.of(context).size.height * 50/109,
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            padding: EdgeInsets.zero,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: bids.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                      child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                            bids[index].freelancerName.toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Container(
                                                width: 150,
                                                child: Text(
                                                    "Profile Rating: " +
                                            bids[index].profileRating.toString(),
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w300,
                                                        fontSize: 10))),
                                                (winningBid == widget.uid)?Icon( Icons.emoji_events,color:Colors.yellow):Container(),          
                                         
                                          ],
                                        ),
                                             Text("MYR ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.grey)),
                                              Text(
                                        bids[index].bidOffer!.toStringAsFixed(2),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 22)), 
                                      ],
                                    ),
                                  ),
                                )),
                                  ));
                            }),
                      );
                    }
                  }),
            ),
            if (!isJobExpired() && widget.role == "Freelancer")
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
                      Navigator.of(context)
                        .push(CupertinoPageRoute(builder: (context) {
                      return BidSubmissionActivity(
                        jobModel: widget.jobModel,
                      );
                    }));
                  },
                  child: const Text('Place a Bid',
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
}
