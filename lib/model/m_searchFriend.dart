class SearchFriend {
  int userId;
  String crewName;
  String displayName;
  String profileImageUrlUser;
  String? skiorboard; // nullable 필드
  bool areWeFriend;

  SearchFriend({
    required this.userId,
    required this.crewName,
    required this.displayName,
    required this.profileImageUrlUser,
    this.skiorboard, // nullable 필드
    required this.areWeFriend,
  });

  // JSON 데이터를 모델로 변환하는 팩토리 함수
  factory SearchFriend.fromJson(Map<String, dynamic> json) {
    return SearchFriend(
      userId: json['user_id'] ?? 0,
      crewName: json['crew_name'] ?? '',
      displayName: json['display_name'] ?? 'Unknown',
      profileImageUrlUser: json['profile_image_url_user'] ?? '',
      skiorboard: json['skiorboard'], // nullable이므로 null 처리
      areWeFriend: json['are_we_friend'] ?? false,
    );
  }

  // 모델 데이터를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'crew_name': crewName,
      'display_name': displayName,
      'profile_image_url_user': profileImageUrlUser,
      'skiorboard': skiorboard, // nullable
      'are_we_friend': areWeFriend,
    };
  }
}
