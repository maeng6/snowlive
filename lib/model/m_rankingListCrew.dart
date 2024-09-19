class RankingListCrewModel {
  MyCrewRankingInfo? myCrewRankingInfo;
  RankingResults? rankingResults; // 변경: List 대신 RankingResults 객체로 수정

  RankingListCrewModel({this.myCrewRankingInfo, this.rankingResults});

  RankingListCrewModel.fromJson(Map<String, dynamic> json) {
    myCrewRankingInfo = json['my_crew_ranking_info'] != null
        ? MyCrewRankingInfo.fromJson(json['my_crew_ranking_info'])
        : null;
    // JSON에서 rankingResults를 가져와서 객체로 변환
    rankingResults = json['results'] != null
        ? RankingResults.fromJson(json['results'])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'my_crew_ranking_info': myCrewRankingInfo?.toJson(),
      'results': rankingResults?.toJson(),
    };
  }
}

class MyCrewRankingInfo {
  MyCrewRankingInfo();

  MyCrewRankingInfo.fromJson(Map<String, dynamic> json) {
    // 실제 구조에 따라 구현
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}

class RankingResults {
  int? count;
  String? next;
  String? previous;
  List<CrewRanking>? results;

  RankingResults({this.count, this.next, this.previous, this.results});

  RankingResults.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results?.add(CrewRanking.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results?.map((crew) => crew.toJson()).toList(),
    };
  }
}

class CrewRanking {
  int? crewId;
  String? crewName;
  String? crewLogoUrl;
  String? description;
  String? color;
  String? baseResortNickname;
  double? overallTotalScore;
  int? overallRank;
  double? overallRankPercentage;
  String? overallTierIconUrl;
  double? resortTotalScore;
  int? resortRank;

  CrewRanking({
    this.crewId,
    this.crewName,
    this.crewLogoUrl,
    this.description,
    this.color,
    this.baseResortNickname,
    this.overallTotalScore,
    this.overallRank,
    this.overallRankPercentage,
    this.overallTierIconUrl,
    this.resortTotalScore,
    this.resortRank,
  });

  CrewRanking.fromJson(Map<String, dynamic> json) {
    crewId = json['crew_id'];
    crewName = json['crew_name'];
    crewLogoUrl = json['crew_logo_url'];
    description = json['description'];
    color = json['color'];
    baseResortNickname = json['base_resort_nickname'];
    overallTotalScore = json['overall_total_score']?.toDouble();
    overallRank = json['overall_rank'];
    overallRankPercentage = json['overall_rank_percentage']?.toDouble();
    overallTierIconUrl = json['overall_tier_icon_url'];
    resortTotalScore = json['resort_total_score']?.toDouble();
    resortRank = json['resort_rank'];
  }

  Map<String, dynamic> toJson() {
    return {
      'crew_id': crewId,
      'crew_name': crewName,
      'crew_logo_url': crewLogoUrl,
      'description': description,
      'color': color,
      'base_resort_nickname': baseResortNickname,
      'overall_total_score': overallTotalScore,
      'overall_rank': overallRank,
      'overall_rank_percentage': overallRankPercentage,
      'overall_tier_icon_url': overallTierIconUrl,
      'resort_total_score': resortTotalScore,
      'resort_rank': resortRank,
    };
  }
}
