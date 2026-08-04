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

/// 이벤트 모델
class EventModel {
  int? eventId;
  int? userId;
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
    category = json['category'];
    title = json['title'];
    description = json['description'];
    thumbImgUrl = json['thumb_img_url'];
    landingUrl = json['landing_url'];

    // views 필드 처리 (리스트 또는 카운트)
    if (json['views'] is List) {
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
      'category': category,
      'title': title,
      'description': description,
      'thumb_img_url': thumbImgUrl,
      'landingUrl': landingUrl,
      'views': views,
      'update_time': updateTime?.toIso8601String(),
      'upload_time': uploadTime?.toIso8601String(),
    };
  }
}
