import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/Ranking/v_Ranking_Crew_All_Screen.dart';
import '../../controller/vm_liveMapController.dart';
import '../../model/m_crewLogoModel.dart';
import '../../widget/w_fullScreenDialog.dart';
import '../LiveCrew/v_crewDetailPage_screen.dart';

class RankingCrewScreen extends StatefulWidget {
  const RankingCrewScreen({Key? key}) : super(key: key);

  @override
  State<RankingCrewScreen> createState() => _RankingCrewScreenState();
}

class _RankingCrewScreenState extends State<RankingCrewScreen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  LiveMapController _liveMapController = Get.find<LiveMapController>();
  //TODO: Dependency Injection**************************************************

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  int? myCrewRank;
  Map? crewRankingMap;
  var assetTop1;
  var assetTop2;
  var assetTop3;


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    if(_userModelController.liveCrew != '' && _userModelController.liveCrew != null) {
      _liveCrewModelController.getCurrnetCrew(_userModelController.liveCrew);
    }else{}

    return  StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('liveCrew')
          .where('baseResort', isEqualTo: _userModelController.favoriteResort)
          .orderBy('totalScore', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Container(
            color: Colors.white,
            child: SafeArea(
              top: false,
              bottom: true,
              child: Scaffold(
                  backgroundColor: Colors.white,
                  body: Text("오류가 발생했습니다")),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            child: SafeArea(
              top: false,
              bottom: true,
              child: Scaffold(
                  backgroundColor: Colors.white,
                  body: Text("")),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            color: Colors.white,
            child: SafeArea(
              top: false,
              bottom: true,
              child: Scaffold(
                backgroundColor: Colors.white,
                body: Container(
                  height: _size.height - 200,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ExtendedImage.asset(
                          'assets/imgs/icons/icon_rankin_indi_nodata.png',
                          enableMemoryCache: true,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(7),
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                        Text("데이터가 없습니다"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        if (snapshot.data!.docs.isNotEmpty) {
          final crewDocs = snapshot.data!.docs;
          crewDocs.sort((a, b) {
            final aTotalScore = a['totalScore'] as int;
            final bTotalScore = b['totalScore'] as int;
            final aLastPassTime = a['lastPassTime'] as Timestamp?;
            final bLastPassTime = b['lastPassTime'] as Timestamp?;
            if (aTotalScore == bTotalScore) {
              if (aLastPassTime != null && bLastPassTime != null) {
                return bLastPassTime.compareTo(aLastPassTime);
              }
            }
            return bTotalScore.compareTo(aTotalScore);
          });
          crewRankingMap =
              _liveMapController.calculateRankCrewAll2(crewDocs: crewDocs);

          for (var crewLogo in crewLogoList) {
            if (crewLogo.crewColor == crewDocs[0]['crewColor']) {
              assetTop1 = crewLogo.crewLogoAsset;
              break;
            }
          }
          for (var crewLogo in crewLogoList) {
            if (crewLogo.crewColor == crewDocs[1]['crewColor']) {
              assetTop2 = crewLogo.crewLogoAsset;
              break;
            }
          }
          for (var crewLogo in crewLogoList) {
            if (crewLogo.crewColor == crewDocs[2]['crewColor']) {
              assetTop3 = crewLogo.crewLogoAsset;
              break;
            }
          }
          print(assetTop1);
          print(assetTop2);
          print(assetTop3);


              return Container(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  bottom: true,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('상위 TOP 3 크루',
                                      style: TextStyle(
                                          color: Color(0xFF949494),
                                          fontSize: 12
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        if(crewDocs.length > 0)
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                CustomFullScreenDialog
                                                    .showDialog();
                                                await _liveCrewModelController
                                                    .getCurrnetCrew(
                                                    crewDocs[0]['crewID']);
                                                CustomFullScreenDialog
                                                    .cancelDialog();
                                                Get.to(() =>
                                                    CrewDetailPage_screen());
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(
                                                      crewDocs[0]['crewColor']),
                                                  borderRadius: BorderRadius
                                                      .circular(8),
                                                ),
                                                height: 154,
                                                width: _size.width / 3 - 12,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                  children: [
                                                    (crewDocs[0]['profileImageUrl']
                                                        .isNotEmpty)
                                                        ? Container(
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .black12,
                                                            spreadRadius: 0,
                                                            blurRadius: 8,
                                                            offset: Offset(0,
                                                                4), // changes position of shadow
                                                          ),
                                                        ],
                                                      ),
                                                      width: 58,
                                                      height: 58,
                                                      child: ExtendedImage
                                                          .network(
                                                        crewDocs[0]['profileImageUrl'],
                                                        enableMemoryCache: true,
                                                        shape: BoxShape
                                                            .rectangle,
                                                        borderRadius: BorderRadius
                                                            .circular(7),
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                        : Container(
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .black12,
                                                            spreadRadius: 0,
                                                            blurRadius: 8,
                                                            offset: Offset(0,
                                                                4), // changes position of shadow
                                                          ),
                                                        ],
                                                      ),
                                                      child: ExtendedImage
                                                          .asset(
                                                        assetTop1,
                                                        enableMemoryCache: true,
                                                        shape: BoxShape
                                                            .rectangle,
                                                        borderRadius: BorderRadius
                                                            .circular(7),
                                                        width: 58,
                                                        height: 58,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    SizedBox(height: 14,),
                                                    ExtendedImage.asset(
                                                      'assets/imgs/icons/icon_crown_1.png',
                                                      width: 28,
                                                      height: 28,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16),
                                                      child: Text(
                                                        crewDocs[0]['crewName'],
                                                        style: TextStyle(
                                                          color: Color(
                                                              0xFFFFFFFF),
                                                          fontWeight: FontWeight
                                                              .bold,
                                                          fontSize: 13,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        SizedBox(width: 8),
                                        if(crewDocs.length > 1)
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                CustomFullScreenDialog
                                                    .showDialog();
                                                await _liveCrewModelController
                                                    .getCurrnetCrew(
                                                    crewDocs[1]['crewID']);
                                                CustomFullScreenDialog
                                                    .cancelDialog();
                                                Get.to(() =>
                                                    CrewDetailPage_screen());
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(
                                                      crewDocs[1]['crewColor']),
                                                  borderRadius: BorderRadius
                                                      .circular(8),
                                                ),
                                                height: 154,
                                                width: _size.width / 3 - 12,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                  children: [
                                                    (crewDocs[1]['profileImageUrl']
                                                        .isNotEmpty)
                                                        ? Container(
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .black12,
                                                            spreadRadius: 0,
                                                            blurRadius: 8,
                                                            offset: Offset(0,
                                                                4), // changes position of shadow
                                                          ),
                                                        ],
                                                      ),
                                                      width: 58,
                                                      height: 58,
                                                      child: ExtendedImage
                                                          .network(
                                                        crewDocs[1]['profileImageUrl'],
                                                        enableMemoryCache: true,
                                                        shape: BoxShape
                                                            .rectangle,
                                                        borderRadius: BorderRadius
                                                            .circular(7),
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                        : Container(
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .black12,
                                                            spreadRadius: 0,
                                                            blurRadius: 8,
                                                            offset: Offset(0,
                                                                4), // changes position of shadow
                                                          ),
                                                        ],
                                                      ),
                                                      child: ExtendedImage
                                                          .asset(
                                                        assetTop2,
                                                        enableMemoryCache: true,
                                                        shape: BoxShape
                                                            .rectangle,
                                                        borderRadius: BorderRadius
                                                            .circular(7),
                                                        width: 58,
                                                        height: 58,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    SizedBox(height: 14,),
                                                    ExtendedImage.asset(
                                                      'assets/imgs/icons/icon_crown_2.png',
                                                      width: 28,
                                                      height: 28,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16),
                                                      child: Text(
                                                        crewDocs[1]['crewName'],
                                                        style: TextStyle(
                                                          color: Color(
                                                              0xFFFFFFFF),
                                                          fontWeight: FontWeight
                                                              .bold,
                                                          fontSize: 13,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        SizedBox(width: 8),
                                        if(crewDocs.length > 2)
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                CustomFullScreenDialog
                                                    .showDialog();
                                                await _liveCrewModelController
                                                    .getCurrnetCrew(
                                                    crewDocs[1]['crewID']);
                                                CustomFullScreenDialog
                                                    .cancelDialog();
                                                Get.to(() =>
                                                    CrewDetailPage_screen());
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(
                                                      crewDocs[2]['crewColor']),
                                                  borderRadius: BorderRadius
                                                      .circular(8),
                                                ),
                                                height: 154,
                                                width: _size.width / 3 - 12,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                  children: [
                                                    (crewDocs[2]['profileImageUrl']
                                                        .isNotEmpty)
                                                        ? Container(
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .black12,
                                                            spreadRadius: 0,
                                                            blurRadius: 8,
                                                            offset: Offset(0,
                                                                4), // changes position of shadow
                                                          ),
                                                        ],
                                                      ),
                                                      width: 58,
                                                      height: 58,
                                                      child: ExtendedImage
                                                          .network(
                                                        crewDocs[2]['profileImageUrl'],
                                                        enableMemoryCache: true,
                                                        shape: BoxShape
                                                            .rectangle,
                                                        borderRadius: BorderRadius
                                                            .circular(7),
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                        : Container(
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .black12,
                                                            spreadRadius: 0,
                                                            blurRadius: 8,
                                                            offset: Offset(0,
                                                                4), // changes position of shadow
                                                          ),
                                                        ],
                                                      ),
                                                      child: ExtendedImage
                                                          .asset(
                                                        assetTop3,
                                                        enableMemoryCache: true,
                                                        shape: BoxShape
                                                            .rectangle,
                                                        borderRadius: BorderRadius
                                                            .circular(7),
                                                        width: 58,
                                                        height: 58,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    SizedBox(height: 14,),
                                                    ExtendedImage.asset(
                                                      'assets/imgs/icons/icon_crown_3.png',
                                                      width: 28,
                                                      height: 28,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16),
                                                      child: Text(
                                                        crewDocs[2]['crewName'],
                                                        style: TextStyle(
                                                          color: Color(
                                                              0xFFFFFFFF),
                                                          fontWeight: FontWeight
                                                              .bold,
                                                          fontSize: 13,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 40,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Text('크루 랭킹 TOP 20',
                                          style: TextStyle(
                                              color: Color(0xFF111111),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Get.to(() =>
                                                RankingCrewAllScreen());
                                          },
                                          child: Text('전체 보기',
                                            style: TextStyle(
                                                color: Color(0xFF949494),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 18),
                                    Container(
                                      height: crewDocs.length * 64,
                                      child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: crewDocs.length < 20
                                            ? crewDocs.length
                                            : 20,
                                        itemBuilder: (context, index) {
                                          for (var crewLogo in crewLogoList)
                                            if (crewDocs[index]['crewColor'] == crewLogo.crewColor)
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${crewRankingMap!['${crewDocs[index]['crewID']}']}',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold,
                                                      fontSize: 15,
                                                      color: Color(0xFF111111)
                                                  ),
                                                ),
                                                SizedBox(width: 14),
                                                GestureDetector(
                                                  onTap: () async {
                                                    CustomFullScreenDialog
                                                        .showDialog();
                                                    await _liveCrewModelController
                                                        .getCurrnetCrew(
                                                        crewDocs[index]['crewID']);
                                                    CustomFullScreenDialog
                                                        .cancelDialog();
                                                    Get.to(() =>
                                                        CrewDetailPage_screen());
                                                  },
                                                  child: Container(
                                                    width: 48,
                                                    height: 48,
                                                    child:
                                                    (crewDocs[index]['profileImageUrl']
                                                        .isNotEmpty)
                                                        ? Container(
                                                        width: 46,
                                                        height: 46,
                                                        decoration: BoxDecoration(
                                                            color: Color(
                                                                crewDocs[index]['crewColor']),
                                                            borderRadius: BorderRadius
                                                                .circular(8)
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets
                                                              .all(2.0),
                                                          child: ExtendedImage
                                                              .network(
                                                            crewDocs[index]['profileImageUrl'],
                                                            enableMemoryCache: true,
                                                            shape: BoxShape
                                                                .rectangle,
                                                            borderRadius: BorderRadius
                                                                .circular(6),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ))
                                                        : Container(
                                                      width: 46,
                                                      height: 46,
                                                      decoration: BoxDecoration(
                                                          color: Color(
                                                              crewDocs[index]['crewColor']),
                                                          borderRadius: BorderRadius
                                                              .circular(8)
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .all(2.0),
                                                        child: ExtendedImage
                                                            .asset(
                                                          crewLogo.crewLogoAsset,
                                                          enableMemoryCache: true,
                                                          shape: BoxShape
                                                              .rectangle,
                                                          borderRadius: BorderRadius
                                                              .circular(6),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 14),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .only(bottom: 3),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text(
                                                        crewDocs[index]['crewName'],
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(
                                                                0xFF111111)
                                                        ),
                                                      ),
                                                      Text(
                                                        crewDocs[index]['crewLeader'],
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Color(
                                                                0xFF949494)
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(child: SizedBox()),
                                                Text(
                                                  '${crewDocs[index]
                                                      .get('totalScore')
                                                      .toString()}점',
                                                  style: TextStyle(
                                                    color: Color(0xFF111111),
                                                    fontWeight: FontWeight
                                                        .normal,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 64,),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('liveCrew')
                              .where('crewID', isEqualTo: _userModelController
                              .liveCrew)
                              .snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<
                              QuerySnapshot> snapshot) {
                            if (!snapshot.hasData || snapshot.data == null) {
                              return Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      spreadRadius: 0,
                                      blurRadius: 6,
                                      offset: Offset(
                                          0, 0), // changes position of shadow
                                    ),
                                  ],
                                  color: Colors.grey,
                                ),
                                height: 80,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text('가입한 크루가 없습니다. 크루에 가입해서 즐겨라 '),
                                ),
                              );
                            }
                            else if (snapshot.data!.docs.isNotEmpty) {
                              final myCrewDocs = snapshot.data!.docs;
                              for (var crewLogo in crewLogoList)
                                if (myCrewDocs[0]['crewColor'] == crewLogo.crewColor)
                              return Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      spreadRadius: 0,
                                      blurRadius: 6,
                                      offset: Offset(
                                          0, 0), // changes position of shadow
                                    ),
                                  ],
                                  color: Color(myCrewDocs[0]['crewColor']),
                                ),
                                height: 80,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${crewRankingMap!['${_userModelController
                                            .liveCrew}']}',
                                        style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      GestureDetector(
                                        onTap: () async {
                                          CustomFullScreenDialog.showDialog();
                                          await _liveCrewModelController
                                              .getCurrnetCrew(
                                              myCrewDocs[0]['crewID']);
                                          CustomFullScreenDialog.cancelDialog();
                                          Get.to(() => CrewDetailPage_screen());
                                        },
                                        child: (myCrewDocs[0]['profileImageUrl']
                                            .isNotEmpty)
                                            ? Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                                color: Color(
                                                    myCrewDocs[0]['crewColor']),
                                                borderRadius: BorderRadius
                                                    .circular(8)
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                  2.0),
                                              child: ExtendedImage.network(
                                                myCrewDocs[0]['profileImageUrl'],
                                                enableMemoryCache: true,
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius
                                                    .circular(6),
                                                fit: BoxFit.cover,
                                              ),
                                            ))
                                            : Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                              color: Color(
                                                  myCrewDocs[0]['crewColor']),
                                              borderRadius: BorderRadius
                                                  .circular(8)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: ExtendedImage.asset(
                                              crewLogo.crewLogoAsset,
                                              enableMemoryCache: true,
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius
                                                  .circular(6),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 3),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              '${myCrewDocs[0]['crewName']}',
                                              style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 2,),
                                            Text(
                                              '${myCrewDocs[0]['crewLeader']}',
                                              style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(child: SizedBox()),
                                      Text(
                                        '${myCrewDocs[0]['totalScore']}점',
                                        style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontWeight: FontWeight.normal,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            else if (snapshot.connectionState ==
                                ConnectionState.waiting) {}
                            else if (snapshot.hasError) {
                              return Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      spreadRadius: 0,
                                      blurRadius: 6,
                                      offset: Offset(
                                          0, 0), // changes position of shadow
                                    ),
                                  ],
                                  color: Colors.grey,
                                ),
                                height: 80,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text('가입한 크루가 없습니다.'),
                                ),
                              );
                            }
                            return Center();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
        }
        return Container();
      }
    );

  }
}
