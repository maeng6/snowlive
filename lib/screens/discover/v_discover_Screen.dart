import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/discover/v_discover_Resort_Banner.dart';
import 'package:snowlive3/screens/discover/v_discover_calendar.dart';
import 'package:snowlive3/screens/discover/v_discover_info.dart';
import 'package:snowlive3/screens/discover/v_discover_tip.dart';


class DiscoverScreen extends StatefulWidget {
  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();

}

class _DiscoverScreenState extends State<DiscoverScreen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  //TODO: Dependency Injection**************************************************


  String getResortName(String resortNickname) {
    switch (resortNickname) {
      case '곤지암':
        return '곤지암리조트';
      case '무주':
        return '무주덕유산리조트';
      case '비발디':
        return '비발디파크';
      case '에덴벨리':
        return '에덴벨리리조트';
      case '강촌':
        return '엘리시안강촌';
      case '오크밸리':
        return '오크밸리리조트';
      case '오투':
        return '오투리조트';
      case '용평':
        return '용평리조트';
      case '웰리힐리':
        return '웰리힐리파크';
      case '지산':
        return '지산리조트';
      case '하이원':
        return '하이원리조트';
      case '휘닉스':
        return '휘닉스평창';
      case '알펜시아':
        return '알펜시아리조트';
      default:
        return resortNickname;
    }
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, //status bar color
      statusBarIconBrightness: Brightness.dark, //status bar icons
    ));

    final double _statusBarSize = MediaQuery.of(context).padding.top;


    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: _statusBarSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(left: 16, top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                        text: TextSpan(
                          text: '',
                          style: TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 20,
                              fontWeight: FontWeight.normal
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${_userModelController.displayName}',
                              style: TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 20,
                                fontWeight: FontWeight.bold
                              )
                            ),
                            TextSpan(
                                text: '님,'
                            ),
                          ]
                        )),
                    SizedBox(height: 2,),
                    RichText(
                        text: TextSpan(
                            text: getResortName(_userModelController.resortNickname!),
                            style: TextStyle(
                                color: Color(0xFF111111),
                                fontSize: 20,
                                fontWeight: FontWeight.normal
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: '의 소식을 확인해 보세요!',
                                  style: TextStyle(
                                      color: Color(0xFF111111),
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal
                                  )
                              ),
                            ]
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                  padding: EdgeInsets.only(top: 10),
                  child: DiscoverScreen_ResortBanner()),
              SizedBox(height: 10),
              DiscoverScreen_Calendar(),
              SizedBox(height: 48),
              DiscoverScreen_Tip(),
              SizedBox(height: 48),
              DiscoverScreen_Info(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}