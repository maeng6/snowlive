class RankingListIndivResponseBeta {
  int? count;
  String? next;
  String? previous;
  List<RankingUserBeta> results;

  RankingListIndivResponseBeta({
    this.count,
    this.next,
    this.previous,
    List<RankingUserBeta>? results,
  }) : results = results ?? [];

  RankingListIndivResponseBeta.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        next = json['next'],
        previous = json['previous'],
        results = (json['results'] as List<dynamic>?)
            ?.map((v) => RankingUserBeta.fromJson(v))
            .toList() ??
            [];
}

class RankingUserBeta {
  int? rankingIndivBetaId;
  UserInfoBeta? userInfo;
  int? resortId;
  Map<String, dynamic>? passcount;
  Map<String, dynamic>? passcountTime;
  int? resortTotalScore;

  RankingUserBeta({
    this.rankingIndivBetaId,
    this.userInfo,
    this.resortId,
    this.passcount,
    this.passcountTime,
    this.resortTotalScore,
  });

  RankingUserBeta.fromJson(Map<String, dynamic> json) {
    rankingIndivBetaId = json['ranking_indiv_beta_id'];
    userInfo = json['user_info'] != null
        ? UserInfoBeta.fromJson(json['user_info'])
        : null;
    resortId = json['resort_id'];
    passcount = json['passcount'] != null
        ? Map<String, dynamic>.from(json['passcount'])
        : null;
    passcountTime = json['passcount_time'] != null
        ? Map<String, dynamic>.from(json['passcount_time'])
        : null;
    resortTotalScore = json['resort_total_score'];
  }
}

class UserInfoBeta {
  int? userId;
  String? displayName;
  String? profileImageUrlUser;
  String? crewName;
  String? resortNickname;

  UserInfoBeta({
    this.userId,
    this.displayName,
    this.profileImageUrlUser,
    this.crewName,
    this.resortNickname,
  });

  UserInfoBeta.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    crewName = json['crew_name'];
    resortNickname = json['resort_nickname'];
  }
}
