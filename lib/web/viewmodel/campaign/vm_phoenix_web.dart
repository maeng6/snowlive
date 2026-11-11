import 'package:com.snowlive/core/api/api_phoenix.dart';
import 'package:get/get.dart';

/// 휘팍 콜라보 랜딩 뷰모델. 이벤트 목록(맵) + 실시간 리더보드/수상자를 담는다.
class PhoenixViewModelWeb extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxList<Map<String, dynamic>> events = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    await _fetch();
    isLoading.value = false;
  }

  /// 전체 스피너 없이 조용히 재조회(개장빵 선착순 새로고침 버튼용 — 화면 유지).
  Future<void> refreshQuietly() => _fetch();

  Future<void> _fetch() async {
    final d = await PhoenixAPI.fetchLanding();
    if (d['ok'] == true) {
      events.value = ((d['events'] as List?) ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      error.value = '';
    } else {
      error.value = '이벤트를 불러오지 못했어요.';
    }
  }

  /// 개장일(opening) 이벤트. 없으면 첫 이벤트.
  Map<String, dynamic>? get openingEvent {
    for (final e in events) {
      if (e['kind'] == 'opening') return e;
    }
    return events.isNotEmpty ? events.first : null;
  }

  List<Map<String, dynamic>> get teasers =>
      events.where((e) => e['status'] == 'teaser').toList();
}
