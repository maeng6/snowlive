import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

class EmailSignupPage extends StatefulWidget {
  const EmailSignupPage({Key? key}) : super(key: key);

  @override
  State<EmailSignupPage> createState() => _EmailSignupPageState();
}

class _EmailSignupPageState extends State<EmailSignupPage> {

  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textEditingController2 = TextEditingController();
  TextEditingController _textEditingController3 = TextEditingController();


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
        child: Stack(
          children: [
            Scaffold(backgroundColor: Colors.white,
              resizeToAvoidBottomInset: true,
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
                  EdgeInsets.only(top: _statusBarSize+58, left: 16, right: 16, bottom: _statusBarSize + 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Text(
                            '이메일 주소와\n비밀번호를 입력해주세요.',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.3),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        '스노우라이브 로그인에 사용할 이메일 주소와\n비밀번호를 입력해 주세요.',
                        style: TextStyle(
                            color: Color(0xff949494),
                            fontSize: 13,
                            height: 1.5
                        ),
                      ),
                      SizedBox(
                        height: 30,
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
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      errorStyle: TextStyle(
                                        fontSize: 12,
                                      ),
                                      labelStyle: TextStyle(color: Color(0xff949494), fontSize: 15),
                                      hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),hintText: '이메일 주소 입력',
                                      labelText: '이메일',
                                      contentPadding: EdgeInsets.only(
                                          top: 20, bottom: 16, left: 16, right: 16),
                                      fillColor: Color(0xFFEFEFEF),
                                      hoverColor: Colors.transparent,
                                      filled: true,
                                      focusColor: Colors.transparent,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      errorBorder:  OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent),
                                      ),
                                      focusedBorder:  OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent),
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
                                  obscureText: true,
                                  textAlignVertical: TextAlignVertical.center,
                                  cursorColor: Color(0xff377EEA),
                                  cursorHeight: 16,
                                  cursorWidth: 2,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  controller: _textEditingController2,
                                  strutStyle: StrutStyle(leading: 0.3),
                                  decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      errorStyle: TextStyle(
                                        fontSize: 12,
                                      ),
                                      labelStyle: TextStyle(color: Color(0xff949494), fontSize: 15),
                                      hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                                      hintText: '비밀번호 입력 (8자 이상)',
                                      labelText: '비밀번호',
                                      contentPadding: EdgeInsets.only(
                                          top: 20, bottom: 16, left: 16, right: 16),
                                      fillColor: Color(0xFFEFEFEF),
                                      hoverColor: Colors.transparent,
                                      filled: true,
                                      focusColor: Colors.transparent,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      errorBorder:  OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent),
                                      ),
                                      focusedBorder:  OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent),
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
                            SizedBox(
                              height: 20,
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
                                  controller: _textEditingController3,
                                  strutStyle: StrutStyle(leading: 0.3),
                                  decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      errorStyle: TextStyle(
                                        fontSize: 12,
                                      ),
                                      labelStyle: TextStyle(color: Color(0xff949494), fontSize: 15),
                                      hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                                      hintText: '비밀번호를 한 번 더 입력해 주세요',
                                      labelText: '비밀번호 확인',
                                      contentPadding: EdgeInsets.only(
                                          top: 20, bottom: 16, left: 16, right: 16),
                                      fillColor: Color(0xFFEFEFEF),
                                      hoverColor: Colors.transparent,
                                      filled: true,
                                      focusColor: Colors.transparent,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      errorBorder:  OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent),
                                      ),
                                      focusedBorder:  OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent),
                                        borderRadius: BorderRadius.circular(6),
                                      )),
                                  validator: (val) {
                                    if(val != _textEditingController2.text || val!.length < 8){
                                      return '비밀번호가 일치하지 않습니다.';
                                    }
                                    return null;
                                  },
                                ),
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
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: ElevatedButton(
                    onPressed: () async{
                      CustomFullScreenDialog.showDialog();
                      if(_formKey.currentState!.validate()){
                        _formKey.currentState!.save();
                      }
                      try{
                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: _textEditingController.text, password: _textEditingController3.text);
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
                        '가입 완료 후 로그인하러 가기',
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
