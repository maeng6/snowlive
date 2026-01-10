import 'package:get/get.dart';
import 'package:com.snowlive/api/api_fleamarket.dart';
import 'package:com.snowlive/model/m_fleamarket_alert.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';

class FleamarketAlertViewModel extends GetxController {
  final FleamarketAPI _fleamarketAPI = FleamarketAPI();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  // 키워드 알림 목록
  final RxList<KeywordAlert> _keywordAlerts = <KeywordAlert>[].obs;
  List<KeywordAlert> get keywordAlerts => _keywordAlerts;

  // 카테고리 알림 목록
  final RxList<CategoryAlert> _categoryAlerts = <CategoryAlert>[].obs;
  List<CategoryAlert> get categoryAlerts => _categoryAlerts;

  // 로딩 상태
  final RxBool isLoading = false.obs;
  final RxBool isKeywordLoading = false.obs;
  final RxBool isCategoryLoading = false.obs;

  // 키워드 최대 개수
  static const int maxKeywordCount = 10;
  static const int maxCategoryCount = 10;

  // ============ 키워드 알림 ============

  /// 키워드 알림 목록 조회
  Future<void> fetchKeywordAlerts() async {
    final userId = _userViewModel.user.user_id;
    if (userId == null) return;

    isKeywordLoading.value = true;
    try {
      final response = await _fleamarketAPI.fetchKeywordAlerts(userId: userId);
      if (response.success) {
        final List<dynamic> data = response.data as List<dynamic>;
        _keywordAlerts.value = data.map((e) => KeywordAlert.fromJson(e)).toList();
      } else {
        print('키워드 알림 조회 실패: ${response.error}');
      }
    } catch (e) {
      print('키워드 알림 조회 오류: $e');
    } finally {
      isKeywordLoading.value = false;
    }
  }

  /// 키워드 알림 등록
  Future<bool> createKeywordAlert({required String keyword}) async {
    final userId = _userViewModel.user.user_id;
    if (userId == null) return false;

    // 최대 개수 체크
    if (_keywordAlerts.length >= maxKeywordCount) {
      Get.snackbar('알림', '키워드는 최대 ${maxKeywordCount}개까지 등록할 수 있습니다.');
      return false;
    }

    // 중복 체크
    if (_keywordAlerts.any((e) => e.keyword == keyword)) {
      Get.snackbar('알림', '이미 등록된 키워드입니다.');
      return false;
    }

    isKeywordLoading.value = true;
    try {
      final response = await _fleamarketAPI.createKeywordAlert(
        userId: userId,
        keyword: keyword,
      );
      if (response.success) {
        final newAlert = KeywordAlert.fromJson(response.data);
        _keywordAlerts.add(newAlert);
        return true;
      } else {
        print('키워드 알림 등록 실패: ${response.error}');
        Get.snackbar('알림', '키워드 등록에 실패했습니다.');
        return false;
      }
    } catch (e) {
      print('키워드 알림 등록 오류: $e');
      Get.snackbar('알림', '키워드 등록 중 오류가 발생했습니다.');
      return false;
    } finally {
      isKeywordLoading.value = false;
    }
  }

  /// 키워드 알림 삭제
  Future<bool> deleteKeywordAlert({required int keywordAlertId}) async {
    final userId = _userViewModel.user.user_id;
    if (userId == null) return false;

    isKeywordLoading.value = true;
    try {
      final response = await _fleamarketAPI.deleteKeywordAlert(
        userId: userId,
        keywordAlertId: keywordAlertId,
      );
      if (response.success) {
        _keywordAlerts.removeWhere((e) => e.keywordAlertId == keywordAlertId);
        return true;
      } else {
        print('키워드 알림 삭제 실패: ${response.error}');
        Get.snackbar('알림', '키워드 삭제에 실패했습니다.');
        return false;
      }
    } catch (e) {
      print('키워드 알림 삭제 오류: $e');
      Get.snackbar('알림', '키워드 삭제 중 오류가 발생했습니다.');
      return false;
    } finally {
      isKeywordLoading.value = false;
    }
  }

  // ============ 카테고리 알림 ============

  /// 카테고리 알림 목록 조회
  Future<void> fetchCategoryAlerts() async {
    final userId = _userViewModel.user.user_id;
    if (userId == null) return;

    isCategoryLoading.value = true;
    try {
      final response = await _fleamarketAPI.fetchCategoryAlerts(userId: userId);
      if (response.success) {
        final List<dynamic> data = response.data as List<dynamic>;
        _categoryAlerts.value = data.map((e) => CategoryAlert.fromJson(e)).toList();
      } else {
        print('카테고리 알림 조회 실패: ${response.error}');
      }
    } catch (e) {
      print('카테고리 알림 조회 오류: $e');
    } finally {
      isCategoryLoading.value = false;
    }
  }

  /// 카테고리 알림 등록
  Future<bool> createCategoryAlert({
    required String categoryMain,
    required String categorySub,
  }) async {
    final userId = _userViewModel.user.user_id;
    if (userId == null) return false;

    // 최대 개수 체크
    if (_categoryAlerts.length >= maxCategoryCount) {
      Get.snackbar('알림', '카테고리는 최대 ${maxCategoryCount}개까지 등록할 수 있습니다.');
      return false;
    }

    // 중복 체크
    if (_categoryAlerts.any((e) =>
        e.categoryMain == categoryMain && e.categorySub == categorySub)) {
      Get.snackbar('알림', '이미 등록된 카테고리입니다.');
      return false;
    }

    isCategoryLoading.value = true;
    try {
      final response = await _fleamarketAPI.createCategoryAlert(
        userId: userId,
        categoryMain: categoryMain,
        categorySub: categorySub,
      );
      if (response.success) {
        final newAlert = CategoryAlert.fromJson(response.data);
        _categoryAlerts.add(newAlert);
        return true;
      } else {
        print('카테고리 알림 등록 실패: ${response.error}');
        Get.snackbar('알림', '카테고리 등록에 실패했습니다.');
        return false;
      }
    } catch (e) {
      print('카테고리 알림 등록 오류: $e');
      Get.snackbar('알림', '카테고리 등록 중 오류가 발생했습니다.');
      return false;
    } finally {
      isCategoryLoading.value = false;
    }
  }

  /// 카테고리 알림 삭제
  Future<bool> deleteCategoryAlert({required int categoryAlertId}) async {
    final userId = _userViewModel.user.user_id;
    if (userId == null) return false;

    isCategoryLoading.value = true;
    try {
      final response = await _fleamarketAPI.deleteCategoryAlert(
        userId: userId,
        categoryAlertId: categoryAlertId,
      );
      if (response.success) {
        _categoryAlerts.removeWhere((e) => e.categoryAlertId == categoryAlertId);
        return true;
      } else {
        print('카테고리 알림 삭제 실패: ${response.error}');
        Get.snackbar('알림', '카테고리 삭제에 실패했습니다.');
        return false;
      }
    } catch (e) {
      print('카테고리 알림 삭제 오류: $e');
      Get.snackbar('알림', '카테고리 삭제 중 오류가 발생했습니다.');
      return false;
    } finally {
      isCategoryLoading.value = false;
    }
  }

  // ============ 공통 ============

  /// 모든 알림 조회 (키워드 + 카테고리)
  Future<void> fetchAllAlerts() async {
    isLoading.value = true;
    await Future.wait([
      fetchKeywordAlerts(),
      fetchCategoryAlerts(),
    ]);
    isLoading.value = false;
  }

  /// 알림 데이터 초기화
  void clearAlerts() {
    _keywordAlerts.clear();
    _categoryAlerts.clear();
  }
}