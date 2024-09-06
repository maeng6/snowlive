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
  }
}

class SeasonRankingInfo {
  double? overallTotalScore;
  int? overallRank;
  double? overallRankPercentage;
  String? overallTierIconUrl;
  int? totalSlopeCount;
  List<CountInfo>? countInfo;
  List<int>? timeInfo;

  SeasonRankingInfo({
    this.overallTotalScore,
    this.overallRank,
    this.overallRankPercentage,
    this.overallTierIconUrl,
    this.totalSlopeCount,
    this.countInfo,
    this.timeInfo,
  });

  SeasonRankingInfo.fromJson(Map<String, dynamic> json) {
    overallTotalScore = json['overall_total_score'];
    overallRank = json['overall_rank'];
    overallRankPercentage = json['overall_rank_percentage'];
    overallTierIconUrl = json['overall_tier_icon_url'];
    totalSlopeCount = json['total_slope_count'];
    if (json['count_info'] != null) {
      countInfo = [];
      json['count_info'].forEach((v) {
        countInfo?.add(CountInfo.fromJson(v));
      });
    }
    if (json['time_info'] != null) {
      timeInfo = List<int>.from(json['time_info']);
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
