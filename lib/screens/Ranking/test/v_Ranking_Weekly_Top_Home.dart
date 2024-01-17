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
            actions: [
              Padding(
                padding: EdgeInsets.only(left: 16, right: 8),
                child: GestureDetector(
                  onTap: () async {
                    print('크루랭킹페이지로 전환');
                    setState(() {
                      isTap[0] = true;
                      isTap[1] = false;
                    });
                    print(isTap);
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '크루랭킹',
                        style: TextStyle(
                          fontFamily: 'Spoqa Han Sans Neo',
                          color: (isTap[0]) ? Color(0xFF111111) : Color(0xFFC8C8C8),
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () async {
                    await _seasonController.getCurrentSeason();
                    print('개인랭킹페이지로 전환');
                    setState(() {
                      isTap[0] = false;
                      isTap[1] = true;
                    });
                    print(isTap);
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '개인랭킹',
                        style: TextStyle(
                          fontFamily: 'Spoqa Han Sans Neo',
                          color: (isTap[1]) ? Color(0xFF111111) : Color(0xFFC8C8C8),
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],

          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '주간랭킹 기록실',
                        style: TextStyle(
                          fontFamily: 'Spoqa Han Sans Neo',
                          color: Color(0xFF111111),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                if(isTap[0] == true)
                  Container(child: RankingCrewWeeklyTopScreen()),
                if(isTap[1] == true)
                  Container(child: RankingIndiWeeklyTopScreen()),
              ],
            ),
          ),
        )

    );
  }
}
