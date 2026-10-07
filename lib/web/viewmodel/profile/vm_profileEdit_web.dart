import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_login.dart';
import 'package:com.snowlive/core/api/api_user.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/viewmodel/util/vm_imageController_web.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// 닉네임 최대 글자 수(앱 · 온보딩과 같다).
const int kProfileNicknameMaxLength = 10;

/// 상태메시지 최대 글자 수(앱과 같다).
const int kProfileStateMsgMaxLength = 20;

enum ProfileEditLoadState { idle, loading, ready, failed }

enum ProfileEditResult { success, nicknameTaken, imageFailed, failed }

/// 내 프로필 편집. `#/profile-edit`
///
/// 앱 `FriendDetailUpdateViewModel`은 모바일 ImageController·전체화면 다이얼로그를 물고 있어
/// 웹에서 쓸 수 없다 → 같은 API로 웹 전용을 둔다. 받는 값 · 보내는 바디는 앱과 같다.
///
/// 앱과 다른 점 두 가지:
/// - 닉네임 중복검사는 별도 버튼 대신 **저장할 때**(바뀌었을 때만) 한다(웹 온보딩과 같은 방식).
/// - 이전 사진 파일은 **저장이 성공한 뒤에** 지운다. 앱은 저장 전에 지워서, 저장이 실패하면
///   프로필이 지워진 사진 주소를 가리킨 채 남는다.
class ProfileEditViewModelWeb extends GetxController {
  ProfileEditViewModelWeb({
    UserAPI? userApi,
    LoginAPI? loginApi,
    ImageControllerWeb? imageController,
    Future<void> Function(String url)? deleteStorageFile,
  })  : _userApi = userApi ?? UserAPI(),
        _loginApi = loginApi ?? LoginAPI(),
        _imageController = imageController ?? Get.put(ImageControllerWeb()),
        _deleteStorageFile = deleteStorageFile ?? _deleteFromFirebaseStorage;

  final UserAPI _userApi;
  final LoginAPI _loginApi;
  final ImageControllerWeb _imageController;
  final Future<void> Function(String url) _deleteStorageFile;

  UserViewModel get _userVM => Get.find<UserViewModel>();
  int? get myUserId => _userVM.user.user_id;

  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController stateMsgController = TextEditingController();

  /// 컨트롤러 텍스트만 보면 Obx가 입력에 반응하지 않는다 → Rx로도 들고 있는다.
  final RxString _nickname = ''.obs;
  final RxnString _nicknameError = RxnString();

  final Rx<ProfileEditLoadState> _loadState = ProfileEditLoadState.idle.obs;
  final RxBool _isSaving = false.obs;

  /// 지금 쓰는 사진 주소(지우면 빈 문자열 = 기본 이미지).
  final RxString _imageUrl = ''.obs;

  /// 새로 고른 사진(저장할 때 올린다).
  final Rxn<XFile> _newImage = Rxn<XFile>();

  static const int _noResort = -1;
  final RxInt _resortIndex = _noResort.obs;
  final RxString _skiOrBoard = ''.obs;
  final RxString _sex = ''.obs;
  final RxBool _hideProfile = false.obs;

  String _originalNickname = '';
  String _originalImageUrl = '';
  int? _instantResort;

  ProfileEditLoadState get loadState => _loadState.value;
  bool get isSaving => _isSaving.value;
  String? get nicknameError => _nicknameError.value;
  String get imageUrl => _imageUrl.value;
  XFile? get newImage => _newImage.value;
  int get resortIndex => _resortIndex.value;
  bool get hasResort => _resortIndex.value != _noResort;
  String get skiOrBoard => _skiOrBoard.value;
  String get sex => _sex.value;
  bool get hideProfile => _hideProfile.value;

  bool get canSave {
    final name = _nickname.value.trim();
    return _loadState.value == ProfileEditLoadState.ready &&
        name.isNotEmpty &&
        name.length <= kProfileNicknameMaxLength &&
        hasResort &&
        _skiOrBoard.value.isNotEmpty &&
        _sex.value.isNotEmpty &&
        !_isSaving.value;
  }

  @override
  void onInit() {
    super.onInit();
    nicknameController.addListener(() {
      _nickname.value = nicknameController.text;
      // 입력을 고치면 이전 중복 결과는 무효다.
      if (_nicknameError.value != null) _nicknameError.value = null;
    });
  }

  @override
  void onClose() {
    nicknameController.dispose();
    stateMsgController.dispose();
    super.onClose();
  }

