import 'package:jritev4/models/bid.dart';

class Job {
  String? jobId;
  String? jobTitle;
  String? jobDescription;
  String? jobRequirements;
  double? jobPrice;
  List<Bid>? bids;
  String? winningBid;

  Job({
    this.jobId,
    this.jobTitle,
    this.jobDescription,
    this.jobRequirements,
    this.jobPrice,
    this.bids,
    this.winningBid
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      jobId: json['jobId'],
      jobTitle: json['jobTitle'],
      jobDescription: json['jobDescription'],
      jobRequirements: json['jobRequirements'],
      winningBid: json['winningBid'],
      jobPrice: json['jobPrice'].toDouble(),
      bids: List<Bid>.from(json['bids'].map((x) => Bid.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'jobDescription': jobDescription,
      'jobRequirements': jobRequirements,
      'jobPrice': jobPrice,
      'winningBid': winningBid,
      'bids': List<dynamic>.from(bids!.map((x) => x.toJson())),
    };
  }
}
