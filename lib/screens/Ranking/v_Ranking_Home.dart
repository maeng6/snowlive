import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/screens/Ranking/v_Ranking_Crew_Screen.dart';
import 'package:com.snowlive/screens/Ranking/v_Ranking_Indi_Screen.dart';
import 'package:com.snowlive/screens/Ranking/v_Ranking_Tutorial_Screen.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:com.snowlive/controller/vm_liveCrewModelController.dart';
import 'package:com.snowlive/screens/Ranking/v_MyRanking_Detail_Screen.dart';
import 'package:com.snowlive/screens/Ranking/test/v_Ranking_Crew_Screen_test.dart';
import 'package:com.snowlive/screens/Ranking/test/v_Ranking_Indi_Screen_test.dart';
import '../../controller/vm_rankingTierModelController.dart';
import '../../controller/vm_userModelController.dart';
import '../../data/imgaUrls/Data_url_image.dart';


class RankingHome extends StatefulWidget {
  RankingHome({Key? key}) : super(key: key);

  @override
  State<RankingHome> createState() => _RankingHomeState();
}

class _RankingHomeState extends State<RankingHome> {

  int counter = 0;
  List<bool> isTap = [
    true,
    false,
  ];

  bool _isKusbf = false;



  @override
  Widget build(BuildContext context) {

    //TODO: Dependency Injection**************************************************
    SeasonController _seasonController = Get.find<SeasonController>();
    UserModelController _userModelController = Get.find<UserModelController>();
    RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
    //TODO: Dependency Injection**************************************************

    Size _size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(58),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            leading: GestureDetector(
              child: Image.asset(
                'assets/imgs/icons/icon_snowLive_back.png',
                scale: 4,
                width: 26,
                height: 26,
              ),
              onTap: () {
                Get.back();
              },
            ),
            centerTitle: false,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '',
                style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.bold,
                    fontSize: 23),
              ),
            ),
            actions: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 14, right: 8),
                    child: GestureDetector(
                      onTap: (){
                        Get.to(()=>RankingTutorialPage());
                      },
                      child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                padding: EdgeInsets.only(top: 6, bottom: 6, left: 10, right: 10), // 텍스트와 테두리 간의 패딩
                                decoration: BoxDecoration(
                                  color: Color(0xFFCBE0FF),
                                  borderRadius: BorderRadius.circular(30.0), // 테두리 모서리 둥글게
                                ),
                                child: Text(
                                  '튜토리얼',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3D83ED)
                                  ),
                                ),
                              ),
                            )
                          ]
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 14, right: 16),
                    child: GestureDetector(
                      onTap: (){
                        Get.to(()=>MyRankingDetailPage());
                      },
                      child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                padding: EdgeInsets.only(top: 6, bottom: 6, left: 8, right: 10), // 텍스트와 테두리 간의 패딩
                                decoration: BoxDecoration(
                                  color: Color(0xFF3D83ED),
                                  borderRadius: BorderRadius.circular(30.0), // 테두리 모서리 둥글게
                                ),
                                child: Row(
                                  children: [
                                    ExtendedImage.asset(
                                      'assets/imgs/icons/icon_crown_circle.png',
                                      enableMemoryCache: true,
                                      shape: BoxShape.circle,
                                      borderRadius: BorderRadius.circular(8),
                                      width: 12,
                                      height: 12,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(width: 3 ,),
                                    Text(
                                      '내 점수',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFFFFF)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ]
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 12),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                height: 44,
                                child: ElevatedButton(
                                  child: Text(
                                    '크루랭킹',
                                    style: TextStyle(
                                        fontFamily: 'Spoqa Han Sans Neo',
                                        color: (isTap[0])
                                            ? Color(0xFF111111)
                                            : Color(0xFFC8C8C8),
                                        fontWeight: (isTap[0])
                                            ? FontWeight.bold
                                            : FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  onPressed: () async{
                                    print('크루랭킹페이지로 전환');
                                    setState(() {
                                      isTap[0] = true;
                                      isTap[1] = false;
                                    });
                                    print(isTap);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(top: 0),
                                    minimumSize: Size(40, 10),
                                    backgroundColor: Color(0xFFFFFFFF),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                height: 44,
                                child: ElevatedButton(
                                  child: Text(
                                    '개인랭킹',
                                    style: TextStyle(
                                        color: (isTap[1])
                                            ? Color(0xFF111111)
                                            : Color(0xFFC8C8C8),
                                        fontWeight: (isTap[1])
                                            ? FontWeight.bold
                                            : FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  onPressed: () async{
                                    await _seasonController.getCurrentSeason();
                                    print('개인랭킹페이지로 전환');
                                    setState(() {
                                      isTap[0] = false;
                                      isTap[1] = true;
                                    });
                                    print(isTap);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(top: 0),
                                    minimumSize: Size(40, 10),
                                    backgroundColor: Color(0xFFFFFFFF),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  (_userModelController.favoriteResort == 12)
                      ? Padding(
                    padding: const EdgeInsets.only(right: 10, bottom: 5),
                    child: Column(
                      children: [
                        Container(
                          height: 44,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ExtendedImage.network(
                                '${KusbfAssetUrlList[0].mainLogo}',
                                enableMemoryCache: true,
                                shape: BoxShape.rectangle,
                                width: 56,
                                fit: BoxFit.cover,
                                loadStateChanged: (ExtendedImageState state) {
                                  switch (state.extendedImageLoadState) {
                                    case LoadState.loading:
                                      return SizedBox.shrink();
                                    default:
                                      return null;
                                  }
                                },
                              ),
                              Transform.scale(
                                scale: 0.8,
                                child: CupertinoSwitch(
                                  value: _isKusbf,
                                  onChanged: (value) {
                                    setState(() {
                                      _isKusbf = value;
                                      // 여기에서 토글 상태 변경에 따른 추가 작업을 수행할 수 있습니다.
                                    });
                                  },
                                  activeColor: Color(0xFF3D83ED),
                                  trackColor: Color(0xFFD8E7FD),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      :SizedBox.shrink()
                ],
              ),
              SizedBox(
                height: 10,
              ),
              if (isTap[0] == true)
                Expanded(child: RankingCrewScreen(isKusbf: _isKusbf,)),
              if (isTap[1] == true)
                Expanded(child: RankingIndiScreen(isKusbf: _isKusbf)),
              // if (isTap[2] == true)
              //   Expanded(child: FleaMarket_Chatroom_List()),
            ],
          ),
        )

    );
  }
}
