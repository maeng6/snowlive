class SnowballHomeResponse {
  List<SnowballKindRemain>? summary;   // [{kind, remaining}]
  List<SnowballRecord>? records;       // 눈송이 획득 기록
  List<SnowballSponsor>? sponsor;      // 스폰서 리스트

  SnowballHomeResponse({this.summary, this.records, this.sponsor});

  SnowballHomeResponse.fromJson(Map<String, dynamic> json) {
    summary = (json['summary'] as List?)
        ?.map((v) => SnowballKindRemain.fromJson(v))
        .toList();
    records = (json['records'] as List?)
        ?.map((v) => SnowballRecord.fromJson(v))
        .toList();
    sponsor = (json['sponsor'] as List?)
        ?.map((v) => SnowballSponsor.fromJson(v))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary?.map((e) => e.toJson()).toList(),
      'records': records?.map((e) => e.toJson()).toList(),
      'sponsor': sponsor?.map((e) => e.toJson()).toList(),
    };
  }
}

class SnowballKindRemain {
  String? kind;
  int? remaining;

  SnowballKindRemain({this.kind, this.remaining});

  SnowballKindRemain.fromJson(Map<String, dynamic> json) {
    kind = json['kind'];
    remaining = json['remaining'];
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'remaining': remaining,
    };
  }
}

class SnowballSponsor {
  String? name;
  String? logoUrl;
  String? landingUrl;
  String? badgeUrl;

  SnowballSponsor({this.name, this.logoUrl, this.landingUrl,this.badgeUrl});

  SnowballSponsor.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    logoUrl = json['logo_url'];
    landingUrl = json['landing_url'];
    badgeUrl = json['badge_url'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logo_url': logoUrl,
      'landing_url': landingUrl,
      'badge_url': badgeUrl,
    };
  }
}

// -----------------------------
// 상점 응답
// -----------------------------
class SnowballShopResponse {
  List<SnowballKindRemain>? summary;        // [{kind, remaining}]
  List<SnowballShopItem>? items;            // 일반 상점 아이템
  List<SnowballShopItem>? brandItems;       // ✅ is_for_mission=true일 때만 내려옴
  bool? isPremiumUser;                      // ✅ 서버 필드: is_premium_user

  SnowballShopResponse({
    this.summary,
    this.items,
    this.brandItems,
    this.isPremiumUser,
  });

  SnowballShopResponse.fromJson(Map<String, dynamic> json) {
    summary = (json['summary'] as List?)
        ?.map((e) => SnowballKindRemain.fromJson(e))
        .toList();

    items = (json['items'] as List?)
        ?.map((e) => SnowballShopItem.fromJson(e))
        .toList();

    // 서버가 is_for_mission=true일 때만 내려줌(없으면 null)
    brandItems = (json['brand_items'] as List?)
        ?.map((e) => SnowballShopItem.fromJson(e))
        .toList();

    isPremiumUser = json['is_premium_user'];
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary?.map((e) => e.toJson()).toList(),
      'items': items?.map((e) => e.toJson()).toList(),
      if (brandItems != null)
        'brand_items': brandItems?.map((e) => e.toJson()).toList(),
      'is_premium_user': isPremiumUser,
    };
  }
}


class PriceEntry {
  int? snowballKindId;
  int? snowballCount;

  PriceEntry({this.snowballKindId, this.snowballCount});

  PriceEntry.fromJson(Map<String, dynamic> json) {
    snowballKindId = json['snowball_kind_id'];
    snowballCount = json['snowball_count'];
  }

  Map<String, dynamic> toJson() {
    return {
      'snowball_kind_id': snowballKindId,
      'snowball_count': snowballCount,
    };
  }
}

class SnowballShopItem {
  String? name;
  String? description;
  int? itemCount; // 남은 수량 (혹은 null=무제한)
  String? imageUrl;
  int? snowballItemId;
  List<PriceEntry>? price; // [{snowball_kind_id, snowball_count}]
  bool? active;            // 내가 이미 구매했으면 false
  String? landingUrl;
  bool? isTierOnly;
  bool? isForMission;
  bool? isFieldGame;

  SnowballShopItem({
    this.name,
    this.description,
    this.itemCount,
    this.imageUrl,
    this.snowballItemId,
    this.price,
    this.active,
    this.landingUrl,
    this.isTierOnly,
    this.isForMission,
    this.isFieldGame,
  });

  SnowballShopItem.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    itemCount = json['item_count'];
    imageUrl = json['image_url'];
    snowballItemId = json['snowball_item_id'];
    price = (json['price'] as List?)
        ?.map((e) => PriceEntry.fromJson(e))
        .toList();
    active = json['active'];
    landingUrl = json['landing_url'];
    isTierOnly = json['is_tier_only'];
    isForMission = json['is_for_mission'];
    isFieldGame = json['is_field_game'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'item_count': itemCount,
      'image_url': imageUrl,
      'snowball_item_id': snowballItemId,
      'price': price?.map((e) => e.toJson()).toList(),
      'active': active,
      'landing_url': landingUrl,
      'is_tier_only': isTierOnly,
      'is_for_mission': isForMission,
      'is_field_game': isFieldGame,
    };
  }
}

// -----------------------------
// 구매 기록
// -----------------------------
class SnowballBuyRecord {
  int? recordId;
  String? itemName;
  String? imageUrl;
  List<PriceEntry>? price;
  String? uploadTime;  // ISO 문자열
  bool? isFieldGame;   // 현장게임 여부
  bool? isReceived;    // 수령 처리 여부

