import 'dart:convert';

import 'package:com.snowlive/core/api/api_crew.dart';
import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/core/model/m_crewMemberRankingList.dart';
import 'package:com.snowlive/core/model/m_crewRecordRoom.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_record_sections_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewDetail_web.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// 시즌 기록실 · 일별 현황 · 크루원 시즌 랭킹 세 화면을 먹이는 웹 전용 뷰모델.
///
/// 코어 뷰모델 3개(`vm_crewRecordRoom`·`vm_dailyRecord`·`vm_crewDetail_recordRoom`)는
/// 웹에서 쓸 수 없다 — 전부 `Get.find<CrewDetailViewModel>()`을 요구하고, 그 클래스는
/// 모바일 라우트 테이블(`routes.dart` → 뷰 79개 → `dart:io`)과 `CustomFullScreenDialog`,
/// `FriendDetailViewModel`(→ `image_picker`)을 물고 온다. 여기서는 조회 API만 감싼다.
///
/// 안내 문구는 띄우지 않는다 — 상태만 노출하고 화면이 알아서 그린다(웹 관례).
class CrewRecordViewModelWeb extends GetxController {
  final CrewAPI _api = CrewAPI();

  /// 일별 리포트 두 엔드포인트는 **`user_id`가 필수**인데(없으면 400 `user_id는
  /// 필수입니다`) 코어 `CrewAPI.getCrewDailyReport*`는 그 값을 보내지 않는다
  /// (`api_crew.dart:244-273`) → 여기서 직접 요청을 만든다. 코어를 고치면 모바일까지
  /// 영향이 가므로 이번엔 건드리지 않는다.
  static const String _crewBaseUrl =
      'https://snowlive-api-c617725e2b78.herokuapp.com/api/crew';

  UserViewModel get _userVM => Get.find<UserViewModel>();

  final Rxn<CrewDetailInfo> _info = Rxn<CrewDetailInfo>();
  final Rxn<SeasonRankingInfo> _stats = Rxn<SeasonRankingInfo>();
  final RxList<CrewRidingRecord> _records = <CrewRidingRecord>[].obs;
  final RxList<CrewRanking> _ranking = <CrewRanking>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;

  /// 첫 조회가 끝났는지. 화면이 **아직 아무것도 안 받은 상태**와 **받았는데 비어 있는
  /// 상태**를 구분해 스켈레톤/빈 상태를 골라 보여줄 수 있게 둔다.
  final RxBool _hasLoaded = false.obs;

  final RxString _season = crewRecordSeasons().first.dbSeason.obs;
  final RxInt _year = DateTime.now().year.obs;

  int? _crewId;

  CrewDetailInfo? get info => _info.value;
  SeasonRankingInfo? get stats => _stats.value;

  /// 날짜 내림차순(서버 순서 그대로).
  List<CrewRidingRecord> get records => _records;
  List<CrewRanking> get memberRanking => _ranking;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;

  /// 첫 조회 전이거나 조회 중. 이 동안에는 빈 상태 대신 스켈레톤을 보여준다.
  bool get isInitialLoading => !_hasLoaded.value || _isLoading.value;
  String get season => _season.value;
  int get year => _year.value;
  int? get crewId => _crewId;

  /// 화면이 그리는 연도 탭. 데이터가 2025-11부터라 그 해까지만 만든다.
  List<int> get years => crewRecordYears(DateTime.now().year);

  // ===== 시즌 축 (기록실 + 크루원 랭킹) =====

  Future<void> loadSeason(int crewId, {String? season}) async {
    _crewId = crewId;
    if (season != null) _season.value = season;
    final target = _season.value;

    _isLoading.value = true;
    _hasError.value = false;
    _records.clear();
    _ranking.clear();
    // 지난 시즌 수치를 새 탭 아래에 남겨두면 잘못 읽힌다(실측: 탭을 바꾼 직후 이전
    // 시즌 점수가 한 프레임 보였다) → 비워서 스켈레톤을 보여준다.
    _info.value = null;
    _stats.value = null;
    try {
      // 로그인 상태면 user_id를 이미 알아서 세 조회를 한 번에 보낸다.
      // 비로그인이면 크루장 id가 필요해 상세를 먼저 받아야 한다.
      final knownUserId = _userVM.user.user_id;
      if (knownUserId != null) {
        await Future.wait([
          _fetchSeasonDetail(crewId, target),
          _fetchSeasonRecords(crewId: crewId, season: target, userId: knownUserId),
          _fetchRanking(crewId: crewId, season: target, userId: knownUserId),
        ]);
        return;
      }

      await _fetchSeasonDetail(crewId, target);
      final leaderId = _info.value?.crewLeaderUserId;
      if (leaderId == null) return;
      await Future.wait([
        _fetchSeasonRecords(crewId: crewId, season: target, userId: leaderId),
        _fetchRanking(crewId: crewId, season: target, userId: leaderId),
      ]);
    } finally {
      _isLoading.value = false;
      _hasLoaded.value = true;
    }
  }

  /// 시즌 탭 전환. 앱은 랭킹을 다시 받지 않아 이전 시즌 랭킹이 남는데(버그) 여기서는
  /// 같은 시즌으로 함께 갱신한다.
  Future<void> setSeason(String season) async {
    final id = _crewId;
    if (id == null || season == _season.value) return;
    await loadSeason(id, season: season);
  }

