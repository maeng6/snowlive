import 'package:com.snowlive/core/model/m_affiliate_product.dart';
import 'package:com.snowlive/web/data/affiliate_product_repository_web.dart';
import 'package:com.snowlive/web/view/shop/shop_sections_web.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// 추천 상품(쿠팡 파트너스) 화면 뷰모델.
///
/// 데이터 출처는 [AffiliateProductRepository] 하나로 추상화돼 있다 — 지금은 하드코딩
/// JSON, 나중엔 서버 API. 화면은 `items`·`selectedCategory`만 본다.
class ShopViewModelWeb extends GetxController {
  final AffiliateProductRepository _repo;

  ShopViewModelWeb(this._repo);

  final RxList<AffiliateProduct> _items = <AffiliateProduct>[].obs;
  final RxString _selectedCategory = kShopAllCategory.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;

  List<AffiliateProduct> get items => _items;
  String get selectedCategory => _selectedCategory.value;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;

  /// `전체` + 데이터에 있는 카테고리.
  List<String> get categories => shopCategories(_items);

  /// 지금 고른 카테고리의 상품.
  List<AffiliateProduct> get visibleItems =>
      shopVisibleItems(_items, _selectedCategory.value);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    _isLoading.value = true;
    _hasError.value = false;
    try {
      _items.assignAll(await _repo.fetchAll());
    } catch (e) {
      debugPrint('[Shop] 추천 상품 조회 실패: $e');
      _hasError.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  void selectCategory(String category) {
    _selectedCategory.value = category;
  }
}
