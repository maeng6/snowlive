import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class MainHomeController extends GetxController {
  RxInt currentPage = 0.obs;
  bool? wait;
  bool getUserComp=false;

  PageController pageController = PageController();

  void switchTab(int index) {
      currentPage.value = index;
      pageController.jumpToPage(index);
  }

  void changePage(int index) {
    currentPage.value = index;
  }

}
