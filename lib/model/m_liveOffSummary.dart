class LiveOffSummaryModel {
  late int userId;
  late bool withinBoundary;
  late bool revealWb;
  late String date;
  late String weekday;
  late String displayName;
  late String profileImageUrlUser;
  late int totalSlopeCount;
  late Map<String, int> slopeCountsByName;
  late String mostRiddenSlope;
  late int mostRiddenCount;
  late double topSpeed;
  late String riderTitle;

  LiveOffSummaryModel({
    this.userId = 0,
    this.withinBoundary = false,
    this.revealWb = true,
    this.date = '',
    this.weekday = '',
    this.displayName = '',
    this.profileImageUrlUser = '',
    this.totalSlopeCount = 0,
    Map<String, int>? slopeCountsByName,
    this.mostRiddenSlope = '',
    this.mostRiddenCount = 0,
    this.topSpeed = 0,
    this.riderTitle = '',
  }) : slopeCountsByName = slopeCountsByName ?? {};

  LiveOffSummaryModel.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'] ?? 0;
    withinBoundary = json['within_boundary'] ?? false;
    revealWb = json['reveal_wb'] ?? true;
    date = json['date'] ?? '';
    weekday = json['weekday'] ?? '';
    displayName = json['display_name'] ?? '';
    profileImageUrlUser = json['profile_image_url_user'] ?? '';
    totalSlopeCount = json['total_slope_count'] ?? 0;

    // slope_counts_by_name 파싱
    if (json['slope_counts_by_name'] != null) {
      slopeCountsByName = Map<String, int>.from(
        (json['slope_counts_by_name'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toInt()),
        ),
      );
    } else {
      slopeCountsByName = {};
    }

    mostRiddenSlope = json['most_ridden_slope'] ?? '';
    mostRiddenCount = json['most_ridden_count'] ?? 0;
    topSpeed = (json['top_speed'] ?? 0).toDouble();
    riderTitle = json['rider_title'] ?? '';
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
      'rider_title': riderTitle,
    };
  }
}