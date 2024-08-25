class FriendDetailModel {
  late FriendUserInfo friendUserInfo;
  late SeasonRankingInfo seasonRankingInfo;
  late List<CalendarInfo> calendarInfo;

  // 기본 생성자
  FriendDetailModel() {
    friendUserInfo = FriendUserInfo();
    seasonRankingInfo = SeasonRankingInfo();
    calendarInfo = [];
  }

  // fromJson 생성자
  FriendDetailModel.fromJson(Map<String, dynamic> json) {
    friendUserInfo = FriendUserInfo.fromJson(json['friend_user_info']);
    seasonRankingInfo = SeasonRankingInfo.fromJson(json['season_ranking_info']);
    calendarInfo = (json['calender_info'] as List)
        .map((e) => CalendarInfo.fromJson(e))
        .toList();
  }
}

class FriendUserInfo {
  late int userId;
  late String displayName;
  late String profileImageUrlUser;
  late String crewName;
  late String? stateMsg;
  late String favoriteResort;
  late bool withinBoundary;
  late bool revealWb;
  late bool hideProfile;
  late bool areWeFriend;
  late bool bestFriend;

  // 기본 생성자
  FriendUserInfo() {
    userId = 0;
    displayName = '';
    profileImageUrlUser = '';
    crewName = '';
    stateMsg = null;
    favoriteResort = '';
    withinBoundary = false;
    revealWb = false;
    hideProfile = false;
    areWeFriend = false;
    bestFriend = false;
  }

  // fromJson 생성자
  FriendUserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    crewName = json['crew_name'];
    stateMsg = json['state_msg'];
    favoriteResort = json['favorite_resort'];
    withinBoundary = json['within_boundary'];
    revealWb = json['reveal_wb'];
    hideProfile = json['hide_profile'];
    areWeFriend = json['are_we_friend'];
    bestFriend = json['best_friend'];
  }

  void setBestFriend(bool value) {
    bestFriend = value;
  }
}

class SeasonRankingInfo {
  late List<SlopeCountInfo> countInfo;
  late Map<String, dynamic> timeInfo;
  late double overallTotalScore;
  late int overallTotalCount;
  late int overallRank;
  late int timeInfo_maxCount;
  late double overallRankPercentage;
  late String overallTierIconUrl;

  // 기본 생성자
  SeasonRankingInfo() {
    countInfo = [];
    timeInfo = {};
    timeInfo_maxCount = 0;
    overallTotalScore = 0.0;
    overallTotalCount = 0;
    overallRank = 0;
    overallRankPercentage = 0.0;
    overallTierIconUrl = '';
  }

  // fromJson 생성자
  SeasonRankingInfo.fromJson(Map<String, dynamic> json) {
    countInfo = (json['count_info'] as List)
        .map((e) => SlopeCountInfo.fromJson(e))
        .toList();
    timeInfo = {
      "00-08": json['time_info'][0],
      "08-10": json['time_info'][1],
      "10-12": json['time_info'][2],
      "12-14": json['time_info'][3],
      "14-16": json['time_info'][4],
      "16-18": json['time_info'][5],
      "18-20": json['time_info'][6],
      "20-22": json['time_info'][7],
      "22-00": json['time_info'][8],
    };
    timeInfo_maxCount = timeInfo.values.reduce((a, b) => a > b ? a : b);
    overallTotalScore = json['overall_total_score'];
    overallTotalCount = json['overall_total_count'];
    overallRank = json['overall_rank'];
    overallRankPercentage = json['overall_rank_percentage'];
    overallTierIconUrl = json['overall_tier_icon_url'];
  }
}

class CalendarInfo {
  late String date;
  late List<SlopeCountInfo> dailyInfo;
  late Map<String, dynamic> timeInfo;
  late int daily_total_count;
  late int timeInfo_maxCount;

  // 기본 생성자
  CalendarInfo() {
    date = '';
    dailyInfo = [];
    timeInfo = {};
    daily_total_count = 0;
    timeInfo_maxCount=0;
  }

  // fromJson 생성자
  CalendarInfo.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    daily_total_count = json['daily_total_count'];
    dailyInfo = (json['daily_info'] as List)
        .map((e) => SlopeCountInfo.fromJson(e))
        .toList();
    timeInfo = {
      "00-08": json['time_info'][0],
      "08-10": json['time_info'][1],
      "10-12": json['time_info'][2],
      "12-14": json['time_info'][3],
      "14-16": json['time_info'][4],
      "16-18": json['time_info'][5],
      "18-20": json['time_info'][6],
      "20-22": json['time_info'][7],
      "22-00": json['time_info'][8],
    };
    timeInfo_maxCount = timeInfo.values.reduce((a, b) => a > b ? a : b);
  }
}

class SlopeCountInfo {
  late String slope;
  late int count;
  late double ratio;

  // 기본 생성자
  SlopeCountInfo() {
    slope = '';
    count = 0;
    ratio = 0.0;
  }

  // fromJson 생성자
  SlopeCountInfo.fromJson(Map<String, dynamic> json) {
    slope = json['slope'];
    count = json['count'];
    ratio = json['ratio'];
  }
}
