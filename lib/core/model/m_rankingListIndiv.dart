class RankingListIndivResponse {
  MyRankingInfo? myRankingInfo;
  Results? results; // Results 클래스를 사용하여 results를 저장

  RankingListIndivResponse({this.myRankingInfo, this.results});

  RankingListIndivResponse.fromJson(Map<String, dynamic> json) {
    // 비로그인(게스트) 요청에서는 my_ranking_info가 없을 수 있어 null 가드를 둔다.
    myRankingInfo = json['my_ranking_info'] != null ? MyRankingInfo.fromJson(json['my_ranking_info']) : null;
    results = json['results'] != null ? Results.fromJson(json['results']) : Results();
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
  int? resortTotalScore;
  int? resortRank;
  String? primaryColor;
  String? secondaryColor;
  String? tierNameKor;
  String? tierNameEng;

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
    this.primaryColor,
    this.secondaryColor,
    this.tierNameKor,
    this.tierNameEng,
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
    resortTotalScore = json['resort_total_score']?.round() ?? 0;
    resortRank = json['resort_rank'] ?? 0;
    primaryColor = json['primary_color'] ?? '3D83ED';
    secondaryColor = json['secondary_color'] ?? 'F0F6FF';
    tierNameKor = json['tier_name_kor'] ?? '';
    tierNameEng = json['tier_name_eng'] ?? '';
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
  int? resortTotalScore;
  int? resortRank;
  String? primaryColor;
  String? secondaryColor;
  String? tierNameKor;
  String? tierNameEng;

  /// 어제(직전 집계) 대비 순위 변동. 양수면 상승(▲), 음수면 하락(▼), null이면 표시 없음.
  /// 홈 `오늘의 랭킹`의 화살표가 이걸 쓴다. 서버가 아직 안 주면 null이라 화살표가 없다.
  int? rankChange;

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
    this.primaryColor,
    this.secondaryColor,
    this.tierNameKor,
    this.tierNameEng,
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
    resortTotalScore = json['resort_total_score']?.round();
    resortRank = json['resort_rank'];
    primaryColor = json['primary_color'] ?? '3D83ED';
    secondaryColor = json['secondary_color'] ?? 'F0F6FF';
    tierNameKor = json['tier_name_kor'] ?? '';
    tierNameEng = json['tier_name_eng'] ?? '';
    rankChange = json['rank_change'];
  }
}
