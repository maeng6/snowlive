import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_login.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_login_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum WebOnboardingStatus { idle, submitting, success, error }

/// 웹 온보딩(신규가입) 뷰모델. 닉네임 + 관심 리조트만 수집한다
/// (프로필 이미지 / 스키보드 / 성별은 웹 스코프에서 제외 — 핸드오프 문서 참고).
class OnboardingViewModelWeb extends GetxController {
  final LoginAPI _loginAPI = LoginAPI();
  UserViewModel get _userVM => Get.find<UserViewModel>();
  LoginViewModelWeb get _loginVM => Get.find<LoginViewModelWeb>();

  final TextEditingController nicknameController = TextEditingController();

  final RxBool _isCheckedDisplayName = false.obs;
  bool get isCheckedDisplayName => _isCheckedDisplayName.value;

  final RxBool _isCheckingDisplayName = false.obs;
  bool get isCheckingDisplayName => _isCheckingDisplayName.value;

  static const int _noResortSelected = -1;
  final RxInt _selectedResortIndex = _noResortSelected.obs;
  int get selectedResortIndex => _selectedResortIndex.value;
  bool get hasResortSelected => _selectedResortIndex.value != _noResortSelected;

  final Rx<WebOnboardingStatus> _status = WebOnboardingStatus.idle.obs;
  WebOnboardingStatus get status => _status.value;
  Rx<WebOnboardingStatus> get statusRx => _status;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  bool get canSubmit =>
      isCheckedDisplayName && hasResortSelected && status != WebOnboardingStatus.submitting;

  OnboardingViewModelWeb() {
    // 닉네임 수정 시 중복확인 상태 리셋 (모바일 SetProfileViewModel과 동일 패턴)
    nicknameController.addListener(() {
      if (_isCheckedDisplayName.value) _isCheckedDisplayName.value = false;
    });
  }

  @override
  void onInit() {
    super.onInit();
    ever(_status, (status) {
      if (status == WebOnboardingStatus.success) {
        Get.offAllNamed(WebRoutes.fleamarketList);
      }
    });
  }

  Future<void> checkDisplayName() async {
    final name = nicknameController.text.trim();
    if (name.isEmpty) return;
    _isCheckingDisplayName.value = true;
    final ApiResponse res = await _loginAPI.checkDisplayName({'display_name': name});
    _isCheckingDisplayName.value = false;
    _isCheckedDisplayName.value = res.success; // 200 = 사용 가능(중복 아님)
  }

  void selectResort(int index) {
    _selectedResortIndex.value = index;
  }

  Future<void> submit() async {
    if (!canSubmit) return;
    _status.value = WebOnboardingStatus.submitting;
    _errorMessage.value = '';

    final body = {
      'uid': _loginVM.pendingUid,
      'email': _loginVM.pendingEmail,
      'display_name': nicknameController.text.trim(),
      'favorite_resort': _selectedResortIndex.value + 1, // 1-based
      'device_id': 'web',
      'device_token': 'web',
    };

    final ApiResponse res = await _loginAPI.registerUser(body);
    if (res.success) {
      await _userVM.updateUserModel_data(res.data);
      _status.value = WebOnboardingStatus.success;
    } else {
      _errorMessage.value = '가입에 실패했습니다. 잠시 후 다시 시도해주세요.';
      _status.value = WebOnboardingStatus.error;
    }
  }

  @override
  void onClose() {
    nicknameController.dispose();
    super.onClose();
  }
}
