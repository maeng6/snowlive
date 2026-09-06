import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_login.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_login_web.dart';
import 'package:com.snowlive/web/viewmodel/util/vm_imageController_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

enum WebOnboardingStatus { idle, submitting, success, error }

/// 종목 선택지. 서버가 받는 값이 곧 표시 문자열이다(모바일 `w_skiorboard.dart:15`와 동일).
/// 데스크탑 목업에는 `보드`로 적혀 있지만 실제 값·모바일 목업 모두 `스노보드`다.
const List<String> kOnboardingSkiOrBoardOptions = ['스키', '스노보드'];

/// 성별 선택지(모바일 `w_sex.dart:15`와 동일).
const List<String> kOnboardingSexOptions = ['남자', '여자'];

const String _kRegisterFallbackMessage = '가입에 실패했습니다. 잠시 후 다시 시도해주세요.';

/// register 실패 응답을 화면 문구로 바꾼다.
///
/// 서버는 `{"message": "회원가입 실패", "errors": {필드: ["문구"]}}` 형태로 준다.
/// 전에는 이 응답을 버리고 "가입에 실패했습니다"만 띄워서 **무엇이 틀렸는지 알 수 없었다.**
/// 닉네임 오류는 필드 아래로 보내고, 나머지는 필드명을 붙여 하단에 모은다.
({String? nicknameError, String generalMessage}) parseRegisterError(Object? error) {
  if (error is! Map) {
    return (nicknameError: null, generalMessage: _kRegisterFallbackMessage);
  }

  final errors = error['errors'];
  if (errors is! Map || errors.isEmpty) {
    final message = error['message'];
    return (
      nicknameError: null,
      generalMessage:
          (message is String && message.isNotEmpty) ? message : _kRegisterFallbackMessage,
    );
  }

  String? nicknameError;
  final parts = <String>[];
  errors.forEach((field, messages) {
    final text = messages is List
        ? messages.whereType<String>().join(' ')
        : (messages is String ? messages : '');
    if (text.isEmpty) return;
    if (field == 'display_name') {
      nicknameError = '이미 사용 중인 닉네임이에요.';
      return;
    }
    parts.add('$field: $text');
  });

  // 닉네임만 문제였다면 필드 아래 문구로 충분하니 하단은 비운다.
  return (nicknameError: nicknameError, generalMessage: parts.join('\n'));
}

/// 웹 온보딩(신규가입) 뷰모델.
///
/// 수집 항목은 모바일 앱과 같다 — 프로필 이미지 / 닉네임 / 자주가는 스키장 /
/// 종목 / 성별. 약관 동의는 **서버로 보내지 않고** 다음 단계로 넘어가는 게이트로만 쓴다.
class OnboardingViewModelWeb extends GetxController {
  final LoginAPI _loginAPI = LoginAPI();
  final ImageControllerWeb _imageController = Get.put(ImageControllerWeb());
  UserViewModel get _userVM => Get.find<UserViewModel>();
  LoginViewModelWeb get _loginVM => Get.find<LoginViewModelWeb>();

  final TextEditingController nicknameController = TextEditingController();

  /// 닉네임을 Rx로도 들고 있는다. 컨트롤러 텍스트만 보면 `Obx`가 입력에 반응하지
  /// 않는다(어떤 Rx도 바뀌지 않아 리빌드가 안 걸림) — '다음' 버튼이 영영 비활성인
  /// 버그가 실제로 있었다.
  final RxString _nickname = ''.obs;
  String get nickname => _nickname.value;

  /// 닉네임 중복 등 서버 검증 실패 문구. 목업에 중복확인 버튼이 없어서
  /// 제출 시점에 검사하고 필드 아래에 띄운다.
  final RxnString _nicknameError = RxnString();
  String? get nicknameError => _nicknameError.value;

  final Rxn<XFile> _profileImage = Rxn<XFile>();
  XFile? get profileImage => _profileImage.value;

  static const int _noResortSelected = -1;
  final RxInt _selectedResortIndex = _noResortSelected.obs;
  int get selectedResortIndex => _selectedResortIndex.value;
  bool get hasResortSelected => _selectedResortIndex.value != _noResortSelected;

  final RxString _skiOrBoard = ''.obs;
  String get skiOrBoard => _skiOrBoard.value;

  final RxString _sex = ''.obs;
  String get sex => _sex.value;

  final RxBool _agreedTos = false.obs;
  bool get agreedTos => _agreedTos.value;

  final RxBool _agreedPrivacy = false.obs;
  bool get agreedPrivacy => _agreedPrivacy.value;

  bool get agreedAll => _agreedTos.value && _agreedPrivacy.value;

  final Rx<WebOnboardingStatus> _status = WebOnboardingStatus.idle.obs;
  WebOnboardingStatus get status => _status.value;
  Rx<WebOnboardingStatus> get statusRx => _status;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  bool get isSubmitting => _status.value == WebOnboardingStatus.submitting;

