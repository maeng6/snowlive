import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/mobile/viewmodel/util/vm_imageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class CustomFullScreenDialogMobile {

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
}
