import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:com.snowlive/controller/user/vm_userModelController.dart';
import 'package:com.snowlive/screens/onboarding/v_setProfileImage.dart';

class SetNickname extends StatefulWidget {
  SetNickname({Key? key}) : super(key: key);

  @override
  State<SetNickname> createState() => _SetNicknameState();
}

class _SetNicknameState extends State<SetNickname> {
  TextEditingController _textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _nickName;
  bool? isCheckedDispName;

  bool isLoading = false;

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  //TODO: Dependency Injection********************************************
  UserModelController userModelController = Get.find<UserModelController>();

  //TODO: Dependency Injection********************************************

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    ); // 상단 StatusBar 생성
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: (Platform.isAndroid)
            ? Brightness.light
            : Brightness.dark //ios:dark, android:light
        ));
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
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
              ),
            ),
            body: Padding(
              padding: EdgeInsets.only(
                  top: _statusBarSize + 58,
                  left: 16,
                  right: 16,
                  bottom: _statusBarSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Text(
                        '스노우라이브\n활동명을 정해주세요.',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.3),),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    '스노우라이브에서 사용할 활동명을 설정해 주세요.\n최대 8자까지 입력할 수 있습니다.',
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
                    child: Container(
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
                              hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                              hintText: '활동명 입력',
                              labelText: '활동명',
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
                            if (val!.length <= 8 && val.length >= 1) {
                              return null;
                            } else if (val.length == 0) {
                              return '활동명을 입력해주세요.';
                            } else {
                              return '최대 입력 가능한 글자 수를 초과했습니다.';
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                ],
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
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    if (_formKey.currentState!.validate()) {
                      _nickName = _textEditingController.text;
                      isCheckedDispName =  await userModelController.checkDuplicateDisplayName(_nickName);
                      if (isCheckedDispName == true) {
                        Get.to(() => SetProfileImage(nickName: _nickName,));
                      }
                      else{
                        Get.dialog(AlertDialog(
                          contentPadding: EdgeInsets.only(
                              bottom: 0,
                              left: 20,
                              right: 20,
                              top: 30),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                  10.0)),
                          buttonPadding:
                          EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 0),
                          content: Text(
                            '이미 존재하는 활동명입니다.\n다른 활동명을 입력해주세요.',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                          ),
                          actions: [
                            Row(
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      '확인',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xff377EEA),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                            )
                          ],
                        ));
                      }
                    } else {}
                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: (isLoading)
                      ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '다음',
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
    );
  }
}
