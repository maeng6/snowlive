import 'package:com.snowlive/controller/vm_versionController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_loginController.dart';
import 'package:com.snowlive/screens/v_MainHome.dart';
import 'package:com.snowlive/screens/login/v_loginpage.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();

    checkForUpdate();

    LoginController _logInController = Get.find<LoginController>();

    // 로그인 관련 작업
    _logInController.loginAgain().then((_) {
      if (_logInController.loginUid != null) {
        Get.offAll(() => MainHome(uid: _logInController.loginUid));
      } else {
        Get.offAll(() => LoginPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}