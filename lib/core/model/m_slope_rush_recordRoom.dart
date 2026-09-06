class SlopeRushRecordRoomResponse {
  final int resortId;
  final String resortFullname;
  final List<SlopeRushRecordRoomItem> slopeRush;

  SlopeRushRecordRoomResponse({
    this.resortId = 0,
    this.resortFullname = "",
    List<SlopeRushRecordRoomItem>? slopeRush,
  }) : slopeRush = slopeRush ?? const [];

  factory SlopeRushRecordRoomResponse.fromJson(Map<String, dynamic> json) {
    final rawList = (json['slope_occupancy'] ??
        json['slope_Rush'] ??
        const []) as List<dynamic>;

    final list = rawList
        .map((e) =>
        SlopeRushRecordRoomItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return SlopeRushRecordRoomResponse(
      resortId: (json['resort_id'] ?? 0) is int
          ? json['resort_id']
          : int.tryParse('${json['resort_id'] ?? 0}') ?? 0,
      resortFullname: (json['resort_fullname'] ?? "").toString(),
      slopeRush: list,
    );
  }

  Map<String, dynamic> toJson() => {
    "resort_id": resortId,
    "resort_fullname": resortFullname,
    "slope_occupancy": slopeRush.map((e) => e.toJson()).toList(),
  };
}

class SlopeRushRecordRoomItem {
  final String slopeFullname;
  final String slopeNickname;
  final List<SlopeRushRecordRoomCrew> crews;

  SlopeRushRecordRoomItem({
    this.slopeFullname = "",
    this.slopeNickname = "",
    List<SlopeRushRecordRoomCrew>? crews,
  }) : crews = crews ?? const [];

  factory SlopeRushRecordRoomItem.fromJson(Map<String, dynamic> json) {
    final list = (json['crews'] as List<dynamic>? ?? [])
        .map((e) =>
        SlopeRushRecordRoomCrew.fromJson(e as Map<String, dynamic>))
        .toList();

    return SlopeRushRecordRoomItem(
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

class SlopeRushRecordRoomCrew {
  final int? crewId;
  final String crewName;
  final String crewLogoUrl;
  final String description;
  final int count;
  final double ratio;

  SlopeRushRecordRoomCrew({
    this.crewId,
    this.crewName = "",
    this.crewLogoUrl = "",
    this.description = "",
    this.count = 0,
    this.ratio = 0.0,
  });

  factory SlopeRushRecordRoomCrew.fromJson(Map<String, dynamic> json) =>
      SlopeRushRecordRoomCrew(
        crewId: json['crew_id'] == null
            ? null
            : (json['crew_id'] is int
            ? json['crew_id'] as int
            : int.tryParse('${json['crew_id']}')),
        crewName: (json['crew_name'] ?? "").toString(),
        crewLogoUrl: (json['crew_logo_url'] ?? "").toString(),
        description: (json['description'] ?? "").toString(),
        count: (json['count'] ?? 0) is int
            ? json['count']
            : int.tryParse('${json['count'] ?? 0}') ?? 0,
        ratio: (json['ratio'] ?? 0.0) is num
            ? (json['ratio'] as num).toDouble()
            : double.tryParse('${json['ratio'] ?? 0.0}') ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
    "crew_id": crewId,
    "crew_name": crewName,
    "crew_logo_url": crewLogoUrl,
    "description": description,
    "count": count,
    "ratio": ratio,
  };
}
