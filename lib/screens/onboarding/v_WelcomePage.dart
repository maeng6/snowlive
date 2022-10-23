import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/onboarding/v_setNickname.dart';
import 'package:snowlive3/screens/v_webPage.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  List multipleSelected = [];
  List checkListItems = [
    {
      "id": 0,
      "value": false,
      "title": "(필수) 스노우라이브 이용약관 동의",
      "url": 'https://sites.google.com/view/snowlive-termsofservice/%ED%99%88',
    },
    {
      "id": 1,
      "value": false,
      "title": "(필수) 개인정보 수집 및 이용동의",
      "url":
          "https://sites.google.com/view/134creativelabprivacypolicy/%ED%99%88"
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool? _isCheckedAll = multipleSelected.length.isEqual(2);

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
                  '스노우라이브의 모든 기능을 편리하게 사용하시기 위해\n아래의 약관동의 및 회원가입이 필요합니다.\n아래 약관에 동의 부탁드립니다.',
                  style: TextStyle(
                    color: Color(0xff949494),
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: Container()
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Column(
                    children: List.generate(
                      checkListItems.length,
                      (index) => CheckboxListTile(
                        dense: true,
                        visualDensity: VisualDensity(vertical: 1),
                        title: Transform.translate(
                          offset: Offset(-16,0),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              checkListItems[index]["title"],
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                        activeColor: Color(0xff377EEA),
                        selectedTileColor: Color(0xff377EEA),
                        controlAffinity: ListTileControlAffinity.leading,
                        secondary: IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            Get.to(() => WebPage(
                                  url: checkListItems[index]["url"],
                                ));
                          },
                          icon: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image.asset(
                                'assets/imgs/icons/icon_arrow_g.png',
                                height: 24,
                                width: 24,
                              ),
                            ],
                          ),
                        ),
                        value: checkListItems[index]["value"],
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            checkListItems[index]["value"] = value;
                            if (multipleSelected
                                .contains(checkListItems[index])) {
                              multipleSelected.remove(checkListItems[index]);
                            } else {
                              multipleSelected.add(checkListItems[index]);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_isCheckedAll) {
                        Get.to(() => SetNickname());
                      } else {
                        null;
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '동의하고 계속하기',
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
                        backgroundColor: (_isCheckedAll)
                            ? Color(0xff377EEA)
                            : Color(0xffDEDEDE)),
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
