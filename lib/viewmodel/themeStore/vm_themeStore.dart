import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_themeStore.dart';
import 'package:com.snowlive/model/m_themeStore.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';

class ThemeStoreViewModel extends GetxController {
  var isLoading = true.obs;
  var _themeStoreMainResponse = ThemeStoreMainResponse().obs;

  ThemeStoreMainResponse get themeStoreMainResponse => _themeStoreMainResponse.value;
  ThemeStore? get themeStore => _themeStoreMainResponse.value.themestore;
  bool get isPermitted => _themeStoreMainResponse.value.isPermitted ?? false;
  List<ThemeStoreItem> get themestoreItems => _themeStoreMainResponse.value.themestoreItems ?? [];

  final ThemeStoreAPI _themeStoreAPI = ThemeStoreAPI();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  /// 테마스토어 메인 데이터 조회
  Future<void> fetchThemeStoreMain() async {
    isLoading(true);
    try {
      final response = await _themeStoreAPI.fetchThemeStoreMain(
        userId: _userViewModel.user.user_id!,
      );
      if (response.success) {
        _themeStoreMainResponse.value = ThemeStoreMainResponse.fromJson(response.data!);
      } else {
        print('Failed to load ThemeStore data: ${response.error}');
      }
    } catch (e) {
      print('Error fetching ThemeStore data: $e');
    } finally {
      isLoading(false);
    }
  }

  /// 구매 기록 생성
  Future<ApiResponse> createBuyRecord({
    required int themestoreItemId,
  }) async {
    try {
      final response = await _themeStoreAPI.createBuyRecord({
        'user_id': _userViewModel.user.user_id,
        'themestore_item_id': themestoreItemId,
      });
      return response;
    } catch (e) {
      print('Error creating buy record: $e');
      return ApiResponse.error({'error': e.toString()});
    }
  }

  /// 구매 기록 수정
  Future<ApiResponse> updateBuyRecord({
    required int themestoreBuyRecordId,
    required Map<String, dynamic> body,
  }) async {
    try {
      body['themestore_buy_record_id'] = themestoreBuyRecordId;
      final response = await _themeStoreAPI.updateBuyRecord(body);
      return response;
    } catch (e) {
      print('Error updating buy record: $e');
      return ApiResponse.error({'error': e.toString()});
    }
  }

  /// 구매 기록 삭제
  Future<ApiResponse> deleteBuyRecord({
    required int themestoreBuyRecordId,
  }) async {
    try {
      final response = await _themeStoreAPI.deleteBuyRecord({
        'user_id': _userViewModel.user.user_id,
        'themestore_buy_record_id': themestoreBuyRecordId,
      });
      return response;
    } catch (e) {
      print('Error deleting buy record: $e');
      return ApiResponse.error({'error': e.toString()});
    }
  }
}