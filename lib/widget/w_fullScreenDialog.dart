import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';


class CustomFullScreenDialog {

  static void showDialog() {
    Get.dialog(
      WillPopScope(
        child: Lottie.asset('assets/json/loadings_wht_final.json'),
        onWillPop: () => Future.value(false),
      ),
      barrierDismissible: false,
      barrierColor: Color(0xff000000).withOpacity(.45),
      useSafeArea: true,
    );
  }

  static void cancelDialog() {
    Get.back();
  }
}