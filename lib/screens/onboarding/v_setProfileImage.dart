import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/onboarding/v_favoriteResort.dart';

class SetProfileImage extends StatelessWidget {
  const SetProfileImage({Key? key}) : super(key: key);

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
                    '프로필 이미지를\n업로드해 주세요.',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                '프로필 이미지를 나중에 업로드하길 원하시면,\n건너뛰기 버튼을 눌러주세요',
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
                  },
                  child: Text(
                    '확인',
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
