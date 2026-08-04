/// 데일리 기록 카드 모델
class DailyRidingCard {
  int? cardId;
  int? userId;
  String? date;
  String? weekday;
  int? totalSlopeCount;
  double? totalDistance;
  Map<String, int>? slopeCountsByName;
  String? mostRiddenSlope;
  int? mostRiddenCount;
  double? topSpeed;
  double? avgSlope;
  String? riderTitle;

  /// 그 날 라이딩한 리조트. 응답에 있는데 파싱이 빠져 있었다(웹 라이딩 카드가 쓴다).
  List<String>? resorts;

  String? createdAt;
  String? updatedAt;

  DailyRidingCard({
    this.cardId,
    this.userId,
    this.date,
    this.weekday,
    this.totalSlopeCount,
    this.totalDistance,
    this.slopeCountsByName,
    this.mostRiddenSlope,
    this.mostRiddenCount,
    this.topSpeed,
    this.avgSlope,
    this.riderTitle,
    this.resorts,
    this.createdAt,
    this.updatedAt,
  });

  DailyRidingCard.fromJson(Map<String, dynamic> json) {
    cardId = json['card_id'];
    userId = json['user_id'];
    date = json['date'];
    weekday = json['weekday'];
    totalSlopeCount = json['total_slope_count'];
    totalDistance = json['total_distance']?.toDouble();
    if (json['slope_counts_by_name'] != null) {
      slopeCountsByName = Map<String, int>.from(
        (json['slope_counts_by_name'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toInt()),
        ),
      );
    }
    mostRiddenSlope = json['most_ridden_slope'];
    mostRiddenCount = json['most_ridden_count'];
    topSpeed = json['top_speed']?.toDouble();
    avgSlope = json['avg_slope']?.toDouble();
    riderTitle = json['rider_title'];
    resorts = json['resorts'] == null
        ? null
        : (json['resorts'] as List).map((e) => '$e').toList();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'card_id': cardId,
      'user_id': userId,
      'date': date,
      'weekday': weekday,
      'total_slope_count': totalSlopeCount,
      'total_distance': totalDistance,
      'slope_counts_by_name': slopeCountsByName,
      'most_ridden_slope': mostRiddenSlope,
      'most_ridden_count': mostRiddenCount,
      'top_speed': topSpeed,
      'avg_slope': avgSlope,
      'rider_title': riderTitle,
      'resorts': resorts,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
