class CrewRankingResponse {
  List<CrewRanking>? rankingResults;

  CrewRankingResponse({this.rankingResults});

  // JSON 데이터를 파싱하는 메서드
  CrewRankingResponse.fromJson(Map<String, dynamic> json) {
    if (json['ranking_results'] != null) {
      rankingResults = (json['ranking_results'] as List)
          .map((item) => CrewRanking.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      rankingResults = [];
    }
  }
}

class CrewRanking {
  int? userId;
  double? totalScore;
  String? displayName;
  String? profileImageUrlUser;
  String? stateMsg;
  bool? withinBoundary;
  bool? revealWb;

  CrewRanking({
    this.userId,
    this.totalScore,
    this.displayName,
    this.profileImageUrlUser,
    this.stateMsg,
    this.withinBoundary,
    this.revealWb,
  });

  // JSON 데이터를 파싱하는 메서드
  CrewRanking.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    totalScore = (json['total_score'] as num?)?.toDouble();
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    stateMsg = json['state_msg'];
    withinBoundary = json['within_boundary'];
    revealWb = json['reveal_wb'];
  }
}
