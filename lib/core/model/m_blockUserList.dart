class UserBlockListResponse {
  late List<UserBlockList> blocks;

  UserBlockListResponse({
    required this.blocks,
  });

  UserBlockListResponse.fromJson(List<dynamic> json) {
    blocks = json.map((item) => UserBlockList.fromJson(item)).toList();
  }

  List<dynamic> toJson() {
    return blocks.map((block) => block.toJson()).toList();
  }
}

class UserBlockList {
  late int blockUserId;
  late UserInfo blockUserInfo;

  UserBlockList({
    required this.blockUserId,
    required this.blockUserInfo,
  });

  UserBlockList.fromJson(Map<String, dynamic> json) {
    blockUserId = json['block_user_id'] ?? 0;
    blockUserInfo = UserInfo.fromJson(json['block_user_info'] ?? {});
  }

  Map<String, dynamic> toJson() {
    return {
      'block_user_id': blockUserId,
      'block_user_info': blockUserInfo.toJson(),
    };
  }
}

class UserInfo {
  late int userId;
  late String displayName;
  late String profileImageUrlUser;
  String? stateMsg;

  UserInfo({
    required this.userId,
    required this.displayName,
    required this.profileImageUrlUser,
    this.stateMsg,
  });

  UserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'] ?? 0;
    displayName = json['display_name'] ?? 'Unknown';
    profileImageUrlUser = json['profile_image_url_user'] ?? '';
    stateMsg = json['state_msg'];
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'profile_image_url_user': profileImageUrlUser,
      'state_msg': stateMsg,
    };
  }
}
