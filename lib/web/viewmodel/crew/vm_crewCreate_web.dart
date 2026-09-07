import 'dart:convert';

import 'package:com.snowlive/core/api/api_crew.dart';
import 'package:com.snowlive/core/model/m_crewList.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:com.snowlive/web/viewmodel/util/vm_imageController_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// 크루 이름 최대 길이(목업 placeholder: `최대 10자 이내`).
const int kCrewNameMaxLength = 10;

/// 목업 기본 선택 색(첫 번째 = 빨강).
const int kCrewDefaultColorIndex = 0;

/// 크루 대표 색 8개. 앱과 같은 팔레트를 그대로 쓴다 — 색 문자열이
/// `crewDefaultLogoUrl`의 키이기도 해서 색을 바꾸면 기본 로고도 같이 바뀐다.
List<Color> get kCrewColors =>
    crewColorList.take(8).whereType<Color>().toList(growable: false);

/// `Color` → 서버가 쓰는 `"0XFFEA4E4E"` 문자열(앱 `vm_setCrew.colorToHex`와 동일).
String crewColorToHex(Color color) =>
    '0X${color.toARGB32().toRadixString(16).toUpperCase()}';

/// 크루 생성 뷰모델.
///
/// 코어 [SetCrewViewModel]은 웹에서 **컴파일 자체가 안 된다** — 파일 첫 줄이
/// `import 'dart:io'`이고 `path_provider`·`image_cropper`·`File`을 실제로 쓴다
/// (`vm_setCrew.dart:1,18,195`). 그래서 생성 절차만 웹 파이프라인으로 다시 짰다.
class CrewCreateViewModelWeb extends GetxController {
  final CrewAPI _api = CrewAPI();

  /// 다른 API 클래스들과 같은 상수(코어에 공유 상수가 없어 그 관례를 따른다).
  static const String _crewBaseUrl =
      'https://snowlive-api-c617725e2b78.herokuapp.com/api/crew';

  UserViewModel get _userVM => Get.find<UserViewModel>();
  ImageControllerWeb get _imageController => Get.find<ImageControllerWeb>();

  final RxString _crewName = ''.obs;
  /// 아직 안 고른 상태. 목업 모바일은 placeholder(`베이스 스키장을 선택해주세요`)로 시작한다.
  static const int noResortSelected = -1;

  final RxInt _resortIndex = noResortSelected.obs;
  final Rxn<XFile> _logoFile = Rxn<XFile>();
  final RxInt _colorIndex = kCrewDefaultColorIndex.obs;
  final RxBool _isSubmitting = false.obs;
  final RxnString _nameError = RxnString();

  String get crewName => _crewName.value;

  /// 리조트 목록의 인덱스. **서버 `base_resort_id`는 인덱스+1**이다
  /// (온보딩의 `favorite_resort`와 같은 규칙 — `resortNameList` 순서가 id 순이다).
  int get resortIndex => _resortIndex.value;
  bool get hasResortSelected => _resortIndex.value != noResortSelected;
  int get resortId => _resortIndex.value + 1;
  String get resortName =>
      hasResortSelected ? (resortNameList[_resortIndex.value] ?? '') : '';

  XFile? get logoFile => _logoFile.value;
  int get colorIndex => _colorIndex.value;
  Color get selectedColor => kCrewColors[_colorIndex.value];
  String get selectedColorHex => crewColorToHex(selectedColor);
  bool get isSubmitting => _isSubmitting.value;
  String? get nameError => _nameError.value;

  @override
  void onInit() {
    super.onInit();
    // 목업 기본값은 그 사람이 자주 가는 스키장이다. 모르면 고르지 않은 상태로 두어
    // placeholder가 보이게 한다(목업 모바일 화면).
    final favorite = _userVM.user.favorite_resort;
    if (favorite != null && favorite >= 1 && favorite <= resortNameList.length) {
      _resortIndex.value = favorite - 1;
    }
  }

  void reset() {
    _resortIndex.value = noResortSelected;
    _crewName.value = '';
    _logoFile.value = null;
    _colorIndex.value = kCrewDefaultColorIndex;
    _nameError.value = null;
    onInit();
  }

