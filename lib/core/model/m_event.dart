/// 이벤트 목록 응답 모델 (페이지네이션 포함)
class EventListResponse {
  int? count;
  String? next;
  String? previous;
  List<EventModel> events;

  EventListResponse({
    this.count,
    this.next,
    this.previous,
    List<EventModel>? events,
  }) : events = events ?? [];

  EventListResponse.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        next = json['next'],
        previous = json['previous'],
        events = (json['results'] as List<dynamic>?)
            ?.map((v) => EventModel.fromJson(v))
            .toList() ?? [];
}

/// 이벤트 작성자 정보. 응답(`user_info`)에 있는데 파싱이 빠져 있었다.
class EventUserInfo {
  int? userId;
  String? displayName;
  String? profileImageUrlUser;
  String? resortNickname;

  EventUserInfo({
    this.userId,
    this.displayName,
    this.profileImageUrlUser,
    this.resortNickname,
  });

  EventUserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    resortNickname = json['resort_nickname'];
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'display_name': displayName,
        'profile_image_url_user': profileImageUrlUser,
        'resort_nickname': resortNickname,
      };
}

/// 이벤트 모델
class EventModel {
  int? eventId;
  int? userId;
  EventUserInfo? userInfo;
  String? category;
  String? title;
  String? description;
  String? thumbImgUrl;
  String? landingUrl;
  int? viewCount;
  List<int>? views;
  DateTime? updateTime;
  DateTime? uploadTime;

  EventModel({
    this.eventId,
    this.userId,
    this.userInfo,
    this.category,
    this.title,
    this.description,
    this.thumbImgUrl,
    this.landingUrl,
    this.viewCount,
    this.views,
    this.updateTime,
    this.uploadTime,
  });

  EventModel.fromJson(Map<String, dynamic> json) {
    eventId = json['event_id'];
    userId = json['user_id'];
    userInfo = json['user_info'] == null
        ? null
        : EventUserInfo.fromJson(json['user_info'] as Map<String, dynamic>);
    category = json['category'];
    title = json['title'];
    description = json['description'];
    thumbImgUrl = json['thumb_img_url'];
    landingUrl = json['landing_url'];

    // views 필드 처리 (리스트 또는 카운트)
    // 서버는 `views_count`로 준다 — 이걸 먼저 본다. 아래 분기들은 과거 응답 호환용.
    if (json['views_count'] is int) {
      viewCount = json['views_count'];
      views = [];
    } else if (json['views'] is List) {
      views = (json['views'] as List<dynamic>?)?.map((e) => e as int).toList();
      viewCount = views?.length ?? 0;
    } else if (json['views'] is int) {
      viewCount = json['views'];
      views = [];
    } else if (json['view_count'] != null) {
      viewCount = json['view_count'];
      views = [];
    } else {
      viewCount = 0;
      views = [];
    }

    // 날짜 파싱
    if (json['update_time'] != null) {
      updateTime = DateTime.tryParse(json['update_time']);
    }
    if (json['upload_time'] != null) {
      uploadTime = DateTime.tryParse(json['upload_time']);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'user_id': userId,
      'user_info': userInfo?.toJson(),
      'category': category,
      'title': title,
      'description': description,
      'thumb_img_url': thumbImgUrl,
      'landing_url': landingUrl,
      'views': views,
      'views_count': viewCount,
      'update_time': updateTime?.toIso8601String(),
      'upload_time': uploadTime?.toIso8601String(),
    };
  }
}
