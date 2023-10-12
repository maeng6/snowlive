import 'package:com.snowlive/controller/vm_resortModelController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class RefreshController extends GetxController {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  //TODO: Dependency Injection**************************************************

  Future<void> onRefresh_resortHome() async {
    await _userModelController.updateInstantResort(_userModelController.favoriteResort);
    await _resortModelController.getSelectedResort(_userModelController.instantResort!);

  }

}
