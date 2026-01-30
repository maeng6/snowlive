import 'package:com.snowlive/api/api_ranking.dart';
import 'package:com.snowlive/model/m_seasonRidingCard.dart';
import 'package:com.snowlive/model/m_dailyRidingCard.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';

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
