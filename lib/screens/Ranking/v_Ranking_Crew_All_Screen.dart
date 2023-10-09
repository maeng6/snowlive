import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_liveCrewModelController.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import '../../controller/vm_liveMapController.dart';
import '../../model/m_crewLogoModel.dart';
import '../../widget/w_fullScreenDialog.dart';
import '../LiveCrew/v_crewDetailPage_screen.dart';

class RankingCrewAllScreen extends StatefulWidget {
  const RankingCrewAllScreen({Key? key}) : super(key: key);

  @override
  State<RankingCrewAllScreen> createState() => _RankingCrewAllScreenState();
}

class _RankingCrewAllScreenState extends State<RankingCrewAllScreen> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  LiveCrewModelController _liveCrewModelController =
  Get.find<LiveCrewModelController>();
  LiveMapController _liveMapController = Get.find<LiveMapController>();
  //TODO: Dependency Injection**************************************************

  var assetBases;

  ScrollController _scrollController = ScrollController();

  Map<String, GlobalKey> itemKeys = {};

  GlobalKey myItemKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // GlobalKey for my item (logged-in user)
    myItemKey = GlobalKey();
  }

  int? myCrewRank;
  Map? crewRankingMap;

  void _scrollToMyRanking() {
    final myRanking = crewRankingMap![_userModelController.liveCrew];

    if (myRanking != null) {
      Scrollable.ensureVisible(
        myItemKey.currentContext!,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
      print('My user ID: ${_userModelController.liveCrew}'); // 현재 로그인된 사용자 ID 출력
      print('My ranking: $myRanking');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    if (_userModelController.liveCrew != '' &&
        _userModelController.liveCrew != null) {
      _liveCrewModelController.getCurrnetCrew(_userModelController.liveCrew);
    } else {}

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('liveCrew')
          .where('baseResort',
          isEqualTo: _userModelController.favoriteResort)
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
                body: Text("오류가 발생했습니다"),
              ),
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
                body: Text(""),
              ),
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
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  leading: GestureDetector(
                    child: Image.asset(
                      'assets/imgs/icons/icon_snowLive_back.png',
                      scale: 4,
                      width: 26,
                      height: 26,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  elevation: 0.0,
                  titleSpacing: 0,
                  centerTitle: true,
                  title: Text(
                    '전체 랭킹',
                    style: TextStyle(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                body: Container(
                  height: _size.height - 200,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ExtendedImage.asset(
                          'assets/imgs/icons/icon_rankin_crew_nodata.png',
                          enableMemoryCache: true,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(7),
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          "데이터가 없습니다",
                          style: TextStyle(
                            color: Color(0xFF949494),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
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

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            actions: <Widget>[
              GestureDetector(
                onTap: _scrollToMyRanking,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      'My 크루',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D83ED),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            backgroundColor: Colors.white,
            leading: GestureDetector(
              child: Image.asset(
                'assets/imgs/icons/icon_snowLive_back.png',
                scale: 4,
                width: 26,
                height: 26,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            elevation: 0.0,
            titleSpacing: 0,
            centerTitle: true,
            title: Text(
              '전체 랭킹',
              style: TextStyle(
                color: Color(0xFF111111),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: crewDocs.map((document) {
                  // Assign myItemKey for the logged-in user's ListTile
                  final itemKey = document.get('crewID') ==
                      _userModelController.liveCrew
                      ? myItemKey
                      : GlobalKey();

                  for (var crewLogo in crewLogoList) {
                    if (crewLogo.crewColor == document['crewColor']) {
                      assetBases = crewLogo.crewLogoAsset;
                      break;
                    }
                  }

                  return Padding(
                    key: itemKey,
                    padding: const EdgeInsets.only(top: 6, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          '${crewRankingMap!['${document['crewID']}']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF111111)),
                        ),
                        SizedBox(width: 14),
                        GestureDetector(
                          onTap: () async {
                            CustomFullScreenDialog.showDialog();
                            await _userModelController.getCurrentUser_crew(_userModelController.uid);
                            await _liveCrewModelController.getCurrnetCrew(document['crewID']);
                            CustomFullScreenDialog.cancelDialog();
                            Get.to(() => CrewDetailPage_screen());
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            child: (document['profileImageUrl'].isNotEmpty)
                                ? Container(
                              width: 46,
                              height: 46,
                              child: ExtendedImage.network(
                                document['profileImageUrl'],
                                enableMemoryCache: true,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(6),
                                fit: BoxFit.cover,
                              ),
                            )
                                : Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Color(document['crewColor']),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: ExtendedImage.asset(
                                  assetBases,
                                  enableMemoryCache: true,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(6),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 14),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                document['crewName'],
                                style: TextStyle(
                                    fontSize: 15, color: Color(0xFF111111)),
                              ),
                              if (document['description'].isNotEmpty)
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    document['description'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12, color: Color(0xFF949494)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Text(
                          '${document.get('totalScore').toString()}점',
                          style: TextStyle(
                            color: Color(0xFF111111),
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
