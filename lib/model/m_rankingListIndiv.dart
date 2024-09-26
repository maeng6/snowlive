class RankingListIndivResponse {
  MyRankingInfo? myRankingInfo;
  Results? results; // Results 클래스를 사용하여 results를 저장

  RankingListIndivResponse({this.myRankingInfo, this.results});

  RankingListIndivResponse.fromJson(Map<String, dynamic> json) {
    myRankingInfo = MyRankingInfo.fromJson(json['my_ranking_info']);
    results = Results.fromJson(json['results']); // results를 Results 클래스로 변환
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
    userId = json['user_id'] ; // 기본값 0
    displayName = json['display_name'] ; // 기본값 'Unknown'
    profileImageUrlUser = json['profile_image_url_user'] ?? ''; // 빈 문자열
    resortNickname = json['resort_nickname'] ?? '-'; // 기본값 'N/A'
    crewName = json['crew_name'] ?? ''; // 기본값 'No Crew'
    overallTotalScore = json['overall_total_score']?.toInt() ?? 0; // 기본값 0
    overallRank = json['overall_rank'] ?? 0; // 기본값 0
    overallRankPercentage = json['overall_rank_percentage']?.toDouble() ?? 0.0; // 기본값 0.0
    overallTierIconUrl = json['overall_tier_icon_url'] ?? ''; // 빈 문자열
    resortTotalScore = json['resort_total_score']?.toInt() ?? 0; // 기본값 0
    resortRank = json['resort_rank'] ?? 0; // 기본값 0
  }
}

class Results {
  int? count;
  String? next;
  String? previous;
  List<RankingUser> rankingUsers; // 기본값을 빈 리스트로 설정

  Results({this.count, this.next, this.previous, List<RankingUser>? rankingUsers})
      : rankingUsers = rankingUsers ?? []; // rankingUsers를 빈 리스트로 초기화

  Results.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        next = json['next'],
        previous = json['previous'],
        rankingUsers = (json['results'] as List<dynamic>?)
            ?.map((v) => RankingUser.fromJson(v))
            .toList() ?? []; // JSON에서 results를 가져와 List로 변환
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
    overallTotalScore = json['overall_total_score']?.toInt();
    overallRank = json['overall_rank'];
    overallRankPercentage = json['overall_rank_percentage']?.toDouble();
    overallTierIconUrl = json['overall_tier_icon_url'];
    resortTotalScore = json['resort_total_score']?.toInt();
    resortRank = json['resort_rank'];
  }
}
