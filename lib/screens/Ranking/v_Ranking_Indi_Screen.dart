import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/model/m_slopeScoreModel.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';

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
  //TODO: Dependency Injection**************************************************


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    _liveCrewModelController.getCurrnetCrew(_userModelController.liveCrew);

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(

            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
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
                            return Text("데이터가 없습니다");
                          }

                          final documents = snapshot.data!.docs;

                          return Column(
                            children: [
                              Container(
                                height: _size.height,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('상위 TOP 3 유저',
                                      style: TextStyle(
                                          color: Color(0xFF949494),
                                          fontSize: 12
                                      ),
                                    ),
                                    SizedBox(height: 15,),
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
                                              return Expanded(
                                                child: GestureDetector(
                                                  onTap: (){
                                                    Get.to(() => FriendDetailPage(uid: userDoc[0]['uid']));
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFCBE0FF),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    height: 154,
                                                    width: 107,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        (userDoc[0]['profileImageUrl'].isNotEmpty)
                                                            ? Container(
                                                              width: 60,
                                                              height: 60,
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
                                                              width: 60,
                                                              height: 60,
                                                              fit: BoxFit.cover,
                                                            ),
                                                        SizedBox(height: 10,),
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
                                                              fontSize: 12,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
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
                                        SizedBox(width: 11,),
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
                                              return Expanded(
                                                child: GestureDetector(
                                                  onTap: (){
                                                    Get.to(() => FriendDetailPage(uid: userDoc[0]['uid']));
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFCBE0FF),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    height: 154,
                                                    width: 107,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        (userDoc[0]['profileImageUrl'].isNotEmpty)
                                                            ? Container(
                                                              width: 60,
                                                              height: 60,
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
                                                              width: 60,
                                                              height: 60,
                                                              fit: BoxFit.cover,
                                                            ),
                                                        SizedBox(height: 10,),
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
                                                              fontSize: 12,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
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
                                        SizedBox(width: 11,),
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
                                              return Expanded(
                                                child: GestureDetector(
                                                  onTap: (){
                                                    Get.to(() => FriendDetailPage(uid: userDoc[0]['uid']));
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFCBE0FF),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    height: 154,
                                                    width: 107,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        (userDoc[0]['profileImageUrl'].isNotEmpty)
                                                            ? Container(
                                                              width: 60,
                                                              height: 60,
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
                                                              width: 60,
                                                              height: 60,
                                                              fit: BoxFit.cover,
                                                            ),
                                                        SizedBox(height: 10,),
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
                                                              fontSize: 12,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
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
                                    SizedBox(height: 30,),
                                    Text('전체 개인 랭킹',
                                      style: TextStyle(
                                          color: Color(0xFF111111),
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Expanded(
                                      child: Container(
                                        width: _size.width,
                                        child: ListView.separated(
                                          separatorBuilder: (context, index) => Divider(
                                            height: 30,
                                            color: Colors.grey,
                                          ),
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

                                                return Row(
                                                  children: [
                                                    Text(
                                                      '${index + 1}',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18,
                                                          color: Color(0xFF000000)
                                                      ),
                                                    ),
                                                    SizedBox(width: 20),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Get.to(() => FriendDetailPage(uid: userData['uid']));
                                                      },
                                                      child: Container(
                                                        width: 50,
                                                        height: 50,
                                                        child: userData['profileImageUrl'].isNotEmpty
                                                            ? ExtendedImage.network(
                                                          userData['profileImageUrl'],
                                                          enableMemoryCache: true,
                                                          shape: BoxShape.circle,
                                                          borderRadius: BorderRadius.circular(8),
                                                          width: 50,
                                                          height: 50,
                                                          fit: BoxFit.cover,
                                                        )
                                                            : ExtendedImage.asset(
                                                          'assets/imgs/profile/img_profile_default_circle.png',
                                                          enableMemoryCache: true,
                                                          shape: BoxShape.circle,
                                                          borderRadius: BorderRadius.circular(8),
                                                          width: 50,
                                                          height: 50,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 16),
                                                    Column(
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
                                                                  fontSize: 13,
                                                                  color: Color(0xFF949494)
                                                              ),
                                                            );
                                                          },
                                                        ),

                                                      ],
                                                    ),
                                                    Expanded(child: SizedBox()),
                                                    Text(
                                                      document.get('totalScore').toString(),
                                                      style: TextStyle(
                                                        color: Color(0xFF111111),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),

                                                  ],
                                                );

                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    )

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
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  color: Color(0xFFCBE0FF),
                  child: StreamBuilder<QuerySnapshot>(
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
                        return CircularProgressIndicator();
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text("데이터가 없습니다");
                      }

                      final documents = snapshot.data!.docs;

                      // 내 UID와 일치하는 데이터 찾기
                      var myData;
                      for (var doc in documents) {
                        if (doc.id == _userModelController.uid) {
                          myData = doc;
                          break;
                        }
                      }

                      if (myData == null) {
                        return Text("내 데이터를 찾을 수 없습니다");
                      }

                      // 내 순위 찾기
                      int myRank = documents.indexOf(myData) + 1;

                      // 내 정보 가져오기
                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('user')
                            .doc(_userModelController.uid)
                            .snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                          if (userSnapshot.hasError) {
                            return Text("오류가 발생했습니다");
                          }

                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                            return Text("데이터가 없습니다");
                          }

                          var userData = userSnapshot.data!.data() as Map<String, dynamic>?;

                          int myScore = myData['totalScore'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  '$myRank',
                                  style: TextStyle(
                                    color: Color(0xFF3D83ED),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => FriendDetailPage(uid: myData['uid']));
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    child: _userModelController.profileImageUrl!.isNotEmpty
                                        ? ExtendedImage.network(
                                      _userModelController.profileImageUrl!,
                                      enableMemoryCache: true,
                                      shape: BoxShape.circle,
                                      borderRadius: BorderRadius.circular(8),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                        : ExtendedImage.asset(
                                      'assets/imgs/profile/img_profile_default_circle.png',
                                      enableMemoryCache: true,
                                      shape: BoxShape.circle,
                                      borderRadius: BorderRadius.circular(8),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${userData!['displayName']}',
                                      style: TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('${_liveCrewModelController.crewName}',
                                    style: TextStyle(
                                      color: Color(0xFF949494)
                                    ),
                                    )
                                  ],
                                ),
                                Expanded(child: SizedBox()),
                                Text(
                                  '$myScore',
                                  style: TextStyle(
                                    color: Color(0xFF111111),
                                    fontWeight: FontWeight.bold,
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
              )

            ],
          ),
        ),
      ),
    );
  }
}
