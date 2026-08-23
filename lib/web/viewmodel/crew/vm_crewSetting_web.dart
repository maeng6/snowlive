import 'package:com.snowlive/core/api/api_crew.dart';
import 'package:com.snowlive/core/model/m_crewApplyList.dart';
import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/core/model/m_crewMemberList.dart';
import 'package:com.snowlive/core/model/m_crewNotice.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/ranking_season_web.dart';
import 'package:com.snowlive/web/viewmodel/util/vm_imageController_web.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// 서버가 쓰는 역할 문자열. 숫자 코드가 아니라 **한글**이다(실측).
const String kCrewRoleLeader = '크루장';
const String kCrewRoleManager = '운영진';
const String kCrewRoleMember = '크루원';

/// 소개글·공지 글자수 제한.
const int kCrewDescriptionMaxLength = 50;
const int kCrewNoticeMaxLength = 200;

/// 쓰기 동작 결과. 실패 사유가 있으면 화면이 그대로 보여준다.
typedef CrewSettingResult = ({bool ok, String? message});

/// 크루 설정 화면 묶음(허브 + 하위 6개)이 함께 쓰는 웹 전용 뷰모델.
///
/// 코어 뷰모델 4개(`vm_crewDetail`, `vm_crewMemberList`, `vm_crewApply`, `vm_crewNotice`)는
/// **웹에서 컴파일 자체가 안 된다** — 셋이 모바일 `routes.dart`(→ 여러 화면이 `dart:io`)를
/// import하고, `vm_crewNotice`는 `vm_crewMemberList`를 물어 전이로 같이 깨진다. 게다가
/// `CustomFullScreenDialog`·`Get.snackbar`·`Get.offAllNamed(AppRoutes...)`·
/// `Get.find<AlarmCenterViewModel>()`가 박혀 있다. 그래서 API만 직접 부른다
/// (`CrewAPI`와 모델들은 순수 Dart라 웹에서 안전하다).
///
/// 안내 문구는 여기서 띄우지 않는다 — 결과만 돌려주고 화면이 토스트를 띄운다(웹 관례).
class CrewSettingViewModelWeb extends GetxController {
  final CrewAPI _api = CrewAPI();

  UserViewModel get _userVM => Get.find<UserViewModel>();
  ImageControllerWeb get _imageController => Get.find<ImageControllerWeb>();

  final Rxn<CrewDetailInfo> _info = Rxn<CrewDetailInfo>();
  final RxList<CrewMember> _members = <CrewMember>[].obs;
  final RxList<CrewNotice> _notices = <CrewNotice>[].obs;
  final RxList<CrewApply> _applications = <CrewApply>[].obs;
  final RxInt _memberTotal = 0.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxBool _isSubmitting = false.obs;

  int? _crewId;

  int? get crewId => _crewId;
  CrewDetailInfo? get info => _info.value;
  List<CrewMember> get members => _members;
  List<CrewNotice> get notices => _notices;
  List<CrewApply> get applications => _applications;
  int get memberTotal => _memberTotal.value;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  bool get isSubmitting => _isSubmitting.value;

  int? get _myUserId => _userVM.user.user_id;

  /// 지금 보고 있는 크루에서 내 역할. 멤버 목록의 `status`를 그대로 쓴다.
  /// 목록에 없으면 빈 문자열(= 크루원도 아님).
  String get myRole {
    final id = _myUserId;
    if (id == null) return '';
    for (final member in _members) {
      if (member.userInfo?.userId == id) return member.status ?? '';
    }
    return '';
  }

  bool get isLeader => myRole == kCrewRoleLeader;
  bool get isManager => myRole == kCrewRoleManager;
  bool get isMember => myRole.isNotEmpty;

  /// 운영진에게 열어주는 스위치들.
  ///
  /// ⚠️ 코어 getter는 값이 null일 때 **true**를 돌려준다(`vm_crewDetail.dart:57-59`).
  /// 모르면 열어주는 셈이라 웹은 뒤집어서 **모르면 닫는다**.
  bool get permissionJoin => info?.permissionJoin ?? false;
  bool get permissionDesc => info?.permissionDesc ?? false;
  bool get permissionNotice => info?.permissionNotice ?? false;

  bool get canEditDescription => isLeader || (isManager && permissionDesc);
  bool get canEditNotice => isLeader || (isManager && permissionNotice);
  bool get canManageApplications => isLeader || (isManager && permissionJoin);

  /// 이미지·컬러, 크루원 관리, 운영진 권한은 크루장 전용이다.
  bool get canManageCrew => isLeader;

  /// 설정 화면 자체에 들어올 수 있는지(뭐라도 할 수 있는 사람).
  bool get canOpenSettings => isMember;

