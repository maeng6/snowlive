class FriendListModel {
  late int friendId;
  late int myUserId;
  late int friendUserId;
  late bool areWeFriend;
  late bool bestFriend;
  late String updateTime;
  late FriendInfo friendInfo;
  late String? lastPassTime; // Nullability를 고려하여 String? 사용
  late String? lastPassSlope; // Nullability를 고려하여 String? 사용

  FriendListModel({
    required this.friendId,
    required this.myUserId,
    required this.friendUserId,
    required this.areWeFriend,
    required this.bestFriend,
    required this.updateTime,
    required this.friendInfo,
    this.lastPassTime,
    this.lastPassSlope,
  });

  FriendListModel.fromJson(Map<String, dynamic> json) {
    friendId = json['friend_id'];
    myUserId = json['my_user_id'];
    friendUserId = json['friend_user_id'];
    areWeFriend = json['are_we_friend'];
    bestFriend = json['best_friend'];
    updateTime = json['update_time'];
    friendInfo = FriendInfo.fromJson(json['friend_info']);
    lastPassTime = json['last_pass_time'];
    lastPassSlope = json['last_pass_slope'];
  }

  Map<String, dynamic> toJson() {
    return {
      'friend_id': friendId,
      'my_user_id': myUserId,
      'friend_user_id': friendUserId,
      'are_we_friend': areWeFriend,
      'best_friend': bestFriend,
      'update_time': updateTime,
      'friend_info': friendInfo.toJson(),
      'last_pass_time': lastPassTime,
      'last_pass_slope': lastPassSlope,
    };
  }
}

class FriendInfo {
  late int userId;
  late String displayName;
  late String profileImageUrlUser;
  late String stateMsg;
  late bool withinBoundary;
  late bool revealWb;
  late String? lastPassTime; // Nullability를 고려하여 String? 사용
  late String? lastPassSlope; // Nullability를 고려하여 String? 사용

  FriendInfo({
    required this.userId,
    required this.displayName,
    required this.profileImageUrlUser,
    required this.stateMsg,
    required this.withinBoundary,
    required this.revealWb,
    this.lastPassTime,
    this.lastPassSlope,
  });

  FriendInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    stateMsg = json['state_msg'];
    withinBoundary = json['within_boundary'];
    revealWb = json['reveal_wb'];
    lastPassTime = json['last_pass_time'];
    lastPassSlope = json['last_pass_slope'];
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'profile_image_url_user': profileImageUrlUser,
      'state_msg': stateMsg,
      'within_boundary': withinBoundary,
      'reveal_wb': revealWb,
      'last_pass_time': lastPassTime,
      'last_pass_slope': lastPassSlope,
    };
  }
}
