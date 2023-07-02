import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  DatabaseService();
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user');
        final CollectionReference jobCollection =
      FirebaseFirestore.instance.collection('job');
  List user = [];

  Future getData() async {
    try {
      await userCollection.get().then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          user.add(result.data());
        }
      });

      return user;
    } catch (e) {
      print("Error - $e");
      return e;
    }
  }
  Future<void> registerUserData(String name,String email,String password,String role) async {
 return await userCollection.doc(email.toLowerCase()).set({
          'name': name,
      'rating':0,
      'email':email,
      'password':password,
      'role':role
    });
  }
 Future<void> updateRating(
      String email,int rating) async {
    return await userCollection.doc(email).update({
        "rating":FieldValue.increment(rating),
    });
  }
   Future<void> rateJob(
      String id,) async {
    return await jobCollection.doc(id).update({
        "rateStatus":'done',
    });
  }
  Future<void> updateUserData(
  String oldEmail,
  String email,
) async {
  var userRef = userCollection.doc(oldEmail);
  var userSnapshot = await userRef.get();
  if (userSnapshot.exists) {
    Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
    data['email'] = email;
    await userCollection.doc(email).set(data);
    await userRef.delete();
    
  }
}
Future<DocumentReference<Object?>> createJob(
      String jobTitle,
      String jobDescription,
      String jobRequirements,
      String jobPrice,
      String category,
      String date,
      String time,
      String email,
 ) async {
    DocumentReference<Object?> newJobRef = await jobCollection.add({
      "jobTitle": jobTitle,
      "jobDescription": jobDescription,
      'jobRequirements': jobRequirements,
      'jobPrice': jobPrice,
      'category': category,
      'expiredDate': date,
      'expiredTime': time,
      "rateStatus":'no',
      "employerEmail":email
    });
    return newJobRef;
  }
  Future<void> updateJob(
      String jobId,
      String winningBid,
 ) async {
  await jobCollection.doc(jobId).update({
      "winningBid":winningBid
    });
  
  }
  Future<void> addBid(
      String userId,
      double bidOffer,
        String completionDate,
      String completionTime,
      String comments,
       int profileRating,
      String jobId,
      String freelancerName,) async {
    return await jobCollection.doc(jobId).update({
      "bid": FieldValue.arrayUnion([
        {
       "userId": userId,
      "bidOffer": bidOffer,
      'completionDate': completionDate,
      'completionTime': completionTime,
      'comments': comments,
      "profileRating": profileRating,
      'jobId': jobId,
      'freelancerName': freelancerName,
        },
      ])
    });
  }

}


