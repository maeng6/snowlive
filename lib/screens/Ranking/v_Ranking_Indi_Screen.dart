import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/controller/vm_liveMapController.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/model/m_slopeScoreModel.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';

import '../../model/m_rankingTierModel.dart';
import '../more/friend/v_friendDetailPage.dart';

class RankingIndiScreen extends StatefulWidget {
  const RankingIndiScreen({Key? key}) : super(key: key);

  @override
  State<RankingIndiScreen> createState() => _RankingIndiScreenState();
}

class _RankingIndiScreenState extends State<RankingIndiScreen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  LiveMapController _liveMapController = Get.find<LiveMapController>();
  //TODO: Dependency Injection**************************************************


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    if(_userModelController.liveCrew != '' && _userModelController.liveCrew != null) {
      _liveCrewModelController.getCurrnetCrew(_userModelController.liveCrew);
    }else{}
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Ranking')
                            .doc('${_seasonController.currentSeason}')
                            .collection('${_userModelController.favoriteResort}')
                            .orderBy('totalScore', descending: true)
                            .snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text("오류가 발생했습니다");
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Lottie.asset('assets/json/loadings_wht_final.json');
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Container(
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

                          return Column(
                            children: [
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('상위 TOP 3 유저',
                                      style: TextStyle(
                                          color: Color(0xFF949494),
                                          fontSize: 12
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        if(documents.length > 0)
                                        StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection('user')
                                              .where('uid', isEqualTo: documents[0].get('uid'))
                                              .snapshots(),
                                          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                            if (!snapshot.hasData || snapshot.data == null) {
                                              return Center();
                                            } else if (snapshot.data!.docs.isNotEmpty) {
                                              final userDoc = snapshot.data!.docs;
                                              return GestureDetector(
                                                onTap: (){
                                                  Get.to(() => FriendDetailPage(uid: userDoc[0]['uid']));
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFDBE9FF),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  height: 154,
                                                  width: _size.width / 3 - 16,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      (userDoc[0]['profileImageUrl'].isNotEmpty)
                                                          ? Container(
                                                            width: 58,
                                                            height: 58,
                                                            child: ExtendedImage.network(
                                                              userDoc[0]['profileImageUrl'],
                                                              enableMemoryCache: true,
                                                              shape: BoxShape.circle,
                                                              width: 100,
                                                              height: 100,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                          : ExtendedImage.asset(
                                                            'assets/imgs/profile/img_profile_default_.png',
                                                            enableMemoryCache: true,
                                                            shape: BoxShape.circle,
                                                            width: 58,
                                                            height: 58,
                                                            fit: BoxFit.cover,
                                                          ),
                                                      SizedBox(height: 14,),
                                                      ExtendedImage.asset(
                                                        'assets/imgs/icons/icon_crown_1.png',
                                                        width: 28,
                                                        height: 28,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                                        child: Text(
                                                          userDoc[0]['displayName'],
                                                          style: TextStyle(
                                                            color: Color(0xFF111111),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 13,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            } else if (snapshot.connectionState == ConnectionState.waiting) {
                                              return Center();
                                            } else {
                                              return Center();
                                            }
                                          },
                                        ),
                                        SizedBox(width: 8,),
                                        if(documents.length > 1)

                                          StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection('user')
                                              .where('uid', isEqualTo: documents[1].get('uid'))
                                              .snapshots(),
                                          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                            if (!snapshot.hasData || snapshot.data == null) {
                                              return Center();
                                            } else if (snapshot.data!.docs.isNotEmpty) {
                                              final userDoc = snapshot.data!.docs;
                                              return GestureDetector(
                                                onTap: (){
                                                  Get.to(() => FriendDetailPage(uid: userDoc[0]['uid']));
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFDBE9FF),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  height: 154,
                                                  width: _size.width / 3 - 16,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      (userDoc[0]['profileImageUrl'].isNotEmpty)
                                                          ? Container(
                                                            width: 58,
                                                            height: 58,
                                                            child: ExtendedImage.network(
                                                              userDoc[0]['profileImageUrl'],
                                                              enableMemoryCache: true,
                                                              shape: BoxShape.circle,
                                                              width: 100,
                                                              height: 100,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                          : ExtendedImage.asset(
                                                            'assets/imgs/profile/img_profile_default_.png',
                                                            enableMemoryCache: true,
                                                            shape: BoxShape.circle,
                                                            width: 58,
                                                            height: 58,
                                                            fit: BoxFit.cover,
                                                          ),
                                                      SizedBox(height: 14,),
                                                      ExtendedImage.asset(
                                                        'assets/imgs/icons/icon_crown_2.png',
                                                        width: 28,
                                                        height: 28,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                                        child: Text(
                                                          userDoc[0]['displayName'],
                                                          style: TextStyle(
                                                            color: Color(0xFF111111),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 13,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            } else if (snapshot.connectionState == ConnectionState.waiting) {
                                              return Center();
                                            } else {
                                              return Center();
                                            }
                                          },
                                        ),
                                        SizedBox(width: 8,),
                                        if(documents.length > 2)

                                          StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection('user')
                                              .where('uid', isEqualTo: documents[2].get('uid'))
                                              .snapshots(),
                                          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                            if (!snapshot.hasData || snapshot.data == null) {
                                              return Center();
                                            } else if (snapshot.data!.docs.isNotEmpty) {
                                              final userDoc = snapshot.data!.docs;
                                              return GestureDetector(
                                                onTap: (){
                                                  Get.to(() => FriendDetailPage(uid: userDoc[0]['uid']));
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFDBE9FF),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  height: 154,
                                                  width: _size.width / 3 - 16,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      (userDoc[0]['profileImageUrl'].isNotEmpty)
                                                          ? Container(
                                                            width: 58,
                                                            height: 58,
                                                            child: ExtendedImage.network(
                                                              userDoc[0]['profileImageUrl'],
                                                              enableMemoryCache: true,
                                                              shape: BoxShape.circle,
                                                              width: 100,
                                                              height: 100,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                          : ExtendedImage.asset(
                                                            'assets/imgs/profile/img_profile_default_.png',
                                                            enableMemoryCache: true,
                                                            shape: BoxShape.circle,
                                                            width: 58,
                                                            height: 58,
                                                            fit: BoxFit.cover,
                                                          ),
                                                      SizedBox(height: 14,),
                                                      ExtendedImage.asset(
                                                        'assets/imgs/icons/icon_crown_3.png',
                                                        width: 28,
                                                        height: 28,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                                        child: Text(
                                                          userDoc[0]['displayName'],
                                                          style: TextStyle(
                                                            color: Color(0xFF111111),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 13,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            } else if (snapshot.connectionState == ConnectionState.waiting) {
                                              return Center();
                                            } else {
                                              return Center();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 40,),
                                    Text('전체 개인 랭킹',
                                      style: TextStyle(
                                          color: Color(0xFF111111),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    SizedBox(height: 18,),
                                    Container(
                                      height: documents.length * 64,
                                      child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: documents.length,
                                        itemBuilder: (context, index) {
                                          final document = documents[index];
                                          return StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('user')
                                                .where('uid', isEqualTo: document.get('uid'))
                                                .snapshots(),
                                            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                              if (!snapshot.hasData || snapshot.data == null) {
                                                return ListTile(
                                                  title: Text('Loading...'),
                                                );
                                              }
                                              final userDoc = snapshot.data!.docs;
                                              final userData = userDoc.isNotEmpty ? userDoc[0] : null;

                                              if (userData == null) {
                                                return ListTile(
                                                  title: Text('User not found'),
                                                );
                                              }

                                              return FutureBuilder<Map<String, int>>(
                                                  future: _liveMapController.calculateRankIndiAll(
                                                    documents[index]['totalScore'], userData['uid']),
                                                  builder: (BuildContext context,
                                                      AsyncSnapshot<Map<String, int>> snapshot) {
                                                    if(snapshot.connectionState == ConnectionState.waiting){
                                                      return Container();
                                                    }else if (snapshot.hasError) {
                                                      return Text('랭킹: 오류 발생');
                                                    }else{
                                                  return Padding(
                                                    padding: const EdgeInsets.only(bottom: 12),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          '${snapshot.data?['rank']}',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 15,
                                                              color: Color(0xFF111111)
                                                          ),
                                                        ),
                                                        SizedBox(width: 14),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Get.to(() => FriendDetailPage(uid: userData['uid']));
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
                                                                    fontSize: 15,
                                                                    color: Color(0xFF111111)
                                                                ),
                                                              ),
                                                              StreamBuilder<QuerySnapshot>(
                                                                stream: FirebaseFirestore.instance
                                                                    .collection('liveCrew')
                                                                    .where('crewID', isEqualTo: userData['liveCrew'])
                                                                    .snapshots(),
                                                                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                                  if (snapshot.hasError) {
                                                                    return Text("오류가 발생했습니다");
                                                                  }

                                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                                    return CircularProgressIndicator();
                                                                  }

                                                                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                                                    return SizedBox();
                                                                  }

                                                                  var crewData = snapshot.data!.docs.first.data() as Map<String, dynamic>?;

                                                                  // 크루명 가져오기
                                                                  String crewName = crewData?['crewName'] ?? '';

                                                                  return Text(
                                                                    crewName,
                                                                    style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Color(0xFF949494)
                                                                    ),
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
                                                  );}
                                                }
                                              );

                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 110,)

                                  ],
                                ),

                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 0,
                      blurRadius: 6,
                      offset: Offset(0, 0), // changes position of shadow
                    ),],
                  color: Color(0xFFDBE9FF),
                ),
                height: 80,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Ranking')
                      .doc('${_seasonController.currentSeason}')
                      .collection('${_userModelController.favoriteResort}')
                      .where('uid', isEqualTo: _userModelController.uid )
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text("오류가 발생했습니다");
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      return Lottie.asset('assets/json/loadings_wht_final.json');
                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      // 데이터가 없을 때 처리
                      return Text("데이터가 없습니다");
                    }
                    final rankingDocs = snapshot.data!.docs;
                    int myScore = rankingDocs[0]['totalScore'];

                    // 내 정보 가져오기
                    return  FutureBuilder<Map<String, int>>(
                        future: _liveMapController.calculateRank(myScore),
                        builder: (BuildContext context,
                            AsyncSnapshot<Map<String, int>> snapshot) {
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return Container(
                                height: 50,
                                child: Center(child: Text('랭킹: 집계 중...')));
                          }else if (snapshot.hasError) {
                            return Text('랭킹: 오류 발생');
                          }else{

                           return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${snapshot.data?['rank']}',
                                    style: TextStyle(
                                      color: Color(0xFF3D83ED),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 14),
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(() => FriendDetailPage(uid: _userModelController.uid));
                                    },
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      child: _userModelController.profileImageUrl!.isNotEmpty
                                          ? ExtendedImage.network(
                                        _userModelController.profileImageUrl!,
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
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_userModelController.displayName}',
                                        style: TextStyle(
                                          color: Color(0xFF111111),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 2,),
                                      Text('${_liveCrewModelController.crewName}',
                                        style: TextStyle(
                                            color: Color(0xFF666666),
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal
                                        ),
                                      )
                                    ],
                                  ),
                                  Expanded(child: SizedBox()),
                                  Row(
                                    children: [
                                      Text(
                                        '${myScore}점',
                                        style: TextStyle(
                                          color: Color(0xFF111111),
                                          fontWeight: FontWeight.normal,
                                          fontSize: 18,
                                        ),
                                      ),
                                      StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('Ranking')
                                              .doc('${_seasonController.currentSeason}')
                                              .collection('${_userModelController.favoriteResort}')
                                              .where('uid', isEqualTo: _userModelController.uid )
                                              .snapshots(),
                                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                            if (!snapshot.hasData || snapshot.data == null) {}
                                            else if (snapshot.data!.docs.isNotEmpty) {
                                              final rankingDocs = snapshot.data!.docs;
                                              for(var rankingTier in rankingTierList)
                                                if(rankingDocs[0]['tier'] == rankingTier.tierName)
                                                  return Transform.translate(
                                                    offset: Offset(6, 2),
                                                    child: ExtendedImage.asset(
                                                      rankingTier.badgeAsset,
                                                      enableMemoryCache: true,
                                                      fit: BoxFit.cover,
                                                      width: 52,
                                                    ),
                                                  );
                                            }
                                            else if (snapshot.connectionState == ConnectionState.waiting) {}
                                            return Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          })
                                    ],
                                  ),
                                ],
                              ),
                            );}
                      }
                    );
                      },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}