  /// 크루원 시즌 랭킹 화면만 쓸 때(URL 직접 진입·새로고침). 일별 목록은 한 시즌이
  /// 121일치나 되어 이 화면에서는 받지 않는다.
  Future<void> loadRanking(int crewId, {String? season}) async {
    _crewId = crewId;
    if (season != null) _season.value = season;

    _isLoading.value = true;
    _hasError.value = false;
    _ranking.clear();
    try {
      final userId = await _resolveUserId(crewId);
      if (userId == null) {
        _hasError.value = true;
        return;
      }
      await _fetchRanking(crewId: crewId, season: _season.value, userId: userId);
    } finally {
      _isLoading.value = false;
      _hasLoaded.value = true;
    }
  }

  // ===== 연도 축 (일별 현황) =====

  Future<void> loadYear(int crewId, {int? year}) async {
    _crewId = crewId;
    if (year != null) _year.value = year;
    final target = _year.value;

    _isLoading.value = true;
    _hasError.value = false;
    _records.clear();
    try {
      final userId = await _resolveUserId(crewId);
      if (userId == null) {
        _hasError.value = true;
        return;
      }
      await _fetchYearRecords(crewId: crewId, year: target, userId: userId);
    } finally {
      _isLoading.value = false;
      _hasLoaded.value = true;
    }
  }

  Future<void> setYear(int year) async {
    final id = _crewId;
    if (id == null || year == _year.value) return;
    await loadYear(id, year: year);
  }

  Future<void> refreshSeason() async {
    final id = _crewId;
    if (id != null) await loadSeason(id);
  }

  Future<void> refreshYear() async {
    final id = _crewId;
    if (id != null) await loadYear(id);
  }

  // ===== 내부 =====

  /// 일별 리포트에 실을 `user_id`. 응답에 개인화된 값이 없어서(누구 id로 불러도 같다)
  /// 비로그인 방문자에게는 **크루장 id로 채워** 호출한다(`vm_crewDetail_web.dart:99`와
  /// 같은 처리, 사용자 확정).
  Future<int?> _resolveUserId(int crewId) async {
    final mine = _userVM.user.user_id;
    if (mine != null) return mine;

    final cached = _info.value;
    if (cached?.crewId == crewId && cached?.crewLeaderUserId != null) {
      return cached!.crewLeaderUserId;
    }
    // 크루홈에서 넘어왔으면 상세를 이미 받아둔 상태다 → 요청을 아낀다.
    if (Get.isRegistered<CrewDetailViewModelWeb>()) {
      final fromHome = Get.find<CrewDetailViewModelWeb>().info;
      if (fromHome?.crewId == crewId && fromHome?.crewLeaderUserId != null) {
        return fromHome!.crewLeaderUserId;
      }
    }
    // 크루장 id는 시즌과 무관하므로 지금 시즌 상세로 받아온다.
    await _fetchSeasonDetail(crewId, _season.value);
    return _info.value?.crewLeaderUserId;
  }

  Future<void> _fetchSeasonDetail(int crewId, String season) async {
    try {
      final res = await _api.getCrewDetails_recordRoom(crewId, season);
      if (!res.success) {
        debugPrint('[CrewRecord] 시즌 상세 실패: ${res.error}');
        _hasError.value = true;
        return;
      }
      // 응답 키가 현재 시즌 `/detail/`과 동일해서(실측) `_recordRoom` 접미사 모델 대신
      // 기존 모델로 파싱한다 → 크루홈 통계 위젯을 타입 변환 없이 그대로 쓸 수 있다.
      final parsed = CrewDetailResponse.fromJson(res.data as Map<String, dynamic>);
      _info.value = parsed.crewDetailInfo;
      _stats.value = parsed.seasonRankingInfo;
    } catch (e) {
      debugPrint('[CrewRecord] 시즌 상세 예외: $e');
      _hasError.value = true;
    }
  }

  Future<void> _fetchRanking({
    required int crewId,
    required String season,
    required int userId,
  }) async {
    try {
      final res = await _api.getCrewRanking_recordRoom(
        crewId: crewId,
        userId: userId,
        selected_season: season,
      );
      if (!res.success) {
        debugPrint('[CrewRecord] 크루원 랭킹 실패: ${res.error}');
        return;
      }
      // 랭킹도 현재 시즌 응답과 키가 같다(실측) → 기존 모델로 파싱한다.
      final parsed = CrewRankingResponse.fromJson(res.data as Map<String, dynamic>);
      _ranking.assignAll(parsed.rankingResults ?? []);
    } catch (e) {
      debugPrint('[CrewRecord] 크루원 랭킹 예외: $e');
    }
  }

  Future<void> _fetchSeasonRecords({
    required int crewId,
    required String season,
    required int userId,
  }) =>
      _fetchRecords(
        Uri.parse('$_crewBaseUrl/crew-daily-report/recordroom/').replace(queryParameters: {
          'crew_id': '$crewId',
          'selected_season': season,
          'user_id': '$userId',
        }),
      );

  Future<void> _fetchYearRecords({
    required int crewId,
    required int year,
    required int userId,
  }) =>
      _fetchRecords(
        Uri.parse('$_crewBaseUrl/crew-daily-report/').replace(queryParameters: {
          'crew_id': '$crewId',
          'year': '$year',
          'user_id': '$userId',
        }),
      );

  Future<void> _fetchRecords(Uri uri) async {
    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        debugPrint('[CrewRecord] 일별 조회 실패(${res.statusCode}): ${utf8.decode(res.bodyBytes)}');
        _hasError.value = true;
        return;
      }
      final decoded = json.decode(utf8.decode(res.bodyBytes));
      if (decoded is! List) {
        debugPrint('[CrewRecord] 일별 조회 응답 형식이 다르다: $decoded');
        _hasError.value = true;
        return;
      }
      _records.assignAll(CrewRecordRoomResponse.fromJson(withCrewRecordTimeInfo(decoded)).records);
    } catch (e) {
      debugPrint('[CrewRecord] 일별 조회 예외: $e');
      _hasError.value = true;
    }
  }
}
