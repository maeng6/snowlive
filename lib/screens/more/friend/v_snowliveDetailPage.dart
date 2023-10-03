import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controller/vm_liveCrewModelController.dart';
import '../../../controller/vm_urlLauncherController.dart';
import '../../discover/v_discover_Resort_Banner.dart';
import '../../v_webPage.dart';


class SnowliveDetailPage extends StatelessWidget {
  SnowliveDetailPage({Key? key}) : super(key: key);

  //TODO: Dependency Injection**************************************************
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  UrlLauncherController _urlLauncherController = Get.find<UrlLauncherController>();
  //TODO: Dependency Injection**************************************************

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

    return Scaffold(
      backgroundColor: Color(0xFFF1F1F3),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading:
        GestureDetector(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/imgs/icons/icon_snowLive_back.png',
                scale: 4,
                width: 26,
                height: 26,
              ),
            ],
          ),
          onTap: () {
            Get.back();
          },
        ),
        elevation: 0.0,
        titleSpacing: 0,
        centerTitle: true,
        toolbarHeight: 58.0, // 이 부분은 AppBar의 높이를 조절합니다.
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: _size.height * 0.15,
                  ),
                  Container(
                    width: 140,
                    height: 140,
                    child: ExtendedImage.asset(
                      'assets/imgs/profile/img_profile_snowliveOperator.png',
                      enableMemoryCache: true,
                      shape: BoxShape.circle,
                      borderRadius: BorderRadius.circular(8),
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('스노우라이브', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111111)),),
                      Padding(
                        padding: const EdgeInsets.only(left : 2.0, bottom: 4),
                        child: Image.asset(
                          'assets/imgs/icons/icon_snowlive_operator.png',
                          scale: 4,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text('스노우라이브 공식계정입니다.\n카카오톡 오픈채팅을 통해\n실시간 문의가 가능합니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xFF949494)),),
                  SizedBox(
                    height: 60,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){
                          _urlLauncherController.otherShare(contents: 'https://snowlive.kr/');
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              child: ExtendedImage.asset(
                                'assets/imgs/icons/icon_link_snowlive.png',
                                enableMemoryCache: true,
                                shape: BoxShape.circle,
                                borderRadius: BorderRadius.circular(8),
                                width: 58,
                                height: 58,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('홈페이지',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xFF111111)),)
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 28,
                      ),
                      GestureDetector(
                        onTap: (){
                          _urlLauncherController.otherShare(contents: 'https://instagram.com/snowlive.134?igshid=YTQwZjQ0NmI0OA==');
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              child: ExtendedImage.asset(
                                'assets/imgs/icons/icon_link_instagram.png',
                                enableMemoryCache: true,
                                shape: BoxShape.circle,
                                borderRadius: BorderRadius.circular(8),
                                width: 58,
                                height: 58,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('인스타그램',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xFF111111)),)
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 24,
                      ),
                      GestureDetector(
                        onTap: (){
                          _liveCrewModelController.otherShare(contents: 'http://pf.kakao.com/_LxnDdG/chat');
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              child: ExtendedImage.asset(
                                'assets/imgs/icons/icon_link_kakao.png',
                                enableMemoryCache: true,
                                shape: BoxShape.circle,
                                borderRadius: BorderRadius.circular(8),
                                width: 58,
                                height: 58,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('카카오 채널',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xFF111111)),)
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 22),
                child: DiscoverScreen_ResortBanner(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}