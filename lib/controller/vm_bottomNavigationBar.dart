import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/brand/v_brandHome.dart';
import 'package:snowlive3/screens/resort/v_resortHome.dart';

class BottomNavigationBarController extends GetxController {

  RxInt currentIndex = 0.obs;

  List<Widget> pages = [
    ResortHome(),
    BrandWebBody(),
  ];

  Widget get currentPage => pages[currentIndex.value];

  void changePage(int index) {
    currentIndex.value = index;
  }
}