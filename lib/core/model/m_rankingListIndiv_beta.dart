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
  int passcountTotal = 0;  // 합계 값을 저장하는 변수

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

    // passcountTime 데이터를 시간 구간으로 치환
    if (json['passcount_time'] != null) {
      var originalPasscountTime = Map<String, dynamic>.from(json['passcount_time']);
      // "9", "10", "11" 키 값을 합산하여 00-08 구간에 할당
      int sum00to08 = (originalPasscountTime["9"] ?? 0) +
          (originalPasscountTime["10"] ?? 0) +
          (originalPasscountTime["11"] ?? 0);
      passcountTime = {
        "00-08": sum00to08,  // 1번 키의 값이 00-08 시간 구간에 대응
        "08-10": originalPasscountTime["1"],  // 2번 키의 값이 08-10 시간 구간에 대응
        "10-12": originalPasscountTime["2"],
        "12-14": originalPasscountTime["3"],
        "14-16": originalPasscountTime["4"],
        "16-18": originalPasscountTime["5"],
        "18-20": originalPasscountTime["6"],
        "20-22": originalPasscountTime["7"],
        "22-00": originalPasscountTime["8"]
      };
    }

    // passcount 값들의 합계를 구해서 passcountTotal에 저장
    if (passcount != null) {
      passcountTotal = passcount!.values.fold(0, (sum, value) => sum + (value as int));
    }
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
