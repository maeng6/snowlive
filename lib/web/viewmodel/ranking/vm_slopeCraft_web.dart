import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_ranking.dart';
import 'package:com.snowlive/core/model/m_slope_rush.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/data/slope_craft_maps_web.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// 슬로프크래프트(슬로프 점령도)용 웹 전용 뷰모델.
///
/// 코어 `SlopeRushViewModel`/`SlopeRushRecordRoomViewModel`을 쓰지 않는다 —
/// 둘 다 화면과 얽힌 상태(선택 슬로프·로딩 상세)를 갖고 있고 웹은 현재/지난 시즌을
/// **한 화면에서** 전환하므로 상태를 하나로 합치는 게 맞다. API·모델은 순수 Dart라
/// 그대로 쓴다(`slope-rush/`, `slope-rush-recordroom/` 둘 다 같은 응답 모양).
class SlopeCraftViewModelWeb extends GetxController {
  final RankingAPI _api = RankingAPI();

  UserViewModel get _userVM => Get.find<UserViewModel>();

  /// ⚠️ 이 API는 `user_id`를 **필수로, 그리고 존재하는 유저**로 받는다
  /// (실측: 없거나 null·0 → 400, 없는 id → 404). 응답에는 개인화된 값이 하나도 없어서
  /// (슬로프 점령은 전역 집계) 비로그인 방문자에게는 아무 유효한 id나 넣어야 조회가 된다.
  /// 서버가 `user_id` 없이도 받아 주면 이 상수를 지우면 된다.
  static const int kGuestUserId = 1;

  /// 지난 시즌 탭의 시즌 선택지. `2324`는 서버가 거부한다(실측:
  /// `Ranking_record_2324 모델을 찾을 수 없습니다`) → 목업의 세 번째 칩은 만들지 않는다.
  static const List<({String label, String season})> kSeasons = [
    (label: '25/26', season: '2526'),
    (label: '24/25', season: '2425'),
  ];

  final RxInt _resortId = 0.obs;
  final RxBool _isPastSeason = false.obs;
  final RxString _season = kSeasons.first.season.obs;
  final RxList<SlopeRushItem> _items = <SlopeRushItem>[].obs;
  final RxnString _selectedSlopeKey = RxnString();
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _resortFullname = ''.obs;

  int get resortId => _resortId.value;
  bool get isPastSeason => _isPastSeason.value;
  String get season => _season.value;
  List<SlopeRushItem> get items => _items;
  String? get selectedSlopeKey => _selectedSlopeKey.value;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get resortFullname => _resortFullname.value;

  /// 지도에 쓸 리조트. 아직 안 골랐으면 내 관심 스키장 → 그것도 없으면 첫 스키장.
  int get effectiveResortId {
    if (_resortId.value != 0) return _resortId.value;
    final fav = _userVM.user.favorite_resort;
    if (fav is int && kSlopeCraftResortSlug.containsKey(fav)) return fav;
    return kSlopeCraftResorts.first.id;
  }

  String get resortName =>
      kSlopeCraftResorts
          .firstWhereOrNull((r) => r.id == effectiveResortId)
          ?.name ??
      _resortFullname.value;

  /// 지금 고른 슬로프(없으면 `전체`).
  SlopeRushItem? get selectedSlope {
    final key = _selectedSlopeKey.value;
    if (key == null) return null;
    for (final item in _items) {
      if (slopeKeyOf(item) == key) return item;
    }
    return null;
  }

  /// 서버 슬로프명(별명 우선) → 지도 이미지 키.
  String? slopeKeyOf(SlopeRushItem item) => slopeCraftSlopeKey(
        effectiveResortId,
        item.slopeNickname.isNotEmpty ? item.slopeNickname : item.slopeFullname,
      );

  /// 그 슬로프를 점령한(1위) 크루. 비율이 가장 높은 크루다.
  SlopeCrew? leaderOf(SlopeRushItem item) {
    if (item.crews.isEmpty) return null;
    final sorted = [...item.crews]..sort((a, b) => b.ratio.compareTo(a.ratio));
    return sorted.first;
  }

  Future<void> load() async {
    final resort = effectiveResortId;
    _resortId.value = resort;
    _isLoading.value = true;
    _hasError.value = false;
    _items.clear();
    try {
      final userId = _userVM.user.user_id ?? kGuestUserId;
      final body = <String, dynamic>{
        'resort_id': resort,
        'user_id': userId,
        if (_isPastSeason.value) 'selected_season': _season.value,
      };
      final ApiResponse res = _isPastSeason.value
          ? await _api.fetchSlopeRush_recordRoom(body)
          : await _api.fetchSlopeRush(body);
      if (!res.success) {
        debugPrint('[SlopeCraft] 조회 실패: ${res.error}');
        _hasError.value = true;
        return;
      }
      // 기록실 응답도 키가 같아서(`slope_occupancy`) 같은 모델로 파싱한다.
      final parsed = SlopeRushResponse.fromJson(res.data as Map<String, dynamic>);
      _resortFullname.value = parsed.resortFullname;
      _items.assignAll(parsed.slopeRush);
    } catch (e) {
      debugPrint('[SlopeCraft] 조회 예외: $e');
      _hasError.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> selectResort(int resortId) async {
    if (resortId == _resortId.value) return;
    _resortId.value = resortId;
    // 스키장이 바뀌면 슬로프 선택은 의미가 없다(지도·목록이 통째로 갈린다).
    _selectedSlopeKey.value = null;
    await load();
  }

  Future<void> setPastSeason(bool value) async {
    if (value == _isPastSeason.value) return;
    _isPastSeason.value = value;
    _selectedSlopeKey.value = null;
    await load();
  }

  Future<void> setSeason(String season) async {
    if (season == _season.value) return;
    _season.value = season;
    _selectedSlopeKey.value = null;
    await load();
  }

  /// 슬로프 선택/해제. 같은 슬로프를 다시 누르면 `전체`로 돌아간다.
  void toggleSlope(String? slopeKey) {
    _selectedSlopeKey.value = _selectedSlopeKey.value == slopeKey ? null : slopeKey;
  }

  void clearSlope() => _selectedSlopeKey.value = null;
}
