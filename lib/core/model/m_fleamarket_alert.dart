/// 키워드 알림 모델
class KeywordAlert {
  int? keywordAlertId;
  int? userId;
  String? keyword;
  bool? active;
  String? uploadTime;

  KeywordAlert({
    this.keywordAlertId,
    this.userId,
    this.keyword,
    this.active,
    this.uploadTime,
  });

  KeywordAlert.fromJson(Map<String, dynamic> json) {
    keywordAlertId = json['keyword_alert_id'];
    userId = json['user_id'];
    keyword = json['keyword'];
    active = json['active'];
    uploadTime = json['upload_time'];
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword_alert_id': keywordAlertId,
      'user_id': userId,
      'keyword': keyword,
      'active': active,
      'upload_time': uploadTime,
    };
  }
}

/// 카테고리 알림 모델
class CategoryAlert {
  int? categoryAlertId;
  int? userId;
  String? categoryMain;
  String? categorySub;
  bool? active;
  String? uploadTime;

  CategoryAlert({
    this.categoryAlertId,
    this.userId,
    this.categoryMain,
    this.categorySub,
    this.active,
    this.uploadTime,
  });

  CategoryAlert.fromJson(Map<String, dynamic> json) {
    categoryAlertId = json['category_alert_id'];
    userId = json['user_id'];
    categoryMain = json['category_main'];
    categorySub = json['category_sub'];
    active = json['active'];
    uploadTime = json['upload_time'];
  }

  Map<String, dynamic> toJson() {
    return {
      'category_alert_id': categoryAlertId,
      'user_id': userId,
      'category_main': categoryMain,
      'category_sub': categorySub,
      'active': active,
      'upload_time': uploadTime,
    };
  }
}