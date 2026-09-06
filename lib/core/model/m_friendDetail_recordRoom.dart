class FriendDetailModel_recordRoom {
  late FriendUserInfo_recordRoom friendUserInfo;
  late SeasonRankingInfo_recordRoom seasonRankingInfo;
  late List<CalendarInfo_recordRoom> calendarInfo;

  FriendDetailModel_recordRoom() {
    friendUserInfo = FriendUserInfo_recordRoom();
    seasonRankingInfo = SeasonRankingInfo_recordRoom();
    calendarInfo = [];
  }

  FriendDetailModel_recordRoom.fromJson(Map<String, dynamic> json) {
    friendUserInfo = FriendUserInfo_recordRoom.fromJson(json['friend_user_info']);
    seasonRankingInfo = SeasonRankingInfo_recordRoom.fromJson(json['season_ranking_info']);
    calendarInfo = (json['calender_info'] as List)
        .map((e) => CalendarInfo_recordRoom.fromJson(e))
        .toList();
  }
}

class FriendUserInfo_recordRoom {
  late int userId;
  late String displayName;
  late String? profileImageUrlUser;
  late String? crewName;
  late int? crewId;
  late String? stateMsg;
  late String favoriteResort;
  late int? favoriteResortId;
  late bool withinBoundary;
  late bool revealWb;
  late bool hideProfile;
  late bool areWeFriend;
  late bool bestFriend;
  late String? skiorboard;
  late String? sex;

  FriendUserInfo_recordRoom() {
    userId = 0;
    displayName = '';
    profileImageUrlUser = '';
    crewName = '';
    crewId = 0;
    stateMsg = null;
    favoriteResort = '';
    favoriteResortId = null;
    withinBoundary = false;
    revealWb = false;
    hideProfile = false;
    areWeFriend = false;
    bestFriend = false;
    skiorboard = '';
    sex = '';
  }

  FriendUserInfo_recordRoom.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    crewName = json['crew_name'];
    crewId = json['crew_id'];
    stateMsg = json['state_msg'];
    favoriteResort = json['favorite_resort'];
    favoriteResortId = json['favorite_resort_id'];
    withinBoundary = json['within_boundary'];
    revealWb = json['reveal_wb'];
    hideProfile = json['hide_profile'];
    areWeFriend = json['are_we_friend'];
    bestFriend = json['best_friend'];
    skiorboard = json['skiorboard'];
    sex = json['sex'];
  }

  void setBestFriend(bool value) {
    bestFriend = value;
  }
}

class SeasonRankingInfo_recordRoom {
  late List<SlopeCountInfo_recordRoom> countInfo;
  late Map<String, dynamic> timeInfo;
  late double overallTotalScore;
  late int overallTotalCount;
  late int overallRank;
  late int timeInfo_maxCount;
  late double overallRankPercentage;
  late String overallTierIconUrl;
  late String primaryColor;
  late String secondaryColor;
  late String tierNameKor;
  late String tierNameEng;

  SeasonRankingInfo_recordRoom() {
    countInfo = [];
    timeInfo = {};
    timeInfo_maxCount = 0;
    overallTotalScore = 0.0;
    overallTotalCount = 0;
    overallRank = 0;
    overallRankPercentage = 0.0;
    overallTierIconUrl = '';
    primaryColor = '3D83ED';
    secondaryColor = 'F0F6FF';
    tierNameKor = '';
    tierNameEng = '';
  }

  SeasonRankingInfo_recordRoom.fromJson(Map<String, dynamic> json) {
    countInfo = (json['count_info'] as List)
        .map((e) => SlopeCountInfo_recordRoom.fromJson(e))
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
    overallTierIconUrl = json['overall_tier_icon_url'] ?? '';
    primaryColor = json['primary_color'] ?? '3D83ED';
    secondaryColor = json['secondary_color'] ?? 'F0F6FF';
    tierNameKor = json['tier_name_kor'] ?? '';
    tierNameEng = json['tier_name_eng']?.toUpperCase() ?? '';
  }
}

class CalendarInfo_recordRoom {
  late String date;
  late List<SlopeCountInfo_recordRoom> dailyInfo;
  late Map<String, dynamic> timeInfo;
  late int daily_total_count;
  late int timeInfo_maxCount;

  CalendarInfo_recordRoom() {
    date = '';
    dailyInfo = [];
    timeInfo = {};
    daily_total_count = 0;
    timeInfo_maxCount=0;
  }

  CalendarInfo_recordRoom.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    daily_total_count = json['daily_total_count'];
    dailyInfo = (json['daily_info'] as List)
        .map((e) => SlopeCountInfo_recordRoom.fromJson(e))
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

class SlopeCountInfo_recordRoom {
  late String slope;
  late int count;
  late double ratio;

  SlopeCountInfo_recordRoom() {
    slope = '';
    count = 0;
    ratio = 0.0;
  }

  SlopeCountInfo_recordRoom.fromJson(Map<String, dynamic> json) {
    slope = json['slope'];
    count = json['count'];
    ratio = json['ratio'];
  }
}
