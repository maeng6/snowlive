import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_loadingPage.dart';
import 'package:snowlive3/controller/vm_splashController.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return AnimatedSplashScreen(
        curve: Curves.easeInCirc,
        splashTransition: SplashTransition.fadeTransition,
        splashIconSize: double.maxFinite,
        duration: 1500,
        //TODO: Dependency Injection********************************************
        splash: GetBuilder(
          init: Get.put(SplashController()),
          builder: (SplashController controller) {
            return ExtendedImage.network(
              '${controller.url}',
              fit: BoxFit.fitHeight,
              cache: true,
            );
          },
        ),
        nextScreen: LoadingPage()
    );
  }
}