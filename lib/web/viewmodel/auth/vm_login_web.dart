import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/core/api/api_login.dart';
import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';

/// 웹 로그인 상태. UI(팀원)는 이 값을 Obx로 관찰해 라우팅한다.
/// idle: 초기 / loading: 진행 / success: 로그인 완료(UserViewModel 세팅됨) /
/// needOnboarding: 신규 유저(가입/온보딩 화면으로) / error: 실패(errorMessage 참조)
enum WebLoginStatus { idle, loading, success, needOnboarding, error }

/// 웹 전용 로그인 뷰모델 (UI 없음 — 팀원이 View 작성).
///
/// 흐름: Firebase signInWithPopup(구글/애플) → uid → 서버 web-login 조회 → UserViewModel 세팅.
/// device_id/token/secure_storage 전혀 안 씀 (Firebase가 브라우저 세션 유지).
///
/// [UI 연결 가이드]
///  - 관찰: `status`(WebLoginStatus), `isLoading`, `errorMessage`
///  - 액션: `signInWithGoogle()`, `signInWithApple()`, `signOut()`
///  - status == success  → 홈으로 라우팅
///  - status == needOnboarding → 온보딩/가입 화면으로 (pendingUid/Email/DisplayName 사용)
class LoginViewModelWeb extends GetxController {
  final LoginAPI _loginAPI = LoginAPI();
  UserViewModel get _userVM => Get.find<UserViewModel>();

  final Rx<WebLoginStatus> _status = WebLoginStatus.idle.obs;
  WebLoginStatus get status => _status.value;
  Rx<WebLoginStatus> get statusRx => _status;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  bool get isLoading => _status.value == WebLoginStatus.loading;

  // 온보딩(신규가입) 시 화면에 넘길 정보
  String? pendingUid;
  String? pendingEmail;
  String? pendingDisplayName;
  String? pendingPhotoUrl;

  Future<void> signInWithGoogle() async {
    await _signIn(() {
      final provider = GoogleAuthProvider()..addScope('email');
      return FirebaseAuth.instance.signInWithPopup(provider);
    });
  }

  Future<void> signInWithApple() async {
    await _signIn(() {
      final provider = OAuthProvider('apple.com')
        ..addScope('email')
        ..addScope('name');
      return FirebaseAuth.instance.signInWithPopup(provider);
    });
  }

  Future<void> _signIn(Future<UserCredential> Function() popup) async {
    try {
      _status.value = WebLoginStatus.loading;
      _errorMessage.value = '';
      final cred = await popup();
      final fbUser = cred.user;
      if (fbUser == null) {
        _fail('로그인 정보를 가져오지 못했습니다.');
        return;
      }
      await _afterFirebase(fbUser);
    } catch (e) {
      _fail('로그인 실패: $e');
    }
  }

  /// Firebase 인증 후 서버 web-login 조회 → 결과에 따라 상태 세팅
  Future<void> _afterFirebase(User fbUser) async {
    final ApiResponse res = await _loginAPI.webLogin({'uid': fbUser.uid});
    if (res.success) {
      final data = res.data as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>;
      final userId = _asInt(user['user_id']);
      await _userVM.updateUserModel_api(userId);
      _status.value = WebLoginStatus.success;
    } else {
      final err = res.error as Map<String, dynamic>?;
      if (err != null && err['message'] == '온보딩이동') {
        pendingUid = fbUser.uid;
        pendingEmail = fbUser.email;
        pendingDisplayName = fbUser.displayName;
        pendingPhotoUrl = fbUser.photoURL;
        _status.value = WebLoginStatus.needOnboarding;
      } else {
        _fail('서버 로그인 실패: ${err ?? ''}');
      }
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _status.value = WebLoginStatus.idle;
  }

  void _fail(String msg) {
    _errorMessage.value = msg;
    _status.value = WebLoginStatus.error;
  }

  int _asInt(dynamic v) => v is int ? v : int.parse('$v');
}
