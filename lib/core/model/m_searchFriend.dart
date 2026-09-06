class SearchFriend {
  int? userId;
  String? crewName;
  String? displayName;
  String? profileImageUrlUser;
  String? skiorboard; // nullable 필드
  bool? areWeFriend;

  SearchFriend({
    this.userId,
    this.crewName,
    this.displayName,
    this.profileImageUrlUser,
    this.skiorboard, // nullable 필드
    this.areWeFriend,
  });

  SearchFriend.fromJson(Map<String, dynamic> json) {
      userId = json['user_id'];
      crewName = json['crew_name'];
      displayName = json['display_name'];
      profileImageUrlUser = json['profile_image_url_user'];
      skiorboard = json['skiorboard'];
      areWeFriend = json['are_we_friend'];
  }

}
