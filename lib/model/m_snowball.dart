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
  int? snowballCount;
  int? snowballItemId; // 새로 추가된 필드
  bool? active;

  SnowballShopItem({
    this.name,
    this.count,
    this.snowballCount,
    this.snowballItemId,
    this.active,
  });

  SnowballShopItem.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    count = json['count'];
    snowballCount = json['snowball_count'];
    snowballItemId = json['snowball_item_id']; // JSON에서 새로운 필드 매핑
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

  SnowballBuyRecord({
    this.recordId,
    this.itemName,
    this.color,
    this.snowballCount,
    this.userName,
    this.phoneNumber,
    this.address,
    this.uploadTime,
  });

  SnowballBuyRecord.fromJson(Map<String, dynamic> json) {
    recordId = json['record_id'];
    itemName = json['item_name'];
    color = json['color'];
    snowballCount = json['snowball_count'];
    userName = json['user_name'];
    phoneNumber = json['phone_number'];
    address = json['address'];
    uploadTime = json['upload_time'];
  }
}
