class RidingRecordCard {
  int? userId;
  bool? withinBoundary;
  bool? revealWb;
  String? date;
  String? weekday;
  String? displayName;
  String? profileImageUrlUser;
  int? totalSlopeCount;
  Map<String, int>? slopeCountsByName;
  String? mostRiddenSlope;
  int? mostRiddenCount;
  double? topSpeed;
  double? totalDistance;
  String? riderTitle;

  RidingRecordCard({
    this.userId,
    this.withinBoundary,
    this.revealWb,
    this.date,
    this.weekday,
    this.displayName,
    this.profileImageUrlUser,
    this.totalSlopeCount,
    this.slopeCountsByName,
    this.mostRiddenSlope,
    this.mostRiddenCount,
    this.topSpeed,
    this.totalDistance,
    this.riderTitle,
  });

  RidingRecordCard.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    withinBoundary = json['within_boundary'];
    revealWb = json['reveal_wb'];
    date = json['date'];
    weekday = json['weekday'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    totalSlopeCount = json['total_slope_count'];
    slopeCountsByName = json['slope_counts_by_name'] != null
        ? Map<String, int>.from(json['slope_counts_by_name'])
        : null;
    mostRiddenSlope = json['most_ridden_slope'];
    mostRiddenCount = json['most_ridden_count'];
    topSpeed = json['top_speed']?.toDouble();
    totalDistance = json['total_distance']?.toDouble();
    riderTitle = json['rider_title'];
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'within_boundary': withinBoundary,
      'reveal_wb': revealWb,
      'date': date,
      'weekday': weekday,
      'display_name': displayName,
      'profile_image_url_user': profileImageUrlUser,
      'total_slope_count': totalSlopeCount,
      'slope_counts_by_name': slopeCountsByName,
      'most_ridden_slope': mostRiddenSlope,
      'most_ridden_count': mostRiddenCount,
      'top_speed': topSpeed,
      'total_distance': totalDistance,
      'rider_title': riderTitle,
    };
  }
}
