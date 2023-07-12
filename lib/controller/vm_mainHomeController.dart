import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class MainHomeController extends GetxController {
  RxInt currentPage = 0.obs;
  bool? wait;
  bool getUserComp=false;

  PageController _pageController = PageController();

  void switchTab(int index) {
      currentPage.value = index;
      _pageController.jumpToPage(index);
  }

  void changePage(int index) {
    currentPage.value = index;
  }

  void navigateToMoreTab() {
    _onItemTapped(4); // if MoreTab is the 5th item (0-indexed)
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }



}
