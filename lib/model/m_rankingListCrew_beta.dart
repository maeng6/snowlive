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

  CrewRankingBeta({this.rankingCrewBetaId, this.crewInfo, this.passcount, this.passcountTime, this.overallTotalScore});

  CrewRankingBeta.fromJson(Map<String, dynamic> json) {
    rankingCrewBetaId = json['ranking_crew_beta_id'];
    crewInfo = json['crew_info'] != null ? CrewInfoBeta.fromJson(json['crew_info']) : null;


    if (json['passcount'] != null && json['passcount'] is Map) {
      passcount = Map<String, dynamic>.from(json['passcount']);
    } else {
      passcount = {};
    }

    if (json['passcount_time'] != null && json['passcount_time'] is Map) {
      passcountTime = Map<String, dynamic>.from(json['passcount_time']);
    } else {
      passcountTime = {};
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
