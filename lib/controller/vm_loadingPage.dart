import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_friendsCommentController.dart';
import 'package:com.snowlive/controller/vm_getDateTimeController.dart';
import 'package:com.snowlive/controller/vm_liveCrewModelController.dart';
import 'package:com.snowlive/controller/vm_liveMapController.dart';
import 'package:com.snowlive/controller/vm_loginController.dart';
import 'package:com.snowlive/controller/vm_mainHomeController.dart';
import 'package:com.snowlive/controller/vm_noticeController.dart';
import 'package:com.snowlive/controller/vm_rankingTierModelController.dart';
import 'package:com.snowlive/controller/vm_resortModelController.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/controller/vm_timeStampController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
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

    // Dependency Injection
    Get.put(ResortModelController(), permanent: true);
    Get.put(UserModelController(), permanent: true);
    Get.put(GetDateTimeController(), permanent: true);
    Get.put(TimeStampController(), permanent: true);
    Get.put(FriendsCommentModelController(), permanent: true);
    Get.put(MainHomeController(), permanent: true);
    Get.put(LiveCrewModelController(), permanent: true);
    Get.put(SeasonController(), permanent: true);

    LoginController _logInController = Get.put(LoginController());

    // 로그인 관련 작업
    _logInController.loginAgain().then((_) {
      if (_logInController.loginUid != null) {
        Get.offAll(() => MainHome(uid: _logInController.loginUid, initialPage: 0,));
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