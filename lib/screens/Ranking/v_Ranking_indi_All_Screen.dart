import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/controller/vm_liveMapController.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/Ranking/v_Ranking_indi_All_Screen.dart';
import '../../model/m_rankingTierModel.dart';
import '../more/friend/v_friendDetailPage.dart';

class RankingIndiAllScreen extends StatefulWidget {
  const RankingIndiAllScreen({Key? key}) : super(key: key);

  @override
  State<RankingIndiAllScreen> createState() => _RankingIndiAllScreenState();
}

class _RankingIndiAllScreenState extends State<RankingIndiAllScreen> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  LiveCrewModelController _liveCrewModelController =
      Get.find<LiveCrewModelController>();
  LiveMapController _liveMapController = Get.find<LiveMapController>();

  //TODO: Dependency Injection**************************************************

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


  Map? userRankingMap;

  void _scrollToMyRanking() {
    final myRanking = userRankingMap![_userModelController.uid];

    if (myRanking != null) {
      Scrollable.ensureVisible(myItemKey.currentContext!,
          duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
      print('My user ID: ${_userModelController.uid}'); // 현재 로그인된 사용자 ID 출력
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
          .collection('Ranking')
          .doc('${_seasonController.currentSeason}')
          .collection('${_userModelController.favoriteResort}')
          .orderBy('totalScore', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Container(
            color: Colors.white,
            child: Scaffold(
                backgroundColor: Colors.white, body: Text("오류가 발생했습니다")),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            child: Scaffold(backgroundColor: Colors.white, body: Text("")),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            color: Colors.white,
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
          );
        }
        final documents = snapshot.data!.docs;
        // 동점자인 경우 lastPassTime을 기준으로 최신 순으로 정렬
        documents.sort((a, b) {
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

        userRankingMap = _liveMapController.calculateRankIndiAll2(
            userRankingDocs: documents);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.location_searching),
                onPressed: _scrollToMyRanking,
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
                  fontSize: 20),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: _size.height,
                width: _size.width,
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];

                    // Assign myItemKey for the logged-in user's ListTile
                    final itemKey = document.get('uid') == _userModelController.uid
                        ? myItemKey
                        : GlobalKey();

                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('user')
                          .where('uid', isEqualTo: document.get('uid'))
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return ListTile(
                            title: Text(''),
                          );
                        }
                        final userDoc = snapshot.data!.docs;
                        final userData = userDoc.isNotEmpty ? userDoc[0] : null;

                        if (userData == null) {
                          return ListTile(
                            title: Text('User not found'),
                          );
                        }

                        return Padding(
                          key: itemKey, // Apply the key here
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Text(
                                '${userRankingMap!['${userDoc[0]['uid']}']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF111111)),
                              ),
                              SizedBox(width: 14),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() =>
                                      FriendDetailPage(uid: userData['uid'], favoriteResort: userData['favoriteResort'],));
                                },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  child: userData['profileImageUrl'].isNotEmpty
                                      ? ExtendedImage.network(
                                          userData['profileImageUrl'],
                                          enableMemoryCache: true,
                                          shape: BoxShape.circle,
                                          borderRadius: BorderRadius.circular(8),
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        )
                                      : ExtendedImage.asset(
                                          'assets/imgs/profile/img_profile_default_circle.png',
                                          enableMemoryCache: true,
                                          shape: BoxShape.circle,
                                          borderRadius: BorderRadius.circular(8),
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
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
                                      userData['displayName'],
                                      style: TextStyle(
                                          fontSize: 15, color: Color(0xFF111111)),
                                    ),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('liveCrew')
                                          .where('crewID',
                                              isEqualTo: userData['liveCrew'])
                                          .snapshots(),
                                      builder: (context,
                                          AsyncSnapshot<QuerySnapshot> snapshot) {
                                        if (snapshot.hasError) {
                                          return Text("오류가 발생했습니다");
                                        }

                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        }

                                        if (!snapshot.hasData ||
                                            snapshot.data!.docs.isEmpty) {
                                          return SizedBox();
                                        }

                                        var crewData = snapshot.data!.docs.first
                                            .data() as Map<String, dynamic>?;

                                        // 크루명 가져오기
                                        String crewName =
                                            crewData?['crewName'] ?? '';

                                        return Text(
                                          crewName,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF949494)),
                                        );
                                      },
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
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
