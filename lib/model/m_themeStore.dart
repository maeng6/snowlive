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
    themestore = json['themestore'] != null
        ? ThemeStore.fromJson(json['themestore'])
        : null;
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
    themestoreId = json['themestore_id'];
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
  String? size;
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
    themestoreItemId = json['themestore_item_id'];
    name = json['name'];
    size = json['size'];
    priceOrigin = json['price_origin'];
    priceEvent = json['price_event'];
    discountPerct = json['discount_perct'];
    discountAmt = json['discount_amt'];
    description = json['description'];
    imageUrl = json['image_url'];
    itemCount = json['item_count'];
    landingUrl = json['landing_url'];
    payUrl = json['pay_url'];
    active = json['active'];
    themestoreId = json['themestore_id'];
    remainingCount = json['remaining_count'];
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
    themestoreBuyRecordId = json['themestore_buy_record_id'];
    message = json['message'];
    error = json['error'];
  }
}