import 'package:com.snowlive/core/api/api_seasonPass.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:get/get.dart';

/// 유료기능 진입점 노출 여부(어드민 출시 토글 OR 테스트대상). 웹 전역 싱글턴.
/// 출시 전에는 테스트 대상에게만 true → 시즌권 메뉴·실시간위치 탭 등을 노출.
/// 어드민에서 paid_features_live를 켜면 전체 유저 true.
class PaidVisibilityControllerWeb extends GetxController {
  final RxBool showPaid = false.obs;
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
    final uid = _uid;
    if (uid == null) {
      showPaid.value = false;
      return;
    }
    try {
      final res = await _api.fetchVisibility(userId: uid);
      if (res.success && res.data is Map) {
        showPaid.value = res.data['show_paid'] == true;
      }
    } catch (_) {
      // 조회 실패 시 노출하지 않음(보수적).
    }
  }

  /// 전역 접근 헬퍼. 미등록 환경(테스트 등)에선 false로 간주.
  static bool get isVisible => Get.isRegistered<PaidVisibilityControllerWeb>()
      ? Get.find<PaidVisibilityControllerWeb>().showPaid.value
      : false;
}
