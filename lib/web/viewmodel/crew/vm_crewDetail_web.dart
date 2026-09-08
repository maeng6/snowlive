import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/core/api/api_crew.dart';
import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/core/model/m_crewMemberRankingList.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/ranking_season_web.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// 크루홈(크루별 상세)용 웹 전용 뷰모델.
///
/// 코어 [CrewDetailViewModel]을 쓰지 않는다 — `fetchCrewDetail` 안에서
/// `Get.find<CrewNoticeViewModel>()`을 부르고(`vm_crewDetail.dart:117,131`)
/// `CustomFullScreenDialog`·`Get.snackbar`·모바일 라우트 테이블이 딸려온다.
/// 여기서는 조회 API 두 개만 감싼다.
///
/// 안내 문구는 띄우지 않는다 — 결과만 돌려주고 화면이 토스트/다이얼로그를 띄운다.
class CrewDetailViewModelWeb extends GetxController {
  final CrewAPI _api = CrewAPI();

  /// 다른 API 클래스들과 같은 상수(코어에 공유 상수가 없어 그 관례를 따른다).
  static const String _crewBaseUrl =
      'https://snowlive-api-c617725e2b78.herokuapp.com/api/crew';

  UserViewModel get _userVM => Get.find<UserViewModel>();

  final Rxn<CrewDetailInfo> _info = Rxn<CrewDetailInfo>();
  final Rxn<SeasonRankingInfo> _season = Rxn<SeasonRankingInfo>();
  final RxList<CrewRanking> _members = <CrewRanking>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxBool _isSubmitting = false.obs;

  // 방문자수(오늘/전체). 상세 응답으로 먼저 채우고, 방문 POST 응답으로 최신화한다.
  final RxnInt _visitorToday = RxnInt();
  final RxnInt _visitorTotal = RxnInt();

  int? _crewId;

  /// 이 진입에서 방문 로그를 이미 POST한 크루. 같은 크루로 재로딩(자동로그인 확정 등)
  /// 될 때 중복 POST를 막는다(서버도 5분 스로틀하지만, 굳이 두 번 부르지 않는다).
  int? _visitLoggedCrewId;

  CrewDetailInfo? get info => _info.value;
  SeasonRankingInfo? get season => _season.value;
  List<CrewRanking> get members => _members;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  bool get isSubmitting => _isSubmitting.value;
  int? get crewId => _crewId;
  int? get visitorToday => _visitorToday.value;
  int? get visitorTotal => _visitorTotal.value;

  /// 지금 보고 있는 크루가 내 크루인지. 서버가 유저 정보에 `crew_id`를 준다.
  bool get isMyCrew {
    final my = _userVM.user.crew_id;
    return my != null && _crewId != null && my == _crewId;
  }

