class RankingListIndivResponse_recordRoom {
  MyRankingInfo_recordRoom? myRankingInfo;
  Results_recordRoom? results;

  RankingListIndivResponse_recordRoom({this.myRankingInfo, this.results});

  RankingListIndivResponse_recordRoom.fromJson(Map<String, dynamic> json) {
    myRankingInfo = MyRankingInfo_recordRoom.fromJson(json['my_ranking_info']);
    results = Results_recordRoom.fromJson(json['results']);
  }
}

class MyRankingInfo_recordRoom {
  int? userId;
  String? displayName;
  String? profileImageUrlUser;
  String? resortNickname;
  String? crewName;
  int? overallTotalScore;
  int? overallRank;
  double? overallRankPercentage;
  String? overallTierIconUrl;
  int? resortTotalScore;
  int? resortRank;
  String? primaryColor;
  String? secondaryColor;
  String? tierNameKor;
  String? tierNameEng;

  MyRankingInfo_recordRoom({
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
    this.primaryColor,
    this.secondaryColor,
    this.tierNameKor,
    this.tierNameEng,
  });

  MyRankingInfo_recordRoom.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'] ?? '';
    resortNickname = json['resort_nickname'] ?? '-';
    crewName = json['crew_name'] ?? '';
    overallTotalScore = json['overall_total_score']?.round() ?? 0;
    overallRank = json['overall_rank'] ?? 0;
    overallRankPercentage = json['overall_rank_percentage']?.toDouble() ?? 0.0;
    overallTierIconUrl = json['overall_tier_icon_url'] ?? '';
    resortTotalScore = json['resort_total_score']?.round() ?? 0;
    resortRank = json['resort_rank'] ?? 0;
    primaryColor = json['primary_color'] ?? '3D83ED';
    secondaryColor = json['secondary_color'] ?? 'F0F6FF';
    tierNameKor = json['tier_name_kor'] ?? '';
    tierNameEng = json['tier_name_eng'] ?? '';
  }
}

class Results_recordRoom {
  int? count;
  String? next;
  String? previous;
  List<RankingUser_recordRoom> rankingUsers;

  Results_recordRoom({this.count, this.next, this.previous, List<RankingUser_recordRoom>? rankingUsers})
      : rankingUsers = rankingUsers ?? [];

  Results_recordRoom.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        next = json['next'],
        previous = json['previous'],
        rankingUsers = (json['results'] as List<dynamic>?)
            ?.map((v) => RankingUser_recordRoom.fromJson(v))
            .toList() ?? [];
}

class RankingUser_recordRoom {
  int? userId;
  String? displayName;
  String? profileImageUrlUser;
  String? resortNickname;
  String? crewName;
  int? overallTotalScore;
  int? overallRank;
  double? overallRankPercentage;
  String? overallTierIconUrl;
  int? resortTotalScore;
  int? resortRank;
  String? primaryColor;
  String? secondaryColor;
  String? tierNameKor;
  String? tierNameEng;

  RankingUser_recordRoom({
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
    this.primaryColor,
    this.secondaryColor,
    this.tierNameKor,
    this.tierNameEng,
  });

  RankingUser_recordRoom.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    resortNickname = json['resort_nickname'];
    crewName = json['crew_name'];
    overallTotalScore = json['overall_total_score']?.round();
    overallRank = json['overall_rank'];
    overallRankPercentage = json['overall_rank_percentage']?.toDouble();
    overallTierIconUrl = json['overall_tier_icon_url'];
    resortTotalScore = json['resort_total_score']?.round();
    resortRank = json['resort_rank'];
    primaryColor = json['primary_color'] ?? '3D83ED';
    secondaryColor = json['secondary_color'] ?? 'F0F6FF';
    tierNameKor = json['tier_name_kor'] ?? '';
    tierNameEng = json['tier_name_eng'] ?? '';
  }
}
