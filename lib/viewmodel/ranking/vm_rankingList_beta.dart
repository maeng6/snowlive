import 'package:com.snowlive/api/api_ranking.dart';
import 'package:com.snowlive/model/m_rankingListCrew_beta.dart';
import 'package:com.snowlive/model/m_rankingListIndiv_beta.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RankingListBetaViewModel extends GetxController {
  var isLoadingBeta_indiv = false.obs;
  var isLoadingBeta_crew = false.obs;
  RxString _crewOrIndiv = '크루'.obs;
  RxBool _isLoadingNextList_crew = false.obs;
  RxBool _isLoadingNextList_indi = false.obs;

  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  // 베타 개인 랭킹 관련 변수
  var _rankingListIndivBetaList = <RankingUserBeta>[].obs;

  // 베타 크루 랭킹 관련 변수
  var _rankingListCrewBetaList = <CrewRankingBeta>[].obs;

  // 페이징 관련 변수
  RxString _nextPageUrlIndivBeta = ''.obs;
  RxString _nextPageUrlCrewBeta = ''.obs;

  List<RankingUserBeta> get rankingListIndivBetaList => _rankingListIndivBetaList;
  List<CrewRankingBeta> get rankingListCrewBetaList => _rankingListCrewBetaList;

  String get nextPageUrlIndivBeta => _nextPageUrlIndivBeta.value;
  String get nextPageUrlCrewBeta => _nextPageUrlCrewBeta.value;

  String get crewOrIndiv => _crewOrIndiv.value;

  bool get isLoadingNextList_crew => _isLoadingNextList_crew.value;
  bool get isLoadingNextList_indi => _isLoadingNextList_indi.value;

  ScrollController scrollControllerIndivBeta = ScrollController();
  ScrollController scrollControllerCrewBeta = ScrollController();

  @override
  void onInit() async{
    super.onInit();
    scrollControllerIndivBeta = ScrollController()..addListener(_scrollListenerIndivBeta);
    scrollControllerCrewBeta = ScrollController()..addListener(_scrollListenerCrewBeta);
    await fetchAllRankingBeta();
  }

  Future<void> fetchAllRankingBeta() async {
    await fetchRankingDataCrewBeta();
    await fetchRankingDataIndivBeta();
  }

  Future<void> fetchRankingDataIndivBeta({ int? userId, String? url}) async {
    try {
      isLoadingBeta_indiv(true);
      final response = await RankingAPI().fetchRankingData_indiv_beta(userId: userId, url: url);
      if (response.success) {
        final rankingListIndivResponseBeta = RankingListIndivResponseBeta.fromJson(response.data!);

        if (url == null) {
          _rankingListIndivBetaList.value = rankingListIndivResponseBeta.results;
        } else {
          _rankingListIndivBetaList.addAll(rankingListIndivResponseBeta.results);
        }
        _nextPageUrlIndivBeta.value = rankingListIndivResponseBeta.next ?? '';
      } else {
        print('Failed to load individual beta ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching individual beta ranking: $e');
    } finally {
      isLoadingBeta_indiv(false);
    }
  }

  Future<void> fetchRankingDataIndivBeta_next({ int? userId, String? url}) async {
    try {
      final response = await RankingAPI().fetchRankingData_indiv_beta(userId: userId, url: url);
      if (response.success) {
        final rankingListIndivResponseBeta = RankingListIndivResponseBeta.fromJson(response.data!);

        if (url == null) {
          _rankingListIndivBetaList.value = rankingListIndivResponseBeta.results;
        } else {
          _rankingListIndivBetaList.addAll(rankingListIndivResponseBeta.results);
        }
        _nextPageUrlIndivBeta.value = rankingListIndivResponseBeta.next ?? '';
      } else {
        print('Failed to load individual beta ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching individual beta ranking: $e');
    }
  }

  Future<void> fetchRankingDataCrewBeta({ int? crewId, String? url}) async {
    try {
      isLoadingBeta_crew(true);
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
        print('Failed to load crew beta ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching crew beta ranking: $e');
    } finally {
      isLoadingBeta_crew(false);
    }
  }

  Future<void> fetchRankingDataCrewBeta_next({ int? crewId, String? url}) async {
    try {
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
        print('Failed to load crew beta ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching crew beta ranking: $e');
    }
  }

  Future<void> fetchNextPageIndivBeta() async {
    if (_nextPageUrlIndivBeta.value.isNotEmpty) {
      await fetchRankingDataIndivBeta_next(userId: _userViewModel.user.user_id, url: _nextPageUrlIndivBeta.value);
    }
  }

  Future<void> fetchNextPageCrewBeta() async {
    if (_nextPageUrlCrewBeta.value.isNotEmpty) {
      await fetchRankingDataCrewBeta_next(crewId: _userViewModel.user.crew_id, url: _nextPageUrlCrewBeta.value);
    }
  }

  Future<void> _scrollListenerIndivBeta() async {
    if (scrollControllerIndivBeta.position.pixels == scrollControllerIndivBeta.position.maxScrollExtent) {
      _isLoadingNextList_indi.value = true;
      await fetchNextPageIndivBeta();
      _isLoadingNextList_indi.value = false;
    }
  }

  Future<void> _scrollListenerCrewBeta() async {
    if (scrollControllerCrewBeta.position.pixels == scrollControllerCrewBeta.position.maxScrollExtent) {
      _isLoadingNextList_crew.value = true;
      print('다음 목록 불러오기 시작');
      await fetchNextPageCrewBeta();
      _isLoadingNextList_crew.value = false;
    }
  }

  void changeCrewOrIndiv(crewOrIndiv){
    _crewOrIndiv.value = crewOrIndiv;
  }

}
