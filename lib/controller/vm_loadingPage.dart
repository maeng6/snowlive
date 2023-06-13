import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_friendsCommentController.dart';
import 'package:snowlive3/controller/vm_getDateTimeController.dart';
import 'package:snowlive3/controller/vm_loginController.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_timeStampController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/v_MainHome.dart';
import 'package:snowlive3/screens/login/v_loginpage.dart';

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

    LoginController _logInController = Get.put(LoginController());

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