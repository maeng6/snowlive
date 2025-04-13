import 'package:com.snowlive/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final bool gotoMainHome;

  const SplashScreen({Key? key, required this.gotoMainHome}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.gotoMainHome) {
        Get.offAllNamed(AppRoutes.mainHome);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // 아무것도 보여주지 않음
  }
}
