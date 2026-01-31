import 'dart:convert';
import 'package:com.snowlive/api/api_ranking.dart';
import 'package:com.snowlive/model/m_seasonRidingCard.dart';
import 'package:com.snowlive/model/m_dailyRidingCard.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RidingCardViewModel extends GetxController {
  final RankingAPI _api = RankingAPI();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  // ============================================
  // 로딩 상태
  // ============================================
  RxBool isLoadingSeasonCard = false.obs;
  RxBool isLoadingDailyList = false.obs;

  // ============================================
  // 시즌 기록 카드
  // ============================================
  Rxn<SeasonRidingCard> seasonRidingCard = Rxn<SeasonRidingCard>();

  // ============================================
  // 데일리 기록 카드 리스트
  // ============================================
  RxList<DailyRidingCard> dailyRidingCardList = <DailyRidingCard>[].obs;

  // ============================================
  // 시즌 선택 상태
  // ============================================
  RxString selectedSeason = '25/26시즌'.obs;
  RxString selectedSeasonDb = '2526'.obs;

  // ============================================
  // 데일리 카드 보기 모드 (grid / list)
  // ============================================
  RxBool isGridView = true.obs;

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  // ============================================
  // 데일리 카드 스킨 타입 (cardId -> cardType)
  // ============================================
  RxMap<int, int> cardTypeMap = <int, int>{}.obs;
  static const String _cardTypeMapKey = 'daily_card_type_map';

  /// 카드 스킨 타입 설정 (SharedPreferences에도 저장)
  Future<void> setCardType(int cardId, int cardType) async {
    cardTypeMap[cardId] = cardType;
    await _saveCardTypeMap();
  }

  /// 카드 스킨 타입 조회 (기본값 0)
  int getCardType(int cardId) {
    return cardTypeMap[cardId] ?? 0;
  }

  /// SharedPreferences에서 카드 타입 맵 불러오기
  Future<void> loadCardTypeMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cardTypeMapKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> decoded = json.decode(jsonString);
        cardTypeMap.value = decoded.map((key, value) => MapEntry(int.parse(key), value as int));
      }
    } catch (e) {
      print('❌ 카드 타입 맵 불러오기 오류: $e');
    }
  }

  /// SharedPreferences에 카드 타입 맵 저장하기
  Future<void> _saveCardTypeMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, int> stringKeyMap = cardTypeMap.map((key, value) => MapEntry(key.toString(), value));
      await prefs.setString(_cardTypeMapKey, json.encode(stringKeyMap));
    } catch (e) {
      print('❌ 카드 타입 맵 저장 오류: $e');
    }
  }

  final List<Map<String, String>> seasonList = [
    {'display': '25/26시즌', 'db': '2526'},
  ];

  /// 시즌 변경
  void changeSeason(String display, String dbValue) {
    selectedSeason.value = display;
    selectedSeasonDb.value = dbValue;
  }

  /// 데일리 카드 최신순 정렬
  List<DailyRidingCard> get sortedDailyCards {
    final sorted = List<DailyRidingCard>.from(dailyRidingCardList);
    sorted.sort((a, b) => (b.date ?? '').compareTo(a.date ?? ''));
    return sorted;
  }

  /// 데일리 카드 월별 그룹화 (최신순)
  Map<String, List<DailyRidingCard>> get groupedDailyCardsByMonth {
    final sorted = sortedDailyCards;
    final Map<String, List<DailyRidingCard>> grouped = {};

    for (final card in sorted) {
      if (card.date == null || card.date!.isEmpty) continue;

      // date 형식: "2025-01-30" -> "1월"
      final parts = card.date!.split('-');
      if (parts.length >= 2) {
        final month = int.tryParse(parts[1]) ?? 0;
        final monthKey = '$month월';

        if (!grouped.containsKey(monthKey)) {
          grouped[monthKey] = [];
        }
        grouped[monthKey]!.add(card);
      }
    }

    return grouped;
  }

  // ============================================
  // 시즌 기록 카드 조회
  // ============================================

  /// 시즌 기록 카드 조회 (현재 시즌)
  Future<void> fetchSeasonRidingCard({int? userId, String? season}) async {
    isLoadingSeasonCard.value = true;
    try {
      final body = {
        'user_id': userId ?? _userViewModel.user.user_id,
        if (season != null) 'season': season,
      };

      final response = await _api.fetchSeasonRidingCard(body);

      if (response.success) {
        seasonRidingCard.value = SeasonRidingCard.fromJson(response.data);
      } else {
        seasonRidingCard.value = null;
        print('❌ 시즌 기록 카드 조회 실패: ${response.error}');
      }
    } catch (e) {
      seasonRidingCard.value = null;
      print('❌ 시즌 기록 카드 조회 에러: $e');
    } finally {
      isLoadingSeasonCard.value = false;
    }
  }

  /// 특정 시즌 기록 카드 조회
  Future<SeasonRidingCard?> fetchSeasonRidingCardBySeason({
    required int userId,
    required String season,
  }) async {
    try {
      final response = await _api.fetchSeasonRidingCard({
        'user_id': userId,
        'season': season,
      });

      if (response.success) {
        return SeasonRidingCard.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('❌ 시즌 기록 카드 조회 에러: $e');
      return null;
    }
  }

  // ============================================
  // 데일리 기록 카드 리스트 조회
  // ============================================

  /// 데일리 기록 카드 리스트 조회
  Future<void> fetchDailyRidingCardList({int? userId}) async {
    isLoadingDailyList.value = true;
    try {
      final response = await _api.fetchDailyRidingCardList({
        'user_id': userId ?? _userViewModel.user.user_id,
      });

      if (response.success) {
        dailyRidingCardList.value = (response.data as List)
            .map((item) => DailyRidingCard.fromJson(item))
            .toList();
      } else {
        dailyRidingCardList.clear();
        print('❌ 데일리 기록 카드 리스트 조회 실패: ${response.error}');
      }
    } catch (e) {
      dailyRidingCardList.clear();
      print('❌ 데일리 기록 카드 리스트 조회 에러: $e');
    } finally {
      isLoadingDailyList.value = false;
    }
  }

  /// 특정 사용자의 데일리 기록 카드 리스트 조회 (반환값 사용)
  Future<List<DailyRidingCard>> fetchDailyRidingCardListByUserId(int userId) async {
    try {
      final response = await _api.fetchDailyRidingCardList({
        'user_id': userId,
      });

      if (response.success) {
        return (response.data as List)
            .map((item) => DailyRidingCard.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ 데일리 기록 카드 리스트 조회 에러: $e');
      return [];
    }
  }

  // ============================================
  // 유틸리티
  // ============================================

  /// 모든 데이터 조회 (시즌 + 데일리)
  Future<void> fetchAllRidingCards({int? userId}) async {
    await Future.wait([
      fetchSeasonRidingCard(userId: userId),
      fetchDailyRidingCardList(userId: userId),
    ]);
  }

  /// 상태 초기화
  void reset() {
    seasonRidingCard.value = null;
    dailyRidingCardList.clear();
    isLoadingSeasonCard.value = false;
    isLoadingDailyList.value = false;
  }

  /// 시즌 카드만 초기화
  void resetSeasonCard() {
    seasonRidingCard.value = null;
    isLoadingSeasonCard.value = false;
  }

  /// 데일리 리스트만 초기화
  void resetDailyList() {
    dailyRidingCardList.clear();
    isLoadingDailyList.value = false;
  }
}
