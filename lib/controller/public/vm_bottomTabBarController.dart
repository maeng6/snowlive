import 'package:com.snowlive/controller/public/vm_loadingController.dart';
import 'package:com.snowlive/controller/ranking/vm_myCrewRankingController.dart';
import 'package:com.snowlive/controller/ranking/vm_myRankingController.dart';
import 'package:com.snowlive/controller/ranking/vm_rankingTierModelController.dart';
import 'package:com.snowlive/controller/user/vm_userModelController.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../widget/w_fullScreenDialog.dart';

class PageControllerManager extends GetxController {
  var _pageController = PageController().obs;
  get pageController => _pageController.value;
}

class BottomTabBarController extends GetxController {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  MyRankingController _myRankingController = Get.find<MyRankingController>();
  LoadingController _loadingController = Get.find<LoadingController>();
  MyCrewRankingController _myCrewRankingController = Get.find<MyCrewRankingController>();
  //TODO: Dependency Injection**************************************************


  RxBool _tap_1 = true.obs;
  RxBool _tap_2 = false.obs;
  RxBool _tap_3 = false.obs;
  RxBool _tap_4 = false.obs;
  RxBool _tap_5 = false.obs;
  RxInt _currentPage = 0.obs;
  bool? get tap_1 => _tap_1.value;
  bool? get tap_2 => _tap_2.value;
  bool? get tap_3 => _tap_3.value;
  bool? get tap_4 => _tap_4.value;
  bool? get tap_5 => _tap_5.value;
  int? get currentPage => _currentPage.value;

  Future<void> _loadRankingData() async {
    CustomFullScreenDialog.showDialog_progress();
    if (_userModelController.favoriteResort != 12 &&
        _userModelController.favoriteResort != 2 &&
        _userModelController.favoriteResort != 0) {
      print('통합랭킹 진입');
      _loadingController.updateProgress(0);
      await _rankingTierModelController.getRankingDocs_integrated();
      _loadingController.updateProgress(10);
      await _rankingTierModelController.getRankingDocs_integrated_Daily();
      _loadingController.updateProgress(20);
      await _rankingTierModelController.getRankingDocs_integrated_Weekly();
      _loadingController.updateProgress(30);
      await _rankingTierModelController.getRankingDocs_crew_integrated();
      _loadingController.updateProgress(40);
      await _rankingTierModelController.getRankingDocs_crew_integrated_Daily();
      _loadingController.updateProgress(50);
      await _rankingTierModelController.getRankingDocs_crew_integrated_Weekly();
      _loadingController.updateProgress(60);
    } else {
      _loadingController.updateProgress(0);
      await _rankingTierModelController.getRankingDocs(baseResort: _userModelController.favoriteResort);
      _loadingController.updateProgress(10);
      await _rankingTierModelController.getRankingDocsDaily(baseResort: _userModelController.favoriteResort);
      _loadingController.updateProgress(20);
      await _rankingTierModelController.getRankingDocsWeekly(baseResort: _userModelController.favoriteResort);
      _loadingController.updateProgress(30);
      await _rankingTierModelController.getRankingDocs_crew(baseResort: _userModelController.favoriteResort!);
      _loadingController.updateProgress(40);
      await _rankingTierModelController.getRankingDocs_crew_Daily(baseResort: _userModelController.favoriteResort!);
      _loadingController.updateProgress(50);
      await _rankingTierModelController.getRankingDocs_crew_Weekly(baseResort: _userModelController.favoriteResort!);
      _loadingController.updateProgress(60);
    }

    await _myRankingController.getMyRankingData(_userModelController.uid);
    await _myRankingController.getMyRankingDataDaily(_userModelController.uid);
    await _myRankingController.getMyRankingDataWeekly(_userModelController.uid);
    _loadingController.updateProgress(70);
    await _myCrewRankingController.getMyCrewRankingData(_userModelController.liveCrew);
    _loadingController.updateProgress(80);
    await _myCrewRankingController.getMyCrewRankingDataDaily(_userModelController.liveCrew);
    _loadingController.updateProgress(90);
    await _myCrewRankingController.getMyCrewRankingDataWeekly(_userModelController.liveCrew);
    _loadingController.updateProgress(100);

    CustomFullScreenDialog.cancelDialog();
  }


  void onItemTapped(int index) {
    // 모든 탭을 초기화
    _tap_1.value = false;
    _tap_2.value = false;
    _tap_3.value = false;
    _tap_4.value = false;
    _tap_5.value = false;

    // 선택된 탭 활성화
    if (index == 0) {
      _tap_1.value = true;
    } else if (index == 1) {
      _tap_2.value = true;
    } else if (index == 2) {
      _tap_3.value = true;
      _loadRankingData();
    } else if (index == 3) {
      _tap_4.value = true;
    } else if (index == 4) {
      _tap_5.value = true;
    }

    Get.find<PageControllerManager>().pageController.jumpToPage(index);
  }

  void changePage(int index) {
    this._currentPage.value = index;
  }

}