  void setCrewName(String value) {
    _crewName.value = value.trim();
    // 글자를 고치는 순간 이전 오류 문구는 치운다.
    if (_nameError.value != null) _nameError.value = null;
  }

  void selectResort(int index) => _resortIndex.value = index;
  void selectColor(int index) => _colorIndex.value = index;
  void setLogoFile(XFile? file) => _logoFile.value = file;

  /// 이름 유효성 + 중복 확인. 통과하면 true, 아니면 [nameError]에 문구가 담긴다.
  /// 다음 단계로 갈 수 있는지(이름 입력 + 스키장 선택). 목업의 진행 버튼 활성 조건.
  bool get canGoToImageStep => _crewName.value.isNotEmpty && hasResortSelected;

  Future<bool> validateName() async {
    final name = _crewName.value;
    if (name.isEmpty) {
      _nameError.value = '크루 이름을 입력해 주세요.';
      return false;
    }
    if (name.length > kCrewNameMaxLength) {
      _nameError.value = '$kCrewNameMaxLength자 이내로 입력해 주세요.';
      return false;
    }
    try {
      final res = await _api.checkCrewName(name);
      if (!res.success) {
        _nameError.value = '이미 사용 중인 이름이에요.';
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('[CrewCreate] 이름 확인 실패: $e');
      _nameError.value = '잠시 후 다시 시도해 주세요.';
      return false;
    }
  }

  /// 크루 생성. 성공하면 새 크루 id를 담아 돌려준다.
  ///
  /// 로고를 안 고르면 `crew_logo_url`을 빈 문자열로 보낸다 — 앱·웹 모두 로고가
  /// 비면 색상별 기본 `LIVE CREW` 로고(`crewDefaultLogoUrl`)로 그리므로 문제없다.
  Future<({bool ok, int? crewId, String? message})> create() async {
    final userId = _userVM.user.user_id;
    if (userId == null) return (ok: false, crewId: null, message: '로그인이 필요합니다.');
    if (_isSubmitting.value) return (ok: false, crewId: null, message: null);

    _isSubmitting.value = true;
    try {
      var logoUrl = '';
      final file = _logoFile.value;
      if (file != null) {
        logoUrl = await _imageController.uploadCrewLogo(
          file: file,
          crewName: _crewName.value,
          onError: (type, error) => _sendErrorLog(userId: userId, type: type, error: error),
        );
      }

      final response = await http.post(
        Uri.parse('$_crewBaseUrl/create/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'crew_name': _crewName.value,
          'crew_logo_url': logoUrl,
          'color': selectedColorHex,
          'base_resort_id': resortId,
        }),
      );
      if (response.statusCode != 201) {
        debugPrint('[CrewCreate] 생성 실패 ${response.statusCode}: ${response.body}');
        return (ok: false, crewId: null, message: _readableError(response.body));
      }

      // 유저 모델을 다시 받아 `crew_id`를 채운다. 이게 없으면 방금 만든 크루가
      // "내 크루"로 안 잡혀서 크루톡 올리기 버튼이 안 뜬다(앱과 같은 처리).
      await _userVM.updateUserModel_api(userId);
      final int? crewId = _userVM.user.crew_id;
      return (ok: true, crewId: crewId, message: null);
    } catch (e) {
      debugPrint('[CrewCreate] 생성 예외: $e');
      return (ok: false, crewId: null, message: null);
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// 서버 에러 본문에서 사람이 읽을 문장을 뽑는다. 형식이 다르면 null.
  String? _readableError(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map) {
        for (final value in decoded.values) {
          if (value is String && value.isNotEmpty) return value;
          if (value is List && value.isNotEmpty) return '${value.first}';
        }
      }
    } catch (_) {}
    return null;
  }

  /// 이미지 업로드 실패는 앱과 같이 서버 로그로 남긴다(생성 자체는 계속 진행).
  Future<void> _sendErrorLog({
    required int userId,
    required String type,
    required String error,
  }) async {
    try {
      await _api.createErrorLog_crew({
        'user_id': userId,
        'request_type': type,
        'error': error,
      });
    } catch (e) {
      debugPrint('[CrewCreate] 에러 로그 전송 실패: $e');
    }
  }
}
