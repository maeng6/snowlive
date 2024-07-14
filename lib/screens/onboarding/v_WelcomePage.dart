import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:com.snowlive/controller/login/vm_loginController.dart';
import 'package:com.snowlive/screens/onboarding/v_setProfile.dart';
import 'package:com.snowlive/screens/v_webPage.dart';
import '../login/v_loginpage.dart';
import '../snowliveDesignStyle.dart';

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
    {
      "id": 2,
      "value": false,
      "title": "(선택) 마케팅 활용 및 광고성 정보 수신 동의",
      "url":
      "https://sites.google.com/view/134creativelabprivacypolicy/%ED%99%88"
    },
    {
      "id": 3,
      "value": false,
      "title": "(선택) 개인정보 제3자 제공 동의",
      "url":
      "https://sites.google.com/view/134creativelabprivacypolicy/%ED%99%88"
    },
  ];

  bool isAllChecked() {
    return checkListItems[0]["value"] && checkListItems[1]["value"];
  }

  bool isEveryItemChecked() {
    return checkListItems.every((item) => item["value"] == true);
  }

  void toggleAllCheckboxes(bool value) {
    setState(() {
      for (var item in checkListItems) {
        item["value"] = value;
      }
    });
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(44),
          child: AppBar(
            leading: GestureDetector(
              child: Image.asset(
                'assets/imgs/icons/icon_snowLive_back.png',
                scale: 4,
                width: 26,
                height: 26,
              ),
              onTap: () {
                if (FirebaseAuth.instance.currentUser!.providerData[0].providerId == 'password') {
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
        body: SafeArea(
          child: Padding(
            padding:
            EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/imgs/icons/icon_onboarding.png',
                      scale: 4, width: 72, height: 72),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      '스노우라이브 이용을 위해 \n기본 정보를 입력해 주세요',
                      style: SDSTextStyle.bold.copyWith(fontSize: 24, color: SDSColor.gray900, height: 1.4),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '스노우라이브의 모든 기능을 편리하게 사용하시기 위해\n아래의 약관동의 후 기본 정보를 입력해 주세요.',
                      style: SDSTextStyle.regular.copyWith(color: SDSColor.gray500, fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        bool newValue = !isEveryItemChecked();
                        toggleAllCheckboxes(newValue);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Image.asset(
                              isEveryItemChecked()
                                  ? 'assets/imgs/icons/icon_check_filled.png'
                                  : 'assets/imgs/icons/icon_check_unfilled.png',
                              height: 24,
                              width: 24,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "전체 동의",
                                style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900,),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Divider(color: SDSColor.gray50, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
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
                                    style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Container(
                                    width: 20,
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      onPressed: () {
                                        Get.to(() => WebPage(
                                          url: checkListItems[index]["url"],
                                        ));
                                      },
                                      icon: Image.asset(
                                        'assets/imgs/icons/icon_arrow_g.png',
                                        height: 20,
                                        width: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: isAllChecked()
                        ? () async {
                      Get.to(() => SetProfile());
                    }
                        : null,
                    child: Text(
                      '다음',
                      style: SDSTextStyle.bold.copyWith(color: SDSColor.snowliveWhite, fontSize: 16),
                    ),
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                      elevation: 0,
                      splashFactory: InkRipple.splashFactory,
                      minimumSize: Size(1000, 48),
                      backgroundColor: isAllChecked() ? SDSColor.snowliveBlue : SDSColor.gray200,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
