class FleamarketDetailResponse {
  FleamarketDetailModel? fleamarketDetail;

  FleamarketDetailResponse({this.fleamarketDetail});

  FleamarketDetailResponse.fromJson(Map<String, dynamic> json) {
    fleamarketDetail = json['flea_market_detail'] != null
        ? FleamarketDetailModel.fromJson(json['flea_market_detail'])
        : null;
  }
}

class FleamarketDetailModel {
  int? fleaId;
  int? userId;
  String? productName;
  String? categoryMain;
  String? categorySub;
  int? price;
  bool? negotiable;
  String? method;
  String? spot;
  String? snsUrl;
  String? title;
  String? description;
  String? updateTime;
  String? uploadTime;
  List<Photo>? photos;
  int? favoriteCount;
  int? viewsCount;
  UserInfo? userInfo;
  int? commentCount;
  bool? block;
  bool? isFavorite;
  String? status;

  FleamarketDetailModel({
    this.fleaId,
    this.userId,
    this.productName,
    this.categoryMain,
    this.categorySub,
    this.price,
    this.negotiable,
    this.method,
    this.spot,
    this.snsUrl,
    this.title,
    this.description,
    this.updateTime,
    this.uploadTime,
    this.photos,
    this.favoriteCount,
    this.viewsCount,
    this.userInfo,
    this.commentCount,
    this.block,
    this.isFavorite,
    this.status,
  });

  FleamarketDetailModel.fromJson(Map<String, dynamic> json) {
    fleaId = json['flea_id'];
    userId = json['user_id'];
    productName = json['product_name'];
    categoryMain = json['category_main'];
    categorySub = json['category_sub'];
    price = json['price'];
    negotiable = json['negotiable'];
    method = json['method'];
    spot = json['spot'];
    snsUrl = json['sns_url'];
    title = json['title'];
    description = json['description'];
    updateTime = json['update_time'];
    uploadTime = json['upload_time'];
    favoriteCount = json['favorite_count'];
    viewsCount = json['views_count'];
    commentCount = json['comment_count'];
    block = json['block'];
    status = json['status'];
    isFavorite = json['isFavorite'];

    if (json['photos'] != null) {
      photos = [];
      json['photos'].forEach((v) {
        photos?.add(Photo.fromJson(v));
      });
    }

    userInfo = json['user_info'] != null
        ? UserInfo.fromJson(json['user_info'])
        : null;
  }
}

class Photo {
  int? displayOrder;
  String? urlFleaPhoto;

  Photo({this.displayOrder, this.urlFleaPhoto});

  Photo.fromJson(Map<String, dynamic> json) {
    displayOrder = json['display_order'];
    urlFleaPhoto = json['url_flea_photo'];
  }
}

class UserInfo {
  int? userId;
  String? displayName;
  String? profileImageUrlUser;

  UserInfo({this.userId, this.displayName, this.profileImageUrlUser});

  UserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
  }
}
