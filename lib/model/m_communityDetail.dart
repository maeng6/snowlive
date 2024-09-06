class CommunityDetail {
  int? communityId;
  int? userId;
  String? categoryMain;
  String? categorySub;
  String? categorySub2;
  String? snsUrl;
  String? title;
  Description? description;
  DateTime? updateTime;
  DateTime? uploadTime;
  int? viewsCount;
  UserInfo? userInfo;
  int? commentCount;

  CommunityDetail({
    this.communityId,
    this.userId,
    this.categoryMain,
    this.categorySub,
    this.categorySub2,
    this.snsUrl,
    this.title,
    this.description,
    this.updateTime,
    this.uploadTime,
    this.viewsCount,
    this.userInfo,
    this.commentCount,
  });

  CommunityDetail.fromJson(Map<String, dynamic> json) {
    communityId = json['community_id'];
    userId = json['user_id'];
    categoryMain = json['category_main'];
    categorySub = json['category_sub'];
    categorySub2 = json['category_sub2'];
    snsUrl = json['sns_url'];
    title = json['title'];
    description = json['description'] != null
        ? Description.fromJson(json['description'])
        : null;
    updateTime = json['update_time'] != null
        ? DateTime.parse(json['update_time'])
        : null;
    uploadTime = json['upload_time'] != null
        ? DateTime.parse(json['upload_time'])
        : null;
    viewsCount = json['views_count'];
    userInfo = json['user_info'] != null
        ? UserInfo.fromJson(json['user_info'])
        : null;
    commentCount = json['comment_count'];
  }
}

class Description {
  String? string;

  Description({this.string});

  Description.fromJson(Map<String, dynamic> json) {
    string = json['string'];
  }
}

class UserInfo {
  int? userId;
  String? displayName;
  String? profileImageUrlUser;

  UserInfo({
    this.userId,
    this.displayName,
    this.profileImageUrlUser,
  });

  UserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
  }
}
