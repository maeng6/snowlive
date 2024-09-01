class CommentResponse {
  int? count;
  String? next;
  String? previous;
  List<CommentModel_flea>? results;

  CommentResponse({this.count, this.next, this.previous, this.results});

  CommentResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = (json['results'] as List)
          .map((i) => CommentModel_flea.fromJson(i))
          .toList();
    }
  }
}

class CommentModel_flea {
  int? commentId;
  int? fleaId;
  String? content;
  int? userId;
  UserInfo? userInfo;
  String? updateTime;
  String? uploadTime;
  bool? secret;
  List<Reply>? replies;

  CommentModel_flea({
    this.commentId,
    this.fleaId,
    this.content,
    this.userId,
    this.userInfo,
    this.updateTime,
    this.uploadTime,
    this.secret,
    this.replies,
  });

  CommentModel_flea.fromJson(Map<String, dynamic> json) {
    commentId = json['comment_id'];
    fleaId = json['flea_id'];
    content = json['content'];
    userId = json['user_id'];
    userInfo = json['user_info'] != null
        ? UserInfo.fromJson(json['user_info'])
        : null;
    updateTime = json['update_time'];
    uploadTime = json['upload_time'];
    secret = json['secret'];
    if (json['replies'] != null) {
      replies = (json['replies'] as List)
          .map((i) => Reply.fromJson(i))
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

  UserInfo({this.userId, this.displayName, this.profileImageUrlUser});

  UserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
  }
}
