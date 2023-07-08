import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/LiveCrew/CreateOnboarding/v_FirstPage_createCrew.dart';
import 'package:snowlive3/screens/LiveCrew/v_crewDetailPage_screen.dart';
import 'package:snowlive3/screens/LiveCrew/v_searchCrewPage.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';
import 'package:snowlive3/screens/v_MainHome.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
import '../../../controller/vm_userModelController.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../controller/vm_liveCrewModelController.dart';
import 'invitation/v_invitation_Screen_crew.dart';

class LiveCrewHome extends StatefulWidget {
  const LiveCrewHome({Key? key}) : super(key: key);

  @override
  State<LiveCrewHome> createState() => _LiveCrewHomeState();
}

class _LiveCrewHomeState extends State<LiveCrewHome> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  //TODO: Dependency Injection**************************************************



  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
        floatingActionButton: Transform.translate(
          offset: Offset(12, -4),
          child: SizedBox(
            width: 112,
            height: 52,
            child: FloatingActionButton.extended(
              onPressed: () async{
                CustomFullScreenDialog.showDialog();
                await _userModelController.getCurrentUser(_userModelController.uid);
                if(_userModelController.liveCrew!.isEmpty || _userModelController.liveCrew =='') {
                  CustomFullScreenDialog.cancelDialog();
                  Get.to(()=>FirstPage_createCrew());
                } else{
                  CustomFullScreenDialog.cancelDialog();
                  Get.dialog(AlertDialog(
                    contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    content: Text('이미 활동중인 크루가 있습니다.',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                    actions: [
                      Row(
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('확인',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF949494),
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                        ],
                        mainAxisAlignment: MainAxisAlignment.end,
                      )
                    ],
                  ));
                }

              },
              icon: Icon(Icons.add),
              label: Text('만들기', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis),),
              backgroundColor: Color(0xFF3D6FED),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: IconButton(
              onPressed: (){
                Get.to(()=>InvitationScreen_crew());
              },
              icon: Image.asset(
                'assets/imgs/icons/icon_settings.png',
                scale: 4,
                width: 26,
                height: 26,
              ),
            ),
          )
        ],
        backgroundColor: Colors.white,
        leading: GestureDetector(
          child: Image.asset(
            'assets/imgs/icons/icon_snowLive_back.png',
            scale: 4,
            width: 26,
            height: 26,
          ),
          onTap: () async{
            await Get.offAll(()=>MainHome(uid: _userModelController.uid));
          },
        ),
        elevation: 0.0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          '라이브 크루',
          style: TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child:
        Column(
          children: [
            SizedBox(
              height: _statusBarSize + 58,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => SearchCrewPage());
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Color(0xFFEFEFEF),
                  ),
                  height: 50,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Color(0xFF666666),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Text(
                            '라이브크루 검색',
                            style:
                            TextStyle(fontSize: 15, color: Color(0xFF666666)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
              child: Column(
                children: [
                  Container(
                    height: 215,
                    width: _size.width,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('liveCrew')
                          .where('memberUidList', arrayContains: _userModelController.uid!)
                          .snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
                        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text('가입한 크루가 없습니다'),
                          );
                        } else {
                          final crewDoc = snapshot.data!.docs.first;
                          return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('user')
                                .where('isOnLive', isEqualTo: true)
                                .snapshots(),
                            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> userSnapshot){
                              if (!userSnapshot.hasData || userSnapshot.data == null) {
                                return Center(
                                  child: Text('유저 정보를 불러오는데 실패했습니다'),
                                );
                              } else {
                                int liveUserCount = 0;
                                userSnapshot.data!.docs.forEach((userDoc) {
                                  if ((crewDoc['memberUidList'] as List).contains(userDoc['uid'])) {
                                    liveUserCount += 1;
                                  }
                                });
                                return GestureDetector(
                                  onTap: () async {
                                    CustomFullScreenDialog.showDialog();
                                    await _liveCrewModelController.getCurrnetCrew(crewDoc['crewID']);
                                    CustomFullScreenDialog.cancelDialog();
                                    Get.to(()=>CrewDetailPage_screen());
                                  },
                                  child: Container(
                                    height: 215,
                                    width: _size.width,
                                    decoration: BoxDecoration(
                                      color: Color(crewDoc['crewColor']),
                                      borderRadius: BorderRadius.circular(14)
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 16, right: 16),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  height: 98,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.only(right: 40),
                                                        child: Text(crewDoc['crewName'],
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          color: Color(0xFFFFFFFF),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 22
                                                        ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Text('LiveOn/전체(명)',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Color(0xFFD7BCF9)
                                                      ),
                                                      ),
                                                      RichText(
                                                        text: TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: '$liveUserCount',
                                                              style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 28),
                                                            ),
                                                            TextSpan(
                                                              text: ' / ',
                                                              style: TextStyle(fontSize: 16, color: Colors.black, height: 0.5)
                                                            ),
                                                            TextSpan(
                                                              text: '${(crewDoc['memberUidList'] as List).length}',
                                                              style: TextStyle(color: Colors.black54, fontSize: 28),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              (crewDoc['profileImageUrl'].isNotEmpty)
                                                  ? GestureDetector(
                                                onTap: () {
                                                  Get.to(() => ProfileImagePage(
                                                      CommentProfileUrl: crewDoc['profileImageUrl']));
                                                },
                                                child: Container(
                                                    width: 96,
                                                    height: 96,
                                                    child: ExtendedImage.network(
                                                      crewDoc['profileImageUrl'],
                                                      enableMemoryCache: true,
                                                      shape: BoxShape.rectangle,
                                                      borderRadius: BorderRadius.circular(16),
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                    )),
                                              )
                                                  : GestureDetector(
                                                onTap: () {
                                                  Get.to(() => ProfileImagePage(
                                                      CommentProfileUrl: ''));
                                                },
                                                child: Container(
                                                  width: 96,
                                                  height: 96,
                                                  child: ExtendedImage.asset(
                                                    'assets/imgs/profile/img_profile_default_.png',
                                                    enableMemoryCache: true,
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.circular(16),
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 30,),
                                          Container(
                                            width: _size.width,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF772ED3),
                                                borderRadius: BorderRadius.circular(8)),
                                              child: Padding(
                                                padding: const EdgeInsets.all(13.0),
                                                child: Row(
                                                  children: [
                                                    ExtendedImage.asset(
                                                      'assets/imgs/icons/icon_notice.png',
                                                      enableMemoryCache: true,
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                                    SizedBox(width: 10,),
                                                    Text(crewDoc['notice'],
                                                    style: TextStyle(
                                                      color: Colors.white
                                                    ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ],
                                                ),
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }
                      },
                    ),
                  )

                ],
              ),
            ),
            SizedBox(height: 30,),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_userModelController.resortNickname } 베이스 크루',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      ElevatedButton(
                        onPressed: (){},
                        child: Text('전체 리스트',
                          style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Color(0xFFF2F3F4),
                            padding: EdgeInsets.symmetric(horizontal: 10)),
                      ),
                    ],
                  ),
                  Container(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('liveCrew')
                            .where('baseResort', isEqualTo: _userModelController.favoriteResort!)
                            .snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return Center(
                              child: Text('가입한 크루가 없습니다'),
                            );
                          } else if (snapshot.data!.docs.isNotEmpty) {
                            final crewDocs = snapshot.data!.docs;
                            return Column(
                              children: crewDocs.map((doc) => GestureDetector(
                                onTap: () async {
                                  CustomFullScreenDialog.showDialog();
                                  await _liveCrewModelController.getCurrnetCrew(doc['crewID']);
                                  CustomFullScreenDialog.cancelDialog();
                                  Get.to(()=>CrewDetailPage_screen());
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Container(
                                    height: 70,
                                    width: _size.width,
                                    child: Row(
                                      children: [
                                        (doc['profileImageUrl'].isNotEmpty)
                                            ? GestureDetector(
                                          onTap: () {
                                            Get.to(() => ProfileImagePage(
                                                CommentProfileUrl: doc['profileImageUrl']));
                                          },
                                          child: Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                  color: Color(doc['crewColor']),
                                                  borderRadius: BorderRadius.circular(8)
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: ExtendedImage.network(
                                                  doc['profileImageUrl'],
                                                  enableMemoryCache: true,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(8),
                                                  fit: BoxFit.cover,
                                                ),
                                              )),
                                        )
                                            : GestureDetector(
                                          onTap: () {
                                            Get.to(() => ProfileImagePage(
                                                CommentProfileUrl: ''));
                                          },
                                          child: Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: Color(doc['crewColor']),
                                              borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: ExtendedImage.asset(
                                                'assets/imgs/profile/img_profile_default_.png',
                                                enableMemoryCache: true,
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.circular(8),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15,),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(doc['crewName'],
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFF111111)
                                            ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            Text('${doc['crewLeader']} / ${(doc['memberUidList'] as List).length}명',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFF949494)
                                            ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )).toList(),
                            );
                          }
                          else if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Center(
                            child: Text('가입한 크루가 없습니다'),
                          );
                        }
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_userModelController.resortNickname } 크루 랭킹 TOP3',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (){},
                    child: Text('전체 랭킹',
                      style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFFF2F3F4),
                        padding: EdgeInsets.symmetric(horizontal: 10)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('liveCrew')
                      .where('baseResort', isEqualTo: _userModelController.favoriteResort!)
                      .orderBy('totalScore', descending: true)
                      .limit(3)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Center(
                        child: Text('가입한 크루가 없습니다'),
                      );
                    } else if (snapshot.data!.docs.isNotEmpty) {
                      final crewDocs = snapshot.data!.docs;
                      return  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(crewDocs[0]['crewColor']),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            height: 154,
                            width: 107,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                (crewDocs[0]['profileImageUrl'].isNotEmpty)
                                    ? GestureDetector(
                                  onTap: () {
                                    Get.to(() => ProfileImagePage(
                                        CommentProfileUrl: crewDocs[0]['profileImageUrl']));
                                  },
                                  child: Container(
                                      width: 60,
                                      height: 60,
                                      child: ExtendedImage.network(
                                        crewDocs[0]['profileImageUrl'],
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(10),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )),
                                )
                                    : GestureDetector(
                                  onTap: () {
                                    Get.to(() => ProfileImagePage(
                                        CommentProfileUrl: ''));
                                  },
                                  child: ExtendedImage.asset(
                                    'assets/imgs/profile/img_profile_default_.png',
                                    enableMemoryCache: true,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 10,),
                                ExtendedImage.asset(
                                  'assets/imgs/icons/icon_crown_1.png',
                                  enableMemoryCache: true,
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(crewDocs[0]['crewName'],
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                  ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(crewDocs[1]['crewColor']),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            height: 154,
                            width: 107,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                (crewDocs[1]['profileImageUrl'].isNotEmpty)
                                    ? GestureDetector(
                                  onTap: () {
                                    Get.to(() => ProfileImagePage(
                                        CommentProfileUrl: crewDocs[1]['profileImageUrl']));
                                  },
                                  child: Container(
                                      width: 60,
                                      height: 60,
                                      child: ExtendedImage.network(
                                        crewDocs[1]['profileImageUrl'],
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(10),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )),
                                )
                                    : GestureDetector(
                                  onTap: () {
                                    Get.to(() => ProfileImagePage(
                                        CommentProfileUrl: ''));
                                  },
                                  child: ExtendedImage.asset(
                                    'assets/imgs/profile/img_profile_default_.png',
                                    enableMemoryCache: true,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 10,),
                                ExtendedImage.asset(
                                  'assets/imgs/icons/icon_crown_2.png',
                                  enableMemoryCache: true,
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(crewDocs[1]['crewName'],
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(crewDocs[2]['crewColor']),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            height: 154,
                            width: 107,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                (crewDocs[2]['profileImageUrl'].isNotEmpty)
                                    ? GestureDetector(
                                  onTap: () {
                                    Get.to(() => ProfileImagePage(
                                        CommentProfileUrl: crewDocs[2]['profileImageUrl']));
                                  },
                                  child: Container(
                                      width: 60,
                                      height: 60,
                                      child: ExtendedImage.network(
                                        crewDocs[2]['profileImageUrl'],
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(10),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )),
                                )
                                    : GestureDetector(
                                  onTap: () {
                                    Get.to(() => ProfileImagePage(
                                        CommentProfileUrl: ''));
                                  },
                                  child: ExtendedImage.asset(
                                    'assets/imgs/profile/img_profile_default_.png',
                                    enableMemoryCache: true,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 10,),
                                ExtendedImage.asset(
                                  'assets/imgs/icons/icon_crown_3.png',
                                  enableMemoryCache: true,
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(crewDocs[2]['crewName'],
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    else if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Center(
                      child: Text('가입한 크루가 없습니다'),
                    );
                  }
              ),
            ),

          ],
        ),
      )
    );
  }
}

// SpeedDial buildSpeedDial1() {
//   return SpeedDial(
//     animatedIcon: AnimatedIcons.menu_close,
//     children: [
//       SpeedDialChild(
//           child: Icon(Icons.add),
//           label: '만들기',
//           onTap: () async{
//             CustomFullScreenDialog.showDialog();
//             await _userModelController.getCurrentUser(_userModelController.uid);
//             if(_userModelController.liveCrew!.isEmpty) {
//               Get.to(FirstPage_createCrew());
//             } else{
//               Get.dialog(AlertDialog(
//                 contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//                 buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
//                 content: Text('이미 활동중인 크루가 있습니다.',
//                   style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15),
//                 ),
//                 actions: [
//                   Row(
//                     children: [
//                       TextButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                             Get.back();
//                           },
//                           child: Text('확인',
//                             style: TextStyle(
//                               fontSize: 15,
//                               color: Color(0xFF949494),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )),
//                     ],
//                     mainAxisAlignment: MainAxisAlignment.end,
//                   )
//                 ],
//               ));
//             }
//           },
//       ),
//       SpeedDialChild(
//           child: Icon(Icons.add),
//           label: '가입하기',
//           onTap: () {
//
//           }
//       ),
//     ],
//   );
// }
//
// SpeedDial buildSpeedDial2() {
//   return SpeedDial(
//     animatedIcon: AnimatedIcons.menu_close,
//     children: [
//       SpeedDialChild(
//           child: Icon(Icons.add),
//           label: '가입하기',
//           onTap: () {
//
//           }
//       ),
//     ],
//   );
// }