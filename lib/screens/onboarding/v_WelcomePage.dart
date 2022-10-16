import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/onboarding/v_setNickname.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          return Future(() => false);
        }, //안드에서 뒤로가기누르면 앱이 꺼지는걸 막는 기능 Willpopscope
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              // leading: Icon(Icons.arrow_back),
              ),
          body: Padding(
            padding:
                const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      '스노우라이브에 오신걸 \n환영합니다.',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '간단한 정보를 입력하고, 스노우라이브와 함께\n즐거운 라이딩을 만들어봐요!',
                  style: TextStyle(
                    color: Color(0xff949494),
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Expanded(child: SizedBox()),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.to(() => SetNickname());
                    },
                    child: Padding(
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
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                        elevation: 0,
                        splashFactory: InkRipple.splashFactory,
                        minimumSize: Size(1000, 56),
                        backgroundColor: Color(0xff377EEA)),
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
