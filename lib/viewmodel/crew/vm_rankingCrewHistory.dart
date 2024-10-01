import 'package:com.snowlive/api/api_ranking.dart';
import 'package:com.snowlive/model/m_rankingListCrew_beta.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RankingCrewHistoryViewModel extends GetxController {
  var isLoadingBeta_Crew = false.obs;

  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  // 베타 개인 랭킹 관련 변수
  var _rankingListCrewBetaList = <CrewRankingBeta>[].obs;

  // 페이징 관련 변수
  RxString _nextPageUrlCrewBeta = ''.obs;

  List<CrewRankingBeta> get rankingListCrewBetaList => _rankingListCrewBetaList;

  String get nextPageUrlCrewBeta => _nextPageUrlCrewBeta.value;

  ScrollController scrollControllerCrewBeta = ScrollController();

  @override
  void onInit() async{
    super.onInit();
    scrollControllerCrewBeta = ScrollController()..addListener(_scrollListenerCrewBeta);
    await fetchAllRankingBeta();
  }

  Future<void> fetchAllRankingBeta() async {
    await fetchRankingDataCrewBeta(crewId: _userViewModel.user.crew_id);
    print('크루 베타기록 가져오기 완료');
  }

  Future<void> fetchRankingDataCrewBeta({ int? crewId, String? url}) async {
    try {
      isLoadingBeta_Crew(true);
      final response = await RankingAPI().fetchRankingData_crew_beta(crewId: crewId, url: url);
      if (response.success) {
        final rankingListCrewResponseBeta = RankingListCrewResponseBeta.fromJson(response.data!);

        if (url == null) {
          _rankingListCrewBetaList.value = rankingListCrewResponseBeta.results!;
        } else {
          _rankingListCrewBetaList.addAll(rankingListCrewResponseBeta.results!);
        }
        _nextPageUrlCrewBeta.value = rankingListCrewResponseBeta.next ?? '';
      } else {
        print('Failed to load Crewidual beta ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching Crewidual beta ranking: $e');
    } finally {
      isLoadingBeta_Crew(false);
    }
  }

  Future<void> fetchNextPageCrewBeta() async {
    if (_nextPageUrlCrewBeta.value.isNotEmpty) {
      await fetchRankingDataCrewBeta(crewId: _userViewModel.user.crew_id, url: _nextPageUrlCrewBeta.value);
    }
  }

  Future<void> _scrollListenerCrewBeta() async {
    if (scrollControllerCrewBeta.position.pixels == scrollControllerCrewBeta.position.maxScrollExtent) {
      await fetchNextPageCrewBeta();
    }
  }


}
