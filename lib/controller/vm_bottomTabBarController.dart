import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class PageControllerManager extends GetxController {
  var _pageController = PageController().obs;
  get pageController => _pageController.value;
}

class BottomTabBarController extends GetxController {
  RxInt _currentPage = 0.obs;
  int? get currentPage => _currentPage.value;

  void onItemTapped(int index) {
    Get.find<PageControllerManager>().pageController.jumpToPage(index);
  }

  void changePage(int index) {
    this._currentPage.value = index;
  }
}
