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
      "title": "(필수) 스노우라이브 이용약관",
      "url": 'https://sites.google.com/view/snowlive-termsofservice/%ED%99%88',
    },
    {
      "id": 1,
      "value": false,
      "title": "(필수) 개인정보 수집 및 이용동의",
      "url": "https://sites.google.com/view/134creativelabprivacypolicy/%ED%99%88"
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
                  '원활한 스노우라이브 사용을 위하여\n아래의 약관동의 및 회원가입이 필요합니다.\n스노우라이브와 함께 즐거운 라이딩을 만들어봐요!',
                  style: TextStyle(
                    color: Color(0xff949494),
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Column(
                  children:
                  List.generate(
                    checkListItems.length, (index) =>
                      CheckboxListTile(
                        title: Text(checkListItems[index]["title"], style: TextStyle(fontSize: 16),),
                        activeColor: Color(0xff377EEA),
                        selectedTileColor: Color(0xff377EEA),
                        controlAffinity: ListTileControlAffinity.leading,
                        secondary: IconButton(
                          onPressed: (){
                            Get.to(()=>WebPage(url: checkListItems[index]["url"],));
                          },
                          icon: Image.asset(
                            'assets/imgs/icons/icon_arrow_g.png',
                            height: 24,
                            width: 24,
                          ),),
                        value: checkListItems[index]["value"],
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                        onChanged: (value) {
                          setState(() {
                            checkListItems[index]["value"] = value;
                            if (multipleSelected.contains(checkListItems[index])) {
                              multipleSelected.remove(checkListItems[index]);
                            } else {
                              multipleSelected.add(checkListItems[index]);
                            }
                          });
                        },
                      ),
                  ),
                ),
                Expanded(child: SizedBox()),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if(_isCheckedAll){
                        Get.to(() => SetNickname());
                      }else{
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
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                        elevation: 0,
                        splashFactory: InkRipple.splashFactory,
                        minimumSize: Size(1000, 56),
                        backgroundColor:
                        (_isCheckedAll)
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


