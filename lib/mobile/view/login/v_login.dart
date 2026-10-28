import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/mobile/routes/routes.dart';
import 'package:com.snowlive/mobile/view/login/v_email_login.dart';
import 'package:com.snowlive/mobile/viewmodel/auth/vm_login.dart';
import 'package:com.snowlive/core/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                                  // 글리프 무게가 아래로 쏠려 있다(무게중심이 bbox
                                  // 중심보다 높이의 8.8% 아래) → 그만큼 올린다.
                                  logoOffsetY: -1.67,
                                  signInMethod: SignInMethod.apple,
                                  buttonColor: Color(0xff111111),
                                  borderColor: Colors.transparent,
                                  textColor: Colors.white,
                                  loginViewModel: _loginViewModel,
                                ),
                              ],
                            )
                                : SizedBox(width: 0,),
                            SizedBox(width: 12),
                            Column(
                              children: [
                                if (_loginViewModel.signInMethod == 'kakao')
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
                                  buttonText: '카카오로 로그인하기',
                                  // PNG는 노란 배경이 꽉 찬 앱아이콘이라 둥근 버튼 위에
                                  // 각진 사각형이 얹혔다 → 배경 없는 심볼 SVG를 쓴다.
                                  logoAddress: 'assets/imgs/logos/kakao_logo.svg',
                                  logoTint: const Color(0xFF3C1E1E),
                                  // 말풍선이 가로로 넓어(16:15) 기본 높이에서는 혼자 커 보인다.
                                  logoHeight: 19.2,
                                  // 몸통은 위, 꼬리만 아래라 무게중심이 위로 쏠려 있다.
                                  logoOffsetY: 1.3,
                                  signInMethod: SignInMethod.kakao,
                                  buttonColor: Color(0xFFFEE500),
                                  borderColor: Colors.transparent,
                                  textColor: Colors.transparent,
                                  loginViewModel: _loginViewModel,
                                ),
                              ],
                            ),
                            SizedBox(width: 12),
                            Column(
                              children: [
                                if (_loginViewModel.signInMethod == 'naver')
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
                                  buttonText: '네이버로 로그인하기',
                                  // 네이버 공식 가이드(NAVER_login_KR 4:82)에서 뽑은 심볼.
                                  // PNG는 120x120 캔버스에 N이 55x69로만 있어 빈 여백까지
                                  // 줄어들어 실제 N이 9.2x11.5로 혼자 작았다.
                                  logoAddress: 'assets/imgs/logos/naver_logo.svg',
                                  logoTint: SDSColor.snowliveWhite,
                                  // 가이드는 버튼 56에 N 20x20(여백 18)인데, 옆 로고들과
                                  // 같이 놓으면 N이 조금 커 보여 19로 줄였다(사용자 확정).
                                  logoHeight: 19,
                                  signInMethod: SignInMethod.naver,
                                  // 가이드 변수 color-primary-background-default.
                                  // 예전 브랜드 그린(#03C75A)보다 어둡다.
                                  buttonColor: Color(0xFF03A94D),
                                  borderColor: Colors.transparent,
                                  textColor: Colors.transparent,
                                  loginViewModel: _loginViewModel,
                                ),
                              ],
                            ),
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
enum SignInMethod { google, facebook, apple, kakao, naver }
class LoginButton extends StatelessWidget {
  final String? buttonText;
  final String? logoAddress;

  /// 로고 높이. 기본 [_logoHeight]이고, 글리프가 유독 넓은 것만 줄인다.
  final double? logoHeight;

  /// 시각 중심 보정(양수 = 아래로). 글리프 무게가 한쪽으로 쏠린 로고만 쓴다.
  final double logoOffsetY;

  /// 단색 글리프(SVG)에 입힐 색.
  final Color? logoTint;

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
    this.logoHeight,
    this.logoOffsetY = 0,
    this.logoTint,
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
        // 웹 로그인·네이버 공식 가이드와 같은 56. 가이드가 "버튼 56에 N 20x20"을
        // 전제하므로 버튼을 맞춰야 여백(18)까지 그대로 따라온다.
        fixedSize: const Size(56, 56),
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
          } else if (signInMethod == SignInMethod.kakao) {
            await loginViewModel.signInWithKakao();
          } else if (signInMethod == SignInMethod.naver) {
            await loginViewModel.signInWithNaver();
          } else {
            await loginViewModel.signInWithApple();
          }
        } catch (e) {
        CustomFullScreenDialog.cancelDialog();

        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [_buildLogo()],
      ),
    );
  }

  /// 로고 기준 높이. 웹 로그인(24)보다 작아서, 웹에서 정한 값은 5/6으로 환산해 쓴다.
  static const double _logoHeight = 20;

  Widget _buildLogo() {
    final h = logoHeight ?? _logoHeight;
    final path = '$logoAddress';
    final logo = path.endsWith('.svg')
        ? SvgPicture.asset(
            path,
            height: h,
            fit: BoxFit.contain,
            colorFilter: logoTint == null
                ? null
                : ColorFilter.mode(logoTint!, BlendMode.srcIn),
          )
        : Image.asset(path, height: h, scale: 1, color: logoTint);
    if (logoOffsetY == 0) return logo;
    return Transform.translate(offset: Offset(0, logoOffsetY), child: logo);
  }
}