  /// 최신 내 정보를 받아 폼을 채운다. 앱처럼 상세 화면 값을 넘겨받지 않고 **직접 조회**해서
  /// 편집 화면에서 새로고침해도 폼이 비지 않는다.
  Future<void> load() async {
    final userId = myUserId;
    if (userId == null) return;
    _loadState.value = ProfileEditLoadState.loading;
    _newImage.value = null;
    _nicknameError.value = null;
    try {
      final res = await _userApi.getUserInfo(userId);
      if (!res.success || res.data is! Map) {
        _loadState.value = ProfileEditLoadState.failed;
        return;
      }
      await _userVM.updateUserModel_data(res.data);
      final user = _userVM.user;
      _originalNickname = (user.display_name as String?) ?? '';
      _originalImageUrl = (user.profile_image_url_user as String?) ?? '';
      _instantResort = user.instant_resort as int?;
      nicknameController.text = _originalNickname;
      stateMsgController.text = (user.state_msg as String?) ?? '';
      _imageUrl.value = _originalImageUrl;
      final favorite = user.favorite_resort as int?;
      _resortIndex.value = favorite == null ? _noResort : favorite - 1;
      _skiOrBoard.value = (user.skiorboard as String?) ?? '';
      _sex.value = (user.sex as String?) ?? '';
      _hideProfile.value = (user.hide_profile as bool?) ?? false;
      _loadState.value = ProfileEditLoadState.ready;
    } catch (e) {
      debugPrint('[ProfileEdit] 조회 실패: $e');
      _loadState.value = ProfileEditLoadState.failed;
    }
  }

  void pickImage(XFile file) => _newImage.value = file;

  /// 사진 지우기 → 기본 이미지(빈 주소). 새로 고른 사진도 함께 버린다.
  void removeImage() {
    _newImage.value = null;
    _imageUrl.value = '';
  }

  void selectResort(int index) => _resortIndex.value = index;
  void selectSkiOrBoard(String value) => _skiOrBoard.value = value;
  void selectSex(String value) => _sex.value = value;
  void setHideProfile(bool value) => _hideProfile.value = value;

  Future<ProfileEditResult> save() async {
    final userId = myUserId;
    if (userId == null || !canSave) return ProfileEditResult.failed;
    _isSaving.value = true;
    try {
      final name = _nickname.value.trim();

      // 1) 닉네임이 바뀌었을 때만 중복검사(그대로면 서버가 자기 자신과 겹친다고 본다).
      if (name != _originalNickname) {
        final ApiResponse check = await _loginApi.checkDisplayName({'display_name': name});
        if (!check.success) {
          _nicknameError.value = '이미 사용 중인 닉네임이에요.';
          return ProfileEditResult.nicknameTaken;
        }
      }

      // 2) 새 사진을 먼저 올린다. 실패하면 저장하지 않는다(사진이 사라지면 안 된다).
      var finalImageUrl = _imageUrl.value;
      final picked = _newImage.value;
      if (picked != null) {
        final uid = (_userVM.user.uid as String?) ?? '$userId';
        final uploaded = await _imageController.uploadProfileImage(file: picked, uid: uid);
        if (uploaded.isEmpty) return ProfileEditResult.imageFailed;
        finalImageUrl = uploaded;
      }

      // 3) 앱과 같은 바디.
      final ApiResponse res = await _userApi.updateUserInfo({
        'user_id': userId,
        'display_name': name,
        'state_msg': stateMsgController.text.trim(),
        'profile_image_url_user': finalImageUrl,
        'hide_profile': _hideProfile.value,
        'instant_resort': _instantResort,
        'favorite_resort': _resortIndex.value + 1, // 1-based = resort_id
        'sex': _sex.value,
        'skiorboard': _skiOrBoard.value,
      });
      if (!res.success) return ProfileEditResult.failed;

      // 4) 상단바 아바타·닉네임이 바로 바뀌게 내 정보를 다시 받는다.
      try {
        final fresh = await _userApi.getUserInfo(userId);
        if (fresh.success && fresh.data is Map) await _userVM.updateUserModel_data(fresh.data);
      } catch (_) {}

      // 5) 저장이 끝난 뒤에야 이전 사진 파일을 지운다(바꿨거나 지웠을 때만).
      if (_originalImageUrl.isNotEmpty &&
          _originalImageUrl != finalImageUrl &&
          isOwnStorageUrl(_originalImageUrl)) {
        try {
          await _deleteStorageFile(_originalImageUrl);
        } catch (e) {
          debugPrint('[ProfileEdit] 이전 사진 삭제 실패(무시): $e');
        }
      }
      _originalNickname = name;
      _originalImageUrl = finalImageUrl;
      _imageUrl.value = finalImageUrl;
      _newImage.value = null;
      return ProfileEditResult.success;
    } catch (e) {
      debugPrint('[ProfileEdit] 저장 실패: $e');
      return ProfileEditResult.failed;
    } finally {
      _isSaving.value = false;
    }
  }

  /// 우리 Firebase Storage에 올린 사진만 지운다 — 소셜 로그인 기본 사진 같은
  /// 외부 주소는 건드리지 않는다.
  static bool isOwnStorageUrl(String url) =>
      url.contains('firebasestorage.googleapis.com') || url.startsWith('gs://');

  static Future<void> _deleteFromFirebaseStorage(String url) =>
      FirebaseStorage.instance.refFromURL(url).delete();
}
