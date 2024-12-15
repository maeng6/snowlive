class RankingListIndivResponse {
  MyRankingInfo? myRankingInfo;
  Results? results;

  RankingListIndivResponse({this.myRankingInfo, this.results});

  RankingListIndivResponse.fromJson(Map<String, dynamic> json) {
    myRankingInfo = MyRankingInfo.fromJson(json['my_ranking_info']);
    results = Results.fromJson(json['results']);
  }

  Map<String, dynamic> toJson() {
    return {
      'my_ranking_info': myRankingInfo?.toJson(),
      'results': results?.toJson(),
    };
  }
}

class MyRankingInfo {
  int? userId;
  String? displayName;
  String? profileImageUrlUser;
  String? resortNickname;
  String? crewName;
  int? overallTotalScore;
  int? overallRank;
  double? overallRankPercentage;
  String? overallTierIconUrl;
  String? primaryColor;
  String? secondaryColor;
  String? tierNameKor;
  String? tierNameEng; // 추가된 필드
  int? resortTotalScore;
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
    this.primaryColor,
    this.secondaryColor,
    this.tierNameKor,
    this.tierNameEng, // 추가된 필드
    this.resortTotalScore,
    this.resortRank,
  });

  MyRankingInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'] ?? '';
    resortNickname = json['resort_nickname'] ?? '-';
    crewName = json['crew_name'] ?? '';
    overallTotalScore = json['overall_total_score']?.round() ?? 0;
    overallRank = json['overall_rank'] ?? 0;
    overallRankPercentage = json['overall_rank_percentage']?.toDouble() ?? 0.0;
    overallTierIconUrl = json['overall_tier_icon_url'] ?? '';
    primaryColor = json['primary_color'] ?? '#FFFFFF';
    secondaryColor = json['secondary_color'] ?? '#000000';
    tierNameKor = json['tier_name_kor'] ?? 'N/A';
    tierNameEng = json['tier_name_eng']?.toUpperCase() ?? 'N/A'; // 추가된 필드
    resortTotalScore = json['resort_total_score']?.round() ?? 0;
    resortRank = json['resort_rank'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'profile_image_url_user': profileImageUrlUser,
      'resort_nickname': resortNickname,
      'crew_name': crewName,
      'overall_total_score': overallTotalScore,
      'overall_rank': overallRank,
      'overall_rank_percentage': overallRankPercentage,
      'overall_tier_icon_url': overallTierIconUrl,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'tier_name_kor': tierNameKor,
      'tier_name_eng': tierNameEng, // 추가된 필드
      'resort_total_score': resortTotalScore,
      'resort_rank': resortRank,
    };
  }
}

class Results {
  int? count;
  String? next;
  String? previous;
  List<RankingUser> rankingUsers;

  Results({this.count, this.next, this.previous, List<RankingUser>? rankingUsers})
      : rankingUsers = rankingUsers ?? [];

  Results.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        next = json['next'],
        previous = json['previous'],
        rankingUsers = (json['results'] as List<dynamic>?)
            ?.map((v) => RankingUser.fromJson(v))
            .toList() ?? [];

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': rankingUsers.map((rankingUser) => rankingUser.toJson()).toList(),
    };
  }
}

class RankingUser {
  int? userId;
  String? displayName;
  String? profileImageUrlUser;
  String? resortNickname;
  String? crewName;
  int? overallTotalScore;
  int? overallRank;
  double? overallRankPercentage;
  String? overallTierIconUrl;
  String? primaryColor;
  String? secondaryColor;
  String? tierNameKor;
  String? tierNameEng; // 추가된 필드
  int? resortTotalScore;
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
    this.primaryColor,
    this.secondaryColor,
    this.tierNameKor,
    this.tierNameEng, // 추가된 필드
    this.resortTotalScore,
    this.resortRank,
  });

  RankingUser.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    resortNickname = json['resort_nickname'];
    crewName = json['crew_name'];
    overallTotalScore = json['overall_total_score']?.round();
    overallRank = json['overall_rank'];
    overallRankPercentage = json['overall_rank_percentage']?.toDouble();
    overallTierIconUrl = json['overall_tier_icon_url'];
    primaryColor = json['primary_color'] ?? '#FFFFFF';
    secondaryColor = json['secondary_color'] ?? '#000000';
    tierNameKor = json['tier_name_kor'] ?? 'N/A';
    tierNameEng = json['tier_name_eng']?.toUpperCase() ?? 'N/A'; // 추가된 필드
    resortTotalScore = json['resort_total_score']?.round();
    resortRank = json['resort_rank'];
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'profile_image_url_user': profileImageUrlUser,
      'resort_nickname': resortNickname,
      'crew_name': crewName,
      'overall_total_score': overallTotalScore,
      'overall_rank': overallRank,
      'overall_rank_percentage': overallRankPercentage,
      'overall_tier_icon_url': overallTierIconUrl,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'tier_name_kor': tierNameKor,
      'tier_name_eng': tierNameEng, // 추가된 필드
      'resort_total_score': resortTotalScore,
      'resort_rank': resortRank,
    };
  }
}
