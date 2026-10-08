import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/core/api/api_crew.dart';
import 'package:com.snowlive/core/model/m_crewApplyList.dart';
import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/core/model/m_crewList.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// `base_resort_id` → 리조트 별명(`휘닉스`). 크루 목록 응답에는 id만 온다.
String crewResortNicknameOf(int? baseResortId) {
  if (baseResortId == null) return '';
  final index = baseResortId - 1;
  if (index < 0 || index >= resortList.length) return '';
  return resortList[index].resortNickname ?? '';
}

/// 크루 가입하기 — 크루 검색 + 가입 신청.
///
/// 목록 API는 페이지네이션이 없어 조건에 맞는 크루를 **전부** 준다(전체 521개,
/// 리조트별로도 휘닉스 169개 — 실측). 잘라서 보여주면 그만큼만 있는 줄 알게 되므로
/// 다 넘기고, 화면이 `ListView.builder`로 지연 렌더한다.
class CrewJoinViewModelWeb extends GetxController {
  final CrewAPI _api = CrewAPI();

  /// 다른 API 클래스들과 같은 상수(코어에 공유 상수가 없어 그 관례를 따른다).
  static const String _crewBaseUrl =
      'https://snowlive-api-c617725e2b78.herokuapp.com/api/crew';

  UserViewModel get _userVM => Get.find<UserViewModel>();

  final RxList<Crew> _crews = <Crew>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxBool _isSubmitting = false.obs;
  final RxString _keyword = ''.obs;
  final RxnInt _resortId = RxnInt();

  // 내가 가입 신청한 크루(승인 전) 목록. 가입한 크루가 없을 때 신청 내역을 보고
  // 취소할 수 있게 한다(앱 `가입 신청한 크루` 화면과 동일).
  final RxList<CrewApply> _myApplications = <CrewApply>[].obs;
  final RxBool _isLoadingApplications = false.obs;
  final RxBool _hasApplicationsError = false.obs;

  List<Crew> get crews => _crews;
  int? get resortId => _resortId.value;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  bool get isSubmitting => _isSubmitting.value;
  String get keyword => _keyword.value;

  List<CrewApply> get myApplications => _myApplications;
  bool get isLoadingApplications => _isLoadingApplications.value;
  bool get hasApplicationsError => _hasApplicationsError.value;
  bool get isLoggedIn => _userVM.user.user_id != null;

