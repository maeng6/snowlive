import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_login.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// 설정 화면의 쓰기 동작(로그아웃·회원탈퇴).
///
/// 읽을 게 없는 화면이라 뷰모델은 얇다. 다만 회원탈퇴는 실패 사유를 화면에서
/// 구분해 안내해야 해서(크루장은 탈퇴 불가) 결과를 [SettingsWithdrawResult]로 돌려준다.
class SettingsViewModelWeb extends GetxController {
  final LoginAPI _loginAPI = LoginAPI();

  UserViewModel get _userVM => Get.find<UserViewModel>();
  AuthCheckViewModelWeb get _authVM => Get.find<AuthCheckViewModelWeb>();

  final RxBool _isSubmitting = false.obs;
  bool get isSubmitting => _isSubmitting.value;

  int? get myUserId => _userVM.user.user_id;
  bool get isLoggedIn => myUserId != null;

  Future<void> signOut() => _authVM.signOut();

  /// 회원탈퇴. 서버에서 지운 뒤 Firebase 세션까지 끊는다.
  ///
  /// 앱은 여기서 프로필 이미지(Storage)와 SecureStorage까지 정리하는데, 웹은
  /// 그 저장소를 쓰지 않고 이미지 삭제는 서버/앱 쪽 책임이라 건드리지 않는다.
  Future<SettingsWithdrawResult> withdraw() async {
    final userId = myUserId;
    if (userId == null) return SettingsWithdrawResult.notLoggedIn;

    _isSubmitting(true);
    try {
      final ApiResponse res = await _loginAPI.deleteUser(userId);
      if (res.success) {
        await FirebaseAuth.instance.signOut();
        await _authVM.signOut();
        return SettingsWithdrawResult.success;
      }
      // 서버가 사유를 문자열로 준다(앱과 같은 메시지).
      final error = res.error;
      final reason = error is Map ? '${error['error'] ?? ''}' : '';
      if (reason.contains('크루장')) return SettingsWithdrawResult.crewLeader;
      return SettingsWithdrawResult.failed;
    } catch (_) {
      return SettingsWithdrawResult.failed;
    } finally {
      _isSubmitting(false);
    }
  }
}

/// 회원탈퇴 결과. 화면이 이 값으로 안내 문구를 고른다.
enum SettingsWithdrawResult {
  success,
  /// 크루장은 위임/삭제 후에만 탈퇴할 수 있다(서버 정책).
  crewLeader,
  failed,
  notLoggedIn,
}
