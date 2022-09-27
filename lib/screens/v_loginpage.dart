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

    final Size _size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(left: 16,right: 16,bottom: 24),
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
                      height: _size.height * 0.23,
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
                      borderColor: Color(0xffDCDCDC),
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
                      borderColor: Colors.transparent,
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
                      borderColor: Colors.transparent,
                      textColor: Colors.white,
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Text('로그인 방법을 선택해주세요',
                    style: TextStyle(fontSize: 14, color: Color(0xFF949494), fontWeight: FontWeight.normal),)
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
