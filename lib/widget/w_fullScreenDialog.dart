import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/util/vm_loadingController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class CustomFullScreenDialog {

  static void showDialog() {
    Get.dialog(
      WillPopScope(
        child: Center(
            child: Container(
                width: 90,
                height: 90,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  color: SDSColor.snowliveBlack.withOpacity(0.8),
                ),
                child: Lottie.asset('assets/json/loadings_wht_final.json',
                )
            )
        ),
        onWillPop: () => Future.value(false),
      ),
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(.5),
      useSafeArea: true,
    );
  }

  static void showDialog_progress() {
    Get.dialog(
      WillPopScope(
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              color: SDSColor.snowliveBlack.withOpacity(0.7),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/json/loadings_wht_final.json'),
                SizedBox(height: 10),
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
                        Text('$progress%',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        ),
                        )
                      ],
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
        onWillPop: () => Future.value(false),
      ),
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(.7),
      useSafeArea: true,
    );
  }

  static void cancelDialog() {
    Get.back();
  }
}