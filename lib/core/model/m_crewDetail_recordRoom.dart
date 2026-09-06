class CrewDetailResponse_recordRoom {
  CrewDetailInfo_recordRoom? crewDetailInfo;
  SeasonRankingInfo_recordRoom? seasonRankingInfo;

  CrewDetailResponse_recordRoom({this.crewDetailInfo, this.seasonRankingInfo});

  CrewDetailResponse_recordRoom.fromJson(Map<String, dynamic> json) {
    crewDetailInfo = json['crew_detail_info'] != null
        ? CrewDetailInfo_recordRoom.fromJson(json['crew_detail_info'])
        : null;
    seasonRankingInfo = json['season_ranking_info'] != null
        ? SeasonRankingInfo_recordRoom.fromJson(json['season_ranking_info'])
        : null;
  }
}

class CrewDetailInfo_recordRoom {
  int? crewId;
  String? crewIdTemp;
  String? crewName;
  String? crewLogoUrl;
  String? color;
  bool? iskusbf;
  bool? revealInSearch;
  String? description;
  String? createdDate;
  bool? permissionJoin;
  bool? permissionDesc;
  bool? permissionNotice;
  bool? permissionSche;
  int? baseResortId;
  String? baseResortNickname;
  String? baseResortFullname;
  int? crewMemberTotal;
  String? notice;
  int? crewLeaderUserId;
  String? crewLeaderDisplayName;

  CrewDetailInfo_recordRoom({
    this.crewId,
    this.crewIdTemp,
    this.crewName,
    this.crewLogoUrl,
    this.color,
    this.iskusbf,
    this.revealInSearch,
    this.description,
    this.createdDate,
    this.permissionJoin,
    this.permissionDesc,
    this.permissionNotice,
    this.permissionSche,
    this.baseResortId,
    this.baseResortNickname,
    this.baseResortFullname,
    this.crewMemberTotal,
    this.notice,
    this.crewLeaderUserId,
    this.crewLeaderDisplayName,
  });

  CrewDetailInfo_recordRoom.fromJson(Map<String, dynamic> json) {
    crewId = json['crew_id'];
    crewIdTemp = json['crew_id_temp'];
    crewName = json['crew_name'];
    crewLogoUrl = json['crew_logo_url'];
    color = json['color'];
    iskusbf = json['iskusbf'];
    revealInSearch = json['reveal_in_search'];
    description = json['description'];
    createdDate = json['created_date'];
    permissionJoin = json['permission_join'];
    permissionDesc = json['permission_desc'];
    permissionNotice = json['permission_notice'];
    permissionSche = json['permission_sche'];
    baseResortId = json['base_resort_id'];
    baseResortNickname = json['base_resort_nickname'];
    baseResortFullname = json['base_resort_fullname'];
    crewMemberTotal = json['crew_member_total'];
    notice = json['notice'];
    crewLeaderUserId = json['crew_leader_user_id'];
    crewLeaderDisplayName = json['crew_leader_display_name'];
  }
}

class SeasonRankingInfo_recordRoom {
  double? overallTotalScore;
  int? overallRank;
  double? overallRankPercentage;
  String? overallTierIconUrl;
  int? totalSlopeCount;
  List<CountInfo_recordRoom>? countInfo;
  Map<String, int>? timeCountInfo;

  SeasonRankingInfo_recordRoom({
    this.overallTotalScore,
    this.overallRank,
    this.overallRankPercentage,
    this.overallTierIconUrl,
    this.totalSlopeCount,
    this.countInfo,
    this.timeCountInfo,
  });

  SeasonRankingInfo_recordRoom.fromJson(Map<String, dynamic> json) {
    overallTotalScore = (json['overall_total_score'] as num?)?.toDouble();
    overallRank = json['overall_rank'];
    overallRankPercentage = (json['overall_rank_percentage'] as num?)?.toDouble();
    overallTierIconUrl = json['overall_tier_icon_url'];
    totalSlopeCount = json['total_slope_count'];

    if (json['count_info'] != null) {
      countInfo = [];
      json['count_info'].forEach((v) {
        countInfo?.add(CountInfo_recordRoom.fromJson(v));
      });
    }

    if (json['time_info'] != null) {
      timeCountInfo = {
        "00-08": json['time_info'][0],
        "08-10": json['time_info'][1],
        "10-12": json['time_info'][2],
        "12-14": json['time_info'][3],
        "14-16": json['time_info'][4],
        "16-18": json['time_info'][5],
        "18-20": json['time_info'][6],
        "20-22": json['time_info'][7],
        "22-00": json['time_info'][8],
      };
    } else {
      timeCountInfo = {};
    }
  }
}

class CountInfo_recordRoom {
  String? slope;
  int? count;

  CountInfo_recordRoom({this.slope, this.count});

  CountInfo_recordRoom.fromJson(Map<String, dynamic> json) {
    slope = json['slope'];
    count = json['count'];
  }
}