import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:com.snowlive/controller/vm_friendsCommentController.dart';
import 'package:com.snowlive/controller/vm_getDateTimeController.dart';
import 'package:com.snowlive/controller/vm_liveCrewModelController.dart';
import 'package:com.snowlive/controller/vm_mainHomeController.dart';
import 'package:com.snowlive/controller/vm_resortModelController.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/controller/vm_timeStampController.dart';
import 'package:com.snowlive/controller/vm_urlLauncherController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:com.snowlive/controller/vm_loadingPage.dart';
import 'package:get/get.dart';
class SplashScreen extends StatelessWidget {
  final String imageUrl;
  SplashScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // Dependency Injection
    Get.put(ResortModelController(), permanent: true);
    Get.put(UserModelController(), permanent: true);
    Get.put(GetDateTimeController(), permanent: true);
    Get.put(TimeStampController(), permanent: true);
    Get.put(FriendsCommentModelController(), permanent: true);
    Get.put(MainHomeController(), permanent: true);
    Get.put(LiveCrewModelController(), permanent: true);
    Get.put(SeasonController(), permanent: true);
    Get.put(UrlLauncherController(), permanent: true);

    return AnimatedSplashScreen(
        curve: Curves.easeInCirc,
        splashTransition: SplashTransition.fadeTransition,
        splashIconSize: double.maxFinite,
        duration: 1500,
        splash: ExtendedImage.network(
          imageUrl,
          fit: BoxFit.fitHeight,
          enableMemoryCache: true,
              ),
        nextScreen: LoadingPage()
    );
  }
}