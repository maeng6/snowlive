import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:snowlive3/controller/vm_liveMapController.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/model/m_rankingTierModel.dart';
import 'package:snowlive3/model/m_slopeScoreModel.dart';

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
  LiveMapController _liveMapController = Get.find<LiveMapController>();
  // TODO: Dependency Injection**************************************************

  Map? userRankingMap;

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
          body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Ranking')
                  .doc('${_seasonController.currentSeason}')
                  .collection('${_userModelController.favoriteResort}')
                  .orderBy('totalScore', descending: true)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData || snapshot.data == null){
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ExtendedImage.asset(
                      'assets/imgs/icons/image_background_myscore.png',
                      enableMemoryCache: true,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                else if(snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ExtendedImage.asset(
                      'assets/imgs/icons/image_background_myscore.png',
                      enableMemoryCache: true,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                else if (!snapshot.hasData || snapshot.data == null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ExtendedImage.asset(
                      'assets/imgs/icons/image_background_myscore.png',
                      enableMemoryCache: true,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                else if (snapshot.data!.docs.isNotEmpty) {
                  final rankingDocs_total = snapshot.data!.docs;
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Ranking')
                        .doc('${_seasonController.currentSeason}')
                        .collection('${_userModelController.favoriteResort}')
                        .where('uid', isEqualTo: _userModelController.uid )
                        .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData || snapshot.data == null){
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ExtendedImage.asset(
                            'assets/imgs/icons/image_background_myscore.png',
                            enableMemoryCache: true,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                      else if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ExtendedImage.asset(
                            'assets/imgs/icons/image_background_myscore.png',
                            enableMemoryCache: true,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                      else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ExtendedImage.asset(
                            'assets/imgs/icons/image_background_myscore.png',
                            enableMemoryCache: true,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                      else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        // 데이터가 없을 때 처리
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ExtendedImage.asset(
                            'assets/imgs/icons/image_background_myscore.png',
                            enableMemoryCache: true,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                      final rankingDocs = snapshot.data!.docs;
                      int totalScore = rankingDocs[0]['totalScore'];
                      Map<String, dynamic>? passCountData = rankingDocs[0]['passCountData'];
                      Map<String, dynamic>? slopeScoresData = rankingDocs[0]['slopeScores'];
                      String maxPassCountSlope = _liveMapController.calculateMaxValue(passCountData);
                      List<Map<String, dynamic>> barData = _liveMapController.calculateBarDataSlopeScore(slopeScoresData);
                      userRankingMap =  _liveMapController.calculateRankIndiAll2(userRankingDocs: rankingDocs_total);
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
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(top: 3, bottom: 3, left: 10, right: 10),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFFFFF),
                                          border: Border.all(color: Color(0xFFD9D9D9), width: 0.9),
                                          borderRadius: BorderRadius.circular(30.0),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              '${userRankingMap!['${_userModelController.uid}']}/${userRankingMap!.length}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF444444),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      for(var rankingTier in rankingTierList)
                                        if(rankingDocs[0]['tier'] == rankingTier.tierName)
                                          ExtendedImage.asset(
                                            enableMemoryCache:true,
                                            rankingTier.badgeAsset,
                                            scale: 4,
                                          ),
                                    ],
                                  )
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
                                        child: barData.isEmpty
                                            ? Center(child: Text('데이터가 없습니다'))
                                            : ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: barData.map((data) {
                                            String slopeName = data['slopeName'];
                                            int scoreForSlope = data['scoreForSlope'];
                                            double barHeightRatio = data['barHeightRatio'];
                                            Color barColor = data['barColor'];

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
                                                      fontWeight: FontWeight.bold,
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
                                                          topLeft: Radius.circular(3),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    slopeName,
                                                    style: TextStyle(fontSize: 11, color: Color(0xFFFFFFFF)),
                                                  ),
                                                  SizedBox(height: 20),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  )


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
                  );
                }
                else if (snapshot.connectionState == ConnectionState.waiting) {}
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ExtendedImage.asset(
                    'assets/imgs/icons/image_background_myscore.png',
                    enableMemoryCache: true,
                    fit: BoxFit.cover,
                  ),
                );
              }),



        ),
      ),
    );
  }
}
