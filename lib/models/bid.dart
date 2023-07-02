class Bid {
  String? id;
  String? userId;
  double? bidOffer;
  String? completionTime;
  String? comments;
  int? profileRating;
  String? jobId;
  String? freelancerName;

  Bid({
    this.id,
    this.userId,
    this.bidOffer,
    this.completionTime,
    this.comments,
    this.profileRating,
    this.jobId,
    this.freelancerName,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['id'],
      userId: json['userId'],
      bidOffer: json['bidOffer'].toDouble(),
      completionTime: json['completionTime'],
      comments: json['comments'],
      profileRating: json['profileRating'],
      jobId: json['jobId'],
      freelancerName: json['freelancerName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bidOffer': bidOffer,
      'completionTime': completionTime,
      'comments': comments,
      'profileRating': profileRating,
      'jobId': jobId,
      'freelancerName': freelancerName,
    };
  }
}