import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/util/vm_imageController.dart';
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

  // 중고거래 이미지 업로드 전용 (진행률 % 표시)
  static void showDialog_uploadFlea() {
    Get.dialog(
      WillPopScope(
        child: Center(
            child: Container(
                width: 90,
                height: 90,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: SDSColor.snowliveBlack.withOpacity(0.8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: Lottie.asset('assets/json/loadings_wht_final.json'),
                    ),
                    SizedBox(height: 6),
                    Obx(() {
                      final imageController = Get.find<ImageController>();
                      if (imageController.isUploading.value && imageController.uploadTotal.value > 0) {
                        int percent = ((imageController.uploadProgress.value / imageController.uploadTotal.value) * 100).toInt();
                        return Text(
                          '$percent%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    }),
                  ],
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