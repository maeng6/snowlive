class CrewRecordRoomResponse {
  List<CrewRidingRecord> records;

  CrewRecordRoomResponse({required this.records});

  CrewRecordRoomResponse.fromJson(List<dynamic>? json)
      : records = json != null
      ? json.map((item) => CrewRidingRecord.fromJson(item)).toList()
      : []; // null일 경우 빈 리스트로 처리
}

class CrewRidingRecord {
  String? date;
  double? totalScore;
  int? totalCount;
  int? memberCount;
  int? withinBoundaryCount;
  List<int>? timeInfo;
  List<TodayMemberInfo>? todayMemberInfo;
  Map<String, int>? timeCountInfo; // 추가된 부분

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
        .toList() ?? [];

    // time_info 배열을 시간대 레이블로 변환
    if (timeInfo != null) {
      timeCountInfo = {
        "00-08": timeInfo![0],
        "08-10": timeInfo![1],
        "10-12": timeInfo![2],
        "12-14": timeInfo![3],
        "14-16": timeInfo![4],
        "16-18": timeInfo![5],
        "18-20": timeInfo![6],
        "20-22": timeInfo![7],
        "22-00": timeInfo![8],
      };
    } else {
      timeCountInfo = {};
    }
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
