import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_authcheck.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//이거 안씀이제
class SplashScreen extends StatefulWidget {
  final String imageUrl;
  final bool gotoMainHome;

  const SplashScreen({Key? key, required this.imageUrl, required this.gotoMainHome}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthCheckViewModel controller = Get.find<AuthCheckViewModel>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      // 0.5초 후 화면 전환
      if (widget.gotoMainHome) {
        Get.offAllNamed(AppRoutes.mainHome);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExtendedImage.network(
        widget.imageUrl,
        fit: BoxFit.cover,
        enableMemoryCache: true,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

