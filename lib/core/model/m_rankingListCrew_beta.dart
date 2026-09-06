class RankingListCrewResponseBeta {
  int? count;
  String? next;
  String? previous;
  List<CrewRankingBeta>? results;

  RankingListCrewResponseBeta({this.count, this.next, this.previous, this.results});

  RankingListCrewResponseBeta.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = <CrewRankingBeta>[];
      json['results'].forEach((v) {
        results!.add(CrewRankingBeta.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results?.map((v) => v.toJson()).toList(),
    };
  }
}

class CrewRankingBeta {
  int? rankingCrewBetaId;
  CrewInfoBeta? crewInfo;
  Map<String, dynamic>? passcount;
  Map<String, dynamic>? passcountTime;
  int? overallTotalScore;
  int passcountTotal = 0;  // 합계 값을 저장하는 변수

  CrewRankingBeta({
    this.rankingCrewBetaId,
    this.crewInfo,
    this.passcount,
    this.passcountTime,
    this.overallTotalScore,
  });

  CrewRankingBeta.fromJson(Map<String, dynamic> json) {
    rankingCrewBetaId = json['ranking_crew_beta_id'];
    crewInfo = json['crew_info'] != null ? CrewInfoBeta.fromJson(json['crew_info']) : null;

    // passcount 값들을 처리
    if (json['passcount'] != null && json['passcount'] is Map) {
      passcount = Map<String, dynamic>.from(json['passcount']);
      // passcount 값들의 합계를 구해서 passcountTotal에 저장
      passcountTotal = passcount!.values.fold(0, (sum, value) => sum + (value as int));
    } else {
      passcount = {};
    }

    // passcountTime 데이터를 시간 구간으로 치환
    if (json['passcount_time'] != null && json['passcount_time'] is Map) {
      var originalPasscountTime = Map<String, dynamic>.from(json['passcount_time']);
      // "9", "10", "11" 키 값을 합산하여 00-08 구간에 할당
      int sum00to08 = (originalPasscountTime["9"] ?? 0) +
          (originalPasscountTime["10"] ?? 0) +
          (originalPasscountTime["11"] ?? 0);
      passcountTime = {
        "00-08": sum00to08,  // 9, 10, 11 시간 구간을 합산하여 00-08에 대응
        "08-10": originalPasscountTime["1"],  // 1번 키의 값이 08-10 시간 구간에 대응
        "10-12": originalPasscountTime["2"],
        "12-14": originalPasscountTime["3"],
        "14-16": originalPasscountTime["4"],
        "16-18": originalPasscountTime["5"],
        "18-20": originalPasscountTime["6"],
        "20-22": originalPasscountTime["7"],
        "22-00": originalPasscountTime["8"]
      };
    }

    overallTotalScore = json['overall_total_score'];
  }

  Map<String, dynamic> toJson() {
    return {
      'ranking_crew_beta_id': rankingCrewBetaId,
      'crew_info': crewInfo?.toJson(),
      'passcount': passcount,
      'passcount_time': passcountTime,
      'overall_total_score': overallTotalScore,
    };
  }
}

class CrewInfoBeta {
  int? crewId;
  String? crewName;
  String? crewLogoUrl;
  String? description;
  String? color;
  String? baseResortNickname;

  CrewInfoBeta({this.crewId, this.crewName, this.crewLogoUrl, this.description, this.color, this.baseResortNickname});

  CrewInfoBeta.fromJson(Map<String, dynamic> json) {
    crewId = json['crew_id'];
    crewName = json['crew_name'];
    crewLogoUrl = json['crew_logo_url'];
    description = json['description'];
    color = json['color'];
    baseResortNickname = json['base_resort_nickname'];
  }

  Map<String, dynamic> toJson() {
    return {
      'crew_id': crewId,
      'crew_name': crewName,
      'crew_logo_url': crewLogoUrl,
      'description': description,
      'color': color,
      'base_resort_nickname': baseResortNickname,
    };
  }
}
