import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainHomeViewModel extends GetxController {

  var _pageController = PageController().obs;
  get pageController => _pageController.value;

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
    } else if (index == 3) {
      _tap_4.value = true;
    } else if (index == 4) {
      _tap_5.value = true;
    }

   _pageController.value.jumpToPage(index);

  }

  void changePage(int index) {
    this._currentPage.value = index;
  }

}
