import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/model/m_slopeScoreModel.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  //TODO: Dependency Injection**************************************************


  Future<Map<String, int>> _calculateRank(int myScore) async {
    int totalUsers = 0;
    int myRank = -1;

    QuerySnapshot userCollection = await FirebaseFirestore.instance
        .collection('user')
        .where('favoriteResort', isEqualTo: _userModelController.favoriteResort)
        .get();

    totalUsers = userCollection.docs.length;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .orderBy('totalScores.${_userModelController.favoriteResort}', descending: true)
        .get();

    List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    for (int i = 0; i < documents.length; i++) {
      if (documents[i].id == _userModelController.uid) {
        myRank = i + 1; // 등수는 1부터 시작하기 때문에 1을 더해줍니다.
        break;
      }
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
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(58),
            child: AppBar(
              centerTitle: false,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '랭킹',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
          ),
          body: Container(
            color: Color(0xFFF1F1F3),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .doc(_userModelController.uid)
                  .collection('Ranking')
                  .doc("${_userModelController.favoriteResort}")
                  .collection('${_seasonController.currentSeason}')
                  .doc('1')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("오류가 발생했습니다");
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Lottie.asset('assets/json/loadings_wht_final.json');
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Column(
                    children: [
                      Text('총 점수: -'),
                      Expanded(
                        child: ListView.builder(
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('슬로프명: -'),
                              subtitle: Text('라이딩 횟수: -\n점수: -'),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                Map<String, dynamic>? data =
                snapshot.data!.data() as Map<String, dynamic>?;

                if (data == null || data.isEmpty) {
                  return Column(
                    children: [
                      Text('총 점수: -'),
                      Expanded(
                        child: ListView.builder(
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('슬로프명: -'),
                              subtitle: Text('라이딩 횟수: -\n점수: -'),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                Map<String, dynamic>? passCountData =
                data['passCountData'] as Map<String, dynamic>?;

                if (passCountData == null || passCountData.isEmpty) {
                  return Column(
                    children: [
                      Text('총 점수: -'),
                      Expanded(
                        child: ListView.builder(
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('슬로프명: -'),
                              subtitle: Text('라이딩 횟수: -\n점수: -'),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                int totalScore = 0;

                for (var slope in passCountData.keys) {
                  totalScore +=
                      (passCountData[slope] as int? ?? 0) *
                          (slopeScoresModel.slopeScores[slope] ?? 0);
                }

                return Column(
                  children: [
                    FutureBuilder<Map<String, int>>(
                      future: _calculateRank(totalScore),
                      builder: (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text('랭킹: 집계 중...');
                        } else if (snapshot.hasError) {
                          return Text('랭킹: 오류 발생');
                        } else {
                          return Text('랭킹: ${snapshot.data?['rank']}/${snapshot.data?['totalUsers']}');
                        }
                      },
                    ),
                    Text('총 점수: $totalScore'),
                    Expanded(
                      child: ListView.builder(
                        itemCount: passCountData.length,
                        itemBuilder: (context, index) {
                          String slopeName = passCountData.keys.elementAt(index);
                          int passCount = passCountData[slopeName] as int? ?? 0;
                          int scoreForSlope =
                              passCount * (slopeScoresModel.slopeScores[slopeName] ?? 0);
                          return ListTile(
                            title: Text('슬로프명: $slopeName'),
                            subtitle: Text('라이딩 횟수: $passCount\n점수: $scoreForSlope'),
                          );
                        },
                      ),
                    ),
                    Text('TOP 10'),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('user')
                            .orderBy('totalScores.${_userModelController.favoriteResort}', descending: true)
                            .limit(10)
                            .snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text("오류가 발생했습니다");
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Lottie.asset('assets/json/loadings_wht_final.json');
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Text("데이터가 없습니다");
                          }

                          List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: documents.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> userData = documents[index].data() as Map<String, dynamic>;
                              Map<String, dynamic> totalScoresMap = userData['totalScores'] as Map<String, dynamic>;
                              List<dynamic> totalScore = totalScoresMap.values.toList();
                              String displayName = userData['displayName'] ?? '';
                              return ListTile(
                                title: Text('${index+1}위 - $displayName'),
                                subtitle: Text('총 점수: ${totalScore[0]}'),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
