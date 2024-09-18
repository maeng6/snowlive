import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';
import '../api/api_ranking.dart';
import '../model/m_rankingListCrew.dart';
import '../model/m_rankingListIndiv.dart';

class RankingListViewModel extends GetxController {
  var isLoading = true.obs;
  var _rankingListCrewList = RankingListCrewModel().rankingCrewList.obs;
  var _rankingListCrewMy = RankingListCrewModel().myCrewRankingInfo.obs;
  var _rankingListIndivList = RankingListIndivResponse().rankingUsers.obs;
  var _rankingListIndivMy = RankingListIndivResponse().myRankingInfo.obs;
  RxString _tapName = '개인랭킹'.obs;
  RxString _dayOrTotal = '일간'.obs;

  List<CrewRanking>? get rankingListCrewList => _rankingListCrewList.value;
  List<RankingUser>? get rankingListIndivList => _rankingListIndivList.value;
  MyCrewRankingInfo? get rankingListCrewMy => _rankingListCrewMy.value;
  MyRankingInfo? get rankingListIndivMy => _rankingListIndivMy.value;
  String get tapName => _tapName.value;
  String get dayOrTotal => _dayOrTotal.value;

  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  void onInit() async{
    super.onInit();

    await fetchRankingDataIndiv(userId: _userViewModel.user.user_id);
    await fetchRankingDataCrew(userId: _userViewModel.user.user_id);

  }

  void changeTap(value) {
    _tapName.value = value;
  }

  void changeDayOrTotal(value) {
    _dayOrTotal.value = value;
  }

  Future<void> fetchRankingDataIndiv({
    required int userId,
    int? resortId,
    bool? daily,
    String? season,
    String? url,
  }) async {
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_indiv(
        userId: userId,
        resortId: resortId,
        daily: daily,
        season: season,
        url: url,
      );

      if (response.success) {
        final rankingListIndivResponse = RankingListIndivResponse.fromJson(response.data!);

        if (url == null) {
          // URL이 null일 경우 데이터 설정
          _rankingListIndivList.value = rankingListIndivResponse.rankingUsers;
        } else {
          // URL이 있을 경우 리스트에 추가
          _rankingListIndivList.value!.addAll(rankingListIndivResponse.rankingUsers ?? []);
        }
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
        _rankingListIndivList.value = rankingListIndivResponse.rankingUsers;
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
    String? url, // URL 추가
  }) async {
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_crew(
        userId: userId,
        resortId: resortId,
        daily: daily,
        season: season,
        url: url, // URL 전달
      );

      if (response.success) {
        final rankingListCrewResponse = RankingListCrewModel.fromJson(response.data!);

        if (url == null) {
          // URL이 null일 경우 데이터 설정
          _rankingListCrewList.value = rankingListCrewResponse.rankingCrewList;
        } else {
          // URL이 있을 경우 리스트에 추가
          _rankingListCrewList.value!.addAll(rankingListCrewResponse.rankingCrewList ?? []);
        }
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
        _rankingListCrewList.value = rankingListCrewResponse.rankingCrewList;
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
