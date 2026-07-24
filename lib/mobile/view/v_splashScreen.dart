import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/service/deep_link_service.dart';
import 'package:com.snowlive/mobile/viewmodel/auth/vm_authcheck.dart';
import 'package:com.snowlive/mobile/viewmodel/vm_splashController.dart';
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
  final defaultSplashAsset = 'assets/imgs/splash_screen/splash_logo.png';

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

      // UI 준비 완료 후 보류된 딥링크 처리
      Get.find<DeepLinkService>().processPendingDeepLink();
    });
  }

  @override
  Widget build(BuildContext context) {
    // controller에 URL이 있으면 네트워크 이미지, 없으면 로컬 이미지
    if (_splashController.url.isEmpty) {
      return ExtendedImage.asset(
        defaultSplashAsset,
        fit: BoxFit.cover,
        cacheWidth: 800,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return ExtendedImage.network(
      _splashController.url,
      fit: BoxFit.cover,
      cacheWidth: 800,
      width: double.infinity,
      height: double.infinity,
      enableMemoryCache: true,
      cache: true,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
          case LoadState.failed:
            // 로딩 중이거나 실패 시 기본 로컬 이미지 표시
            return ExtendedImage.asset(
              defaultSplashAsset,
              fit: BoxFit.cover,
              cacheWidth: 800,
              width: double.infinity,
              height: double.infinity,
            );
          case LoadState.completed:
            return ExtendedRawImage(
              image: state.extendedImageInfo?.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
        }
      },
    );
  }
}


