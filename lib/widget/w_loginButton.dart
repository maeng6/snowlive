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
import 'package:snowlive3/screens/login/v_loginpage.dart';
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
            if(auth.currentUser != null){
            try {
                print('신규회원 온보딩코스 진입');
                CustomFullScreenDialog.cancelDialog();
                print('Google 로그인');
                Get.offAll(() => WelcomePage());
              } catch(e){
            }}
            else{
              CustomFullScreenDialog.cancelDialog();
              Get.back();
            }
          }
          else if (signInMethod == SignInMethod.facebook) {
            await _loginController.signInWithFacebook();
            if(auth.currentUser != null){
            try {
              print('신규회원 온보딩코스 진입');
              CustomFullScreenDialog.cancelDialog();
              print('Google 로그인');
              Get.offAll(() => WelcomePage());
            } catch(e){
            }}
            else{
              CustomFullScreenDialog.cancelDialog();
              Get.back();
            }
          }
          else {
              await _loginController.signInWithApple();
              if(auth.currentUser != null){
              try {
              CustomFullScreenDialog.cancelDialog();
              print('Apple 로그인');
              Get.offAll(() => WelcomePage());
            }catch(e){
            }}
            else {
              CustomFullScreenDialog.cancelDialog();
              Get.back();
            }
          }
        } catch (e) {
          CustomFullScreenDialog.cancelDialog();
          Get.back();
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
