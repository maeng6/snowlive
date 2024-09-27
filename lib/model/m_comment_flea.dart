import 'm_communityList.dart';
import 'm_fleamarket.dart';

class CommentResponse_flea {
  int? count;
  String? next;
  String? previous;
  List<CommentModel_flea>? results;

  CommentResponse_flea({this.count, this.next, this.previous, this.results});

  CommentResponse_flea.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = (json['results'] as List)
          .map((i) => CommentModel_flea.fromJson(i))
          .toList();
    }
  }

  CommentResponse_flea.fromJson_comment(var commentList) {
    count = 0;
    next = '';
    previous = '';
    results =  (commentList as List)
          .map((i) => CommentModel_flea.fromJson(i))
          .toList();

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
    userInfo = UserInfo.fromJson(json['user_info']);
    updateTime = json['update_time'];
    uploadTime = json['upload_time'];
    secret = json['secret'];
    if (json['replies'] != null) {
      replies = (json['replies'] as List)
          .map((i) => Reply.fromJson(i))
          .toList();
    }
  }

  CommentModel_flea.fromJson_model(CommentModel_flea commentModel_flea) {
    commentId = commentModel_flea.commentId;
    fleaId = commentModel_flea.fleaId;
    content = commentModel_flea.content;
    userId = commentModel_flea.userId;
    userInfo = UserInfo.fromJson_model(commentModel_flea.userInfo!);
    updateTime = commentModel_flea.updateTime;
    uploadTime = commentModel_flea.uploadTime;
    secret = commentModel_flea.secret;
    if (commentModel_flea.replies != null) {
      replies = (commentModel_flea.replies as List)
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
    secret = reply.secret;
  }

}

