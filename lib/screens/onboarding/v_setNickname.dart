import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/onboarding/v_setProfileImage.dart';

class SetNickname extends StatelessWidget {
  const SetNickname({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: Icon(Icons.arrow_back),
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
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
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
              TextFormField(
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 13
                  ),
                  hintText: '닉네임 입력',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)
                    )
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Text('최대 20글자까지 입력 가능합니다.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10
                ),
                ),
              ),
              Expanded(child: SizedBox()),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    Get.to(SetProfileImage());
                  },
                  child: Text(
                    '다음',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                      splashFactory: InkRipple.splashFactory,
                      minimumSize: Size(350, 56),
                      backgroundColor: Color(0xff2C97FB)),
                ),
              ),     SizedBox(
                height: 5,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    Get.to(SetProfileImage());
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
    );
  }
}
