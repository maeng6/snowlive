import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controller/vm_loadingController.dart';


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

  static void showDialog_progress() {
    Get.dialog(
      WillPopScope(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/json/loadings_wht_final.json'),
            SizedBox(height: 20),
            Obx(() {
              final progress = Get.find<LoadingController>().progress.value;
              return DefaultTextStyle(
                style: TextStyle(
                  fontSize: 10.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                child: Column(
                  children: [
                    Text('$progress%',)
                  ],
                ),
              );
            }),
          ],
        ),
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