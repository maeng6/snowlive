class AlarmCenterResponse {
  int? count;
  String? next;
  String? previous;
  List<AlarmCenterModel>? results;

  AlarmCenterResponse({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  // fromJson 생성자
  AlarmCenterResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results?.add(AlarmCenterModel.fromJson(v));
      });
    }
  }
}

class AlarmCenterModel {
  late int alarmCenterId;
  late AlarmInfo alarmInfo;
  late DateTime date;
  late bool active;
  late OtherUserInfo otherUserInfo;
  late int? pkRequestFriend;
  late int? pkFriendsTalk;
  late int? pkApplyCrew;
  late int? pkFleamarket;
  late int? pkCommentFleamarket;
  late int? pkCommunity;
  late int? pkCommentCommunity;
  late int? pkReplyFleamarket;
  late int? pkReplyCommunity;
  late String? textMain;
  late String? textSub;
  late int? crewLeaderUserId;

  // 기본 생성자
  AlarmCenterModel() {
    alarmCenterId = 0;
    alarmInfo = AlarmInfo();
    date = DateTime.now();
    active = false;
    otherUserInfo = OtherUserInfo();
    pkRequestFriend = null;
    pkFriendsTalk = null;
    pkApplyCrew = null;
    pkFleamarket = null;
    pkCommentFleamarket = null;
    pkCommunity = null;
    pkCommentCommunity = null;
    pkReplyFleamarket = null;
    pkReplyCommunity = null;
    textMain = null;
    textSub = null;
    crewLeaderUserId = null;
  }

  // fromJson 생성자
  AlarmCenterModel.fromJson(Map<String, dynamic> json) {
    alarmCenterId = json['alarmcenter_id'] ?? 0;
    alarmInfo = json['alarminfo'] != null ? AlarmInfo.fromJson(json['alarminfo']) : AlarmInfo();
    date = json['date'] != null ? DateTime.parse(json['date']) : DateTime.now();
    active = json['active'] ?? false;
    otherUserInfo = json['other_user_info'] != null
        ? OtherUserInfo.fromJson(json['other_user_info'])
        : OtherUserInfo();
    pkRequestFriend = json['pk_request_friend'];
    pkFriendsTalk = json['pk_friends_talk'];
    pkApplyCrew = json['pk_apply_crew'];
    pkFleamarket = json['pk_fleamarket'];
    pkCommentFleamarket = json['pk_comment_fleamarket'];
    pkCommunity = json['pk_community'];
    pkCommentCommunity = json['pk_comment_community'];
    pkReplyFleamarket = json['pk_reply_fleamarket'];
    pkReplyCommunity = json['pk_reply_community'];
    textMain = json['text_main'];
    textSub = json['text_sub'];
    crewLeaderUserId = json['crew_leader_user_id'];
  }
}

class AlarmInfo {
  late int alarmInfoId;
  late String alarmInfoName;
  late String alarmText;

  // 기본 생성자
  AlarmInfo() {
    alarmInfoId = 0;
    alarmInfoName = '';
    alarmText = '';
  }

  // fromJson 생성자
  AlarmInfo.fromJson(Map<String, dynamic> json) {
    alarmInfoId = json['alarminfo_id'] ?? 0;
    alarmInfoName = json['alarminfo_name'] ?? '';
    alarmText = json['alarm_text'] ?? '';
  }
}

class OtherUserInfo {
  late int userId;
  late String displayName;
  late String profileImageUrlUser;

  // 기본 생성자
  OtherUserInfo() {
    userId = 0;
    displayName = '';
    profileImageUrlUser = '';
  }

  // fromJson 생성자
  OtherUserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'] ?? 0;
    displayName = json['display_name'] ?? '';
    profileImageUrlUser = json['profile_image_url_user'] ?? '';
  }
}
