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
    friendsTalkId = json['friends_talk_id'] ?? 0; // null 처리
    authorUserId = json['author_user_id'] ?? 0; // null 처리
    friendUserId = json['friend_user_id'] ?? 0; // null 처리
    content = json['content'] ?? ''; // null 처리
    count = json['count'] ?? 0; // null 처리
    report = json['report'] ?? 0; // null 처리
    updateTime = json['update_time'] != null ? DateTime.parse(json['update_time']) : DateTime.now(); // null 처리
    uploadTime = json['upload_time'] != null ? DateTime.parse(json['upload_time']) : DateTime.now(); // null 처리
    authorInfo = json['author_info'] != null ? AuthorInfo.fromJson(json['author_info']) : AuthorInfo(); // null 처리
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
    userId = json['user_id'] ?? 0; // null 처리
    displayName = json['display_name'] ?? ''; // null 처리
    profileImageUrlUser = json['profile_image_url_user'] ?? ''; // null 처리
    crewName = json['crew_name'] ?? ''; // null 처리
    favoriteResortNickname = json['favorite_resort_nickname'] ?? ''; // null 처리
  }
}
