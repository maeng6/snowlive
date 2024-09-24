import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/login/v_email_login.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_login.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

final auth = FirebaseAuth.instance;
final ref = FirebaseFirestore.instance;

class LoginView extends StatelessWidget {
  LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final LoginViewModel _loginViewModel = Get.find<LoginViewModel>();

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
        statusBarBrightness: (Platform.isAndroid) ? Brightness.light : Brightness.dark, // ios:dark, android:light
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: SDSColor.snowliveWhite,
            elevation: 0.0,
            centerTitle: false,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '',
                style: SDSTextStyle.bold.copyWith(color: SDSColor.gray900, fontSize: 18),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: _statusBarSize),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: SDSColor.snowliveWhite,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: _size.height * 0.08,
                    ),
                    Image.asset(
                      'assets/imgs/logos/snowliveLogo_main_new_blue.png',
                      width: 140,
                      scale: 4,
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      '스노우라이브와 함께',
                      style: SDSTextStyle.extraBold.copyWith(
                        fontSize: 28,
                        color: SDSColor.gray900,
                      ),
                    ),
                    Text(
                      '신나는 라이딩을',
                      style: SDSTextStyle.extraBold.copyWith(
                        fontSize: 28,
                        color: SDSColor.gray900,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      '지금 바로 함께 하세요',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 15,
                        color: SDSColor.gray500,
                      ),
                    ),
                  ],
                ),
                Container(
                  child: Image.asset(
                    'assets/imgs/imgs/img_onboarding_1.png',
                    width: _size.width,
                  ),
                ),
                Obx(() => Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              children: [
                                if (_loginViewModel.signInMethod == 'google')
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: SDSColor.snowliveBlack.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      child: Text(
                                        '마지막\n로그인',
                                        style: SDSTextStyle.regular.copyWith(
                                          color: SDSColor.snowliveWhite,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                LoginButton(
                                  buttonText: 'Google로 로그인하기',
                                  logoAddress: 'assets/imgs/logos/logos_google.png',
                                  signInMethod: SignInMethod.google,
                                  buttonColor: Colors.transparent,
                                  borderColor: SDSColor.gray100,
                                  textColor: Colors.transparent,
                                  loginViewModel: _loginViewModel,
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            (Platform.isIOS)
                                ? Column(
                              children: [
                                if (_loginViewModel.signInMethod == 'apple')
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFF111111).withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      child: Text(
                                        '마지막\n로그인',
                                        style: SDSTextStyle.regular.copyWith(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                LoginButton(
                                  buttonText: 'Apple로 로그인하기',
                                  logoAddress: 'assets/imgs/logos/logos_apple.png',
                                  signInMethod: SignInMethod.apple,
                                  buttonColor: Color(0xff111111),
                                  borderColor: Colors.transparent,
                                  textColor: Colors.white,
                                  loginViewModel: _loginViewModel,
                                ),
                              ],
                            )
                                : SizedBox(width: 0,),
                          ],
                        ),
                        if (Platform.isAndroid && _loginViewModel.isAndroidEmailLogIn == true)
                          GestureDetector(
                            onTap: () {
                              Get.to(() => EmailLoginPage());
                            },
                            child: Text(
                              '이메일로 로그인하기',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF949494),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
enum SignInMethod { google, facebook, apple }
class LoginButton extends StatelessWidget {
  final String? buttonText;
  final String? logoAddress;
  final SignInMethod? signInMethod;
  final Color? buttonColor;
  final Color? textColor;
  final Color? borderColor;
  final LoginViewModel loginViewModel;  // 추가된 부분

  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;

  LoginButton({
    this.buttonText,
    this.logoAddress,
    this.signInMethod,
    this.buttonColor,
    this.textColor,
    this.borderColor,
    required this.loginViewModel,  // 추가된 부분
  });

  @override
  Widget build(BuildContext context) {
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
        try {
          if (signInMethod == SignInMethod.google) {
            await loginViewModel.signInWithGoogle();
          } else if (signInMethod == SignInMethod.facebook) {
            if (Platform.isIOS)
            await loginViewModel.signInWithFacebook();
            if (Platform.isAndroid)
            await loginViewModel.signInWithFacebook_android();
          } else {
            await loginViewModel.signInWithApple();
          }
        } catch (e) {
        CustomFullScreenDialog.cancelDialog();

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