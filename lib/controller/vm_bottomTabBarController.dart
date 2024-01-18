import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class PageControllerManager extends GetxController {
  var _pageController = PageController().obs;
  get pageController => _pageController.value;
}

class BottomTabBarController extends GetxController {
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

  void onItemTapped(int index) {
    if(index == 3) {
      this._tap_1.value = true;
      this._tap_2.value = false;
      this._tap_3.value = false;
      this._tap_4.value = false;
      this._tap_5.value = false;
    }
    Get.find<PageControllerManager>().pageController.jumpToPage(index);
  }

  void onItemTapped_Lost() {
    Get.find<PageControllerManager>().pageController.jumpToPage(3);
  }

  void changePage(int index) {
    this._currentPage.value = index;
  }

  void changePage_goto_Lost() {
    this._tap_1.value = false;
    this._tap_2.value = false;
    this._tap_3.value = true;
    this._tap_4.value = false;
    this._tap_5.value = false;
    this._currentPage.value = 3;
  }
}
