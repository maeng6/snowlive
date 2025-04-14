import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_authcheck.dart';
import 'package:com.snowlive/viewmodel/vm_splashController.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({Key? key}) : super(key: key);

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  final SplashController _splashController = Get.find<SplashController>();
  final defaultSplashUrl = 'https://i.esdrop.com/d/f/yytYSNBROy/spAvUnyvK6.png';

  @override
  void initState() {
    super.initState();

    // 이미지 노출한 상태에서 userCheck 실행
    Future.microtask(() async {
      await _splashController.userCheck();
      final nextRoute = _splashController.gotoMainHome
          ? AppRoutes.mainHome
          : AppRoutes.login;

      // 약간의 여유 딜레이 후 화면 전환
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed(nextRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final splashUrl = _splashController.url.isNotEmpty
        ? _splashController.url
        : defaultSplashUrl;

    return ExtendedImage.network(
      splashUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      enableMemoryCache: true,
    );
  }
}


