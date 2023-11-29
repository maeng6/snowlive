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

class RankingIndiAllScreen extends StatefulWidget {
  RankingIndiAllScreen({Key? key, required this.isKusbf}) : super(key: key);

  bool isKusbf = false;

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
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('kusbf')
            .doc('1')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

          if (snapshot.hasError) {
            return SizedBox.shrink();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox.shrink();
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return SizedBox.shrink();
          }

          List<dynamic> _kusbfList = [];
          _kusbfList = snapshot.data!.get('kusbf') as List<dynamic>;


          return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('liveCrew')
                  .where('kusbf', isEqualTo: true)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

                if (snapshot.hasError) {
                  return SizedBox.shrink();
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox.shrink();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return SizedBox.shrink();
                }

                // 'liveCrew' 컬렉션의 모든 문서에서 'memberUidList' 필드를 가져와서 합칩니다.
                List<dynamic> allMemberUidList = [];
                for (var doc in snapshot.data!.docs) {
                  List<dynamic> memberUidList = doc['memberUidList'];
                  allMemberUidList.addAll(memberUidList);
                }
                print(allMemberUidList.length);


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
                    final document = snapshot.data!.docs;
                    // 동점자인 경우 lastPassTime을 기준으로 최신 순으로 정렬
                    final filteredDocuments = document.where((doc) {
                      final uid = doc['uid'];
                      return allMemberUidList.contains(uid);
                    }).toList();
                    print(filteredDocuments.length);

                    final documents = widget.isKusbf == true ? filteredDocuments : document;

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
                          '전체 랭킹',
                          style: TextStyle(
                              color: Color(0xFF111111),
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                      body: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 60),
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
                                            decoration: BoxDecoration(
                                                color: Color(0xFFDFECFF),
                                                borderRadius: BorderRadius
                                                    .circular(50)
                                            ),
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
                                          SizedBox(width: 10),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 3),
                                            child: Container(
                                              width: _size.width - 240,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    userData['displayName'],
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Color(0xFF111111)),
                                                  ),
                                                  // if(userData['stateMsg'].isNotEmpty)
                                                    // Text(userData['stateMsg'],
                                                    //   maxLines: 1,
                                                    //   overflow: TextOverflow.ellipsis,
                                                    //   style: TextStyle(
                                                    //       fontSize: 12,
                                                    //       color: Color(0xFF949494)
                                                    //   ),)
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
                                                        return SizedBox.shrink();
                                                      }

                                                      if (!snapshot.hasData ||
                                                          snapshot.data!.docs.isEmpty) {
                                                        return SizedBox.shrink();
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
                                          ),
                                          Expanded(child: SizedBox()),
                                          Row(
                                            children: [
                                              Text(
                                                '${document.get('totalScore').toString()}점',
                                                style: TextStyle(
                                                  color: Color(0xFF111111),
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              for(var rankingTier in rankingTierList)
                                                if(document.get('tier') == rankingTier.tierName)
                                                  Transform.translate(
                                                    offset: Offset(6, 2),
                                                    child: ExtendedImage.network(
                                                      rankingTier.badgeAsset,
                                                      enableMemoryCache: true,
                                                      fit: BoxFit.cover,
                                                      width: 40,
                                                    ),
                                                  )
                                            ],
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
                  },
                );
              }
          );
        }
    );
  }
}
