class RequestFriendListResponse {
  late List<RequestFriendList> requests;

  RequestFriendListResponse({
    required this.requests,
  });

  RequestFriendListResponse.fromJson(List<dynamic> json) {
    requests = json.map((item) => RequestFriendList.fromJson(item)).toList();
  }

  List<dynamic> toJson() {
    return requests.map((request) => request.toJson()).toList();
  }
}

class RequestFriendList {
  late int friendId;
  late int sendUserId;
  late int receiveUserId;
  late bool senderAccept;
  late bool receiverAccept;
  late bool areWeFriend;
  late bool bestFriend;
  late String updateTime;
  late ReceiveUserInfo receiveUserInfo;

  RequestFriendList({
    required this.friendId,
    required this.sendUserId,
    required this.receiveUserId,
    required this.senderAccept,
    required this.receiverAccept,
    required this.areWeFriend,
    required this.bestFriend,
    required this.updateTime,
    required this.receiveUserInfo,
  });

  RequestFriendList.fromJson(Map<String, dynamic> json) {
    friendId = json['friend_id'] ?? 0;
    sendUserId = json['send_user_id'] ?? 0;
    receiveUserId = json['receive_user_id'] ?? 0;
    senderAccept = json['sender_accept'] ?? false;
    receiverAccept = json['receiver_accept'] ?? false;
    areWeFriend = json['are_we_friend'] ?? false;
    bestFriend = json['best_friend'] ?? false;
    updateTime = json['update_time'] ?? '';
    receiveUserInfo = ReceiveUserInfo.fromJson(json['receive_user_info'] ?? {});
  }

  Map<String, dynamic> toJson() {
    return {
      'friend_id': friendId,
      'send_user_id': sendUserId,
      'receive_user_id': receiveUserId,
      'sender_accept': senderAccept,
      'receiver_accept': receiverAccept,
      'are_we_friend': areWeFriend,
      'best_friend': bestFriend,
      'update_time': updateTime,
      'receive_user_info': receiveUserInfo.toJson(),
    };
  }
}

class ReceiveUserInfo {
  late String displayName;
  late String profileImageUrlUser;
  late String? stateMsg; // Nullability를 고려하여 String? 사용

  ReceiveUserInfo({
    required this.displayName,
    required this.profileImageUrlUser,
    this.stateMsg,
  });

  ReceiveUserInfo.fromJson(Map<String, dynamic> json) {
    displayName = json['display_name'] ?? 'Unknown'; // Null 처리, 기본값 'Unknown'
    profileImageUrlUser = json['profile_image_url_user'] ?? ''; // Null 처리, 기본값 빈 문자열
    stateMsg = json['state_msg'] != null ? json['state_msg'] as String : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'profile_image_url_user': profileImageUrlUser,
      'state_msg': stateMsg,
    };
  }
}
