import 'package:get/get.dart';
import '../api/api_ranking.dart';
import '../model/m_rankingListCrew.dart';
import '../model/m_rankingListIndiv.dart';

class RankingListViewModel extends GetxController {
  var isLoading = true.obs;
  var _rankingListCrew = RankingListCrewModel().obs;
  var _rankingListIndiv = RankingListIndivResponse().obs;

  RankingListCrewModel get rankingListCrew => _rankingListCrew.value;
  RankingListIndivResponse get rankingListIndiv => _rankingListIndiv.value;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchRankingDataIndiv({
    required int userId,
    int? resortId,
    bool? daily,
    String? season,
  }) async {
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_indiv(
        userId: userId,
        resortId: resortId,
        daily: daily,
        season: season,
      );

      if (response.success) {
        final rankingListIndivResponse = RankingListIndivResponse.fromJson(response.data!);
        _rankingListIndiv.value = rankingListIndivResponse;
      } else {
        print('Failed to load individual ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching individual ranking: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchRankingDataIndiv_refresh({
    required int userId,
    int? resortId,
    bool? daily,
    String? season,
  }) async {
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_indiv_Refresh(
        userId: userId,
        resortId: resortId,
        daily: daily,
        season: season,
      );

      if (response.success) {
        final rankingListIndivResponse = RankingListIndivResponse.fromJson(response.data!);
        _rankingListIndiv.value = rankingListIndivResponse;
      } else {
        print('Failed to load individual ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching individual ranking: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchRankingDataCrew({
    required int userId,
    int? resortId,
    bool? daily,
    String? season,
  }) async {
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_crew(
        userId: userId,
        resortId: resortId,
        daily: daily,
        season: season,
      );

      if (response.success) {
        final rankingListCrewResponse = RankingListCrewModel.fromJson(response.data!);
        _rankingListCrew.value = rankingListCrewResponse;
      } else {
        print('Failed to load crew ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching crew ranking: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchRankingDataCrew_refresh({
    required int userId,
    int? resortId,
    bool? daily,
    String? season,
  }) async {
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_crew_Refresh(
        userId: userId,
        resortId: resortId,
        daily: daily,
        season: season,
      );

      if (response.success) {
        final rankingListCrewResponse = RankingListCrewModel.fromJson(response.data!);
        _rankingListCrew.value = rankingListCrewResponse;
      } else {
        print('Failed to load crew ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching crew ranking: $e');
    } finally {
      isLoading(false);
    }
  }




}
