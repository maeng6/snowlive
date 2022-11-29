import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_getDateTimeController.dart';
import 'package:snowlive3/controller/vm_loginController.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
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
  Widget build(BuildContext context) {
    //TODO: Dependency Injection************************************************
    Get.put(ResortModelController(), permanent: true);
    ResortModelController _resortModelController = ResortModelController();
    Get.put(UserModelController(), permanent: true);
    UserModelController _userModelController = UserModelController();
    Get.put(GetDateTimeController(), permanent: true);
    LoginController _logInController = LoginController();
    //TODO: Dependency Injection************************************************

    return FutureBuilder(
      future: _logInController.loginAgain(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        print('uid : ${_logInController.loginUid}');
        if (snapshot.connectionState == ConnectionState.done &&
             _logInController.loginUid!=null) {
          return FutureBuilder(
              future: _userModelController.getCurrentUser(_logInController.loginUid),
              builder: (context, AsyncSnapshot<dynamic> snapshot){
                  return FutureBuilder(
                      future: _resortModelController.getSelectedResort(_userModelController.favoriteResort),
                      builder: (context, AsyncSnapshot<dynamic> snapshot){
                          return MainHome();
                      }
                  );
              }
          );
        }  else if (snapshot.connectionState == ConnectionState.done &&
             _logInController.loginUid==null) {
          return LoginPage();
        } return LoginPage();
      },
    );
  }
}