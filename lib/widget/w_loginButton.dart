import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_loadingPage.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/onboarding/v_WelcomePage.dart';
import 'package:snowlive3/controller/vm_loginController.dart';
import 'package:snowlive3/screens/v_MainHome.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

enum SignInMethod { google, facebook, apple }

class LoginButton extends StatelessWidget {
  String? buttonText;
  String? logoAddress;
  var signInMethod;
  Color? buttonColor;
  Color? textColor;
  Color? borderColor;
  var loginVal;

  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;

  LoginButton(
      {this.buttonText,
      this.logoAddress,
      this.signInMethod,
      this.buttonColor,
      this.textColor,
      this.borderColor});

  @override
  Widget build(BuildContext context) {
    //TODO: Dependency Injection************************************************
    Get.put(LoginController());
    LoginController _loginController = Get.find<LoginController>();
    UserModelController _userModelController = Get.find<UserModelController>();
    //TODO: Dependency Injection************************************************

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.only(top: 15, bottom: 15),
        elevation: 0,
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor!),
          borderRadius: BorderRadius.all(
            Radius.circular(6),
          ),
        ),
      ),
      onPressed: () async {
        CustomFullScreenDialog.showDialog();
        try {
          if (signInMethod == SignInMethod.google) {
            await _loginController.signInWithGoogle();
            await FlutterSecureStorage()
                .write(key: 'login', value: 'true');
            try {
              if (_userModelController.exist! == true) {
                print('기존회원 이동');
                await _userModelController.getCurrentUser(auth.currentUser!.uid);
                CustomFullScreenDialog.cancelDialog();
                Get.offAll(() => LoadingPage());
              } else {
                print('신규회원 온보딩코스 진입');
                await _loginController.createUserDoc(0);
                CustomFullScreenDialog.cancelDialog();
                print('Google 로그인');
                Get.offAll(() => WelcomePage());
              }
            }catch(e){
              print('catch 신규회원 온보딩코스 진입');
              await _loginController.createUserDoc(0);
              CustomFullScreenDialog.cancelDialog();
              print('Google 로그인');
              Get.offAll(() => WelcomePage());
            }
          } else if (signInMethod == SignInMethod.facebook) {
            await _loginController.signInWithFacebook();
            await FlutterSecureStorage()
                .write(key: 'login', value: 'true');
            if( _userModelController.exist! == true) {
              print('기존회원 메인홈 이동');
              await _userModelController.getCurrentUser(auth.currentUser!.uid);
              CustomFullScreenDialog.cancelDialog();
              Get.offAll(()=>MainHome());
            }else{
              print('신규회원 온보딩코스 진입');
              await _loginController.createUserDoc(0);
              CustomFullScreenDialog.cancelDialog();
              print('Facebook 로그인');
              Get.offAll(() => WelcomePage());
            }
          } else {
            await _loginController.signInWithApple();
            await FlutterSecureStorage()
                .write(key: 'login', value: 'true');
            if( _userModelController.exist! == true) {
              print('기존회원 메인홈 이동');
              await _userModelController.getCurrentUser(auth.currentUser!.uid);
              CustomFullScreenDialog.cancelDialog();
              Get.offAll(()=>MainHome());
            }else{
              print('신규회원 온보딩코스 진입');
              await _loginController.createUserDoc(0);
              CustomFullScreenDialog.cancelDialog();
              print('Apple 로그인');
              Get.offAll(() => WelcomePage());
            }
          }
        } catch (e) {
          if (auth.currentUser == null) {
            CustomFullScreenDialog.cancelDialog();
            print('curruentUser = null');
            Get.snackbar('로그인 취소', '다시 시도해주세요.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.black87,
                colorText: Colors.white,
                duration: Duration(milliseconds: 2000));
          } else {
            CustomFullScreenDialog.cancelDialog();
            Get.snackbar('로그인 실패', '다시 시도해주세요.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.black87,
                colorText: Colors.white,
                duration: Duration(milliseconds: 2000));
            print(e);
          }
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            '$logoAddress',
            height: 20,
            scale: 1,
          ),
          Container(
            alignment: Alignment.center,
            width: 220,
            child: Text(
              '$buttonText',
              style: TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.normal),
            ),
          ),
          Opacity(
              opacity: 0.0,
              child: Image.asset(
                '$logoAddress',
                height: 20,
              )),
        ],
      ),
    );
  }
}
