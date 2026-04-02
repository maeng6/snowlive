import 'package:com.snowlive/api/api_ranking.dart';
import 'package:com.snowlive/model/m_rankingListCrew_beta.dart';
import 'package:com.snowlive/model/m_rankingListIndiv_beta.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RankingIndivHistoryViewModel extends GetxController {
  var isLoadingBeta_indiv = false.obs;

  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  // 베타 개인 랭킹 관련 변수
  var _rankingListIndivBetaList = <RankingUserBeta>[].obs;

  // 페이징 관련 변수
  RxString _nextPageUrlIndivBeta = ''.obs;

  List<RankingUserBeta> get rankingListIndivBetaList => _rankingListIndivBetaList;

  ScrollController scrollControllerIndivBeta = ScrollController();

  RxString _selectedCategory_season = '25/26시즌'.obs;

  String get selectedCategory_season => _selectedCategory_season.value;
  String get nextPageUrlIndivBeta => _nextPageUrlIndivBeta.value;

  @override
  void onInit() async{
    super.onInit();
    scrollControllerIndivBeta = ScrollController()..addListener(_scrollListenerIndivBeta);
    await fetchAllRankingBeta();
  }

  @override
  void onClose() {
    scrollControllerIndivBeta.removeListener(_scrollListenerIndivBeta);
    scrollControllerIndivBeta.dispose();
    super.onClose();
  }

  Future<void> fetchAllRankingBeta() async {
    await fetchRankingDataIndivBeta(userId: _userViewModel.user.user_id);
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

  Future<void> fetchNextPageIndivBeta() async {
    if (_nextPageUrlIndivBeta.value.isNotEmpty) {
      await fetchRankingDataIndivBeta(userId: _userViewModel.user.user_id, url: _nextPageUrlIndivBeta.value);
    }
  }

  Future<void> _scrollListenerIndivBeta() async {
    if (scrollControllerIndivBeta.position.pixels == scrollControllerIndivBeta.position.maxScrollExtent) {
      await fetchNextPageIndivBeta();
    }
  }

  void changeCategory_season(value) {
    _selectedCategory_season.value = value;
  }


}

