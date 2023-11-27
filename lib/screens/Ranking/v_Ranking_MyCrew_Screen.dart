import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:com.snowlive/controller/vm_liveCrewModelController.dart';
import 'package:com.snowlive/controller/vm_liveMapController.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:com.snowlive/screens/Ranking/v_Ranking_indi_All_Screen.dart';
import '../../controller/vm_allUserDocsController.dart';
import '../../model/m_rankingTierModel.dart';
import '../more/friend/v_friendDetailPage.dart';

class RankingMyCrewScreen extends StatefulWidget {
  const RankingMyCrewScreen({Key? key}) : super(key: key);

  @override
  State<RankingMyCrewScreen> createState() => _RankingMyCrewScreenState();
}

class _RankingMyCrewScreenState extends State<RankingMyCrewScreen> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  LiveCrewModelController _liveCrewModelController =
  Get.find<LiveCrewModelController>();
  LiveMapController _liveMapController = Get.find<LiveMapController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
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
      _liveCrewModelController.getCurrrentCrew(_userModelController.liveCrew);
    } else {}
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('liveCrew')
            .where('crewID', isEqualTo: _liveCrewModelController.crewID)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            SizedBox.shrink();
          }
          else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final crewDocs = snapshot.data!.docs;
            List memberList = crewDocs[0]['memberUidList'];
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Ranking')
                  .doc('${_seasonController.currentSeason}')
                  .collection('${_liveCrewModelController.baseResort}')
                  .orderBy('totalScore', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  SizedBox.shrink();
                }
                else if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  final AllUserScoreDocs = snapshot.data!.docs;
                  final documents = AllUserScoreDocs.where((doc) =>
                      memberList.contains(doc.data()['uid'])).toList();
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
                        GestureDetector(
                          onTap: _scrollToMyRanking,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Text(
                                'My 랭킹',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3D83ED)),
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
                        '크루원 랭킹',
                        style: TextStyle(
                            color: Color(0xFF111111),
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                    body: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        child: Column(
                          children: documents.map((document) {
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
                                  return SizedBox.shrink();
                                }
                                final userDoc = snapshot.data!.docs;
                                final userData = userDoc.isNotEmpty ? userDoc[0] : null;

                                if (userData == null) {
                                  return SizedBox.shrink();
                                }

                                return Padding(
                                  key: itemKey, // Apply the key here
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onTap: (){
                                      Get.to(() =>
                                          FriendDetailPage(uid: userDoc[0]['uid'],
                                            favoriteResort: userDoc[0]['favoriteResort'],));
                                    },
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
                                        Container(
                                          width: 48,
                                          height: 48,
                                          child: userData['profileImageUrl'].isNotEmpty
                                              ? ExtendedImage.network(
                                            userData['profileImageUrl'],
                                            enableMemoryCache: true,
                                            cacheHeight: 100,
                                            shape: BoxShape.circle,
                                            borderRadius: BorderRadius.circular(8),
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                            loadStateChanged: (
                                                ExtendedImageState state) {
                                              switch (state.extendedImageLoadState) {
                                                case LoadState.loading:
                                                  return SizedBox.shrink();
                                                case LoadState.completed:
                                                  return state.completedWidget;
                                                case LoadState.failed:
                                                  return ExtendedImage.asset(
                                                    'assets/imgs/profile/img_profile_default_circle.png',
                                                    shape: BoxShape.circle,
                                                    borderRadius: BorderRadius.circular(
                                                        8),
                                                    width: 48,
                                                    height: 48,
                                                    fit: BoxFit.cover,
                                                  ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                default:
                                                  return null;
                                              }
                                            },
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
                                        SizedBox(width: 14),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 3),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userData['displayName'],
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xFF111111)),
                                              ),
                                              if(userData['stateMsg'].isNotEmpty)
                                                Text(userData['stateMsg'],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF949494)
                                                  ),)
                                              // StreamBuilder<QuerySnapshot>(
                                              //   stream: FirebaseFirestore.instance
                                              //       .collection('liveCrew')
                                              //       .where('crewID',
                                              //       isEqualTo: userData['liveCrew'])
                                              //       .snapshots(),
                                              //   builder: (context,
                                              //       AsyncSnapshot<QuerySnapshot> snapshot) {
                                              //     if (snapshot.hasError) {
                                              //       return Text("오류가 발생했습니다");
                                              //     }
                                              //
                                              //     if (snapshot.connectionState ==
                                              //         ConnectionState.waiting) {
                                              //       return CircularProgressIndicator();
                                              //     }
                                              //
                                              //     if (!snapshot.hasData ||
                                              //         snapshot.data!.docs.isEmpty) {
                                              //       return SizedBox();
                                              //     }
                                              //
                                              //     var crewData = snapshot.data!.docs.first
                                              //         .data() as Map<String, dynamic>?;
                                              //
                                              //     // 크루명 가져오기
                                              //     String crewName =
                                              //         crewData?['crewName'] ?? '';
                                              //
                                              //     return Text(
                                              //       crewName,
                                              //       style: TextStyle(
                                              //           fontSize: 12,
                                              //           color: Color(0xFF949494)),
                                              //     );
                                              //   },
                                              // ),
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
                                  ),

                                );

                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );

                }

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
                              'My 랭킹',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3D83ED)),
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
                      '크루원 랭킹',
                      style: TextStyle(
                          color: Color(0xFF111111),
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30, bottom: 20),
                            child: Text(
                              '랭킹에 참여중인 크루원이 없습니다',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF949494)
                              ),),
                          ),
                        )
                    ),
                  ),
                );

              },
            );
          }
          return Container();
        }
    );
  }
}
