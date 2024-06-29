import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:com.snowlive/controller/login/vm_loginController.dart';
import 'package:com.snowlive/screens/onboarding/v_setNickname.dart';
import 'package:com.snowlive/screens/v_webPage.dart';
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

  bool isAllChecked() {
    return multipleSelected.length == checkListItems.length;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness:
        (Platform.isAndroid) ? Brightness.light : Brightness.dark,
      ),
    );

    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
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
                if (FirebaseAuth.instance.currentUser!.providerData[0].providerId ==
                    'password') {
                  Get.offAll(() => LoginPage());
                } else {
                  LoginController().signOut_welcome();
                }
              },
            ),
            backgroundColor: Colors.white,
            elevation: 0.0,
            centerTitle: false,
            titleSpacing: 0,
          ),
        ),
        body: Padding(
          padding:
          EdgeInsets.only(top: _statusBarSize + 58, left: 16, right: 16, bottom: _statusBarSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    '스노우라이브\n서비스 이용 동의',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '스노우라이브의 모든 기능을 편리하게 사용하시기 위해\n아래의 약관동의 및 회원가입을 진행해 주세요.',
                style: TextStyle(color: Color(0xff949494), fontSize: 13, height: 1.5),
              ),
              Expanded(
                child: Container(),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: Column(
                  children: List.generate(
                    checkListItems.length,
                        (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          checkListItems[index]["value"] = !checkListItems[index]["value"];
                          if (checkListItems[index]["value"]) {
                            if (!multipleSelected.contains(checkListItems[index])) {
                              multipleSelected.add(checkListItems[index]);
                            }
                          } else {
                            multipleSelected.remove(checkListItems[index]);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Image.asset(
                              checkListItems[index]["value"]
                                  ? 'assets/imgs/icons/icon_check_filled.png'
                                  : 'assets/imgs/icons/icon_check_unfilled.png',
                              height: 24,
                              width: 24,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                checkListItems[index]["title"],
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                Get.to(() => WebPage(
                                  url: checkListItems[index]["url"],
                                ));
                              },
                              icon: Image.asset(
                                'assets/imgs/icons/icon_arrow_g.png',
                                height: 24,
                                width: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: isAllChecked()
                      ? () async {
                    Get.to(() => SetNickname());
                  }
                      : null,
                  child: Text(
                    '동의하고 계속하기',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: TextButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                    elevation: 0,
                    splashFactory: InkRipple.splashFactory,
                    minimumSize: Size(1000, 56),
                    backgroundColor: isAllChecked() ? Color(0xff377EEA) : Color(0xffDEDEDE),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
