import 'package:flutter_quill/flutter_quill.dart' as quill;

class CommunityDetail {
  int? communityId;
  int? userId;
  String? categoryMain;
  String? categorySub;
  String? categorySub2;
  String? snsUrl;
  String? title;
  String? thumbImg;
  quill.Document? description;
  String? updateTime;
  String? uploadTime;
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
    this.thumbImg,
    this.description,
    this.updateTime,
    this.uploadTime,
    this.viewsCount,
    this.userInfo,
    this.commentCount,
  });

  CommunityDetail.fromCommunityModel(CommunityDetail communityDetail) {
    communityId = communityDetail.communityId;
    userId = communityDetail.userId;
    categoryMain = communityDetail.categoryMain;
    categorySub = communityDetail.categorySub;
    categorySub2 = communityDetail.categorySub2;
    snsUrl = communityDetail.snsUrl;
    title = communityDetail.title;
    thumbImg = communityDetail.thumbImg;
    description = communityDetail.description;
    updateTime = communityDetail.updateTime;
    uploadTime = communityDetail.uploadTime;
    viewsCount = communityDetail.viewsCount;
    userInfo = communityDetail.userInfo;
    commentCount = communityDetail.commentCount;
  }

  CommunityDetail.fromJson(Map<String, dynamic> json) {
    communityId = json['community_id'];
    userId = json['user_id'];
    categoryMain = json['category_main'];
    categorySub = json['category_sub'];
    categorySub2 = json['category_sub2'];
    snsUrl = json['sns_url'];
    title = json['title'];
    thumbImg = json['thumb_img_url'];
    description = json['description'];
    updateTime = json['update_time'];
    uploadTime = json['upload_time'];
    viewsCount = json['views_count'];
    userInfo = UserInfo.fromJson(json['user_info']);
    commentCount = json['comment_count'];
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
