class CrewRidingRecordResponse {
  List<CrewRidingRecord>? records;

  CrewRidingRecordResponse({this.records});

  CrewRidingRecordResponse.fromJson(List<dynamic> json) {
    records = json.map((item) => CrewRidingRecord.fromJson(item)).toList();
  }
}

class CrewRidingRecord {
  String? date;
  double? totalScore;
  int? totalCount;
  int? memberCount;
  int? withinBoundaryCount;
  List<int>? timeInfo;
  List<TodayMemberInfo>? todayMemberInfo;

  CrewRidingRecord({
    this.date,
    this.totalScore,
    this.totalCount,
    this.memberCount,
    this.withinBoundaryCount,
    this.timeInfo,
    this.todayMemberInfo,
  });

  CrewRidingRecord.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    totalScore = json['total_score']?.toDouble();
    totalCount = json['total_count'];
    memberCount = json['member_count'];
    withinBoundaryCount = json['within_boundary_count'];
    timeInfo = List<int>.from(json['time_info'] ?? []);
    todayMemberInfo = (json['today_member_info'] as List<dynamic>?)
        ?.map((item) => TodayMemberInfo.fromJson(item))
        .toList();
  }
}

class TodayMemberInfo {
  int? userId;
  String? displayName;
  String? profileImageUrlUser;
  bool? withinBoundary;
  bool? revealWb;
  double? totalScore;

  TodayMemberInfo({
    this.userId,
    this.displayName,
    this.profileImageUrlUser,
    this.withinBoundary,
    this.revealWb,
    this.totalScore,
  });

  TodayMemberInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    withinBoundary = json['within_boundary'];
    revealWb = json['reveal_wb'];
    totalScore = json['total_score']?.toDouble();
  }
}
