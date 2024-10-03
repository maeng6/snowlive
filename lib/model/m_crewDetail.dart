class CrewDetailResponse {
  CrewDetailInfo? crewDetailInfo;
  SeasonRankingInfo? seasonRankingInfo;

  CrewDetailResponse({this.crewDetailInfo, this.seasonRankingInfo});

  CrewDetailResponse.fromJson(Map<String, dynamic> json) {
    crewDetailInfo = json['crew_detail_info'] != null
        ? CrewDetailInfo.fromJson(json['crew_detail_info'])
        : null;
    seasonRankingInfo = json['season_ranking_info'] != null
        ? SeasonRankingInfo.fromJson(json['season_ranking_info'])
        : null;
  }
}

class CrewDetailInfo {
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
  int? crewMemberTotal;
  String? notice;
  int? crewLeaderUserId; // 크루 리더 user_id 필드 추가

  CrewDetailInfo({
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
    this.crewMemberTotal,
    this.notice,
    this.crewLeaderUserId, // 크루 리더 user_id 필드 추가
  });

  CrewDetailInfo.fromJson(Map<String, dynamic> json) {
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
    crewMemberTotal = json['crew_member_total'];
    notice = json['notice'];
    crewLeaderUserId = json['crew_leader_user_id']; // 크루 리더 user_id 초기화
  }
}

class SeasonRankingInfo {
  double? overallTotalScore;
  int? overallRank;
  double? overallRankPercentage;
  String? overallTierIconUrl;
  int? totalSlopeCount;
  List<CountInfo>? countInfo;
  Map<String, int>? timeCountInfo;

  SeasonRankingInfo({
    this.overallTotalScore,
    this.overallRank,
    this.overallRankPercentage,
    this.overallTierIconUrl,
    this.totalSlopeCount,
    this.countInfo,
    this.timeCountInfo,
  });

  SeasonRankingInfo.fromJson(Map<String, dynamic> json) {
    overallTotalScore = (json['overall_total_score'] as num?)?.toDouble();
    overallRank = json['overall_rank'];
    overallRankPercentage = (json['overall_rank_percentage'] as num?)?.toDouble();
    overallTierIconUrl = json['overall_tier_icon_url'];
    totalSlopeCount = json['total_slope_count'];

    if (json['count_info'] != null) {
      countInfo = [];
      json['count_info'].forEach((v) {
        countInfo?.add(CountInfo.fromJson(v));
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

class CountInfo {
  String? slope;
  int? count;

  CountInfo({this.slope, this.count});

  CountInfo.fromJson(Map<String, dynamic> json) {
    slope = json['slope'];
    count = json['count'];
  }
}
