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

  /// GNB로 (다시) 들어올 때 — 섹션 메인 상태(`전체`)로 되돌리고 목록을 새로 받는다.
  ///
  /// 이 뷰모델은 라우트가 스택에 남아 있는 한 살아 있어서(다른 탭 갔다가 GNB로
  /// 돌아오면 `Get.toNamed`가 새 라우트를 쌓고 `Get.find`는 같은 인스턴스를 준다)
  /// 아무것도 안 하면 전에 고른 카테고리·오래된 목록이 그대로 보인다(사용자 지적).
  /// 최초 진입은 [onInit]의 [load]가 이미 돌고 있으니 중복 조회하지 않는다.
  /// 이미 받은 목록은 비우지 않는다 — 화면은 `isLoading && items.isEmpty`일 때만
  /// 스켈레톤이라 기존 카드 위로 조용히 갱신된다.
  void enterFromGnb() {
    _selectedCategory.value = kShopAllCategory;
    if (!_isLoading.value) load();
  }
}
