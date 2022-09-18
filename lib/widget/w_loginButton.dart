import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/onboarding/v_WelcomePage.dart';
import 'package:snowlive3/controller/vm_loginController.dart';
import 'package:snowlive3/screens/v_loginpage.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

enum SignInMethod {
  google,
  facebook,
  apple
}

class LoginButton extends StatelessWidget {

  String? buttonText;
  String? logoAddress;
  var signInMethod;
  Color? buttonColor;
  Color? textColor;

   LoginButton(
      {this.buttonText,
        this.logoAddress,
        this.signInMethod,
      this.buttonColor,
      this.textColor}
      );

  @override
  Widget build(BuildContext context) {

    //TODO: Dependency Injection************************************************
    Get.put(LoginController());
    LoginController _loginController = LoginController();
    //TODO: Dependency Injection************************************************

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.only(top: 15,bottom: 15),
        elevation: 0,
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xffDCDCDC)),
          borderRadius: BorderRadius.all(
            Radius.circular(4.0),
          ),
        ),
      ),
      onPressed: () async{
        CustomFullScreenDialog.showDialog();
        try {
          if (signInMethod == SignInMethod.google) {
            await _loginController.signInWithGoogle();
            await _loginController.createUserDoc(0);
            CustomFullScreenDialog.cancelDialog();
            Get.offAll(WelcomePage());
            print(auth.currentUser);
          } else if (signInMethod == SignInMethod.facebook) {
            await _loginController.signInWithFacebook();
            await _loginController.createUserDoc(0);
            CustomFullScreenDialog.cancelDialog();
            Get.offAll(WelcomePage());
          } else {}
        }catch(e) {
          if (auth.currentUser == null) {
            Get.snackbar('로그인 취소', '다시 시도해주세요.',
                snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.white,
              duration: Duration(milliseconds: 1000)
            );
          } else {
            Get.snackbar('로그인 실패', '다시 시도해주세요.',
              snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.white,
                duration: Duration(milliseconds: 1000)
            );
            print(e);
          }
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset('$logoAddress',
          height: 20,),
          Container(
            alignment: Alignment.center,
            width: 220,
            child: Text('$buttonText',
            style: TextStyle(
              fontSize: 12,
              color: textColor
            ),),
          ),
          Opacity(
            opacity: 0.0,
              child: Image.asset('$logoAddress',
              height: 20,)
          ),
        ],
      ),
    );
  }
}

