import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:snowlive3/screens/LiveCrew/CreateOnboarding/v_setCrewName.dart';

import '../v_liveCrewHome.dart';
import '../v_searchCrewPage.dart';

class FirstPage_createCrew extends StatefulWidget {
  const FirstPage_createCrew({Key? key}) : super(key: key);

  @override
  State<FirstPage_createCrew> createState() => _FirstPage_createCrewState();
}

class _FirstPage_createCrewState extends State<FirstPage_createCrew> {


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

    final double _statusBarSize = MediaQuery.of(context).padding.top;
    final Size _size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      }, //안드에서 뒤로가기누르면 앱이 꺼지는걸 막는 기능 Willpopscope
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(58),
              child: AppBar(
                actions: [
                  ElevatedButton(
                    onPressed: (){
                      Get.to(()=>LiveCrewHome());
                    },
                    child: Text('둘러보기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111111)),),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFffffff),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(
                            color: Color(0xFFFFFFFF))
                    ),),
                ],
                leading: GestureDetector(
                  child: Image.asset(
                    'assets/imgs/icons/icon_snowLive_back.png',
                    scale: 4,
                    width: 26,
                    height: 26,
                  ),
                  onTap: () {
                    Get.back();
                  },
                ),
                backgroundColor: Colors.white,
                elevation: 0.0,
                centerTitle: false,
                titleSpacing: 0,
                title: Text('',
                  style: TextStyle(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.w900,
                      fontSize: 23),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                height: _size.height - _statusBarSize - 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: _size.width,
                      child: Lottie.asset('assets/json/SL_LT_crew_1.json',
                      width: _size.width,
                          fit: BoxFit.fill),
                    ),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '함께해서 더 즐거운 라이딩',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Image.asset('assets/imgs/liveCrew/img_liveCrew_title_onboarding.png',
                              scale: 1, width: 150),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            '라이브크루를 통해 다양한 사람들과 교류하며',
                            style: TextStyle(
                              color: Color(0xff949494),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            '더욱 특별한 경험을 만들어보세요.',
                            style: TextStyle(
                              color: Color(0xff949494),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            right: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.to(()=> SearchCrewPage());
                        },
                        child: Text(
                          '가입하기',
                          style: TextStyle(
                              color: Color(0xFF3D83ED),
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        style: TextButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(6))),
                            elevation: 0,
                            splashFactory: InkRipple.splashFactory,
                            minimumSize: Size(100, 56),
                            backgroundColor:
                            Color(0xffD8E7FD)),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.to(()=>SetCrewName());
                        },
                        child: Text(
                          '만들기',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        style: TextButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(6))),
                            elevation: 0,
                            splashFactory: InkRipple.splashFactory,
                            minimumSize: Size(100, 56),
                            backgroundColor:
                            Color(0xff3D83ED)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// EdgeInsets.only(top: _statusBarSize+58, left: 16, right: 16, bottom: _statusBarSize),