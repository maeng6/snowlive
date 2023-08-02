import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:snowlive3/controller/vm_liveMapController.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/model/m_rankingTierModel.dart';
import 'package:snowlive3/model/m_slopeScoreModel.dart';
import 'package:snowlive3/screens/v_MainHome.dart';

import '../resort/v_resortHome.dart';

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
      color: Color(0xFF3D83ED),
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
          body: SingleChildScrollView(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Ranking')
                    .doc('${_seasonController.currentSeason}')
                    .collection('${_userModelController.favoriteResort}')
                    .orderBy('totalScore', descending: true)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData || snapshot.data == null){
                    return Center(
                      child: Container(
                        width: _size.width,
                        height: _size.height-200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 94,
                              child: ExtendedImage.asset(
                                'assets/imgs/ranking/icon_ranking_nodata.png',
                                enableMemoryCache: true,
                                scale: 4,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Center(
                              child: Text('랭킹 정보가 없어요!',
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 15
                                ),),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Center(
                              child: Text('라이브온을 시작해 랭킹 게임에 참여해 보세요.',
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 15
                                ),),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 16, right: 12, bottom: 20),
                                child: Column(
                                    children: [
                                      Container(
                                        height: 40,
                                        child: ElevatedButton(
                                          child: Text(
                                            '라이브온 하러 가기',
                                            style: TextStyle(
                                                color: Color(0xFFffffff),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                          onPressed: () async{
                                            Get.offAll(()=>MainHome(uid: _userModelController.uid));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                            minimumSize: Size(40, 10),
                                            backgroundColor: Color(0xFF073985),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8)),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                    ]
                                )
                            )

                          ],
                        ),
                      ),
                    );
                  }
                  else if(snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Container(
                        width: _size.width,
                        height: _size.height-200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 94,
                              child: ExtendedImage.asset(
                                'assets/imgs/ranking/icon_ranking_nodata.png',
                                enableMemoryCache: true,
                                scale: 4,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Center(
                              child: Text('랭킹 정보가 없어요!',
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 15
                                ),),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Center(
                              child: Text('라이브온을 시작해 랭킹 게임에 참여해 보세요.',
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 15
                                ),),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 16, right: 12, bottom: 20),
                                child: Column(
                                    children: [
                                      Container(
                                        height: 40,
                                        child: ElevatedButton(
                                          child: Text(
                                            '라이브온 하러 가기',
                                            style: TextStyle(
                                                color: Color(0xFFffffff),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                          onPressed: () async{
                                            Get.offAll(()=>MainHome(uid: _userModelController.uid));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                            minimumSize: Size(40, 10),
                                            backgroundColor: Color(0xFF073985),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8)),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                    ]
                                )
                            )

                          ],
                        ),
                      ),
                    );
                  }
                  else if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: Container(
                        width: _size.width,
                        height: _size.height-200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 94,
                              child: ExtendedImage.asset(
                                'assets/imgs/ranking/icon_ranking_nodata.png',
                                enableMemoryCache: true,
                                scale: 4,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Center(
                              child: Text('랭킹 정보가 없어요!',
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 15
                                ),),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Center(
                              child: Text('라이브온을 시작해 랭킹 게임에 참여해 보세요.',
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 15
                                ),),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 16, right: 12, bottom: 20),
                                child: Column(
                                    children: [
                                      Container(
                                        height: 40,
                                        child: ElevatedButton(
                                          child: Text(
                                            '라이브온 하러 가기',
                                            style: TextStyle(
                                                color: Color(0xFFffffff),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                          onPressed: () async{
                                            Get.offAll(()=>MainHome(uid: _userModelController.uid));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                            minimumSize: Size(40, 10),
                                            backgroundColor: Color(0xFF073985),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8)),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                    ]
                                )
                            )

                          ],
                        ),
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
                          return Center(
                            child: Container(
                              width: _size.width,
                              height: _size.height-200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 94,
                                    child: ExtendedImage.asset(
                                      'assets/imgs/ranking/icon_ranking_nodata.png',
                                      enableMemoryCache: true,
                                      scale: 4,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Center(
                                    child: Text('랭킹 정보가 없어요!',
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 15
                                      ),),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Center(
                                    child: Text('라이브온을 시작해 랭킹 게임에 참여해 보세요.',
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 15
                                      ),),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(left: 16, right: 12, bottom: 20),
                                      child: Column(
                                          children: [
                                            Container(
                                              height: 40,
                                              child: ElevatedButton(
                                                child: Text(
                                                  '라이브온 하러 가기',
                                                  style: TextStyle(
                                                      color: Color(0xFFffffff),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14),
                                                ),
                                                onPressed: () async{
                                                  Get.offAll(()=>MainHome(uid: _userModelController.uid));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                                  minimumSize: Size(40, 10),
                                                  backgroundColor: Color(0xFF073985),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8)),
                                                  elevation: 0,
                                                ),
                                              ),
                                            ),
                                          ]
                                      )
                                  )

                                ],
                              ),
                            ),
                          );
                        }
                        else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: Container(
                              width: _size.width,
                              height: _size.height-200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 94,
                                    child: ExtendedImage.asset(
                                      'assets/imgs/ranking/icon_ranking_nodata.png',
                                      enableMemoryCache: true,
                                      scale: 4,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Center(
                                    child: Text('랭킹 정보가 없어요!',
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 15
                                      ),),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Center(
                                    child: Text('라이브온을 시작해 랭킹 게임에 참여해 보세요.',
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 15
                                      ),),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(left: 16, right: 12, bottom: 20),
                                      child: Column(
                                          children: [
                                            Container(
                                              height: 40,
                                              child: ElevatedButton(
                                                child: Text(
                                                  '라이브온 하러 가기',
                                                  style: TextStyle(
                                                      color: Color(0xFFffffff),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14),
                                                ),
                                                onPressed: () async{
                                                  Get.offAll(()=>MainHome(uid: _userModelController.uid));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                                  minimumSize: Size(40, 10),
                                                  backgroundColor: Color(0xFF073985),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8)),
                                                  elevation: 0,
                                                ),
                                              ),
                                            ),
                                          ]
                                      )
                                  )

                                ],
                              ),
                            ),
                          );
                        }
                        else if (snapshot.hasError) {
                          return Center(
                            child: Container(
                              width: _size.width,
                              height: _size.height-200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 94,
                                    child: ExtendedImage.asset(
                                      'assets/imgs/ranking/icon_ranking_nodata.png',
                                      enableMemoryCache: true,
                                      scale: 4,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Center(
                                    child: Text('랭킹 정보가 없어요!',
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 15
                                      ),),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Center(
                                    child: Text('라이브온을 시작해 랭킹 게임에 참여해 보세요.',
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 15
                                      ),),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(left: 16, right: 12, bottom: 20),
                                      child: Column(
                                          children: [
                                            Container(
                                              height: 40,
                                              child: ElevatedButton(
                                                child: Text(
                                                  '라이브온 하러 가기',
                                                  style: TextStyle(
                                                      color: Color(0xFFffffff),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14),
                                                ),
                                                onPressed: () async{
                                                  Get.offAll(()=>MainHome(uid: _userModelController.uid));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                                  minimumSize: Size(40, 10),
                                                  backgroundColor: Color(0xFF073985),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8)),
                                                  elevation: 0,
                                                ),
                                              ),
                                            ),
                                          ]
                                      )
                                  )

                                ],
                              ),
                            ),
                          );
                        }
                        else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          // 데이터가 없을 때 처리
                          return Center(
                            child: Container(
                              width: _size.width,
                              height: _size.height-200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 94,
                                    child: ExtendedImage.asset(
                                      'assets/imgs/ranking/icon_ranking_nodata.png',
                                      enableMemoryCache: true,
                                      scale: 4,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Center(
                                    child: Text('랭킹 정보가 없어요!',
                                      style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 15
                                    ),),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Center(
                                    child: Text('라이브온을 시작해 랭킹 게임에 참여해 보세요.',
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 15
                                      ),),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                              Padding(
                                padding: EdgeInsets.only(left: 16, right: 12, bottom: 20),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 40,
                                      child: ElevatedButton(
                                        child: Text(
                                          '라이브온 하러 가기',
                                          style: TextStyle(
                                              color: Color(0xFFffffff),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        onPressed: () async{
                                          Get.offAll(()=>MainHome(uid: _userModelController.uid));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                          minimumSize: Size(40, 10),
                                          backgroundColor: Color(0xFF073985),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8)),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ]
                                )
                              )

                                ],
                              ),
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
                                    top: 16,
                                    right: 28,
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(top: 3, bottom: 3, left: 10, right: 10),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFFFFFF),
                                            border: Border.all(color: Color(0xFFD9D9D9), width: 1),
                                            borderRadius: BorderRadius.circular(30.0),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                '${userRankingMap!['${_userModelController.uid}']}등',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF444444),
                                                  fontWeight: FontWeight.bold),
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
                                        Container(
                                          height: 120,
                                          child: Text(
                                            '$totalScore',
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 120,
                                                fontWeight: FontWeight.normal,
                                                color: Color(0xFF3D83ED),
                                                ),
                                          ),
                                        ),
                                        Text(
                                          'POINTS',
                                          style: GoogleFonts.bebasNeue(
                                            fontSize: 30,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFF000000),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 16,
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
                            SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                  color: Color(0xFF1357BC),
                                  borderRadius: BorderRadius.circular(20),
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                width: _size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 14),
                                        child: Text(
                                          '포인트 상세',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),

                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: barData.length < 4 ? 40 : 20),
                                      height: 240,
                                      width: _size.width,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: barData.isEmpty
                                                  ? Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Image.asset(
                                                        'assets/imgs/icons/icon_ranking_nodata_1.png',
                                                        scale: 4,
                                                        width: 43,
                                                        height: 32,
                                                      ),
                                                SizedBox(height: 12,),
                                              Text('데이터가 없습니다.',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.normal
                                                ),),
                                                  SizedBox(
                                                    height: 36,
                                                  )
                                                ],
                                              ))
                                                  : SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                    child: Container(
                                                      child: Row(
                                                mainAxisAlignment:
                                                barData.length < 2
                                                    ? MainAxisAlignment.center
                                                    : MainAxisAlignment.spaceBetween,
                                                children: barData.map((data) {
                                                      String slopeName = data['slopeName'];
                                                      int scoreForSlope = data['scoreForSlope'];
                                                      double barHeightRatio = data['barHeightRatio'];
                                                      Color barColor = data['barColor'];
                                                      return Container(
                                                        margin: EdgeInsets.symmetric(horizontal: 5),
                                                        width: barData.length < 5 ? _size.width / 5 - 10 : _size.width / 5 - 28,
                                                        height: 185,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            Text(
                                                              '$scoreForSlope',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                color: Color(0xFFFFFFFF),
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            SizedBox(height: 4),
                                                            Container(
                                                              width: 58,
                                                              height: 140 * barHeightRatio,
                                                              child: Container(
                                                                width: 58,
                                                                height: 140 * barHeightRatio,
                                                                decoration: BoxDecoration(
                                                                  color: barColor,
                                                                  borderRadius: BorderRadius.only(
                                                                    topRight: Radius.circular(4),
                                                                    topLeft: Radius.circular(4),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 10),
                                                            Text(
                                                              slopeName,
                                                              style: TextStyle(fontSize: 12, color: Color(0xFFFFFFFF)),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                }).toList(),
                                              ),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )


                                  ],
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
                  return Center(
                    child: Container(
                      width: _size.width,
                      height: _size.height-200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 94,
                            child: ExtendedImage.asset(
                              'assets/imgs/ranking/icon_ranking_nodata.png',
                              enableMemoryCache: true,
                              scale: 4,
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Center(
                            child: Text('랭킹 정보가 없어요!',
                              style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 15
                              ),),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Center(
                            child: Text('라이브온을 시작해 랭킹 게임에 참여해 보세요.',
                              style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 15
                              ),),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 16, right: 12, bottom: 20),
                              child: Column(
                                  children: [
                                    Container(
                                      height: 40,
                                      child: ElevatedButton(
                                        child: Text(
                                          '라이브온 하러 가기',
                                          style: TextStyle(
                                              color: Color(0xFFffffff),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        onPressed: () async{
                                          Get.offAll(()=>MainHome(uid: _userModelController.uid));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                          minimumSize: Size(40, 10),
                                          backgroundColor: Color(0xFF073985),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8)),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ]
                              )
                          )

                        ],
                      ),
                    ),
                  );
                }),
          ),



        ),
      ),
    );
  }
}
