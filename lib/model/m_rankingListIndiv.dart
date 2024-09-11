class RankingListIndivResponse {
  MyRankingInfo? myRankingInfo;
  Results? results;

  RankingListIndivResponse({this.myRankingInfo, this.results});

  RankingListIndivResponse.fromJson(Map<String, dynamic> json) {
    myRankingInfo = json['my_ranking_info'] != null
        ? MyRankingInfo.fromJson(json['my_ranking_info'])
        : null;
    results = json['results'] != null ? Results.fromJson(json['results']) : null;
  }
}

class MyRankingInfo {
  int? userId;
  String? displayName;
  String? profileImageUrlUser;
  String? resortNickname;
  String? crewName;
  double? overallTotalScore;
  int? overallRank;
  double? overallRankPercentage;
  String? overallTierIconUrl;
  double? resortTotalScore;
  int? resortRank;

  MyRankingInfo({
    this.userId,
    this.displayName,
    this.profileImageUrlUser,
    this.resortNickname,
    this.crewName,
    this.overallTotalScore,
    this.overallRank,
    this.overallRankPercentage,
    this.overallTierIconUrl,
    this.resortTotalScore,
    this.resortRank,
  });

  MyRankingInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    resortNickname = json['resort_nickname'];
    crewName = json['crew_name'];
    overallTotalScore = json['overall_total_score']?.toDouble();
    overallRank = json['overall_rank'];
    overallRankPercentage = json['overall_rank_percentage']?.toDouble();
    overallTierIconUrl = json['overall_tier_icon_url'];
    resortTotalScore = json['resort_total_score']?.toDouble();
    resortRank = json['resort_rank'];
  }
}

class Results {
  int? count;
  String? next;
  String? previous;
  List<RankingUser>? rankingUsers;

  Results({this.count, this.next, this.previous, this.rankingUsers});

  Results.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      rankingUsers = [];
      json['results'].forEach((v) {
        rankingUsers?.add(RankingUser.fromJson(v));
      });
    }
  }
}

class RankingUser {
  int? userId;
  String? displayName;
  String? profileImageUrlUser;
  String? resortNickname;
  String? crewName;
  double? overallTotalScore;
  int? overallRank;
  double? overallRankPercentage;
  String? overallTierIconUrl;
  double? resortTotalScore;
  int? resortRank;

  RankingUser({
    this.userId,
    this.displayName,
    this.profileImageUrlUser,
    this.resortNickname,
    this.crewName,
    this.overallTotalScore,
    this.overallRank,
    this.overallRankPercentage,
    this.overallTierIconUrl,
    this.resortTotalScore,
    this.resortRank,
  });

  RankingUser.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    resortNickname = json['resort_nickname'];
    crewName = json['crew_name'];
    overallTotalScore = json['overall_total_score']?.toDouble();
    overallRank = json['overall_rank'];
    overallRankPercentage = json['overall_rank_percentage']?.toDouble();
    overallTierIconUrl = json['overall_tier_icon_url'];
    resortTotalScore = json['resort_total_score']?.toDouble();
    resortRank = json['resort_rank'];
  }
}
