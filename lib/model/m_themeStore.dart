class ThemeStoreMainResponse {
  ThemeStore? themestore;
  bool? isPermitted;
  List<ThemeStoreItem>? themestoreItems;

  ThemeStoreMainResponse({
    this.themestore,
    this.isPermitted,
    this.themestoreItems,
  });

  ThemeStoreMainResponse.fromJson(Map<String, dynamic> json) {
    themestore =
    json['themestore'] != null ? ThemeStore.fromJson(json['themestore']) : null;
    isPermitted = json['is_permitted'];
    if (json['themestore_items'] != null) {
      themestoreItems = [];
      json['themestore_items'].forEach((v) {
        themestoreItems?.add(ThemeStoreItem.fromJson(v));
      });
    }
  }
}

class ThemeStore {
  int? themestoreId;
  String? name;
  String? mainImageUrl;
  String? brandLandingUrl;
  String? startDate;
  String? endDate;
  bool? active;

  ThemeStore({
    this.themestoreId,
    this.name,
    this.mainImageUrl,
    this.brandLandingUrl,
    this.startDate,
    this.endDate,
    this.active,
  });

  ThemeStore.fromJson(Map<String, dynamic> json) {
    themestoreId = json['themestore_id'] is int
        ? json['themestore_id']
        : (json['themestore_id'] as num?)?.toInt();
    name = json['name'];
    mainImageUrl = json['main_image_url'];
    brandLandingUrl = json['brand_landing_url'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    active = json['active'];
  }
}

class ThemeStoreItem {
  int? themestoreItemId;
  String? name;
  dynamic size; // ✅ 서버에서 int/문자 혼재 가능해서 안전하게
  int? priceOrigin;
  int? priceEvent;
  int? discountPerct;
  int? discountAmt;
  String? description;
  String? imageUrl;
  int? itemCount;
  String? landingUrl;
  String? payUrl;
  bool? active;
  int? themestoreId;
  int? remainingCount;

  ThemeStoreItem({
    this.themestoreItemId,
    this.name,
    this.size,
    this.priceOrigin,
    this.priceEvent,
    this.discountPerct,
    this.discountAmt,
    this.description,
    this.imageUrl,
    this.itemCount,
    this.landingUrl,
    this.payUrl,
    this.active,
    this.themestoreId,
    this.remainingCount,
  });

  ThemeStoreItem.fromJson(Map<String, dynamic> json) {
    themestoreItemId = json['themestore_item_id'] is int
        ? json['themestore_item_id']
        : (json['themestore_item_id'] as num?)?.toInt();
    name = json['name'];
    size = json['size']; // int로도, string으로도 올 수 있음
    priceOrigin = json['price_origin'] is int
        ? json['price_origin']
        : (json['price_origin'] as num?)?.toInt();
    priceEvent = json['price_event'] is int
        ? json['price_event']
        : (json['price_event'] as num?)?.toInt();
    discountPerct = json['discount_perct'] is int
        ? json['discount_perct']
        : (json['discount_perct'] as num?)?.toInt();
    discountAmt = json['discount_amt'] is int
        ? json['discount_amt']
        : (json['discount_amt'] as num?)?.toInt();
    description = json['description'];
    imageUrl = json['image_url'];
    itemCount = json['item_count'] is int
        ? json['item_count']
        : (json['item_count'] as num?)?.toInt();
    landingUrl = json['landing_url'];
    payUrl = json['pay_url'];
    active = json['active'];
    themestoreId = json['themestore_id'] is int
        ? json['themestore_id']
        : (json['themestore_id'] as num?)?.toInt();
    remainingCount = json['remaining_count'] is int
        ? json['remaining_count']
        : (json['remaining_count'] as num?)?.toInt();
  }
}

class ThemeStoreBuyRecordResponse {
  int? themestoreBuyRecordId;
  String? message;
  String? error;

  ThemeStoreBuyRecordResponse({
    this.themestoreBuyRecordId,
    this.message,
    this.error,
  });

  ThemeStoreBuyRecordResponse.fromJson(Map<String, dynamic> json) {
    themestoreBuyRecordId = json['themestore_buy_record_id'] is int
        ? json['themestore_buy_record_id']
        : (json['themestore_buy_record_id'] as num?)?.toInt();
    message = json['message'];
    error = json['error'];
  }
}

/// ✅ 구매내역 응답
class ThemeStoreBuyRecord {
  int? themestoreBuyRecordId;
  String? displayName;
  String? name;
  String? phoneNumber;
  String? uploadTime;

  ThemeStoreItem? themestoreItem; // ✅ 추가 (중첩 객체)

  ThemeStoreBuyRecord({
    this.themestoreBuyRecordId,
    this.displayName,
    this.name,
    this.phoneNumber,
    this.uploadTime,
    this.themestoreItem,
  });

  ThemeStoreBuyRecord.fromJson(Map<String, dynamic> json) {
    themestoreBuyRecordId = json['themestore_buy_record_id'] is int
        ? json['themestore_buy_record_id']
        : (json['themestore_buy_record_id'] as num?)?.toInt();

    displayName = json['display_name'];
    name = json['name'];
    phoneNumber = json['phone_number'];
    uploadTime = json['upload_time'];

    // ✅ 핵심 변경: itemName 제거하고 themestore_item 파싱
    themestoreItem = json['themestore_item'] != null
        ? ThemeStoreItem.fromJson(json['themestore_item'])
        : null;
  }

  /// (옵션) 기존 코드 호환용: record.itemName 처럼 쓰던 곳 살리고 싶으면 사용
  String? get itemName => themestoreItem?.name;
}
