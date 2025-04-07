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
    // 모든 탭 초기화
    _tap_1.value = false;
    _tap_2.value = false;
    _tap_3.value = false;
    _tap_4.value = false;
    _tap_5.value = false;

    // 탭 활성화 처리
    if (index == 0) _tap_1.value = true;
    if (index == 1) _tap_2.value = true;
    if (index == 2) _tap_3.value = true;
    if (index == 3) _tap_4.value = true; // 슬마켓
    if (index == 4) _tap_5.value = true;

    _currentPage.value = index;

    // 슬마켓(커뮤니티)은 PageView에 없으므로 jumpToPage 하지 않음
    if (index == 3) return;

    // index 4 ("더보기")는 PageView에서는 index 3임!
    final pageViewIndex = index > 3 ? index - 1 : index;
    _pageController.value.jumpToPage(pageViewIndex);
  }

  void changePage(int index) {
    // PageView는 슬마켓이 빠져 있으므로, 3번부터는 탭 index +1로 매핑
    _currentPage.value = index >= 3 ? index + 1 : index;

    // 탭 활성화 상태도 변경
    _tap_1.value = index == 0;
    _tap_2.value = index == 1;
    _tap_3.value = index == 2;
    _tap_4.value = false;      // 슬마켓은 PageView에 없음
    _tap_5.value = index == 3;
  }


}
