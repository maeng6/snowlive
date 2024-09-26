import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class CommunityListResponse {
  int? count;
  String? next;
  String? previous;
  List<Community>? results;

  CommunityListResponse({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  CommunityListResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    results = (json['results'] as List<dynamic>?)
        ?.map((item) => Community.fromJson(item))
        .toList();
  }
}

class Community {
  int? communityId;
  int? userId;
  String? categoryMain;
  String? categorySub;
  String? categorySub2;
  String? snsUrl;
  String? title;
  String? thumbImg;
  quill.Document? description;  // quill.Document 형식으로 변경
  String? updateTime;
  String? uploadTime;
  int? viewsCount;
  UserInfo? userInfo;
  int? commentCount;
  List<dynamic>? commentList;

  Community({
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

  Community.fromJson(Map<String, dynamic> json) {
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
        final List<dynamic> deltaList = jsonDecode(json['description']);
        description = quill.Document.fromJson(deltaList);
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
  String? resortNickname;
  String? crewName;

  UserInfo({
    this.userId,
    this.displayName,
    this.profileImageUrlUser,
    this.resortNickname,
    this.crewName,
  });

  UserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    resortNickname = json['resort_nickname'];
    crewName = json['crew_name'];
  }

  UserInfo.fromJson_model(UserInfo userInfo) {
    userId = userInfo.userId;
    displayName = userInfo.displayName;
    profileImageUrlUser = userInfo.profileImageUrlUser;
    resortNickname = userInfo.resortNickname;
    crewName = userInfo.crewName;
  }
}

class CommentModel_community {
  int? commentId;
  int? communityId;
  String? content;
  int? userId;
  UserInfo? userInfo;
  String? updateTime;
  String? uploadTime;
  List<dynamic>? replies;

  CommentModel_community({
    this.commentId,
    this.communityId,
    this.content,
    this.userId,
    this.userInfo,
    this.updateTime,
    this.uploadTime,
    this.replies,
  });

  CommentModel_community.fromJson(Map<String, dynamic> json) {
    commentId = json['comment_id'];
    communityId = json['community_id'];
    content = json['content'];
    userId = json['user_id'];
    userInfo = UserInfo.fromJson(json['user_info']);
    updateTime = json['update_time'];
    uploadTime = json['upload_time'];
    if (json['replies'] != null) {
      replies = (json['replies']??[] as List)
          .map((i) => Reply.fromJson(i))
          .toList();
    }
  }

  CommentModel_community.fromJson_model(CommentModel_community commentModel_community) {
    commentId = commentModel_community.commentId;
    communityId = commentModel_community.communityId;
    content = commentModel_community.content;
    userId = commentModel_community.userId;
    userInfo = UserInfo.fromJson_model(commentModel_community.userInfo!);
    updateTime = commentModel_community.updateTime;
    uploadTime = commentModel_community.uploadTime;
    if (commentModel_community.replies != null) {
      replies = (commentModel_community.replies??[] as List)
          .map((i) => Reply.fromJson_model(i))
          .toList();
    }
  }

}

class Reply {
  int? replyId;
  String? content;
  int? userId;
  UserInfo? userInfo;
  String? updateTime;
  String? uploadTime;
  int? commentId;

  Reply({
    this.replyId,
    this.content,
    this.userId,
    this.userInfo,
    this.updateTime,
    this.uploadTime,
    this.commentId,
  });

  Reply.fromJson(Map<String, dynamic> json) {
    replyId = json['reply_id'];
    content = json['content'];
    userId = json['user_id'];
    userInfo = json['user_info'] != null
        ? UserInfo.fromJson(json['user_info'])
        : null;
    updateTime = json['update_time'];
    uploadTime = json['upload_time'];
    commentId = json['comment_id'];
  }

  Reply.fromJson_model(Reply reply) {
    replyId = reply.replyId;
    content = reply.content;
    userId = reply.userId;
    userInfo = reply.userInfo != null
        ? UserInfo.fromJson_model(reply.userInfo!)
        : null;
    updateTime = reply.updateTime;
    uploadTime = reply.uploadTime;
    commentId = reply.commentId;
  }
}