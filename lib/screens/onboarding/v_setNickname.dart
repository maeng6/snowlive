import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/onboarding/v_setProfileImage.dart';

class SetNickname extends StatefulWidget {
  SetNickname({Key? key}) : super(key: key);

  @override
  State<SetNickname> createState() => _SetNicknameState();
}

class _SetNicknameState extends State<SetNickname> {
  TextEditingController _textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _nickName;

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
      child: Scaffold(
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
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Image.asset(
                  'assets/imgs/icons/icon_onb_indicator2.png',
                  scale: 4,
                  width: 56,
                  height: 8,
                ),
              ),
            ],
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
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '스노우라이브에서 사용할 활동명을 설정해 주세요.\n활동명은 언제든지 변경할 수 있습니다.',
                style: TextStyle(
                  color: Color(0xff949494),
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: 40,
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
                          errorStyle: TextStyle(
                            fontSize: 12,
                          ),
                          hintStyle:
                              TextStyle(color: Color(0xff949494), fontSize: 16),
                          hintText: '활동명 입력',
                          labelText: '활동명',
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
                        if (val!.length <= 20 && val.length >= 1) {
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
              SizedBox(
                height: 6,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 19),
                child: Text(
                  '최대 20자까지 입력 가능합니다.',
                  style: TextStyle(color: Color(0xff949494), fontSize: 12),
                ),
              ),
              Expanded(child: SizedBox()),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,top: 30),
                  child: ElevatedButton(
                    onPressed: () async {
                      await FlutterSecureStorage()
                          .write(key: 'uid', value: auth.currentUser!.uid);
                      setState(() {
                        isLoading = true;
                      });
                      if (_formKey.currentState!.validate()) {
                        _nickName = _textEditingController.text;
                        Get.to(() => SetProfileImage(nickName: _nickName,));
                      } else {

                      }
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
            ],
          ),
        ),
      ),
    );
  }
}
