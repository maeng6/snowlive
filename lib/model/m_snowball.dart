class SnowballHomeResponse {
  SnowballSummary? summary;
  List<SnowballShopItem>? goldshop;
  List<SnowballShopItem>? whiteshop;
  List<SnowballSponsor>? sponsor;

  SnowballHomeResponse({
    this.summary,
    this.goldshop,
    this.whiteshop,
    this.sponsor,
  });

  SnowballHomeResponse.fromJson(Map<String, dynamic> json) {
    summary = json['summary'] != null ? SnowballSummary.fromJson(json['summary']) : null;
    goldshop = (json['goldshop'] as List?)?.map((v) => SnowballShopItem.fromJson(v)).toList();
    whiteshop = (json['whiteshop'] as List?)?.map((v) => SnowballShopItem.fromJson(v)).toList();
    sponsor = (json['sponsor'] as List?)?.map((v) => SnowballSponsor.fromJson(v)).toList();
  }
}

class SnowballSummary {
  int? white;
  int? gold;

  SnowballSummary({
    this.white,
    this.gold,
  });

  SnowballSummary.fromJson(Map<String, dynamic> json) {
    white = json['white'];
    gold = json['gold'];
  }
}

class SnowballShopItem {
  String? name;
  int? count;
  String? description;
  String? imageUrl;
  int? snowballCount;
  int? snowballItemId;
  bool? active;

  SnowballShopItem({
    this.name,
    this.count,
    this.description,
    this.imageUrl,
    this.snowballCount,
    this.snowballItemId,
    this.active,
  });

  SnowballShopItem.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    count = json['count'];
    description = json['description'];
    imageUrl = json['image_url'];
    snowballCount = json['snowball_count'];
    snowballItemId = json['snowball_item_id'];
    active = json['active'];
  }
}

class SnowballSponsor {
  String? name;
  String? logoUrl;

  SnowballSponsor({
    this.name,
    this.logoUrl,
  });

  SnowballSponsor.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    logoUrl = json['logo_url'];
  }
}

class SnowballBuyRecord {
  int? recordId;
  String? itemName;
  String? color;
  int? snowballCount;
  String? userName;
  String? phoneNumber;
  String? address;
  String? uploadTime;
  String? imageUrl;

  SnowballBuyRecord({
    this.recordId,
    this.itemName,
    this.color,
    this.snowballCount,
    this.userName,
    this.phoneNumber,
    this.address,
    this.uploadTime,
    this.imageUrl
  });

  SnowballBuyRecord.fromJson(Map<String, dynamic> json) {
    recordId = json['record_id'];
    itemName = json['item_name'];
    color = json['color'];
    snowballCount = json['count'];
    userName = json['user_name'];
    phoneNumber = json['phone_number'];
    address = json['address'];
    uploadTime = json['upload_time'];
    imageUrl = json['image_url'];
  }
}

class SnowballRecordResponse {
  List<SnowballRecord>? records;

  SnowballRecordResponse({this.records});

  SnowballRecordResponse.fromJson(List<dynamic> jsonList) {
    records = jsonList.map((v) => SnowballRecord.fromJson(v)).toList();
  }
}

class SnowballRecord {
  int? snowballRecordId;
  int? userId;
  String? passTime;
  String? coordinates;
  bool? active;
  String? color;

  SnowballRecord({
    this.snowballRecordId,
    this.userId,
    this.passTime,
    this.coordinates,
    this.active,
    this.color,
  });

  SnowballRecord.fromJson(Map<String, dynamic> json) {
    snowballRecordId = json['snowball_record_id'];
    userId = json['user_id'];
    passTime = json['pass_time'];
    coordinates = json['coordinates'];
    active = json['active'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    return {
      'snowball_record_id': snowballRecordId,
      'user_id': userId,
      'pass_time': passTime,
      'coordinates': coordinates,
      'active': active,
      'color': color,
    };
  }
}
