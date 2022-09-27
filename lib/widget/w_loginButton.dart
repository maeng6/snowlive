import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/onboarding/v_WelcomePage.dart';
import 'package:snowlive3/controller/vm_loginController.dart';
import 'package:snowlive3/screens/v_loginpage.dart';
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
            await _loginController.createUserDoc(0);
            (auth.currentUser != null)
                ? await FlutterSecureStorage()
                    .write(key: 'login', value: auth.currentUser!.displayName)
                : CustomFullScreenDialog.cancelDialog();
            CustomFullScreenDialog.cancelDialog();
            loginVal = await FlutterSecureStorage().read(key: 'login');
            //TODO : 기존에 이용하고 있던 유저는 바로 메인홈으로 가도록 구현 필요
            print('로그인 상태 저장 완료, login : $loginVal');
            Get.offAll(() => WelcomePage());
          } else if (signInMethod == SignInMethod.facebook) {
            await _loginController.signInWithGoogle();
            await _loginController.createUserDoc(0);
            (auth.currentUser != null)
                ? await FlutterSecureStorage()
                    .write(key: 'login', value: auth.currentUser!.displayName)
                : CustomFullScreenDialog.cancelDialog();
            CustomFullScreenDialog.cancelDialog();
            loginVal = await FlutterSecureStorage().read(key: 'login');
            //TODO : 기존에 이용하고 있던 유저는 바로 메인홈으로 가도록 구현 필요
            print('로그인 상태 저장 완료, login : $loginVal');
            Get.offAll(() => WelcomePage());
          } else {}
        } catch (e) {
          if (auth.currentUser == null) {
            Get.snackbar('로그인 취소', '다시 시도해주세요.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.black87,
                colorText: Colors.white,
                duration: Duration(milliseconds: 2000));
          } else {
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