  /// 약관 단계 통과 조건. 두 항목 모두 필수다.
  bool get canProceedTerms => agreedAll;

  /// 프로필 단계 제출 조건. 목업의 `*`는 닉네임·스키장에만 붙어 있지만
  /// 모바일 앱과 동일하게 **4개 모두 필수**로 둔다(`v_setProfile.dart:634`).
  bool get canSubmitProfile =>
      _nickname.value.trim().isNotEmpty &&
      hasResortSelected &&
      _skiOrBoard.value.isNotEmpty &&
      _sex.value.isNotEmpty &&
      !isSubmitting;

  OnboardingViewModelWeb() {
    nicknameController.addListener(() {
      _nickname.value = nicknameController.text;
      // 입력을 고치면 이전 검증 결과는 무효다.
      if (_nicknameError.value != null) _nicknameError.value = null;
    });
  }

  void toggleTos() => _agreedTos.value = !_agreedTos.value;

  void togglePrivacy() => _agreedPrivacy.value = !_agreedPrivacy.value;

  /// '전체 동의' — 하나라도 꺼져 있으면 전부 켜고, 다 켜져 있으면 전부 끈다.
  void toggleAgreeAll() {
    final next = !agreedAll;
    _agreedTos.value = next;
    _agreedPrivacy.value = next;
  }

  void setProfileImage(XFile? file) => _profileImage.value = file;

  void selectResort(int index) => _selectedResortIndex.value = index;

  void selectSkiOrBoard(String value) => _skiOrBoard.value = value;

  void selectSex(String value) => _sex.value = value;

  Future<void> submit() async {
    if (!canSubmitProfile) return;
    _status.value = WebOnboardingStatus.submitting;
    _errorMessage.value = '';
    _nicknameError.value = null;

    final name = _nickname.value.trim();

    // 200이면 사용 가능(중복 아님). 목업에 중복확인 버튼이 없어 여기서 검사한다.
    final ApiResponse nameRes = await _loginAPI.checkDisplayName({'display_name': name});
    if (!nameRes.success) {
      _nicknameError.value = '이미 사용 중인 닉네임이에요.';
      _status.value = WebOnboardingStatus.idle;
      return;
    }

    final uid = _loginVM.pendingUid;
    if (uid == null) {
      _errorMessage.value = '로그인 정보가 없습니다. 다시 로그인해주세요.';
      _status.value = WebOnboardingStatus.error;
      return;
    }

    // 프로필 이미지는 가입과 동시에 올려서 URL을 바디에 담는다(모바일과 동일).
    String profileImageUrl = '';
    final picked = _profileImage.value;
    if (picked != null) {
      profileImageUrl = await _imageController.uploadProfileImage(file: picked, uid: uid);
    }

    final body = {
      'uid': uid,
      // ⚠️ Firebase가 이메일을 안 주는 계정이 있다(애플 이메일 가리기, 이메일 스코프를
      // 이미 동의해서 두 번째 로그인부터는 안 내려주는 경우 등). 그대로 null을 보내면
      // 서버가 `{"email":["This field may not be null."]}`로 400을 준다(실측).
      // 모바일 앱이 모든 유저에게 쓰는 `{uid}@1.com` 더미로 채운다.
      'email': _emailOrFallback(uid),
      'display_name': name,
      'favorite_resort': _selectedResortIndex.value + 1, // 1-based = resort_id
      'skiorboard': _skiOrBoard.value,
      'sex': _sex.value,
      'profile_image_url_user': profileImageUrl,
      'device_id': 'web',
      'device_token': 'web',
    };

    final ApiResponse res = await _loginAPI.registerUser(body);
    if (res.success) {
      await _userVM.updateUserModel_data(res.data);
      // 성공 후 이동은 뷰가 결정한다 — 가입 완료 모달을 먼저 보여줘야 한다.
      _status.value = WebOnboardingStatus.success;
    } else {
      _applyRegisterError(res.error);
      _status.value = WebOnboardingStatus.error;
    }
  }

  /// Firebase가 이메일을 안 주는 계정을 위한 대체 주소.
  /// 모바일 앱은 모든 유저에게 이 형식을 쓰므로(`v_setProfile.dart:657`) 서버가 이미 받는 모양이다.
  String _emailOrFallback(String uid) {
    final email = _loginVM.pendingEmail;
    if (email == null || email.trim().isEmpty) return '$uid@1.com';
    return email;
  }

  void _applyRegisterError(Object? error) {
    final parsed = parseRegisterError(error);
    if (parsed.nicknameError != null) _nicknameError.value = parsed.nicknameError;
    _errorMessage.value = parsed.generalMessage;
  }

  @override
  void onClose() {
    nicknameController.dispose();
    super.onClose();
  }
}
