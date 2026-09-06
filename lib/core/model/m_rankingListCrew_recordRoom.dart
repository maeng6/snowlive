class RankingListCrewModel_recordRoom {
  MyCrewRankingInfo_recordRoom? myCrewRankingInfo;
  RankingResults_recordRoom? rankingResults;

  RankingListCrewModel_recordRoom({this.myCrewRankingInfo, this.rankingResults});

  RankingListCrewModel_recordRoom.fromJson(Map<String, dynamic> json) {
    myCrewRankingInfo = MyCrewRankingInfo_recordRoom.fromJson(json['my_crew_ranking_info']);
    rankingResults = RankingResults_recordRoom.fromJson(json['results']);
  }

  Map<String, dynamic> toJson() {
    return {
      'my_crew_ranking_info': myCrewRankingInfo?.toJson(),
      'results': rankingResults?.toJson(),
    };
  }
}

class MyCrewRankingInfo_recordRoom {
  int? crewId;
  String? crewName;
  String? crewLogoUrl;
  String? description;
  String? color;
  String? baseResortNickname;
  int? resortTotalScore;
  int? resortRank;
  int? overallTotalScore;
  int? overallRank;
  double? overallRankPercentage;
  String? overallTierIconUrl;

  MyCrewRankingInfo_recordRoom({
    this.crewId,
    this.crewName,
    this.crewLogoUrl,
    this.description,
    this.color,
    this.baseResortNickname,
    this.resortTotalScore,
    this.resortRank,
    this.overallTotalScore,
    this.overallRank,
    this.overallRankPercentage,
    this.overallTierIconUrl,
  });

  MyCrewRankingInfo_recordRoom.fromJson(Map<String, dynamic> json) {
    crewId = json['crew_id'];
    crewName = json['crew_name'];
    if (json['crew_logo_url'] == "") {
      crewLogoUrl = null;
    } else {
      crewLogoUrl = json['crew_logo_url'] ?? null;
    }
    description = json['description'];
    color = json['color'];
    baseResortNickname = json['base_resort_nickname'];
    resortTotalScore = json['resort_total_score']?.round();
    resortRank = json['resort_rank'];
    overallTotalScore = json['overall_total_score']?.round();
    overallRank = json['overall_rank'];
    overallRankPercentage = json['overall_rank_percentage']?.toDouble();
    overallTierIconUrl = json['overall_tier_icon_url'];
  }

  Map<String, dynamic> toJson() {
    return {
      'crew_id': crewId,
      'crew_name': crewName,
      'crew_logo_url': crewLogoUrl,
      'description': description,
      'color': color,
      'base_resort_nickname': baseResortNickname,
      'resort_total_score': resortTotalScore,
      'resort_rank': resortRank,
      'overall_total_score': overallTotalScore,
      'overall_rank': overallRank,
      'overall_rank_percentage': overallRankPercentage,
      'overall_tier_icon_url': overallTierIconUrl,
    };
  }
}

class RankingResults_recordRoom {
  int? count;
  String? next;
  String? previous;
  List<CrewRanking_recordRoom>? results;

  RankingResults_recordRoom({
    this.count,
    this.next,
    this.previous,
    List<CrewRanking_recordRoom>? results,
  }) : results = results ?? [];

  RankingResults_recordRoom.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results?.add(CrewRanking_recordRoom.fromJson(v));
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

class CrewRanking_recordRoom {
  int? crewId;
  String? crewName;
  String? crewLogoUrl;
  String? description;
  String? color;
  String? baseResortNickname;
  int? overallTotalScore;
  int? overallRank;
  double? overallRankPercentage;
  String? overallTierIconUrl;
  int? resortTotalScore;
  int? resortRank;

  CrewRanking_recordRoom({
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

  CrewRanking_recordRoom.fromJson(Map<String, dynamic> json) {
    crewId = json['crew_id'];
    crewName = json['crew_name'];
    crewLogoUrl = json['crew_logo_url'];
    description = json['description'];
    color = json['color'];
    baseResortNickname = json['base_resort_nickname'];
    overallTotalScore = json['overall_total_score']?.round();
    overallRank = json['overall_rank'];
    overallRankPercentage = json['overall_rank_percentage']?.toDouble();
    overallTierIconUrl = json['overall_tier_icon_url'];
    resortTotalScore = json['resort_total_score']?.round();
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
