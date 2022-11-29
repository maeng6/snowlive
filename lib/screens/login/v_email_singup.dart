import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/screens/login/v_loginpage.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

class EmailSignupPage extends StatefulWidget {
  const EmailSignupPage({Key? key}) : super(key: key);

  @override
  State<EmailSignupPage> createState() => _EmailSignupPageState();
}

class _EmailSignupPageState extends State<EmailSignupPage> {

  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textEditingController2 = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      }, //안드에서 뒤로가기누르면 앱이 꺼지는걸 막는 기능 Willpopscope
      child: Scaffold(backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
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
                Navigator.pop(context);
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
                    '이메일 주소와\n비밀번호를 입력해주세요.',
                    style:
                    TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '스노우라이브 로그인에 사용할 이메일 주소와\n비밀번호를 입력해 주세요.',
                style: TextStyle(
                  color: Color(0xff949494),
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      child: Center(
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: Color(0xff377EEA),
                          cursorHeight: 16,
                          cursorWidth: 2,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _textEditingController,
                          strutStyle: StrutStyle(leading: 0.3),
                          decoration: InputDecoration(
                              errorStyle: TextStyle(
                                fontSize: 12,
                              ),
                              hintStyle:
                              TextStyle(color: Color(0xff949494), fontSize: 16),
                              hintText: '이메일 주소 입력',
                              labelText: '이메일',
                              contentPadding: EdgeInsets.only(
                                  top: 20, bottom: 20, left: 20, right: 20),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFDEDEDE)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFDEDEDE)),
                                borderRadius: BorderRadius.circular(6),
                              )),
                          validator: (val) {
                            if(!val!.contains('@')){
                              return '올바른 이메일 주소 형식을 입력해 주세요';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Center(
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: Color(0xff377EEA),
                          cursorHeight: 16,
                          cursorWidth: 2,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _textEditingController2,
                          strutStyle: StrutStyle(leading: 0.3),
                          decoration: InputDecoration(
                              errorStyle: TextStyle(
                                fontSize: 12,
                              ),
                              hintStyle:
                              TextStyle(color: Color(0xff949494), fontSize: 16),
                              hintText: '비밀번호 입력',
                              labelText: '비밀번호',
                              contentPadding: EdgeInsets.only(
                                  top: 20, bottom: 20, left: 20, right: 20),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFDEDEDE)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFDEDEDE)),
                                borderRadius: BorderRadius.circular(6),
                              )),
                          validator: (val) {
                            if(val!.length < 8){
                              return '최소 8자 이상 입력해 주세요';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: SizedBox()),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,top: 30),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async{
                        CustomFullScreenDialog.showDialog();
                        if(_formKey.currentState!.validate()){
                          _formKey.currentState!.save();
                        }
                        try{
                          await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: _textEditingController.text, password: _textEditingController2.text);
                          CustomFullScreenDialog.cancelDialog();
                          Navigator.pop(context);
                        }catch(e){
                          CustomFullScreenDialog.cancelDialog();
                          Get.snackbar('회원가입 실패', '이메일/비밀번호 정보를 확인해 주세요.',
                              margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.black87,
                              colorText: Colors.white,
                              duration: Duration(milliseconds: 3000));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '가입 완료 후 로그인 페이지로 이동',
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
                          backgroundColor: _formKey.isBlank == null
                              ? Color(0xffDEDEDE)
                              : Color(0xff377EEA)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: (Platform.isIOS)
                    ? 24
                    : 0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
