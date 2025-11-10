// lib/model/slope_Rush_models.dart
class SlopeRushResponse {
  final int resortId;
  final String resortFullname;
  final List<SlopeRushItem> slopeRush;

  SlopeRushResponse({
    this.resortId = 0,
    this.resortFullname = "",
    List<SlopeRushItem>? slopeRush,
  }) : slopeRush = slopeRush ?? const [];

  factory SlopeRushResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['slope_Rush'] as List<dynamic>? ?? [])
        .map((e) => SlopeRushItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return SlopeRushResponse(
      resortId: (json['resort_id'] ?? 0) is int ? json['resort_id'] : int.tryParse('${json['resort_id'] ?? 0}') ?? 0,
      resortFullname: (json['resort_fullname'] ?? "").toString(),
      slopeRush: list,
    );
  }

  Map<String, dynamic> toJson() => {
    "resort_id": resortId,
    "resort_fullname": resortFullname,
    "slope_Rush": slopeRush.map((e) => e.toJson()).toList(),
  };
}

class SlopeRushItem {
  final String slopeFullname;
  final String slopeNickname;
  final List<SlopeCrew> crews;

  SlopeRushItem({
    this.slopeFullname = "",
    this.slopeNickname = "",
    List<SlopeCrew>? crews,
  }) : crews = crews ?? const [];

  factory SlopeRushItem.fromJson(Map<String, dynamic> json) {
    final list = (json['crews'] as List<dynamic>? ?? [])
        .map((e) => SlopeCrew.fromJson(e as Map<String, dynamic>))
        .toList();

    return SlopeRushItem(
      slopeFullname: (json['slope_fullname'] ?? "").toString(),
      slopeNickname: (json['slope_nickname'] ?? "").toString(),
      crews: list,
    );
  }

  Map<String, dynamic> toJson() => {
    "slope_fullname": slopeFullname,
    "slope_nickname": slopeNickname,
    "crews": crews.map((e) => e.toJson()).toList(),
  };
}

class SlopeCrew {
  final int? crewId;                // 서버에서 null일 수도 있으니 nullable
  final String crewName;
  final String crewLogoUrl;         // URL은 기본 "" 선호
  final int count;
  final double ratio;

  SlopeCrew({
    this.crewId,
    this.crewName = "",
    this.crewLogoUrl = "",
    this.count = 0,
    this.ratio = 0.0,
  });

  factory SlopeCrew.fromJson(Map<String, dynamic> json) => SlopeCrew(
    crewId: json['crew_id'] == null
        ? null
        : (json['crew_id'] is int
        ? json['crew_id'] as int
        : int.tryParse('${json['crew_id']}')),
    crewName: (json['crew_name'] ?? "").toString(),
    crewLogoUrl: (json['crew_logo_url'] ?? "").toString(),
    count: (json['count'] ?? 0) is int ? json['count'] : int.tryParse('${json['count'] ?? 0}') ?? 0,
    ratio: (json['ratio'] ?? 0.0) is num ? (json['ratio'] as num).toDouble() : double.tryParse('${json['ratio'] ?? 0.0}') ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "crew_id": crewId,
    "crew_name": crewName,
    "crew_logo_url": crewLogoUrl,
    "count": count,
    "ratio": ratio,
  };
}
