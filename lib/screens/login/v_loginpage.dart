import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/screens/login/v_email_login.dart';
import 'package:snowlive3/widget/w_loginButton.dart';

final auth = FirebaseAuth.instance;
final ref = FirebaseFirestore.instance;

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    ); // 상단 StatusBar 생성
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.white, // Color for Android
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness:
            (Platform.isAndroid)
                ?Brightness.light
                :Brightness.dark //ios:dark, android:light
        ));

    return Scaffold(backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          centerTitle: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              '',
              style: GoogleFonts.notoSans(
                  color: Color(0xFF111111),
                  fontWeight: FontWeight.w900,
                  fontSize: 23),
            ),
          ),
        ),
      ),
      body: Padding(
        padding:  EdgeInsets.only(left: 16,right: 16,bottom: 24, top: _statusBarSize),
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
                  (Platform.isIOS)
                  ?LoginButton(
                    buttonText: 'Apple로 로그인하기',
                    logoAddress: 'assets/imgs/logos/logos_apple.png',
                    signInMethod: SignInMethod.apple,
                    buttonColor: Color(0xff111111),
                    borderColor: Colors.transparent,
                    textColor: Colors.white,
                  )
                  :SizedBox(height: 0,),
                  SizedBox(
                    height:
                    (Platform.isIOS)
                    ? 24
                    : 12,
                  ),
                  GestureDetector(
                    onTap: (){
                      Get.to(()=>EmailLoginPage());
                    },
                    child: Text('다른 방법으로 시작하기',
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF949494),
                        fontWeight: FontWeight.normal,
                    decoration: TextDecoration.underline
                    ),),
                  ),
                  SizedBox(
                   height: (Platform.isIOS)
                        ? 24
                        : 0,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}