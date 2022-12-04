import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/controller/vm_loginController.dart';
import 'package:snowlive3/screens/onboarding/v_setNickname.dart';
import 'package:snowlive3/screens/v_webPage.dart';

import '../login/v_loginpage.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  List multipleSelected = [];
  List checkListItems = [
    {
      "id": 0,
      "value": false,
      "title": "(필수) 스노우라이브 이용약관 동의",
      "url": 'https://sites.google.com/view/snowlive-termsofservice/%ED%99%88',
    },
    {
      "id": 1,
      "value": false,
      "title": "(필수) 개인정보 수집 및 이용동의",
      "url":
          "https://sites.google.com/view/134creativelabprivacypolicy/%ED%99%88"
    },
  ];

  @override
  Widget build(BuildContext context) {

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

    bool? _isCheckedAll = multipleSelected.length.isEqual(2);
    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      }, //안드에서 뒤로가기누르면 앱이 꺼지는걸 막는 기능 Willpopscope
      child: Scaffold(backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(58),
          child: AppBar(
            leading: GestureDetector(
              child: Image.asset(
                'assets/imgs/icons/icon_snowLive_back.png',
                scale: 4,
                width: 26,
                height: 26,
              ),
              onTap: () {
                if(FirebaseAuth.instance.currentUser!.providerData[0].providerId =='password') {
                  Get.offAll(() => LoginPage());
                }else {
                  LoginController().signOut_welcome();
                }
              },
            ),
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
          padding:
               EdgeInsets.only(top: _statusBarSize+58, left: 16, right: 16, bottom: _statusBarSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    '스노우라이브에 오신 것을 \n환영합니다.',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '스노우라이브의 모든 기능을 편리하게 사용하시기 위해\n아래의 약관동의 및 회원가입을 진행해 주세요.',
                style: TextStyle(
                  color: Color(0xff949494),
                  fontSize: 14,
                ),
              ),
              Expanded(
                child: Container()
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: Column(
                  children: List.generate(
                    checkListItems.length,
                    (index) => CheckboxListTile(
                      dense: true,
                      visualDensity: VisualDensity(vertical: 1),
                      title: Transform.translate(
                        offset: Offset(-16,0),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            checkListItems[index]["title"],
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      activeColor: Color(0xff377EEA),
                      selectedTileColor: Color(0xff377EEA),
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: IconButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          Get.to(() => WebPage(
                                url: checkListItems[index]["url"],
                              ));
                        },
                        icon: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset(
                              'assets/imgs/icons/icon_arrow_g.png',
                              height: 24,
                              width: 24,
                            ),
                          ],
                        ),
                      ),
                      value: checkListItems[index]["value"],
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setState(() {
                          checkListItems[index]["value"] = value;
                          if (multipleSelected
                              .contains(checkListItems[index])) {
                            multipleSelected.remove(checkListItems[index]);
                          } else {
                            multipleSelected.add(checkListItems[index]);
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_isCheckedAll) {
                      Get.to(() => SetNickname());
                    } else {
                      null;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '동의하고 계속하기',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                  style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      elevation: 0,
                      splashFactory: InkRipple.splashFactory,
                      minimumSize: Size(1000, 56),
                      backgroundColor: (_isCheckedAll)
                          ? Color(0xff377EEA)
                          : Color(0xffDEDEDE)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
