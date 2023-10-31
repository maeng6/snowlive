import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:com.snowlive/screens/login/v_email_login.dart';
import 'package:com.snowlive/widget/w_loginButton.dart';

import '../../controller/vm_loginController.dart';

final auth = FirebaseAuth.instance;
final ref = FirebaseFirestore.instance;

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //TODO: Dependency Injection************************************************
  LoginController _loginController = Get.find<LoginController>();
  //TODO: Dependency Injection************************************************

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

    return WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Scaffold(backgroundColor: Color(0xFFF1F1F3),
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Color(0xFFF1F1F3),
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
            color: Color(0xFFF1F1F3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: _size.height * 0.23,
                    ),
                    Image.asset('assets/imgs/logos/snowlive_logo_new.png',
                      height:98 ,
                      width: 236,
                    ),
                    SizedBox(
                      height: 14,
                    ),
                    Text('RIDING WITH SNOWLIVE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFBBBBBB)),)

                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            LoginButton(
                              buttonText: 'Google로 로그인하기',
                              logoAddress: 'assets/imgs/logos/logos_google.png',
                              signInMethod: SignInMethod.google,
                              buttonColor: Color(0xffFFFFFF),
                              borderColor: Colors.transparent,
                              textColor: Colors.black,

                            ),
                            if(_loginController.signInMethod == 'google')
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF111111).withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    child: Text('마지막\n로그인',
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal
                                    ),)),
                              )
                          ],
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Column(
                          children: [
                            LoginButton(
                              buttonText: 'Facebook으로 로그인하기',
                              logoAddress: 'assets/imgs/logos/logos_facebook.png',
                              signInMethod: SignInMethod.facebook,
                              buttonColor: Color(0xff1877F2),
                              borderColor: Colors.transparent,
                              textColor: Colors.white,
                            ),
                            if(_loginController.signInMethod == 'facebook')
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF111111).withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    child: Text('마지막\n로그인',
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 13,
                                          fontWeight: FontWeight.normal
                                      ),)),
                              )
                          ],
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        (Platform.isIOS)
                            ?Column(
                              children: [
                                LoginButton(
                          buttonText: 'Apple로 로그인하기',
                          logoAddress: 'assets/imgs/logos/logos_apple.png',
                          signInMethod: SignInMethod.apple,
                          buttonColor: Color(0xff111111),
                          borderColor: Colors.transparent,
                          textColor: Colors.white,
                        ),
                                if(_loginController.signInMethod == 'apple')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFF111111).withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        child: Text('마지막\n로그인',
                                          style: TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal
                                          ),)),
                                  )
                              ],
                            )
                            :SizedBox(width: 0,),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    // GestureDetector(
                    //   onTap: (){
                    //     Get.to(()=>EmailLoginPage());
                    //   },
                    //   child: Text('이메일로 로그인하기',
                    //     style: TextStyle(
                    //       fontSize: 14,
                    //       color: Color(0xFF949494),
                    //       fontWeight: FontWeight.normal,
                    //     ),),
                    // ),
                    SizedBox(
                      height: (Platform.isIOS)
                          ? 64
                          : 40,
                    )
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