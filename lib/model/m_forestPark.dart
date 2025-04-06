class LeafItem {
  int? leafItemId;
  String? name;
  String? imageUrl;
  int? leafKind1Count;
  int? leafKind2Count;
  int? eventDate;

  LeafItem({
    this.leafItemId,
    this.name,
    this.imageUrl,
    this.leafKind1Count,
    this.leafKind2Count,
    this.eventDate,
  });

  LeafItem.fromJson(Map<String, dynamic> json) {
    leafItemId = json['leaf_item_id'];
    name = json['name'];
    imageUrl = json['image_url'];
    leafKind1Count = json['leaf_kind_1_count'];
    leafKind2Count = json['leaf_kind_2_count'];
    eventDate = json['event_date'];
  }
}

class BuyRecord {
  int? recordId;
  String? itemName;
  String? imageUrl;
  bool? isReceived;
  String? uploadTime;

  BuyRecord({
    this.recordId,
    this.itemName,
    this.imageUrl,
    this.isReceived,
    this.uploadTime,
  });

  BuyRecord.fromJson(Map<String, dynamic> json) {
    recordId = json['record_id'];
    itemName = json['item_name'];
    imageUrl = json['image_url'];
    isReceived = json['is_received'];
    uploadTime = json['upload_time'];
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
}

class Quiz {
  int? quizId;
  String? question;
  List<String>? choices;
  int? leafId;
  int? leafCount;

  Quiz({
    this.quizId,
    this.question,
    this.choices,
    this.leafId,
    this.leafCount,
  });

  Quiz.fromJson(Map<String, dynamic> json) {
    quizId = json['quiz_id'];
    question = json['question'];
    choices = List<String>.from(json['choices'] ?? []);
    leafId = json['leaf_id'];
    leafCount = json['leaf_count'];
  }
}
