import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/core/api/api_login.dart';
import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';

/// 웹 자동로그인 상태. UI(팀원)는 스플래시/가드에서 이 값으로 라우팅한다.
enum WebAuthStatus { checking, authenticated, unauthenticated, needOnboarding }

/// 웹 전용 자동로그인 뷰모델 (UI 없음).
///
/// Firebase가 브라우저에 세션을 자동 유지하므로, 앱 로드 시 세션을 확인해
/// 로그인 상태를 복원한다. secure_storage/device 불필요.
///
/// [UI 연결 가이드]
///  - 앱 진입(스플래시)에서 `checkAuth()` 호출 후 `status` 관찰
///  - authenticated → 홈 / unauthenticated → 로그인 / needOnboarding → 온보딩
class AuthCheckViewModelWeb extends GetxController {
  final LoginAPI _loginAPI = LoginAPI();
  UserViewModel get _userVM => Get.find<UserViewModel>();

  final Rx<WebAuthStatus> _status = WebAuthStatus.checking.obs;
  WebAuthStatus get status => _status.value;
  Rx<WebAuthStatus> get statusRx => _status;

  @override
  void onInit() {
    super.onInit();
    checkAuth();
  }

  Future<void> checkAuth() async {
    _status.value = WebAuthStatus.checking;
    // authStateChanges().first: Firebase가 저장된 세션을 복원할 때까지 대기 (currentUser는 초기에 null일 수 있음)
    final User? fbUser = await FirebaseAuth.instance.authStateChanges().first;
    // 과거에 쓰던 익명 세션이 브라우저에 남아 있으면, 그 계정이 콘솔에서 삭제됐거나
    // 익명 공급자가 꺼진 경우 토큰 갱신이 identitytoolkit 400으로 계속 실패한다.
    // 더 이상 익명 로그인을 쓰지 않으므로, 남아 있으면 조용히 정리(로그아웃)한다.
    if (fbUser != null && fbUser.isAnonymous) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      _status.value = WebAuthStatus.unauthenticated;
      return;
    }
    if (fbUser == null) {
      _status.value = WebAuthStatus.unauthenticated;
      return;
    }
    try {
      final ApiResponse res = await _loginAPI.webLogin({'uid': fbUser.uid});
      if (res.success) {
        final user = (res.data as Map<String, dynamic>)['user'] as Map<String, dynamic>;
        await _userVM.updateUserModel_api(_asInt(user['user_id']));
        _status.value = WebAuthStatus.authenticated;
      } else {
        final err = res.error as Map<String, dynamic>?;
        _status.value = (err != null && err['message'] == '온보딩이동')
            ? WebAuthStatus.needOnboarding
            : WebAuthStatus.unauthenticated;
      }
    } catch (_) {
      _status.value = WebAuthStatus.unauthenticated;
    }
  }

  /// 로그인/회원가입이 끝난 직후 호출한다.
  ///
  /// ⚠️ [checkAuth]는 `onInit`에서 **앱 로드 때 한 번만** 돌고, 그 뒤 상태를 바꾸는 건
  /// [signOut]뿐이었다. 그래서 세션 중에 로그인해도 `status`가 `unauthenticated`에
  /// 머물러, 이 값을 보는 화면들이 전부 로그인 전 상태로 남았다
  /// (키워드 알림 설정이 로그인 후에도 로그인 유도를 계속 띄우던 문제,
  ///  커뮤니티·중고거래 상세의 `ever(statusRx)` 재조회가 안 걸리던 문제).
  ///
  /// 호출 시점에 [LoginViewModelWeb]/온보딩이 이미 서버 조회와 [UserViewModel]
  /// 세팅을 마쳤으므로 다시 네트워크를 타지 않고 상태만 맞춘다.
  void markAuthenticated() {
    if (_status.value == WebAuthStatus.authenticated) return;
    _status.value = WebAuthStatus.authenticated;
  }

  /// 로그아웃 공통 — Firebase 세션 · `status` · **[UserViewModel]까지 한 번에** 비운다.
  ///
  /// ⚠️ 예전에는 유저 모델을 호출부가 각자 지웠다(GNB 3곳만 `resetUser()`를 불렀다).
  /// 그래서 설정 화면의 로그아웃·회원탈퇴는 세션만 끊고 모델이 남아, GNB가
  /// 계속 로그인 상태(프로필·마이페이지)로 보였다. 로그인 여부를 보는 화면은
  /// `status`가 아니라 `userVM.user.user_id`를 읽는 곳이 많아서 체감상 "로그아웃이
  /// 안 되는" 상태가 된다.
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _userVM.resetUser();
    _status.value = WebAuthStatus.unauthenticated;
  }

  int _asInt(dynamic v) => v is int ? v : int.parse('$v');
}