  /// 크루 목록 조회.
  ///
  /// [resortId]를 주면 그 스키장을 베이스로 하는 크루만 받는다(라이브크루 홈의
  /// `전체보기`). 검색어가 있으면 이름으로 걸러 받는다. 둘 다 없으면 전체 목록이다.
  Future<void> search([String? keyword, int? resortId]) async {
    final query = (keyword ?? '').trim();
    _keyword.value = query;
    _resortId.value = resortId;
    _isLoading.value = true;
    _hasError.value = false;
    try {
      final res = await _api.listCrews(
        crewName: query.isEmpty ? null : query,
        baseResortId: resortId?.toString(),
      );
      if (!res.success) {
        debugPrint('[CrewJoin] 목록 실패: ${res.error}');
        _hasError.value = true;
        _crews.clear();
        return;
      }
      // 이 API는 Map이 아니라 **List**를 돌려준다(`CrewListResponse.fromJson(List)`).
      final parsed = CrewListResponse.fromJson(res.data as List<dynamic>);
      _crews.assignAll(parsed.results ?? []);
    } catch (e) {
      debugPrint('[CrewJoin] 목록 예외: $e');
      _hasError.value = true;
      _crews.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  /// 내가 가입 신청한 크루 목록(`/crew-member/apply/?user_id=`). 승인 전 신청만 온다.
  Future<void> loadMyApplications() async {
    final userId = _userVM.user.user_id;
    if (userId == null) {
      _myApplications.clear();
      return;
    }
    _isLoadingApplications.value = true;
    _hasApplicationsError.value = false;
    try {
      final res = await _api.listCrewApplicationsUser(userId);
      if (!res.success) {
        debugPrint('[CrewJoin] 내 신청 목록 실패: ${res.error}');
        _hasApplicationsError.value = true;
        _myApplications.clear();
        return;
      }
      final parsed = CrewApplyListResponse.fromJson(res.data as List<dynamic>);
      _myApplications.assignAll(parsed.crewApplyList ?? []);
    } catch (e) {
      debugPrint('[CrewJoin] 내 신청 목록 예외: $e');
      _hasApplicationsError.value = true;
      _myApplications.clear();
    } finally {
      _isLoadingApplications.value = false;
    }
  }

  /// 신청 취소(`/crew-member/delete-apply/`). 내가 신청자이자 요청자다.
  /// 성공하면 목록에서 그 크루를 즉시 뺀다.
  Future<({bool ok, String? message})> cancelApplication(int crewId) async {
    final userId = _userVM.user.user_id;
    if (userId == null) return (ok: false, message: '로그인이 필요합니다.');
    try {
      final res = await _api.deleteCrewApplication({
        'applicant_user_id': userId,
        'crew_id': crewId,
        'user_id': userId,
      });
      if (!res.success) {
        debugPrint('[CrewJoin] 신청 취소 실패: ${res.error}');
        return (ok: false, message: null);
      }
      _myApplications.removeWhere((a) => a.crewId == crewId);
      return (ok: true, message: null);
    } catch (e) {
      debugPrint('[CrewJoin] 신청 취소 예외: $e');
      return (ok: false, message: null);
    }
  }

  /// 팝업에 멤버 수·소개를 채우기 위한 상세 조회(목록 응답에는 멤버 수가 없다).
  Future<CrewDetailInfo?> fetchDetail(int crewId) async {
    try {
      final res = await _api.getCrewDetails(crewId);
      if (!res.success) return null;
      return CrewDetailResponse.fromJson(res.data as Map<String, dynamic>).crewDetailInfo;
    } catch (e) {
      debugPrint('[CrewJoin] 상세 조회 실패: $e');
      return null;
    }
  }

  /// 가입 신청. 실패 사유를 화면에 보여줄 수 있게 **본문을 살려서** 돌려준다
  /// (`CrewAPI.applyForCrew`는 실패 시 응답 본문을 버린다 — `api_crew.dart:137`).
  Future<({bool ok, String? message})> apply({
    required int crewId,
    required int? crewLeaderUserId,
    String? title,
  }) async {
    final userId = _userVM.user.user_id;
    if (userId == null) return (ok: false, message: '로그인이 필요합니다.');
    if (_isSubmitting.value) return (ok: false, message: null);

    _isSubmitting.value = true;
    try {
      final response = await http.post(
        Uri.parse('$_crewBaseUrl/crew-member/apply/'),
        headers: {'Content-Type': 'application/json'},
        // 앱과 같은 형식으로 보낸다(문자열).
        body: json.encode({
          'crew_id': crewId.toString(),
          'applicant_user_id': userId.toString(),
          // title은 서버 필수값(null 불가). 신청 메시지가 비어 있으면 기본 문구로 보낸다.
          'title': (title != null && title.trim().isNotEmpty)
              ? title.trim()
              : '안녕하세요. 크루 가입 신청합니다.',
        }),
      );
      if (response.statusCode == 201) {
        await _markCrewNotification(crewLeaderUserId);
        return (ok: true, message: null);
      }
      debugPrint('[CrewJoin] 신청 실패 ${response.statusCode}: ${response.body}');
      return (ok: false, message: _readableError(response.body));
    } catch (e) {
      debugPrint('[CrewJoin] 신청 예외: $e');
      return (ok: false, message: null);
    } finally {
      _isSubmitting.value = false;
    }
  }

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

  /// 크루장 앱의 알림 배지를 켜준다. 실패해도 신청 자체는 성공이므로 로그만 남긴다.
  Future<void> _markCrewNotification(int? leaderUserId) async {
    if (leaderUserId == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notificationCenter')
          .where('uid', isEqualTo: leaderUserId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({'total': true, 'crew': true});
      } else {
        await FirebaseFirestore.instance.collection('notificationCenter').add({
          'uid': leaderUserId,
          'total': true,
          'friend': false,
          'crew': true,
        });
      }
    } catch (e) {
      debugPrint('[CrewJoin] 알림센터 갱신 실패(신청 자체는 성공): $e');
    }
  }
}