  SnowballBuyRecord({
    this.recordId,
    this.itemName,
    this.imageUrl,
    this.price,
    this.uploadTime,
    this.isFieldGame,
    this.isReceived,
  });

  SnowballBuyRecord.fromJson(Map<String, dynamic> json) {
    recordId = json['record_id'];
    itemName = json['item_name'];
    imageUrl = json['image_url'];
    price = (json['price'] as List?)
        ?.map((e) => PriceEntry.fromJson(e))
        .toList();
    uploadTime = json['upload_time'];
    isFieldGame = json['is_field_game'];
    isReceived = json['is_received'];
  }

  Map<String, dynamic> toJson() {
    return {
      'record_id': recordId,
      'item_name': itemName,
      'image_url': imageUrl,
      'price': price?.map((e) => e.toJson()).toList(),
      'upload_time': uploadTime,
      'is_field_game': isFieldGame,
      'is_received': isReceived,
    };
  }
}

// -----------------------------
// 눈송이 기록(개별 기록 객체)
// -----------------------------
class SnowballRecord {
  int? snowballRecordId;
  int? userId;
  String? passTime;
  String? coordinates; // 서버가 문자열/Geo JSON을 문자열 형태로 제공한다고 가정
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
    color = json['snowball_kind'];
    slopeName = json['slope_name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'snowball_record_id': snowballRecordId,
      'user_id': userId,
      'pass_time': passTime,
      'coordinates': coordinates,
      'active': active,
      'color': color,
      'slope_name': slopeName,
    };
  }
}

// -----------------------------
// 미션 상태
// -----------------------------
class MissionPiece {
  String? title;
  bool? complete;

  MissionPiece({this.title, this.complete});

  MissionPiece.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    complete = json['complete'];
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'complete': complete,
    };
  }
}

class MissionStatus {
  // mission_status: { mission_1:{title,complete}, ... }
  Map<String, MissionPiece>? missionStatus;
  bool? completeTotal;
  List<BrandItemPremium>? brandItemPremium;
  List<BrandItemBasic>? brandItemBasic;
  bool? isApplied;

  MissionStatus({
    this.missionStatus,
    this.completeTotal,
    this.brandItemPremium,
    this.brandItemBasic,
    this.isApplied,
  });

  MissionStatus.fromJson(Map<String, dynamic> json) {
    final ms = json['mission_status'];
    if (ms is Map) {
      missionStatus = {};
      ms.forEach((k, v) {
        missionStatus![k.toString()] = MissionPiece.fromJson(v);
      });
    }
    completeTotal = json['complete_total'];
    brandItemPremium = (json['brand_item_premium'] as List?)
        ?.map((e) => BrandItemPremium.fromJson(e))
        .toList();
    brandItemBasic = (json['brand_item_basic'] as List?)
        ?.map((e) => BrandItemBasic.fromJson(e))
        .toList();
    isApplied = json['is_applied'];
  }

  Map<String, dynamic> toJson() {
    return {
      'mission_status':
      missionStatus?.map((k, v) => MapEntry(k, v.toJson())),
      'complete_total': completeTotal,
      'brand_item_premium':
      brandItemPremium?.map((e) => e.toJson()).toList(),
      'brand_item_basic':
      brandItemBasic?.map((e) => e.toJson()).toList(),
      'is_applied': isApplied,
    };
  }
}

class BrandItemPremium {
  int? snowballItemBrandId;
  String? name;
  String? description;
  String? imageUrl;
  int? itemCount;
  String? landingUrl;
  int? eventDate;

  BrandItemPremium({
    this.snowballItemBrandId,
    this.name,
    this.description,
    this.imageUrl,
    this.itemCount,
    this.landingUrl,
    this.eventDate,
  });

  BrandItemPremium.fromJson(Map<String, dynamic> json) {
    snowballItemBrandId = json['snowball_item_brand_id'];
    name = json['name'];
    description = json['description'];
    imageUrl = json['image_url'];
    itemCount = json['item_count'];
    landingUrl = json['landing_url'];
    eventDate = json['event_date'];
  }

  Map<String, dynamic> toJson() {
    return {
      'snowball_item_brand_id': snowballItemBrandId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'item_count': itemCount,
      'landing_url': landingUrl,
      'event_date': eventDate,
    };
  }
}

class BrandItemBasic {
  int? snowballItemId;
  String? name;
  String? description;
  String? imageUrl;
  List<PriceEntry>? price;
  String? landingUrl;
  int? eventDate;
  bool? isFieldGame;
  bool? isTierOnly;
  bool? isForMission;

  BrandItemBasic({
    this.snowballItemId,
    this.name,
    this.description,
    this.imageUrl,
    this.price,
    this.landingUrl,
    this.eventDate,
    this.isFieldGame,
    this.isTierOnly,
    this.isForMission,
  });

  BrandItemBasic.fromJson(Map<String, dynamic> json) {
    snowballItemId = json['snowball_item_id'];
    name = json['name'];
    description = json['description'];
    imageUrl = json['image_url'];
    price = (json['price'] as List?)
        ?.map((e) => PriceEntry.fromJson(e))
        .toList();
    landingUrl = json['landing_url'];
    eventDate = json['event_date'];
    isFieldGame = json['is_field_game'];
    isTierOnly = json['is_tier_only'];
    isForMission = json['is_for_mission'];
  }

  Map<String, dynamic> toJson() {
    return {
      'snowball_item_id': snowballItemId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price?.map((e) => e.toJson()).toList(),
      'landing_url': landingUrl,
      'event_date': eventDate,
      'is_field_game': isFieldGame,
      'is_tier_only': isTierOnly,
      'is_for_mission': isForMission,
    };
  }
}
