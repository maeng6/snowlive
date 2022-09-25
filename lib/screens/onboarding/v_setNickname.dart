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
              child: Icon(Icons.arrow_back),
              onTap: () => Get.back(result: () => WelcomePage()),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      '스노우라이브\n닉네임을 정해주세요.',
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  '스노우라이브에서 사용할 닉네임을 정해주시고,\n건너뛰기를 하셔도 언제든지 변경하실 수 있습니다.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _textEditingController,
                    decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        hintText: '닉네임 입력',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey))),
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
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Text(
                    '최대 20글자까지 입력 가능합니다.',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
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
                        Get.snackbar('닉네임 저장 실패', '올바른 닉네임을 입력해주세요.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.white,
                            duration: Duration(milliseconds: 1000));
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
                            style: TextStyle(color: Colors.white),
                          ),
                    style: TextButton.styleFrom(
                        splashFactory: InkRipple.splashFactory,
                        minimumSize: Size(350, 56),
                        backgroundColor: Color(0xff2C97FB)),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.to(() => SetProfileImage());
                    },
                    child: Text(
                      '건너뛰기',
                      style: TextStyle(color: Colors.grey),
                    ),
                    style: TextButton.styleFrom(
                        splashFactory: InkRipple.splashFactory,
                        minimumSize: Size(350, 56),
                        backgroundColor: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
