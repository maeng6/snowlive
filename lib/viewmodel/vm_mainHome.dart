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

    // 탭 활성화 처리 (스라마켓 탭 숨김)
    if (index == 0) _tap_1.value = true;  // 홈
    if (index == 1) _tap_2.value = true;  // 중고거래
    if (index == 2) _tap_3.value = true;  // 랭킹 (기존 index 3)
    if (index == 3) _tap_5.value = true;  // 더보기 (기존 index 4)

    _currentPage.value = index;

    // 스라마켓 탭이 숨겨져서 BottomNavBar와 PageView 인덱스가 일치
    _pageController.value.jumpToPage(index);
  }

  void changePage(int index) {
    // 스라마켓 탭이 숨겨져서 BottomNavBar와 PageView 인덱스가 일치
    _currentPage.value = index;

    // 탭 활성화 상태도 변경
    _tap_1.value = index == 0;  // 홈
    _tap_2.value = index == 1;  // 중고거래
    _tap_3.value = index == 2;  // 랭킹 (기존 index 3)
    _tap_4.value = false;        // 스라마켓 탭 숨김
    _tap_5.value = index == 3;  // 더보기 (기존 index 4)
  }

  @override
  void onClose() {
    // 메모리 누수 방지: PageController 정리
    _pageController.value.dispose();
    super.onClose();
  }
}
