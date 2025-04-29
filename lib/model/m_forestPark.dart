class Quiz {
  int? quizId;
  int? leafId;
  String? leafColor;
  int? leafCount;
  String? question;
  bool? isMcq;
  String? imgUrl;
  String? imgUrlAd;
  String? option1;
  String? option2;
  String? option3;
  String? option4;
  String? answer;
  int? eventDate;
  String? hintUrl;

  Quiz({
    this.quizId,
    this.leafId,
    this.leafColor,
    this.leafCount,
    this.question,
    this.isMcq,
    this.imgUrl,
    this.imgUrlAd,
    this.option1,
    this.option2,
    this.option3,
    this.option4,
    this.answer,
    this.eventDate,
    this.hintUrl
  });

  Quiz.fromJson(Map<String, dynamic> json) {
    quizId = json['quiz_id'];
    leafId = json['leaf_id'];
    leafColor = json['leaf_color'];
    leafCount = json['leaf_count'];
    question = json['question'];
    isMcq = json['is_mcq'];
    imgUrl = json['img_url'];
    imgUrlAd = json['img_url_ad'];
    option1 = json['option_1'];
    option2 = json['option_2'];
    option3 = json['option_3'];
    option4 = json['option_4'];
    answer = json['answer'];
    eventDate = json['event_date'];
    hintUrl = json['hint_url'];
  }

  Map<String, dynamic> toJson() {
    return {
      'quiz_id': quizId,
      'leaf_id': leafId,
      'leaf_color': leafColor,
      'leaf_count': leafCount,
      'question': question,
      'is_mcq': isMcq,
      'img_url': imgUrl,
      'img_url_ad': imgUrlAd,
      'option_1': option1,
      'option_2': option2,
      'option_3': option3,
      'option_4': option4,
      'answer': answer,
      'event_date': eventDate,
      'hintUrl' : hintUrl,
    };
  }
}


class LeafItem {
  int? leafItemId;
  String? name;
  int? leafKind1Count;
  int? leafKind2Count;
  int? leafItemCount;
  String? imageUrl;
  String? description;
  String? landingUrl;
  int? eventDate;

  LeafItem({
    this.leafItemId,
    this.name,
    this.leafKind1Count,
    this.leafKind2Count,
    this.leafItemCount,
    this.imageUrl,
    this.description,
    this.landingUrl,
    this.eventDate,
  });

  LeafItem.fromJson(Map<String, dynamic> json) {
    leafItemId = json['leaf_item_id'];
    name = json['name'];
    leafKind1Count = json['leaf_kind_1_count'];
    leafKind2Count = json['leaf_kind_2_count'];
    leafItemCount = json['leaf_item_count'];
    imageUrl = json['image_url'];
    description = json['description'];
    landingUrl = json['landing_url'];
    eventDate = json['event_date'];
  }

  Map<String, dynamic> toJson() {
    return {
      'leaf_item_id': leafItemId,
      'name': name,
      'leaf_kind_1_count': leafKind1Count,
      'leaf_kind_2_count': leafKind2Count,
      'leaf_item_count': leafItemCount,
      'image_url': imageUrl,
      'description': description,
      'landing_url': landingUrl,
      'event_date': eventDate,
    };
  }
}

class BuyRecord {
  int? recordId;
  LeafItem? leafItem;
  int? userId;
  bool? isReceived;
  String? uploadTime;

  BuyRecord({
    this.recordId,
    this.leafItem,
    this.userId,
    this.isReceived,
    this.uploadTime,
  });

  BuyRecord.fromJson(Map<String, dynamic> json) {
    recordId = json['leaf_buy_record_id'];
    userId = json['user_id'];
    isReceived = json['is_received'];
    uploadTime = json['upload_time'];
    leafItem = json['leaf_item'] != null
        ? LeafItem.fromJson(json['leaf_item'])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'leaf_buy_record_id': recordId,
      'leaf_item': leafItem?.toJson(),
      'user_id': userId,
      'is_received': isReceived,
      'upload_time': uploadTime,
    };
  }
}

class LeafRemain {
  int? remainGreen;
  int? remainGold;

  LeafRemain({this.remainGreen, this.remainGold});

  LeafRemain.fromJson(Map<String, dynamic> json) {
    remainGreen = json['remain_green'];
    remainGold = json['remain_gold'];
  }

  Map<String, dynamic> toJson() {
    return {
      'remain_green': remainGreen,
      'remain_gold': remainGold,
    };
  }
}
