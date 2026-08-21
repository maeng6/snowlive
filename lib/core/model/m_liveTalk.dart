/// LiveTalk 모델 파일

// 사용자 정보
class LiveTalkUserInfo {
  int? userId;
  String? displayName;
  String? profileImageUrl;

  LiveTalkUserInfo({
    this.userId,
    this.displayName,
    this.profileImageUrl,
  });

  LiveTalkUserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrl = json['profile_image_url'];
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'profile_image_url': profileImageUrl,
    };
  }
}

// 답글
class LiveTalkReply {
  int? replyId;
  int? commentId;
  int? userId;
  LiveTalkUserInfo? userInfo;
  String? content;
  int? likeCount;
  bool? isLiked;
  int? report;
  String? uploadTime;
  String? updateTime;
  bool isPending;  // 게시 중 상태 (낙관적 UI용)

  LiveTalkReply({
    this.replyId,
    this.commentId,
    this.userId,
    this.userInfo,
    this.content,
    this.likeCount,
    this.isLiked,
    this.report,
    this.uploadTime,
    this.updateTime,
    this.isPending = false,
  });

  LiveTalkReply.fromJson(Map<String, dynamic> json)
      : isPending = false {
    replyId = json['reply_id'];
    commentId = json['comment_id'];
    userId = json['user_id'];
    userInfo = json['user_info'] != null
        ? LiveTalkUserInfo.fromJson(json['user_info'])
        : null;
    content = json['content'];
    likeCount = json['like_count'] ?? 0;
    isLiked = json['is_liked'] ?? false;
    report = json['report'] ?? 0;
    uploadTime = json['upload_time'];
    updateTime = json['update_time'];
  }

  Map<String, dynamic> toJson() {
    return {
      'reply_id': replyId,
      'comment_id': commentId,
      'user_id': userId,
      'user_info': userInfo?.toJson(),
      'content': content,
      'like_count': likeCount,
      'is_liked': isLiked,
      'report': report,
      'upload_time': uploadTime,
      'update_time': updateTime,
    };
  }
}

// 댓글
class LiveTalkComment {
  int? commentId;
  int? livetalkId;
  int? userId;
  LiveTalkUserInfo? userInfo;
  String? content;
  int? likeCount;
  bool? isLiked;
  int? replyCount;
  List<LiveTalkReply>? replies;
  int? report;
  String? uploadTime;
  String? updateTime;
  bool isPending;  // 게시 중 상태 (낙관적 UI용)

  LiveTalkComment({
    this.commentId,
    this.livetalkId,
    this.userId,
    this.userInfo,
    this.content,
    this.likeCount,
    this.isLiked,
    this.replyCount,
    this.replies,
    this.report,
    this.uploadTime,
    this.updateTime,
    this.isPending = false,
  });

  LiveTalkComment.fromJson(Map<String, dynamic> json)
      : isPending = false {
    commentId = json['comment_id'];
    livetalkId = json['livetalk_id'];
    userId = json['user_id'];
    userInfo = json['user_info'] != null
        ? LiveTalkUserInfo.fromJson(json['user_info'])
        : null;
    content = json['content'];
    likeCount = json['like_count'] ?? 0;
    isLiked = json['is_liked'] ?? false;
    replyCount = json['reply_count'] ?? 0;
    if (json['replies'] != null) {
      replies = (json['replies'] as List)
          .map((item) => LiveTalkReply.fromJson(item))
          .toList();
    } else {
      replies = [];
    }
    report = json['report'] ?? 0;
    uploadTime = json['upload_time'];
    updateTime = json['update_time'];
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'livetalk_id': livetalkId,
      'user_id': userId,
      'user_info': userInfo?.toJson(),
      'content': content,
      'like_count': likeCount,
      'is_liked': isLiked,
      'reply_count': replyCount,
      'replies': replies?.map((r) => r.toJson()).toList(),
      'report': report,
      'upload_time': uploadTime,
      'update_time': updateTime,
    };
  }
}

// 게시글
class LiveTalk {
  int? livetalkId;
  int? userId;
  LiveTalkUserInfo? userInfo;
  int? crewId;   // 크루 라이브톡이면 크루 id, 일반 라이브톡이면 null
  bool? secret;  // 크루톡 공개/비공개. crew_id가 있으면 non-null(정책), 일반톡은 null
  String? description;
  String? imageUrl;
  int? likeCount;
  bool? isLiked;
  int? commentCount;
  bool? block;
  int? report;
  String? uploadTime;
  String? updateTime;
  List<LiveTalkComment>? comments; // 상세 조회 시에만 포함

  LiveTalk({
    this.livetalkId,
    this.userId,
    this.userInfo,
    this.crewId,
    this.secret,
    this.description,
    this.imageUrl,
    this.likeCount,
    this.isLiked,
    this.commentCount,
    this.block,
    this.report,
    this.uploadTime,
    this.updateTime,
    this.comments,
  });

  /// 크루 라이브톡인지(crew_id가 있으면 크루톡).
  bool get isCrewTalk => crewId != null;

  LiveTalk.fromJson(Map<String, dynamic> json) {
    livetalkId = json['livetalk_id'];
    userId = json['user_id'];
    userInfo = json['user_info'] != null
        ? LiveTalkUserInfo.fromJson(json['user_info'])
        : null;
    crewId = json['crew_id'];
    secret = json['secret'];
    description = json['description'];
    imageUrl = json['image_url'];
    likeCount = json['like_count'] ?? 0;
    isLiked = json['is_liked'] ?? false;
    commentCount = json['comment_count'] ?? 0;
    block = json['block'] ?? false;
    report = json['report'] ?? 0;
    uploadTime = json['upload_time'];
    updateTime = json['update_time'];
    if (json['comments'] != null) {
      comments = (json['comments'] as List)
          .map((item) => LiveTalkComment.fromJson(item))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'livetalk_id': livetalkId,
      'user_id': userId,
      'user_info': userInfo?.toJson(),
      'crew_id': crewId,
      'secret': secret,
      'description': description,
      'image_url': imageUrl,
      'like_count': likeCount,
      'is_liked': isLiked,
      'comment_count': commentCount,
      'block': block,
      'report': report,
      'upload_time': uploadTime,
      'update_time': updateTime,
      'comments': comments?.map((c) => c.toJson()).toList(),
    };
  }
}

// 목록 조회 응답 (페이지네이션)
class LiveTalkListResponse {
  int? count;
  String? next;
  String? previous;
  List<LiveTalk>? results;

  LiveTalkListResponse({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  LiveTalkListResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = (json['results'] as List)
          .map((item) => LiveTalk.fromJson(item))
          .toList();
    } else {
      results = [];
    }
  }
}

// 좋아요 토글 응답
class LiveTalkLikeResponse {
  bool? liked;
  int? likeCount;

  LiveTalkLikeResponse({
    this.liked,
    this.likeCount,
  });

  LiveTalkLikeResponse.fromJson(Map<String, dynamic> json) {
    liked = json['liked'];
    likeCount = json['like_count'];
  }
}

// 신고 응답
class LiveTalkReportResponse {
  String? message;
  int? reportCount;

  LiveTalkReportResponse({
    this.message,
    this.reportCount,
  });

  LiveTalkReportResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    reportCount = json['report_count'];
  }
}
