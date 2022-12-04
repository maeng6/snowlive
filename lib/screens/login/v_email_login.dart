
import 'dart:io';

import 'package:avoid_keyboard/avoid_keyboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/screens/login/v_email_singup.dart';
import 'package:snowlive3/screens/login/v_loginpage.dart';
import 'package:snowlive3/screens/onboarding/v_WelcomePage.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({Key? key}) : super(key: key);

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {

  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textEditingController2 = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    final double _statusBarSize = MediaQuery.of(context).padding.top;
    Size _size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      }, //안드에서 뒤로가기누르면 앱이 꺼지는걸 막는 기능 Willpopscope
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
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
          body: SingleChildScrollView(
            child: Padding(
              padding:
              EdgeInsets.only(top: _statusBarSize+58, left: 16, right: 16, bottom: _statusBarSize),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이메일을 이용하여\n로그인을 진행합니다.',
                        style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        '이전에 가입하신 이메일로 로그인 해주세요.\n회원이 아니시라면 회원가입을 진행해주세요.',
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
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              child: Center(
                                child: TextFormField(
                                  obscureText: true,
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
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: _size.height - 504-_statusBarSize*2-58,
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,top: 30),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            CustomFullScreenDialog.showDialog();
                            try{
                             final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                  email: _textEditingController.text, password: _textEditingController2.text);
                             CustomFullScreenDialog.cancelDialog();
                             if(credential.user != null){
                            print(auth.currentUser!.providerData[0].providerId);
                                Get.offAll(()=>WelcomePage());
                              }
                            }catch(e){
                              CustomFullScreenDialog.cancelDialog();
                              Get.snackbar('로그인 실패', '로그인 정보를 확인해 주세요.',
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
                              '로그인하기',
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

                        SizedBox(
                          height: 12,
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {_textEditingController.clear();
                            _textEditingController2.clear();
                            Get.to(()=>EmailSignupPage());
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '새 이메일 주소로 회원가입',
                                style: TextStyle(fontFamily: 'NotoSansKR', color: Color(0xff949494), fontSize: 16, fontWeight: FontWeight.w300),

                              ),
                            ),
                            style: TextButton.styleFrom(
                                elevation: 0,
                                splashFactory: InkRipple.splashFactory,
                                minimumSize: Size(1000, 41),
                                backgroundColor: Colors.white),
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
      ),
    );
  }
}