  Future<void> load(int crewId) async {
    _crewId = crewId;
    _isLoading.value = true;
    _hasError.value = false;
    try {
      // 못 구하면 빈 문자열을 보내 서버가 기본 시즌으로 처리하게 한다(랭킹과 동일).
      final season = await fetchCurrentRankingSeason() ?? '';
      final res = await _api.getCrewDetails(crewId, season: season);
      if (!res.success) {
        debugPrint('[CrewDetail] 조회 실패: ${res.error}');
        _hasError.value = true;
        return;
      }
      final parsed = CrewDetailResponse.fromJson(res.data as Map<String, dynamic>);
      _info.value = parsed.crewDetailInfo;
      _season.value = parsed.seasonRankingInfo;
      // 상세 응답이 준 방문자수로 먼저 채운 뒤(=우리 방문 POST 이전 값),
      // 방문 POST가 오늘 카운트를 +1 반영한 최신값으로 덮어쓴다.
      _visitorToday.value = parsed.crewDetailInfo?.visitorToday;
      _visitorTotal.value = parsed.crewDetailInfo?.visitorTotal;
      _logVisit(crewId); // 진입당 1회 방문 집계(비차단)
      await _loadMembers(crewId: crewId, season: season);
    } catch (e) {
      debugPrint('[CrewDetail] 조회 예외: $e');
      _hasError.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    final id = _crewId;
    if (id != null) await load(id);
  }

  /// 크루홈 방문 집계(게스트 포함, 서버가 5분 스로틀). 진입당 1회만 POST하고,
  /// 응답의 today/total로 헤더 표시값을 최신화한다. 실패해도 화면엔 영향 없다.
  Future<void> _logVisit(int crewId) async {
    if (_visitLoggedCrewId == crewId) return; // 같은 진입 재로딩 → 중복 방지
    _visitLoggedCrewId = crewId;
    try {
      final res = await _api.visitCrew(crewId, userId: _userVM.user.user_id);
      if (res.success && res.data != null) {
        _visitorToday.value = res.data!['today'] as int?;
        _visitorTotal.value = res.data!['total'] as int?;
      }
    } catch (e) {
      debugPrint('[CrewDetail] 방문 집계 실패(무시): $e');
    }
  }

  /// 멤버 랭킹.
  ///
  /// ⚠️ 이 API는 `user_id`를 **필수**로 받는다(없으면 400: "crew_id와 user_id는
  /// 필수입니다"). 그런데 응답(`ranking_results`)에는 개인화된 값이 하나도 없어서
  /// 누구 id로 부르든 결과가 같다(실측). 그래서 비로그인 방문자에게도 목업대로
  /// 멤버를 보여주기 위해 **크루장 id로 채워** 호출한다(사용자 확정).
  Future<void> _loadMembers({required int crewId, required String season}) async {
    final userId = _userVM.user.user_id ?? _info.value?.crewLeaderUserId;
    if (userId == null) {
      _members.clear();
      return;
    }
    try {
      final res = await _api.getCrewRanking(crewId: crewId, userId: userId, season: season);
      if (!res.success) {
        debugPrint('[CrewDetail] 멤버 랭킹 실패: ${res.error}');
        _members.clear();
        return;
      }
      final parsed = CrewRankingResponse.fromJson(res.data as Map<String, dynamic>);
      _members.assignAll(parsed.rankingResults ?? []);
    } catch (e) {
      debugPrint('[CrewDetail] 멤버 랭킹 예외: $e');
      _members.clear();
    }
  }

  /// 가입 신청. 실패 사유를 화면에 보여줄 수 있게 **본문을 살려서** 돌려준다
  /// (`CrewAPI.applyForCrew`는 실패 시 응답 본문을 버린다 — `api_crew.dart:137`).
  Future<({bool ok, String? message})> applyForCrew({String? title}) async {
    final crewId = _crewId;
    final userId = _userVM.user.user_id;
    if (crewId == null) return (ok: false, message: null);
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
          'title': title,
        }),
      );
      if (response.statusCode == 201) {
        // 크루장 앱의 알림 배지를 켜준다. 없으면 신청이 온 걸 눈치채지 못한다.
        await _markCrewNotification(_info.value?.crewLeaderUserId);
        return (ok: true, message: null);
      }
      debugPrint('[CrewDetail] 가입 신청 실패 ${response.statusCode}: ${response.body}');
      return (ok: false, message: _readableError(response.body));
    } catch (e) {
      debugPrint('[CrewDetail] 가입 신청 예외: $e');
      return (ok: false, message: null);
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// 서버 에러 본문에서 사람이 읽을 문장을 뽑는다. 형식이 다르면 null(일반 문구 사용).
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

  /// 앱 알림센터 배지용 Firestore 문서를 켠다(`vm_alarmCenter.updateNotification` 이식).
  /// 실패해도 신청 자체는 성공이므로 삼키고 로그만 남긴다.
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
      debugPrint('[CrewDetail] 알림센터 갱신 실패(신청 자체는 성공): $e');
    }
  }
}
