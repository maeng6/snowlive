class CrewRankingResponse_recordRoom {
  List<CrewRanking_recordRoom>? rankingResults;

  CrewRankingResponse_recordRoom({this.rankingResults});

  CrewRankingResponse_recordRoom.fromJson(Map<String, dynamic> json) {
    if (json['ranking_results'] != null) {
      rankingResults = (json['ranking_results'] as List)
          .map((item) => CrewRanking_recordRoom.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      rankingResults = [];
    }
  }
}

class CrewRanking_recordRoom {
  int? userId;
  double? totalScore;
  String? displayName;
  String? profileImageUrlUser;
  String? stateMsg;
  bool? withinBoundary;
  bool? revealWb;
  int? overallRank;
  double? overallRankPercentage;
  String? tierIconUrl;

  CrewRanking_recordRoom({
    this.userId,
    this.totalScore,
    this.displayName,
    this.profileImageUrlUser,
    this.stateMsg,
    this.withinBoundary,
    this.revealWb,
    this.overallRank,
    this.overallRankPercentage,
    this.tierIconUrl,
  });

  CrewRanking_recordRoom.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    totalScore = (json['total_score'] as num?)?.toDouble();
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    stateMsg = json['state_msg'];
    withinBoundary = json['within_boundary'];
    revealWb = json['reveal_wb'];
    overallRank = json['overall_rank'];
    overallRankPercentage = (json['overall_rank_percentage'] as num?)?.toDouble();
    tierIconUrl = json['tier_icon_url'];
  }
}
