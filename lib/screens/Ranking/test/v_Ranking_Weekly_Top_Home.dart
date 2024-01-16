import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/screens/Ranking/test/v_Ranking_crew_Weekly_Top_Screen.dart';
import 'package:com.snowlive/screens/Ranking/test/v_Ranking_indi_Weekly_Top_Screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../controller/vm_rankingTierModelController.dart';
import '../../../controller/vm_userModelController.dart';



class RankingWeeklyTopHome extends StatefulWidget {
  const RankingWeeklyTopHome({Key? key}) : super(key: key);

  @override
  State<RankingWeeklyTopHome> createState() => _RankingWeeklyTopHomeState();
}

class _RankingWeeklyTopHomeState extends State<RankingWeeklyTopHome> {

  int counter = 0;

  List<bool> isTap = [
    true,
    false,
  ];


  //TODO: Dependency Injection**************************************************
  SeasonController _seasonController = Get.find<SeasonController>();
  //TODO: Dependency Injection**************************************************


  @override
  Widget build(BuildContext context) {

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
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Column(
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
                ],
              ),
              SizedBox(
                height: 6,
              ),
              Container(
                width: _size.width,
                height: 1,
                color: Color(0xFFececec),
              ),
              if(isTap[0] == true)
                Expanded(child: RankingCrewWeeklyTopScreen()),
              if(isTap[1] == true)
                Expanded(child: RankingIndiWeeklyTopScreen()),
            ],
          ),
        )

    );
  }
}
