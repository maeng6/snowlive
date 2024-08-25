class FriendsTalk {
  late int friendsTalkId;
  late int authorUserId;
  late int friendUserId;
  late String content;
  late int count;
  late int report;
  late DateTime updateTime;
  late DateTime uploadTime;
  late AuthorInfo authorInfo;

  // 기본 생성자
  FriendsTalk() {
    friendsTalkId = 0;
    authorUserId = 0;
    friendUserId = 0;
    content = '';
    count = 0;
    report = 0;
    updateTime = DateTime.now();
    uploadTime = DateTime.now();
    authorInfo = AuthorInfo();
  }

  // fromJson 생성자
  FriendsTalk.fromJson(Map<String, dynamic> json) {
    friendsTalkId = json['friends_talk_id'];
    authorUserId = json['author_user_id'];
    friendUserId = json['friend_user_id'];
    content = json['content'];
    count = json['count'];
    report = json['report'];
    updateTime = DateTime.parse(json['update_time']);
    uploadTime = DateTime.parse(json['upload_time']);
    authorInfo = AuthorInfo.fromJson(json['author_info']);
  }
}

class AuthorInfo {
  late int userId;
  late String displayName;
  late String profileImageUrlUser;
  late String crewName;
  late String favoriteResortNickname;

  // 기본 생성자
  AuthorInfo() {
    userId = 0;
    displayName = '';
    profileImageUrlUser = '';
    crewName = '';
    favoriteResortNickname = '';
  }

  // fromJson 생성자
  AuthorInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    crewName = json['crew_name'];
    favoriteResortNickname = json['favorite_resort_nickname'];
  }
}
