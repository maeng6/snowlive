/// 시즌 기록 카드 모델
class SeasonRidingCard {
  int? userId;
  String? displayName;
  String? profileImageUrlUser;
  String? season;
  int? totalSlopeCount;
  double? totalDistance;
  double? topSpeed;
  String? createdAt;
  String? updatedAt;

  SeasonRidingCard({
    this.userId,
    this.displayName,
    this.profileImageUrlUser,
    this.season,
    this.totalSlopeCount,
    this.totalDistance,
    this.topSpeed,
    this.createdAt,
    this.updatedAt,
  });

  SeasonRidingCard.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    season = json['season'];
    totalSlopeCount = json['total_slope_count'];
    totalDistance = json['total_distance']?.toDouble();
    topSpeed = json['top_speed']?.toDouble();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'profile_image_url_user': profileImageUrlUser,
      'season': season,
      'total_slope_count': totalSlopeCount,
      'total_distance': totalDistance,
      'top_speed': topSpeed,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
