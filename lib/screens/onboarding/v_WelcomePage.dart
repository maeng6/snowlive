import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/onboarding/v_setNickname.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
       appBar: AppBar(
          // leading: Icon(Icons.arrow_back),
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
                    '스노우라이브에 오신걸 \n환영합니다.',
                    style:
                    TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                '간단한 정보를 입력하고, 스노우라이브와 함께\n즐거운 라이딩을 만들어봐요!',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Expanded(child: SizedBox()),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    Get.to(SetNickname());
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
