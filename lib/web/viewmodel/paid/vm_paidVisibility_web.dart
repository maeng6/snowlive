import 'package:com.snowlive/core/api/api_seasonPass.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:get/get.dart';

/// 유료기능 진입점 노출 여부(어드민 출시 토글 OR 테스트대상). 웹 전역 싱글턴.
/// 출시 전에는 테스트 대상에게만 true → 시즌권 메뉴·실시간위치 탭 등을 노출.
/// 어드민에서 paid_features_live를 켜면 전체 유저 true.
class PaidVisibilityControllerWeb extends GetxController {
  final RxBool showPaid = false.obs;
  // 웹 GNB 메뉴 온오프 맵 {route_prefix: bool}. 키 없으면 노출(true).
  final RxMap<String, bool> menus = <String, bool>{}.obs;
  final RxBool todayRanking = true.obs; // 웹 홈 '오늘의 랭킹' 섹션
  final SeasonPassAPI _api = SeasonPassAPI();

  @override
  void onInit() {
    super.onInit();
    // 로그인 확정/전환 시마다 다시 조회(게스트면 false).
    if (Get.isRegistered<AuthCheckViewModelWeb>()) {
      final auth = Get.find<AuthCheckViewModelWeb>();
      ever<WebAuthStatus>(auth.statusRx, (_) => refresh());
    }
    refresh();
  }

  int? get _uid {
    if (!Get.isRegistered<UserViewModel>()) return null;
    final id = Get.find<UserViewModel>().user?.user_id;
    return (id is int) ? id : int.tryParse('$id');
  }

  Future<void> refresh() async {
    final uid = _uid; // 게스트면 null — 메뉴 토글은 그래도 반영돼야 하므로 그대로 조회.
    if (uid == null) {
      showPaid.value = false; // 유료 진입점은 비로그인 숨김(기존 정책)
    }
    try {
      final res = await _api.fetchVisibility(userId: uid);
      if (res.success && res.data is Map) {
        showPaid.value = res.data['show_paid'] == true;
        final m = res.data['menus'];
        if (m is Map) {
          menus.assignAll(m.map((k, v) => MapEntry('$k', v == true)));
        }
        if (res.data['today_ranking'] != null) {
          todayRanking.value = res.data['today_ranking'] == true;
        }
      }
    } catch (_) {
      // 조회 실패 시 유료는 숨김(보수적), 랭킹은 기본 노출 유지.
    }
  }

  static PaidVisibilityControllerWeb? get _c =>
      Get.isRegistered<PaidVisibilityControllerWeb>()
          ? Get.find<PaidVisibilityControllerWeb>()
          : null;

  /// 유료기능 진입점 노출 여부. 미등록 환경(테스트 등)에선 false.
  static bool get isVisible => _c?.showPaid.value ?? false;

  /// 웹 GNB 메뉴(route prefix) 노출 여부. 맵에 키가 없으면 기본 노출(true).
  static bool menuVisible(String? routePrefix) =>
      routePrefix == null ? true : (_c?.menus[routePrefix] ?? true);

  /// 웹 홈 '오늘의 랭킹' 섹션 노출 여부. 기본 노출(true).
  static bool get todayRankingVisible => _c?.todayRanking.value ?? true;
}
