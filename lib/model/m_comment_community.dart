
import 'package:com.snowlive/model/m_communityList.dart';

class CommentResponseCommunity {
  int? count;
  String? next;
  String? previous;
  List<CommentModel_community>? results;

  CommentResponseCommunity({this.count, this.next, this.previous, this.results});

  CommentResponseCommunity.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = (json['results'] as List)
          .map((i) => CommentModel_community.fromJson(i))
          .toList();
    }
  }

  CommentResponseCommunity.fromJson_comment(var commentList) {
    count = 0;
    next = '';
    previous = '';

      results = (commentList as List)
          .map((i) => CommentModel_community.fromJson(i))
          .toList();
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
  bool? secret;

  Reply({
    this.replyId,
    this.content,
    this.userId,
    this.userInfo,
    this.updateTime,
    this.uploadTime,
    this.commentId,
    this.secret,
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
    secret = json['secret'];
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


