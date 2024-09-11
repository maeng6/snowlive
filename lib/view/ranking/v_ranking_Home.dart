import 'package:com.snowlive/controller/public/vm_limitController.dart';
import 'package:com.snowlive/screens/Ranking/v_Ranking_Crew_Screen.dart';
import 'package:com.snowlive/screens/Ranking/v_Ranking_Indi_Screen.dart';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controller/user/vm_userModelController.dart';
import '../../../data/imgaUrls/Data_url_image.dart';
import '../../../widget/w_floatingButton_ranking.dart';

class RankingHomeView extends StatefulWidget {
  RankingHomeView({Key? key}) : super(key: key);

  @override
  State<RankingHomeView> createState() => _RankingHomeViewState();
}

class _RankingHomeViewState extends State<RankingHomeView> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  limitController _seasonController = Get.find<limitController>();
  //TODO: Dependency Injection**************************************************

  int counter = 0;
  List<bool> isTap = [
    true,
    false,
  ];

  List<bool> isTapPeriod = [
    true,
    false,
    false,
  ];

  bool _isKusbf = false;
  bool _isDaily = true;
  bool _isWeekly = false;

  String _selectedOption = '일간';

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 상태바 투명하게
      statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 밝기
    ));

    Size _size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 12),
                          child: ElevatedButton(
                            child: Text(
                              '개인랭킹',
                              style: SDSTextStyle.extraBold.copyWith(
                                  color: (isTap[0])
                                      ? Color(0xFF111111)
                                      : Color(0xFFDEDEDE),
                                  fontSize: 18),
                            ),
                            onPressed: () async {
                              await _seasonController.getCurrentSeason();
                              print('개인랭킹페이지로 전환');
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
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: ElevatedButton(
                            onPressed: () async {
                              print('크루랭킹페이지로 전환');
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
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: Container(
                              child: Text(
                                '크루랭킹',
                                style: SDSTextStyle.extraBold.copyWith(
                                    color: (isTap[1])
                                        ? Color(0xFF111111)
                                        : Color(0xFFC8C8C8),
                                    fontSize: 18),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                    // (_userModelController.favoriteResort == 12)
                    //     ? Padding(
                    //       padding: const EdgeInsets.only(right: 12),
                    //       child: Row(
                    //         crossAxisAlignment: CrossAxisAlignment.center,
                    //         mainAxisAlignment: MainAxisAlignment.end,
                    //         children: [
                    //           ExtendedImage.network(
                    //             '${KusbfAssetUrlList[0].mainLogo}',
                    //             enableMemoryCache: true,
                    //             shape: BoxShape.rectangle,
                    //             width: 56,
                    //             fit: BoxFit.cover,
                    //             loadStateChanged:
                    //                 (ExtendedImageState state) {
                    //               switch (state.extendedImageLoadState) {
                    //                 case LoadState.loading:
                    //                   return SizedBox.shrink();
                    //                 default:
                    //                   return null;
                    //               }
                    //             },
                    //           ),
                    //           Transform.scale(
                    //             scale: 0.8,
                    //             child: CupertinoSwitch(
                    //               value: _isKusbf,
                    //               onChanged: (value) {
                    //                 setState(() {
                    //                   _isKusbf = value;
                    //                   // 여기에서 토글 상태 변경에 따른 추가 작업을 수행할 수 있습니다.
                    //                 });
                    //               },
                    //               activeColor: Color(0xFF3D83ED),
                    //               trackColor: Color(0xFFD8E7FD),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     )
                    //     : SizedBox.shrink()
                  ],
                ),
              ),
              if (isTap[0] == true)
                Expanded(
                    child: RankingIndiScreen(
                      isKusbf: _isKusbf,
                      isDaily: _isDaily,
                      isWeekly: _isWeekly,
                    )),
              if (isTap[1] == true)
                Expanded(
                  child: RankingCrewScreen(
                    isKusbf: _isKusbf,
                    isDaily: _isDaily,
                    isWeekly: _isWeekly,
                  )),
              // if (isTap[2] == true)
              //   Expanded(child: FleaMarket_Chatroom_List()),
            ],
          ),
        ),
        floatingActionButton: FloatingButtonWithOptions(
          selectedOption: _selectedOption,
          onOptionSelected: (String value) {
            setState(() {
              if (value == '일간') {
                isTapPeriod[0] = true;
                isTapPeriod[1] = false;
                isTapPeriod[2] = false;
                _isDaily = true;
                _isWeekly = false;
              } else if (value == '주간') {
                isTapPeriod[0] = false;
                isTapPeriod[1] = true;
                isTapPeriod[2] = false;
                _isDaily = false;
                _isWeekly = true;
              } else if (value == '누적') {
                isTapPeriod[0] = false;
                isTapPeriod[1] = false;
                isTapPeriod[2] = true;
                _isDaily = false;
                _isWeekly = false;
              }
              _selectedOption = value;
            });
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked);
  }
}


