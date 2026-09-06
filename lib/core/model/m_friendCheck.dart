class CheckFriendModel {
  late int friendId;
  late int myUserId;
  late int friendUserId;
  late bool areWeFriend;
  late bool bestFriend;
  late String updateTime;
  late MyUserInfo myUserInfo;
  late FriendUserInfo friendUserInfo;

  CheckFriendModel({
    friendId,
    myUserId,
    friendUserId,
    areWeFriend,
    bestFriend,
    updateTime,
    myUserInfo,
    friendUserInfo,
  });

  CheckFriendModel.fromJson(Map<String, dynamic> json) {
    friendId = json['friend_id'] ?? 0;
    myUserId = json['my_user_id'] ?? 0;
    friendUserId = json['friend_user_id'] ?? 0;
    areWeFriend = json['are_we_friend'] ?? false;
    bestFriend = json['best_friend'] ?? false;
    updateTime = json['update_time'] ?? '';
    myUserInfo = MyUserInfo.fromJson(json['my_user_info'] ?? {});
    friendUserInfo = FriendUserInfo.fromJson(json['friend_user_info'] ?? {});
  }

  Map<String, dynamic> toJson() {
    return {
      'friend_id': friendId,
      'my_user_id': myUserId,
      'friend_user_id': friendUserId,
      'are_we_friend': areWeFriend,
      'best_friend': bestFriend,
      'update_time': updateTime,
      'my_user_info': myUserInfo.toJson(),
      'friend_user_info': friendUserInfo.toJson(),
    };
  }
}

class MyUserInfo {
  late int userId;
  late String displayName;
  late String profileImageUrlUser;
  late String stateMsg;
  late bool withinBoundary;
  late bool revealWb;

  MyUserInfo({
    required this.userId,
    required this.displayName,
    required this.profileImageUrlUser,
    required this.stateMsg,
    required this.withinBoundary,
    required this.revealWb,
  });

  MyUserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'] ?? 0;
    displayName = json['display_name'] ?? 'Unknown';
    profileImageUrlUser = json['profile_image_url_user'] ?? '';
    stateMsg = json['state_msg'] ?? '';
    withinBoundary = json['within_boundary'] ?? false;
    revealWb = json['reveal_wb'] ?? false;
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'profile_image_url_user': profileImageUrlUser,
      'state_msg': stateMsg,
      'within_boundary': withinBoundary,
      'reveal_wb': revealWb,
    };
  }
}

class FriendUserInfo {
  late int userId;
  late String displayName;
  late String profileImageUrlUser;
  late String stateMsg;
  late bool withinBoundary;
  late bool revealWb;

  FriendUserInfo({
    required this.userId,
    required this.displayName,
    required this.profileImageUrlUser,
    required this.stateMsg,
    required this.withinBoundary,
    required this.revealWb,
  });

  FriendUserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'] ?? 0;
    displayName = json['display_name'] ?? 'Unknown';
    profileImageUrlUser = json['profile_image_url_user'] ?? '';
    stateMsg = json['state_msg'] ?? '';
    withinBoundary = json['within_boundary'] ?? false;
    revealWb = json['reveal_wb'] ?? false;
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'profile_image_url_user': profileImageUrlUser,
      'state_msg': stateMsg,
      'within_boundary': withinBoundary,
      'reveal_wb': revealWb,
    };
  }
}
