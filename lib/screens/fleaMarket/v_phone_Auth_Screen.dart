import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_Upload.dart';
import 'package:snowlive3/screens/onboarding/v_setProfileImage.dart';
import 'package:snowlive3/screens/v_MainHome.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
import 'package:snowlive3/widget/w_phoneNumber.dart';

class PhoneAuthScreen extends StatefulWidget {
  PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textEditingController2 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _nickName;

  bool isLoading = false;
  bool requestedAuth = false;
  bool authOk = false;
  bool buttonColorActive = true;
  bool buttonColorActive2 = true;
  var _phoneNumber;
  var _veriNumber;



  String? verificationId;

  FirebaseAuth _auth = FirebaseAuth.instance;


  void signInWithPhoneAuthCredential(PhoneAuthCredential phoneAuthCredential) async {
    final credential = phoneAuthCredential;

    try {
      final userCredential = await FirebaseAuth.instance.currentUser
          ?.linkWithCredential(credential);

      await FirebaseFirestore.instance.collection('user')
          .doc(_userModelController.uid).update({'phoneAuth': true});

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          print("The provider has already been linked to the user.");
          FirebaseFirestore.instance.collection('user')
              .doc(_userModelController.uid).update({'phoneAuth': true});
          break;
        case "invalid-credential":
          print("The provider's credential is not valid.");
          setState(() {
            buttonColorActive2=true;
          });
          Get.snackbar('인증번호 오류','유효한 인증번호를 입력해 주세요.',
              margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.black87,
              colorText: Colors.white,
              duration: Duration(milliseconds: 3000));
          break;
        case "credential-already-in-use":
          print("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          break;
      // See the API reference for the full list of error codes.
        default:
          print("Unknown error.");
          setState(() {
            buttonColorActive2=true;
          });
          Get.snackbar('인증번호 오류','유효한 인증번호를 입력해 주세요.',
              margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.black87,
              colorText: Colors.white,
              duration: Duration(milliseconds: 3000));
      }
    }
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  //TODO: Dependency Injection********************************************
  UserModelController _userModelController = Get.find<UserModelController>();
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
              Text(
                '스노우마켓 이용을 위해\n본인인증을 진행해 주세요.',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '본인인증은 최초 1회만 진행됩니다.',
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
                    child: Column(
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, //숫자만!
                            NumberFormatter(), // 자동하이픈
                            LengthLimitingTextInputFormatter(13)
                          ],
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: Color(0xff377EEA),
                          cursorHeight: 16,
                          cursorWidth: 2,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _textEditingController,
                          strutStyle: StrutStyle(leading: 0.3),
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              splashColor: Colors.transparent,
                              onPressed: () async{
                                if(_textEditingController.text.trim().isEmpty
                                || !_formKey.currentState!.validate() || buttonColorActive == false)
                                {return ;}
                                CustomFullScreenDialog.showDialog();
                                FocusScope.of(context).unfocus();
                                buttonColorActive = false;
                                try{
                                  await _auth.verifyPhoneNumber(
                                    timeout: const Duration(seconds: 60),
                                    codeAutoRetrievalTimeout: (String verificationId) {
                                      // Auto-resolution timed out...
                                    },
                                    phoneNumber: "+82"+_phoneNumber.trim(),
                                    verificationCompleted: (phoneAuthCredential) async {
                                      print("otp 문자옴");
                                    },
                                    verificationFailed: (verificationFailed) async {
                                      print(verificationFailed.code);

                                      print("코드발송실패");

                                    },
                                    codeSent: (verificationId, resendingToken) async {
                                      print("코드보냄");

                                      setState(() {
                                        requestedAuth=true;
                                        this.verificationId = verificationId;
                                      });
                                    },
                                  );
                                }catch(e){print('에러');}
                                CustomFullScreenDialog.cancelDialog();
                              },
                              icon: (_textEditingController.text.length < 13
                              || !_formKey.currentState!.validate() || buttonColorActive == false)
                                  ? Image.asset(
                                'assets/imgs/icons/icon_livetalk_send_g.png',
                                width: 27,
                                height: 27,
                              )
                                  : Image.asset(
                                'assets/imgs/icons/icon_livetalk_send.png',
                                width: 27,
                                height: 27,
                              ),
                            ),
                              errorStyle: TextStyle(
                                fontSize: 12,
                              ),
                              hintStyle:
                              TextStyle(color: Color(0xff949494), fontSize: 16),
                              hintText: '010-0000-0000',
                              labelText: '전화번호 입력',
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
                            if (val!.length == 13 && RegExp(r'^010?-([0-9]{4})?-([0-9]{4})$').hasMatch(val)) {
                              return null;
                            } else {
                              return '올바른 전화번호를 입력해 주세요.';
                            }
                          },
                          onChanged: (value){
                            setState(() {
                              _phoneNumber = value;
                            });
                          },
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        if(requestedAuth == true)
                        TextFormField(
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, //숫자만!
                            LengthLimitingTextInputFormatter(6)
                          ],
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
                              hintText: '123456',
                              labelText: '인증번호 입력',
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
                          validator: (val2) {
                            if (val2!.length == 6) {
                              return null;
                            } else {
                              return '올바른 인증번호를 입력해주세요.';
                            }
                          },
                          onChanged: (value2){
                            setState(() {
                              _veriNumber = value2;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 6,
              ),
              Expanded(child: SizedBox()),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,top: 30),
                  child: ElevatedButton(
                    onPressed: () async{
                      if(_textEditingController2.text.trim().isEmpty
                      || buttonColorActive2 == false)
                      {return ;}
                      CustomFullScreenDialog.showDialog();
                      FocusScope.of(context).unfocus();
                      buttonColorActive2 = false;
                      try{
                        if(_textEditingController2.text.length <6){
                          return ;
                        }else{
                          PhoneAuthCredential phoneAuthCredential =
                          PhoneAuthProvider.credential(
                              verificationId: verificationId!, smsCode: _textEditingController2.text);

                          signInWithPhoneAuthCredential(phoneAuthCredential);
                        }
                      }catch(e){print('에러');}
                      CustomFullScreenDialog.cancelDialog();
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '완료',
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
                        backgroundColor:
                        (_textEditingController2.text.length != 6
                        || buttonColorActive2 == false)
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
