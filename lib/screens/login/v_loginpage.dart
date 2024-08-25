import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/alarm/vm_noticeController.dart';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:com.snowlive/view/v_login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/screens/login/v_email_login.dart';


import '../../controller/login/vm_loginController.dart';

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

    //TODO: Dependency Injection************************************************
    Get.put(NoticeController(), permanent: true);
    NoticeController _noticeController = Get.find<NoticeController>();
    //TODO: Dependency Injection************************************************

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
      child: Scaffold(backgroundColor: Color(0xFFFFFFFF),
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
              child: Text('',
                style: SDSTextStyle.bold.copyWith(
                    color: SDSColor.gray900,
                    fontSize: 18),
              ),
            ),
          ),
        ),
        body: Padding(
          padding:  EdgeInsets.only(left: 16,right: 16, top: _statusBarSize),
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
                      height: _size.height * 0.1,
                    ),
                    Image.asset('assets/imgs/logos/snowliveLogo_main_new_blue.png',
                      height:24 ,
                      width: 140,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text('스노우라이브와 함께', style: SDSTextStyle.extraBold.copyWith(fontSize: 30, color: SDSColor.gray900,),),
                    SizedBox(
                      height: 4,
                    ),
                    Text('신나는 라이딩을', style: SDSTextStyle.extraBold.copyWith(fontSize: 30, color: SDSColor.gray900,),),
                    SizedBox(
                      height: 8,
                    ),
                    Text('지금 바로 함께 하세요', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500,),),

                  ],
                ),
                Container(
                  height: 240,
                  color: Colors.red.withOpacity(0.2),
                ),
                Obx(()=>Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            children: [
                              if(_loginController.signInMethod == 'google')
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: SDSColor.snowliveBlack.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      child: Text('마지막\n로그인',
                                        style: SDSTextStyle.regular.copyWith(
                                            color: SDSColor.snowliveWhite,
                                            fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      )),

                                ),


                            ],
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Column(
                            children: [
                              if(_loginController.signInMethod == 'facebook')
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFF111111).withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      child: Text('마지막\n로그인',
                                        style: SDSTextStyle.regular.copyWith(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      )),
                                ),


                            ],
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          (Platform.isIOS)
                              ? Column(
                            children: [
                              if(_loginController.signInMethod == 'apple')
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFF111111).withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      child: Text('마지막\n로그인',
                                        style: SDSTextStyle.regular.copyWith(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      )),
                                ),


                            ],
                          )
                              : SizedBox(width: 0,),
                        ],
                      ),
                      if(Platform.isAndroid && _noticeController.isAndroidEmailLogIn == true)
                        GestureDetector(
                          onTap: (){
                            Get.to(()=>EmailLoginPage());
                          },
                          child: Text('이메일로 로그인하기',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF949494),
                              fontWeight: FontWeight.normal,
                            ),),
                        ),
                    ],
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