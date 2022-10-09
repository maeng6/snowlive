import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/onboarding/v_WelcomePage.dart';
import 'package:snowlive3/screens/onboarding/v_setProfileImage.dart';

class SetNickname extends StatefulWidget {
  SetNickname({Key? key}) : super(key: key);

  @override
  State<SetNickname> createState() => _SetNicknameState();
}

class _SetNicknameState extends State<SetNickname> {
  TextEditingController _textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false, //키보드가 올라와도 밑에부터 화면을 밀어올리지 않기
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: GestureDetector(
              child: Image.asset('assets/imgs/icons/icon_snowLive_back.png', scale: 4, width: 26,
                height: 26,),
              onTap: () => Get.back(result: () => WelcomePage()),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      '스노우라이브\n닉네임을 정해주세요.',
                      style:
                      TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '스노우라이브에서 사용할 닉네임을 정해주시고,\n건너뛰기를 하셔도 언제든지 변경하실 수 있습니다.',
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
                  child: TextFormField(
                    cursorColor: Color(0xff377EEA),
                    cursorHeight: 16,
                    cursorWidth: 2,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _textEditingController,
                    strutStyle: StrutStyle(
                      leading: 0.3
                    ),
                    decoration: InputDecoration(

                      errorStyle: TextStyle(
                        fontSize: 12,
                      ),
                        hintStyle: TextStyle(color: Color(0xff949494), fontSize: 16),
                        hintText: '활동명 입력',
                        labelText: '활동명',
                        contentPadding: EdgeInsets.only(top: 22, bottom: 20, left: 20, right: 20),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFDCDCDC)),
                        borderRadius: BorderRadius.circular(6),
                        ),

                    ),
                    validator: (val) {
                      if (val!.length <= 20 && val.length >= 1) {
                        return null;
                      } else if (val.length == 0) {
                        return '닉네임을 입력해주세요.';
                      } else {
                        return '최대 글자 수를 초과했습니다.';
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 19),
                  child: Text(
                    '최대 20글자까지 입력 가능합니다.',
                    style: TextStyle(color: Color(0xff949494), fontSize: 12),
                  ),
                ),
                Expanded(child: SizedBox()),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      if (_formKey.currentState!.validate()) {
                        await userModelController
                            .updateNickname(_textEditingController.text);
                        Get.to(() => SetProfileImage());
                      } else {
                        Get.snackbar('닉네임을 입력해주세요', '나중에 정하시려면 건너뛰기를 눌러주세요',
                            snackPosition: SnackPosition.BOTTOM,
                            margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            duration: Duration(milliseconds: 3000));
                      }
                      setState(() {
                        isLoading = false;
                      });
                    },
                    child: (isLoading)
                        ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : Text(
                            '다음',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    style: TextButton.styleFrom(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                        elevation: 0,
                        splashFactory: InkRipple.splashFactory,
                        minimumSize: Size(1000, 56),
                        backgroundColor: _formKey.isBlank == null ? Color(0xffDEDEDE) : Color(0xff377EEA)),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.to(() => SetProfileImage());
                    },
                    child: Text(
                      '건너뛰기',
                      style: TextStyle(color: Color(0xff949494), fontSize: 16, fontWeight: FontWeight.normal),
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
        ),
      ),
    );
  }
}
