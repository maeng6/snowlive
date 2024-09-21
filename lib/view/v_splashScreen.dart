import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_authcheck.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final String imageUrl;

  SplashScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // Get.find로 컨트롤러 가져오기
  final AuthCheckViewModel controller = Get.find<AuthCheckViewModel>();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // initState에서 초기화 작업 수행
  Future<void> _initialize() async {
    await controller.checkForUpdate();
    await controller.userCheck();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        curve: Curves.easeInCirc,
        splashIconSize: double.maxFinite,
        duration: 1500,
        splash: ExtendedImage.network(
          widget.imageUrl,
          fit: BoxFit.fitHeight,
          enableMemoryCache: true,
        ),
      nextScreen: Builder(
        builder: (context) {
          // 빌드가 완료된 후 화면 전환 처리
          WidgetsBinding.instance.addPostFrameCallback((_) {
            gotoMainHomeOrLogin();
          });
          return Container(); // 화면 전환 전 빈 컨테이너 반환
        },
      ),
    );
  }

  void gotoMainHomeOrLogin(){
    if(controller.gotoMainHome == true) {
      Get.offAllNamed(AppRoutes.mainHome);
    }else{
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
