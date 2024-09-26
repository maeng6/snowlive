import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'm_communityList.dart';

class CommunityDetailModel {
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
  List<dynamic>? commentList;

  CommunityDetailModel({
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
    this.commentList,
  });

  CommunityDetailModel.fromCommunityModel(Community community) {
    communityId = community.communityId;
    userId = community.userId;
    categoryMain = community.categoryMain;
    categorySub = community.categorySub;
    categorySub2 = community.categorySub2;
    snsUrl = community.snsUrl;
    title = community.title;
    thumbImg = community.thumbImg;
    description = community.description;
    updateTime = community.updateTime;
    uploadTime = community.uploadTime;
    viewsCount = community.viewsCount;
    userInfo = community.userInfo;
    commentCount = community.commentCount;
    commentList = community.commentList;
  }

  CommunityDetailModel.fromJson(Map<String, dynamic> json) {
    communityId = json['community_id'];
    userId = json['user_id'];
    categoryMain = json['category_main'];
    categorySub = json['category_sub'];
    categorySub2 = json['category_sub2'];
    snsUrl = json['sns_url'];
    title = json['title'];
    thumbImg = json['thumb_img_url'];

    // description을 string에서 quill.Document로 변환
    if (json['description'] != null && json['description'] is String) {
      try {
        final List<dynamic> deltaList = jsonDecode(json['description']);
        description = quill.Document.fromJson(deltaList);
      } catch (e) {
        print('Error parsing description: $e');
        description = quill.Document();  // 에러 발생 시 빈 Document로 설정
      }
    } else {
      description = quill.Document();
    }


    updateTime = json['update_time'];
    uploadTime = json['upload_time'];
    viewsCount = json['views_count'];
    userInfo = UserInfo.fromJson(json['user_info']);
    commentCount = json['comment_count'];
    commentList = (json['comments']??[] as List)
        .map((i) => CommentModel_community.fromJson(i))
        .toList();
  }
}


