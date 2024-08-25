import 'package:com.snowlive/controller/ranking/vm_myRankingController.dart';
import 'package:com.snowlive/controller/resort/vm_resortModelController.dart';
import 'package:com.snowlive/controller/user/vm_userModelController.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class RefreshController extends GetxController {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  MyRankingController _myRankingController = Get.find<MyRankingController>();
  //TODO: Dependency Injection**************************************************

  Future<void> onRefresh_resortHome() async {
    await _userModelController.updateInstantResort(_userModelController.favoriteResort);
    await _resortModelController.getSelectedResort(_userModelController.instantResort!);
  }

  Future<void> onRefresh_ranking_indi() async {
    await _myRankingController.getMyRankingData(_userModelController.uid);
  }

}
