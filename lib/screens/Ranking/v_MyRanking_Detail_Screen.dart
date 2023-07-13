import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/model/m_slopeScoreModel.dart';

import '../more/friend/v_friendDetailPage.dart';

class MyRankingDetailPage extends StatefulWidget {
  const MyRankingDetailPage({Key? key}) : super(key: key);

  @override
  State<MyRankingDetailPage> createState() => _MyRankingDetailPageState();
}

class _MyRankingDetailPageState extends State<MyRankingDetailPage> {
  // TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  // TODO: Dependency Injection**************************************************

  Future<Map<String, int>> _calculateRank(int myScore) async {
    int totalUsers = 0;
    int myRank = 0; // 기본값을 0으로 설정

    QuerySnapshot userCollection = await FirebaseFirestore.instance
        .collection('user')
        .where('favoriteResort', isEqualTo: _userModelController.favoriteResort)
        .get();

    totalUsers = userCollection.docs.length;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('${_userModelController.favoriteResort}')
        .orderBy('totalScore', descending: true)
        .get();

    List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    for (int i = 0; i < documents.length; i++) {
      if (documents[i].id == _userModelController.uid) {
        myRank = i + 1; // 등수는 1부터 시작하기 때문에 1을 더해줍니다.
        break;
      }
    }

    if (myRank == 0) {
      // 등수가 0이면 데이터가 없는 것으로 처리
      return {'totalUsers': totalUsers, 'rank': 0};
    }

    return {'totalUsers': totalUsers, 'rank': myRank};
  }


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Color(0xFF3D83ED),
          appBar: AppBar(
            backgroundColor: Color(0xFF3D83ED),
            leading: GestureDetector(
              child: Image.asset(
                'assets/imgs/icons/icon_snowLive_back.png',
                scale: 4,
                width: 26,
                height: 26,
                color: Color(0xFFFFFFFF),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            elevation: 0.0,
          ),
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Ranking')
                .doc('${_seasonController.currentSeason}')
                .collection('${_userModelController.favoriteResort}')
                .doc("${_userModelController.uid}")
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text("오류가 발생했습니다");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Lottie.asset('assets/json/loadings_wht_final.json');
              }


              Map<String, dynamic>? data =
              snapshot.data!.data() as Map<String, dynamic>?;

              Map<String, dynamic>? passCountData =
              data?['passCountData'] as Map<String, dynamic>?;

              int totalScore = 0;

              if (passCountData != null && passCountData.isNotEmpty) {
                for (var slope in passCountData.keys) {
                  totalScore +=
                      (passCountData[slope] as int? ?? 0) *
                          (slopeScoresModel.slopeScores[slope] ?? 0);
                }
              }

              String maxPassCountSlope = "";

              if (passCountData != null && passCountData.isNotEmpty) {
                maxPassCountSlope = passCountData.entries.reduce((maxEntry, entry) {
                  return maxEntry.value > entry.value ? maxEntry : entry;
                }).key;
              }

              return Column(
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ExtendedImage.asset(
                          'assets/imgs/icons/image_background_myscore.png',
                          enableMemoryCache: true,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 40,
                        child: FutureBuilder<Map<String, int>>(
                          future: _calculateRank(totalScore),
                          builder: (BuildContext context,
                              AsyncSnapshot<Map<String, int>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('랭킹: 집계 중...');
                            } else if (snapshot.hasError) {
                              return Text('랭킹: 오류 발생');
                            } else {
                              return Container(
                                padding: EdgeInsets.only(
                                    top: 3, bottom: 3, left: 10, right: 10),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFFFF),
                                  border: Border.all(
                                      color: Color(0xFFD9D9D9), width: 0.9),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Text(
                                  '${snapshot.data?['rank']}/${snapshot.data?['totalUsers']}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF444444),
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$totalScore',
                                style: TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3D83ED),
                                    height: 1.2),
                              ),
                              Text(
                                'POINTS',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF000000),
                                  height: 1,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 10,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${_seasonController.currentSeason} 시즌 '
                                '${_resortModelController.getResortName(_userModelController.resortNickname!)} 포인트',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xFF1357BC),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 2,
                              offset: Offset(1, 0),
                            ),
                          ]
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              '슬로프별 점수 현황',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                child:
                                passCountData?.entries.isEmpty ?? true ?
                                Center(child: Text('데이터가 없습니다'))
                                    : ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: (passCountData!.entries.toList()
                                    ..sort((a, b) {
                                      int scoreA = a.value * (slopeScoresModel.slopeScores[a.key] ?? 0);
                                      int scoreB = b.value * (slopeScoresModel.slopeScores[b.key] ?? 0);
                                      return scoreB.compareTo(scoreA);
                                    })).take(5).map((entry) {

                                    String slopeName = entry.key;
                                    int passCount = entry.value ?? 0;
                                    int scoreForSlope = passCount * (slopeScoresModel.slopeScores[slopeName] ?? 0);

                                    // Find the maximum score for sorted slopes
                                    int maxScore = passCountData.entries.toList().take(5).map((e) {
                                      return e.value * (slopeScoresModel.slopeScores[e.key] ?? 0);
                                    }).reduce((value, element) => value > element ? value : element);

                                    // Calculate the height ratio based on the score for each slope
                                    double barHeightRatio = scoreForSlope.toDouble() / maxScore.toDouble();

                                    // Determine the color of the bar based on whether this pass count is the maximum
                                    Color barColor = scoreForSlope == maxScore ? Color(0xFFC3DBFF) : Color(0xFF093372);  // use your desired colors

                                    return Container(
                                      margin: EdgeInsets.symmetric(horizontal: 5),
                                      width: 50,
                                      height: 95,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '$scoreForSlope',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFFFFFFFF),
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                            width: 50,
                                            height: 95 * barHeightRatio,
                                            child: Container(
                                              width: 20,
                                              height: 95 * barHeightRatio,
                                              decoration: BoxDecoration(
                                                  color: barColor,
                                                  borderRadius: BorderRadius.only(
                                                      topRight: Radius.circular(3),
                                                      topLeft: Radius.circular(3)
                                                  )
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            slopeName,
                                            style: TextStyle(fontSize: 11, color: Color(0xFFFFFFFF)),
                                          ),
                                          SizedBox(height: 20,)
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Container(
                      width: _size.width,
                      decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 2,
                              offset: Offset(1, 0),
                            ),
                          ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('자주타는 슬로프',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF111111),
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Expanded(child: SizedBox()),
                                  Text('$maxPassCountSlope',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3D83ED)
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
