
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
    goldshop = (json['shop_3'] as List?)?.map((v) => SnowballShopItem.fromJson(v)).toList();
    whiteshop = (json['shop'] as List?)?.map((v) => SnowballShopItem.fromJson(v)).toList();
    sponsor = (json['sponsor'] as List?)?.map((v) => SnowballSponsor.fromJson(v)).toList();
  }
}

class SnowballSummary {
  int? white;
  int? gold;

  SnowballSummary({this.white, this.gold});

  SnowballSummary.fromJson(Map<String, dynamic> json) {
    white = json['white'];
    gold = json['gold'];
  }

  Map<String, dynamic> toJson() => {
    'white': white,
    'gold': gold,
  };
}

class SnowballShopItem {
  String? name;
  int? count;
  String? description;
  String? imageUrl;
  int? snowballItemId;
  bool? active;
  String? landingUrl;
  List<SnowballPrice>? price;

  SnowballShopItem({
    this.name,
    this.count,
    this.description,
    this.imageUrl,
    this.snowballItemId,
    this.active,
    this.landingUrl,
    this.price,
  });

  SnowballShopItem.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    count = json['item_count'];
    description = json['description'];
    imageUrl = json['image_url'];
    snowballItemId = json['snowball_item_id'];
    active = json['active'];
    landingUrl = json['landing_url'];
    price = (json['price'] as List?)?.map((e) => SnowballPrice.fromJson(e)).toList();
  }
}

class SnowballPrice {
  int? snowballKindId;
  int? snowballCount;

  SnowballPrice({this.snowballKindId, this.snowballCount});

  SnowballPrice.fromJson(Map<String, dynamic> json) {
    snowballKindId = json['snowball_kind_id'];
    snowballCount = json['snowball_count'];
  }

  Map<String, dynamic> toJson() => {
    'snowball_kind_id': snowballKindId,
    'snowball_count': snowballCount,
  };
}

class SnowballSponsor {
  String? name;
  String? logoUrl;
  String? landingUrl;

  SnowballSponsor({this.name, this.logoUrl, this.landingUrl});

  SnowballSponsor.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    logoUrl = json['logo_url'];
    landingUrl = json['landing_url'];
  }
}

class SnowballBuyRecord {
  int? recordId;
  String? itemName;
  String? uploadTime;
  String? imageUrl;
  List<SnowballPrice>? price;
  bool? isFieldGame;
  bool? isReceived;

  SnowballBuyRecord({
    this.recordId,
    this.itemName,
    this.uploadTime,
    this.imageUrl,
    this.price,
    this.isFieldGame,
    this.isReceived,
  });

  SnowballBuyRecord.fromJson(Map<String, dynamic> json) {
    recordId = json['record_id'];
    itemName = json['item_name'];
    uploadTime = json['upload_time'];
    imageUrl = json['image_url'];
    isFieldGame = json['is_field_game'];
    isReceived = json['is_received'];
    price = (json['price'] as List?)?.map((e) => SnowballPrice.fromJson(e)).toList();
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
  String? slopeName;

  SnowballRecord({
    this.snowballRecordId,
    this.userId,
    this.passTime,
    this.coordinates,
    this.active,
    this.color,
    this.slopeName,
  });

  SnowballRecord.fromJson(Map<String, dynamic> json) {
    snowballRecordId = json['snowball_record_id'];
    userId = json['user_id'];
    passTime = json['pass_time'];
    coordinates = json['coordinates'];
    active = json['active'];
    color = json['color'];
    slopeName = json['slope_name'];
  }

  Map<String, dynamic> toJson() => {
    'snowball_record_id': snowballRecordId,
    'user_id': userId,
    'pass_time': passTime,
    'coordinates': coordinates,
    'active': active,
    'color': color,
    'slope_name': slopeName,
  };
}
