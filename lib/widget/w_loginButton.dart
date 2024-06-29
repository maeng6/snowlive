import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/login/vm_loginController.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';

import '../controller/login/vm_loadingPage.dart';
import '../screens/onboarding/v_FirstPage.dart';

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
    LoginController _loginController = Get.find<LoginController>();
    //TODO: Dependency Injection************************************************

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(58, 58),
        padding: EdgeInsets.only(top: 15, bottom: 15),
        elevation: 0,
        backgroundColor: buttonColor,
        shape: CircleBorder(
          side: BorderSide(color: borderColor!),
        ),
      ),
      onPressed: () async {
        CustomFullScreenDialog.showDialog();
        try {
          if (signInMethod == SignInMethod.google) {
            await _loginController.signInWithGoogle();
          }
          else if (signInMethod == SignInMethod.facebook) {
            await _loginController.signInWithFacebook();
          }
          else {
            await _loginController.signInWithApple();
            if(auth.currentUser != null){
              try {
                User? currentUser = auth.currentUser;
                if (currentUser != null) {
                  await FlutterSecureStorage().write(key: 'signInMethod', value: 'apple');
                  await _loginController.getExistUserDoc(uid: currentUser.uid);
                }
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
          )
        ],
      ),
    );
  }
}