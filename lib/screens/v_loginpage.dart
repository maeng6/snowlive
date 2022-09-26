import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snowlive3/widget/w_loginButton.dart';

final auth = FirebaseAuth.instance;
final ref = FirebaseFirestore.instance;

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(left: 20,right: 20,bottom: 44),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 200,
                    ),
                    Image.asset('assets/imgs/logos/snowLiveLogo.png',
                      height:73 ,
                      width: 214,
                    ),
                  ],
                ),
                Column(
                  children: [
                    LoginButton(
                      buttonText: 'Google로 로그인하기',
                      logoAddress: 'assets/imgs/logos/logos_google.png',
                      signInMethod: SignInMethod.google,
                      buttonColor: Color(0xffFFFFFF),
                      textColor: Colors.black,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    LoginButton(
                      buttonText: 'Facebook으로 로그인하기',
                      logoAddress: 'assets/imgs/logos/logos_facebook.png',
                      signInMethod: SignInMethod.facebook,
                      buttonColor: Color(0xff1877F2),
                      textColor: Colors.white,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    LoginButton(
                      buttonText: 'Apple로 로그인하기',
                      logoAddress: 'assets/imgs/logos/logos_apple.png',
                      signInMethod: SignInMethod.apple,
                      buttonColor: Color(0xff111111),
                      textColor: Colors.white,
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
