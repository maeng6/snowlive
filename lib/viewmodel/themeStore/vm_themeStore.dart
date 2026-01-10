import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_themeStore.dart';
import 'package:com.snowlive/model/m_themeStore.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';

class ThemeStoreViewModel extends GetxController {
  var isLoading = true.obs;
  var _themeStoreMainResponse = ThemeStoreMainResponse().obs;
  var buyRecords = <ThemeStoreBuyRecord>[].obs;
  var isFetchingRecords = false.obs;

  ThemeStoreMainResponse get themeStoreMainResponse => _themeStoreMainResponse.value;
  ThemeStore? get themeStore => _themeStoreMainResponse.value.themestore;
  bool get isPermitted => _themeStoreMainResponse.value.isPermitted ?? false;
  List<ThemeStoreItem> get themestoreItems => _themeStoreMainResponse.value.themestoreItems ?? [];

  final ThemeStoreAPI _themeStoreAPI = ThemeStoreAPI();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  /// 테마스토어 메인 데이터 조회
  /// [showLoading] - true면 풀스크린 로딩 표시, false면 표시 안함 (pull-to-refresh용)
  Future<void> fetchThemeStoreMain({bool showLoading = true}) async {
    if (showLoading) {
      isLoading(true);
    }
    try {
      // user_id가 null이면 early return
      if (_userViewModel.user.user_id == null) {
        print('Error: user_id is null');
        isLoading(false);
        return;
      }

      final response = await _themeStoreAPI.fetchThemeStoreMain(
        userId: _userViewModel.user.user_id!,
      );
      if (response.success) {
        _themeStoreMainResponse.value = ThemeStoreMainResponse.fromJson(response.data!);
        print('✅ ThemeStore data loaded successfully');
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
    required String name,
    required String phoneNumber,
  }) async {
    try {
      final response = await _themeStoreAPI.createBuyRecord({
        'user_id': _userViewModel.user.user_id,
        'themestore_item_id': themestoreItemId,
        'name': name,
        'phone_number': phoneNumber,
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

  /// 내 구매 기록 목록 조회
  /// [showLoading] - true면 풀스크린 로딩 표시, false면 표시 안함 (pull-to-refresh용)
  Future<void> fetchMyBuyRecords({bool showLoading = true}) async {
    if (showLoading) {
      isFetchingRecords(true);
    }
    try {
      if (_userViewModel.user.user_id == null) {
        print('Error: user_id is null');
        return;
      }

      final response = await _themeStoreAPI.fetchMyBuyRecords(
        userId: _userViewModel.user.user_id!,
      );

      if (!response.success) {
        print('Failed to load buy records: ${response.error}');
        return;
      }

      final dynamic data = response.data;
      List<dynamic> recordsJson = [];

      // ✅ 케이스1) 서버가 List로 바로 내려주는 경우: [ {...}, {...} ]
      if (data is List) {
        recordsJson = data;
      }
      // ✅ 케이스2) 서버가 Map으로 감싸서 내려주는 경우: { "buy_records": [ ... ] }
      else if (data is Map) {
        final map = Map<String, dynamic>.from(data as Map);
        final dynamic candidate = map['buy_records'] ?? map['records'] ?? map['data'] ?? [];
        if (candidate is List) recordsJson = candidate;
      } else {
        print('Unexpected response data type: ${data.runtimeType}');
        buyRecords.clear();
        return;
      }

      // ✅ element 타입이 Map<String,dynamic>이 아닐 수 있어서 안전 변환
      final parsed = <ThemeStoreBuyRecord>[];
      for (final e in recordsJson) {
        if (e is Map<String, dynamic>) {
          parsed.add(ThemeStoreBuyRecord.fromJson(e));
        } else if (e is Map) {
          parsed.add(ThemeStoreBuyRecord.fromJson(Map<String, dynamic>.from(e)));
        } else {
          print('Skip invalid record element type: ${e.runtimeType}');
        }
      }

      buyRecords.value = parsed;
      print('✅ Buy records loaded successfully: ${buyRecords.length} records');
    } catch (e) {
      print('Error fetching buy records: $e');
    } finally {
      isFetchingRecords(false);
    }
  }


}