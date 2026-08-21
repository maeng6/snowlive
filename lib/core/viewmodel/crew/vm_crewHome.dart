import 'package:com.snowlive/core/api/api_crewHome.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// 크루홈 뷰모델. 크루 메뉴 진입 시 상단/중단/하단을 한 번에 조회한다.
/// 게스트(비로그인)도 조회 가능. 최초 조회는 화면에서 [fetchCrewHome]를 호출한다
/// (onInit 자동조회로 두면 진입마다 중복 요청이 나갈 수 있어 화면이 트리거한다).
class CrewHomeViewModel extends GetxController {
  final CrewHomeAPI _api = CrewHomeAPI();

  final Rxn<CrewHomeModel> _home = Rxn<CrewHomeModel>();
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;

  CrewHomeModel? get home => _home.value;
  bool get isLoading => _isLoading.value;

  /// 조회 자체 실패(네트워크/4xx). 개별 항목 파싱 실패는 포함되지 않는다.
  bool get hasError => _hasError.value;

  Future<void> fetchCrewHome() async {
    _isLoading.value = true;
    _hasError.value = false;
    try {
      final res = await _api.fetchCrewHome();
      if (res.success) {
        _home.value = CrewHomeModel.fromJson(res.data as Map<String, dynamic>);
      } else {
        debugPrint('[CrewHome] 조회 실패: ${res.error}');
        _hasError.value = true;
      }
    } catch (e) {
      debugPrint('[CrewHome] 조회 예외: $e');
      _hasError.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refresh() => fetchCrewHome();
}