  Future<void> load(int crewId) async {
    _crewId = crewId;
    _isLoading.value = true;
    _hasError.value = false;
    try {
      // 상세와 멤버는 항상 필요하다(멤버가 없으면 내 역할을 알 수 없다).
      final season = await fetchCurrentRankingSeason() ?? '';
      final results = await Future.wait([
        _api.getCrewDetails(crewId, season: season),
        _api.listCrewMembers(crewId),
      ]);

      final detailRes = results[0];
      if (!detailRes.success) {
        debugPrint('[CrewSetting] 상세 조회 실패: ${detailRes.error}');
        _hasError.value = true;
        return;
      }
      _info.value =
          CrewDetailResponse.fromJson(detailRes.data as Map<String, dynamic>).crewDetailInfo;

      final memberRes = results[1];
      if (memberRes.success) {
        final parsed =
            CrewMemberListResponse.fromJson(memberRes.data as Map<String, dynamic>);
        _members.assignAll(parsed.crewMembers ?? []);
        _memberTotal.value = parsed.totalMemberCount ?? _members.length;
      } else {
        debugPrint('[CrewSetting] 멤버 조회 실패: ${memberRes.error}');
        _members.clear();
      }

      // 공지와 신청 목록은 권한이 있는 사람만 본다(공지 목록은 크루원이 아니면 403).
      await Future.wait([
        if (isMember) refreshNotices(),
        if (canManageApplications) refreshApplications(),
      ]);
    } catch (e) {
      debugPrint('[CrewSetting] 조회 예외: $e');
      _hasError.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    final id = _crewId;
    if (id != null) await load(id);
  }

  /// 공지 목록. **크루원이 아니면 서버가 403을 준다** → 조용히 비운다.
  Future<void> refreshNotices() async {
    final crewId = _crewId;
    final userId = _myUserId;
    if (crewId == null || userId == null) {
      _notices.clear();
      return;
    }
    try {
      final res = await _api.listCrewNotices(userId, crewId);
      if (!res.success) {
        debugPrint('[CrewSetting] 공지 조회 실패: ${res.error}');
        _notices.clear();
        return;
      }
      _notices.assignAll(
        CrewNoticeListResponse.fromJson(res.data as List<dynamic>).notices ?? [],
      );
    } catch (e) {
      // 모델이 upload_time을 무조건 DateTime.parse 한다 → 값이 비면 여기로 떨어진다.
      debugPrint('[CrewSetting] 공지 파싱 예외: $e');
      _notices.clear();
    }
  }

  Future<void> refreshApplications() async {
    final crewId = _crewId;
    if (crewId == null) return;
    try {
      final res = await _api.listCrewApplications(crewId);
      if (!res.success) {
        debugPrint('[CrewSetting] 신청 목록 실패: ${res.error}');
        _applications.clear();
        return;
      }
      _applications.assignAll(
        CrewApplyListResponse.fromJson(res.data as List<dynamic>).crewApplyList ?? [],
      );
    } catch (e) {
      debugPrint('[CrewSetting] 신청 목록 예외: $e');
      _applications.clear();
    }
  }

  Future<void> refreshMembers() async {
    final crewId = _crewId;
    if (crewId == null) return;
    final res = await _api.listCrewMembers(crewId);
    if (!res.success) return;
    final parsed = CrewMemberListResponse.fromJson(res.data as Map<String, dynamic>);
    _members.assignAll(parsed.crewMembers ?? []);
    _memberTotal.value = parsed.totalMemberCount ?? _members.length;
  }

  // ===== 크루 정보 수정 =====

  /// 소개글만 바꾼다.
  ///
  /// ⚠️ 앱은 이 자리에서 크루 전체 업데이트를 부르는데, 그 경로는 **기존 로고를 Storage에서
  /// 지우고 `crew_logo_url: ''`을 보내고 색을 빨강으로 덮는다**(`vm_setCrew.dart:121-137,233`).
  /// 웹은 그 사고를 재현하지 않고 바꾸려는 필드만 보낸다(서버는 부분 업데이트를 받는다).
  Future<CrewSettingResult> saveDescription(String text) =>
      _updateDetail({'description': text.trim()});

  /// 운영진 권한 3개를 한 번에 저장한다(목업의 `저장하기`).
  Future<CrewSettingResult> savePermissions({
    required bool join,
    required bool desc,
    required bool notice,
  }) =>
      _updateDetail({
        'permission_join': join,
        'permission_desc': desc,
        'permission_notice': notice,
      });

  /// 로고·색상 저장. [removeLogo]면 URL만 비운다.
  ///
  /// 앱은 Storage 파일까지 지우지만 웹은 URL만 비운다 — 파일을 지우면 되돌릴 수 없고,
  /// 로고가 비면 색상별 기본 `LIVE CREW` 로고로 그려지므로 화면상 결과는 같다.
  Future<CrewSettingResult> saveImageAndColor({
    XFile? newLogo,
    bool removeLogo = false,
    required String colorHex,
  }) async {
    final crewName = info?.crewName;
    if (crewName == null) return (ok: false, message: null);

    String? logoUrl;
    if (newLogo != null) {
      logoUrl = await _imageController.uploadCrewLogo(file: newLogo, crewName: crewName);
      if (logoUrl.isEmpty) {
        return (ok: false, message: '이미지 업로드에 실패했어요. 잠시 후 다시 시도해주세요.');
      }
    } else if (removeLogo) {
      logoUrl = '';
    }

    return _updateDetail({
      'color': colorHex,
      if (logoUrl != null) 'crew_logo_url': logoUrl,
    });
  }

  /// PUT `/detail/{crewId}/`. 서버는 부분 업데이트를 받지만 **`user_id`와 `crew_name`은
  /// 모든 호출부가 예외 없이 함께 보낸다**(권한 검증용) → 여기서 항상 붙인다.
  Future<CrewSettingResult> _updateDetail(Map<String, dynamic> fields) async {
    final crewId = _crewId;
    final userId = _myUserId;
    final crewName = info?.crewName;
    if (crewId == null || crewName == null) return (ok: false, message: null);
    if (userId == null) return (ok: false, message: '로그인이 필요합니다.');

    return _run(() async {
      final res = await _api.updateCrewDetails(crewId, {
        'user_id': userId,
        'crew_name': crewName,
        ...fields,
      });
      if (!res.success) {
        debugPrint('[CrewSetting] 정보 수정 실패: ${res.error}');
        return (ok: false, message: _readableErrorFrom(res.error));
      }
      await refresh();
      return (ok: true, message: null);
    });
  }

  // ===== 공지사항 =====

  Future<CrewSettingResult> createNotice(String text) async {
    final crewId = _crewId;
    final userId = _myUserId;
    if (crewId == null) return (ok: false, message: null);
    if (userId == null) return (ok: false, message: '로그인이 필요합니다.');

    return _run(() async {
      final res = await _api.createCrewNotice({
        'user_id': userId,
        'crew_id': crewId,
        'notice': text.trim(),
      });
      if (!res.success) return (ok: false, message: _readableErrorFrom(res.error));
      await refreshNotices();
      return (ok: true, message: null);
    });
  }

  /// 공지 수정. **목록이 주는 키는 `notice_crew_id`인데 요청 키는 `notice_id`** 다.
  Future<CrewSettingResult> updateNotice({
    required int noticeId,
    required String text,
  }) async {
    final userId = _myUserId;
    if (userId == null) return (ok: false, message: '로그인이 필요합니다.');

    return _run(() async {
      final res = await _api.updateCrewNotice({
        'user_id': userId,
        'notice_id': noticeId,
        'notice': text.trim(),
      });
      if (!res.success) return (ok: false, message: _readableErrorFrom(res.error));
      await refreshNotices();
      return (ok: true, message: null);
    });
  }

  /// 공지 삭제.
  ///
  /// ⚠️ **body를 실은 DELETE**라 서버 CORS가 `DELETE` + `Content-Type`을 허용해야 통과한다.
  /// 그리고 `user_id`로 **작성자 id**를 보낸다 — 앱이 그렇게 보내므로(`v_crewNoticeList.dart:152`)
  /// 서버 권한 검사가 그 값을 기준으로 돌 가능성이 있어 동작을 그대로 따른다.
  Future<CrewSettingResult> deleteNotice({
    required int noticeId,
    required int authorUserId,
  }) {
    return _run(() async {
      final res = await _api.deleteCrewNotice(authorUserId, noticeId);
      // `ApiResponse<void>`라 에러 본문을 타입으로 꺼낼 수 없다 → 일반 문구만.
      if (!res.success) return (ok: false, message: null);
      await refreshNotices();
      return (ok: true, message: null);
    });
  }

  // ===== 가입 신청 =====

  Future<CrewSettingResult> approveApplication(int applicantUserId) async {
    final crewId = _crewId;
    if (crewId == null) return (ok: false, message: null);

    return _run(() async {
      final res = await _api.approveCrewApplication({
        'applicant_user_id': applicantUserId,
        'crew_id': crewId,
      });
      if (!res.success) return (ok: false, message: _readableErrorFrom(res.error));
      // 승인하면 멤버가 늘어나므로 두 목록을 순서대로 갱신한다(앱은 병렬로 던져 순서가 어긋난다).
      await refreshApplications();
      await refreshMembers();
      return (ok: true, message: null);
    });
  }

  /// 신청 거절. ⚠️ 이것도 **body를 실은 DELETE**다.
  Future<CrewSettingResult> rejectApplication(int applicantUserId) async {
    final crewId = _crewId;
    final userId = _myUserId;
    if (crewId == null) return (ok: false, message: null);
    if (userId == null) return (ok: false, message: '로그인이 필요합니다.');

    return _run(() async {
      final res = await _api.deleteCrewApplication({
        'applicant_user_id': applicantUserId,
        'crew_id': crewId,
        'user_id': userId,
      });
      if (!res.success) return (ok: false, message: _readableErrorFrom(res.error));
      await refreshApplications();
      return (ok: true, message: null);
    });
  }

  // ===== 크루원 관리 =====

  /// 역할 변경. [status]는 [kCrewRoleManager] / [kCrewRoleMember] 같은 한글 문자열이다.
  Future<CrewSettingResult> changeMemberRole({
    required int memberUserId,
    required String status,
  }) async {
    final crewId = _crewId;
    final userId = _myUserId;
    if (crewId == null) return (ok: false, message: null);
    if (userId == null) return (ok: false, message: '로그인이 필요합니다.');

    return _run(() async {
      final res = await _api.updateCrewMemberStatus({
        'user_id': userId,
        'crew_id': crewId,
        'crew_member_user_id': memberUserId,
        'status': status,
      });
      if (!res.success) return (ok: false, message: _readableErrorFrom(res.error));
      await refreshMembers();
      return (ok: true, message: null);
    });
  }

  /// 강퇴. 서버는 **탈퇴와 같은 API**를 쓰고 대상 id만 다르다.
  Future<CrewSettingResult> expelMember(int memberUserId) =>
      _leave(memberUserId: memberUserId, refreshAfter: true);

  /// 내 탈퇴.
  Future<CrewSettingResult> withdraw() async {
    final userId = _myUserId;
    if (userId == null) return (ok: false, message: '로그인이 필요합니다.');
    final result = await _leave(memberUserId: userId, refreshAfter: false);
    if (result.ok) await _syncMyUser();
    return result;
  }

  Future<CrewSettingResult> _leave({
    required int memberUserId,
    required bool refreshAfter,
  }) async {
    final crewId = _crewId;
    final userId = _myUserId;
    if (crewId == null) return (ok: false, message: null);
    if (userId == null) return (ok: false, message: '로그인이 필요합니다.');

    return _run(() async {
      final res = await _api.withdrawCrew({
        'crew_member_user_id': memberUserId,
        'user_id': userId,
        'crew_id': crewId,
      });
      if (!res.success) return (ok: false, message: _readableErrorFrom(res.error));
      if (refreshAfter) await refreshMembers();
      return (ok: true, message: null);
    });
  }

  // ===== 크루 삭제 =====

  /// 크루 삭제. **크루원이 남아 있으면 서버가 거절한다**(앱 문구를 그대로 쓴다).
  Future<CrewSettingResult> deleteCrew() async {
    final crewId = _crewId;
    final userId = _myUserId;
    if (crewId == null) return (ok: false, message: null);
    if (userId == null) return (ok: false, message: '로그인이 필요합니다.');

    return _run(() async {
      final res = await _api.deleteCrew(crewId, userId.toString());
      if (!res.success) {
        // `ApiResponse<void>`라 본문을 꺼낼 수 없다. 서버가 거절하는 사유는 사실상
        // 이것뿐이라(앱도 같은 문구를 쓴다) 그대로 안내한다.
        return (ok: false, message: '크루 멤버가 있는 상태에서는 크루 삭제가 불가합니다.');
      }
      await _syncMyUser();
      return (ok: true, message: null);
    });
  }

  // ===== 내부 =====

  /// 삭제·탈퇴 후 내 `crew_id`를 서버 값으로 맞춘다. 안 하면 "내 크루"로 계속 잡힌다.
  Future<void> _syncMyUser() async {
    final userId = _myUserId;
    if (userId == null) return;
    try {
      await _userVM.updateUserModel_api(userId);
    } catch (e) {
      debugPrint('[CrewSetting] 유저 정보 갱신 실패: $e');
    }
  }

  Future<CrewSettingResult> _run(Future<CrewSettingResult> Function() action) async {
    if (_isSubmitting.value) return (ok: false, message: null);
    _isSubmitting.value = true;
    try {
      return await action();
    } catch (e) {
      debugPrint('[CrewSetting] 요청 예외: $e');
      return (ok: false, message: null);
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// 서버 에러 본문에서 사람이 읽을 문장을 뽑는다. 형식이 다르면 null(일반 문구 사용).
  String? _readableErrorFrom(Object? error) {
    if (error is String && error.isNotEmpty) return error;
    if (error is Map) {
      for (final value in error.values) {
        if (value is String && value.isNotEmpty) return value;
        if (value is List && value.isNotEmpty) return '${value.first}';
      }
    }
    return null;
  }
}
