import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/screens/LiveCrew/v_crewDetailPage_screen.dart';
import 'package:snowlive3/screens/LiveCrew/v_liveCrewList_more.dart';
import 'package:snowlive3/screens/LiveCrew/v_searchCrewPage.dart';
import 'package:snowlive3/screens/Ranking/v_Ranking_Crew_All_Screen.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
import '../../../controller/vm_userModelController.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../controller/vm_liveCrewModelController.dart';
import '../../model/m_crewLogoModel.dart';
import '../more/friend/v_friendDetailPage.dart';
import 'CreateOnboarding/v_setCrewName.dart';
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

  var assetMyCrew;
  var assetTop1;
  var assetTop2;
  var assetTop3;
  var assetBases;


  SpeedDial buildSpeedDial1() {
    return SpeedDial(
      backgroundColor: Color(0xFF3D83ED),
      overlayColor: Color(0xFF000000),
      overlayOpacity: 0.5,
      curve: Curves.bounceIn,
      elevation: 4,
      icon: Icons.add,
      children: [
        SpeedDialChild(
          child: Icon(Icons.add),
          label: '만들기',
          backgroundColor: Colors.white,  // 배경 색상 변경
          foregroundColor: Color(0xFF222222),
          // 아이콘 색상 변경
          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF222222), fontSize: 14), // 라벨 스타일 변경
          labelBackgroundColor: Colors.white,
          onTap: () async{
            CustomFullScreenDialog.showDialog();
            await _userModelController.getCurrentUser(_userModelController.uid);
            if(_userModelController.liveCrew!.isEmpty || _userModelController.liveCrew =='') {
              CustomFullScreenDialog.cancelDialog();
              Get.to(()=>SetCrewName());
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
                              color: Color(0xFF222222),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.end,
                  )
                ],
              ));
            }
          },
        ),
        SpeedDialChild(
            child: Icon(Icons.add),
            backgroundColor: Colors.white,  // 배경 색상 변경
            foregroundColor: Color(0xFF222222),
            label: '가입하기',
            labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF222222), fontSize: 14),
            onTap: () {
              Get.to(()=>SearchCrewPage());
            }
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
        floatingActionButton:
        (_userModelController.liveCrew!.isEmpty || _userModelController.liveCrew =='')
            ?  buildSpeedDial1()
        : null,
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
            CustomFullScreenDialog.showDialog();
            await _userModelController.getCurrentUser_crew(_userModelController.uid);
            CustomFullScreenDialog.cancelDialog();
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          '라이브크루',
          style: TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body:
      SingleChildScrollView(
        child: Column(
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
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('liveCrew')
                    .where('crewID', isEqualTo: _userModelController.liveCrew)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {}
                  else if (snapshot.data!.docs.isNotEmpty) {
        final crewDocs = snapshot.data!.docs;
        if(crewDocs[0]['leaderUid'] == _userModelController.uid)
       return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('user')
                .where('applyCrewList', arrayContains: _userModelController.liveCrew)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {}
              else if (snapshot.data!.docs.isNotEmpty) {
                final applyDocs = snapshot.data!.docs;
                return Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 16),
                        child: Center(child: Text('라이브 크루에 새로운 가입신청이 있습니다!', style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF111111),
                          fontWeight: FontWeight.normal
                        ),)),
                      ),
                      Container(
                        height: 188,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: applyDocs.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xFFF1F3F3),
                                ),
                                width: 160,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    (applyDocs[index]['profileImageUrl'].isNotEmpty)
                                        ? GestureDetector(
                                      onTap: () {
                                        Get.to(() => FriendDetailPage(uid: applyDocs[index]['uid'], favoriteResort: applyDocs[index]['favoriteResort'],));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 16, bottom: 10),
                                        child: Container(
                                            width: 58,
                                            height: 58,
                                            child: ExtendedImage.network(
                                              applyDocs[index]['profileImageUrl'],
                                              enableMemoryCache: true,
                                              shape: BoxShape.circle,
                                              borderRadius: BorderRadius.circular(8),
                                              width: 58,
                                              height: 58,
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                    )
                                        : GestureDetector(
                                      onTap: () {
                                        Get.to(() => FriendDetailPage(uid: applyDocs[index]['uid'], favoriteResort: applyDocs[index]['favoriteResort'],));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 16, bottom: 10),
                                        child: Container(
                                          width: 58,
                                          height: 58,
                                          child: ExtendedImage.asset(
                                            'assets/imgs/profile/img_profile_default_circle.png',
                                            enableMemoryCache: true,
                                            shape: BoxShape.circle,
                                            borderRadius: BorderRadius.circular(8),
                                            width: 58,
                                            height: 58,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text('${applyDocs[index]['displayName']}', style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111111),
                                      fontSize: 14
                                    ),),
                                    Text('${applyDocs[index]['resortNickname']}', style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Color(0xFF111111),
                                        fontSize: 14
                                    ),),
                                    Container(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10, bottom: 10, right: 14, left: 14),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: (){
                                                  showModalBottomSheet(
                                                      context: context,
                                                      builder: (context) {
                                                        return Container(
                                                          color: Colors.white,
                                                          height: 180,
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 20.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.start,
                                                              children: [
                                                                SizedBox(
                                                                  height: 30,
                                                                ),
                                                                Text(
                                                                  '요청을 거절하시겠습니까?',
                                                                  style: TextStyle(
                                                                      fontSize: 18,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Color(0xFF111111)),
                                                                ),
                                                                SizedBox(
                                                                  height: 30,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment.spaceEvenly,
                                                                  children: [
                                                                    Expanded(
                                                                      child: ElevatedButton(
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        child: Text(
                                                                          '취소',
                                                                          style: TextStyle(
                                                                              color: Color(0xFF3D83ED),
                                                                              fontSize: 15,
                                                                              fontWeight:
                                                                              FontWeight.bold),
                                                                        ),
                                                                        style: TextButton.styleFrom(
                                                                            splashFactory: InkRipple
                                                                                .splashFactory,
                                                                            elevation: 0,
                                                                            minimumSize:
                                                                            Size(100, 56),
                                                                            backgroundColor:
                                                                            Color(0xff3D83ED).withOpacity(0.2),
                                                                            padding:
                                                                            EdgeInsets.symmetric(
                                                                                horizontal: 0)),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Expanded(
                                                                      child: ElevatedButton(
                                                                        onPressed: () async {
                                                                          try{
                                                                            Navigator.pop(context);
                                                                            CustomFullScreenDialog.showDialog();
                                                                            await _liveCrewModelController.deleteInvitation_crew(crewID: _liveCrewModelController.crewID, applyUid: applyDocs[index]['uid']);
                                                                            await _liveCrewModelController.getCurrnetCrew(_liveCrewModelController.crewID);
                                                                            CustomFullScreenDialog.cancelDialog();
                                                                          }catch(e){
                                                                            Navigator.pop(context);
                                                                          }

                                                                        },
                                                                        child: Text(
                                                                          '확인',
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 15,
                                                                              fontWeight:
                                                                              FontWeight.bold),
                                                                        ),
                                                                        style: TextButton.styleFrom(
                                                                            splashFactory: InkRipple.splashFactory,
                                                                            elevation: 0,
                                                                            minimumSize: Size(100, 56),
                                                                            backgroundColor: Color(0xff3D83ED),
                                                                            padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                }, child: Text('거절', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF3D83ED)),),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Color(0xFF3D83ED).withOpacity(0.2),
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8)),
                                                    side: BorderSide(
                                                        color: Color(0xFFDEDEDE).withOpacity(0)
                                                    )
                                                ),),
                                            ),
                                            SizedBox(width: 8,),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: (){
                                                  showModalBottomSheet(
                                                      context: context,
                                                      builder: (context) {
                                                        return Container(
                                                          color: Colors.white,
                                                          height: 180,
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 20.0),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                SizedBox(
                                                                  height: 30,
                                                                ),
                                                                Text(
                                                                  '크루원으로 등록하시겠습니까?',
                                                                  style: TextStyle(
                                                                      fontSize: 18,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Color(0xFF111111)),
                                                                ),
                                                                SizedBox(
                                                                  height: 30,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment.spaceEvenly,
                                                                  children: [
                                                                    Expanded(
                                                                      child: ElevatedButton(
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        child: Text(
                                                                          '취소',
                                                                          style: TextStyle(
                                                                              color: Color(0xFF3D83ED),
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        style: TextButton.styleFrom(
                                                                            splashFactory: InkRipple
                                                                                .splashFactory,
                                                                            elevation: 0,
                                                                            minimumSize: Size(100, 56),
                                                                            backgroundColor: Color(0xff3D83ED).withOpacity(0.2),
                                                                            padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Expanded(
                                                                      child: ElevatedButton(
                                                                        onPressed: () async {
                                                                          try{
                                                                            if(applyDocs[index]['liveCrew'] == null || applyDocs[index]['liveCrew'] == ''){
                                                                              Navigator.pop(context);
                                                                              CustomFullScreenDialog.showDialog();
                                                                              await _liveCrewModelController.updateCrewMember(applyUid: applyDocs[index]['uid'], crewID: _liveCrewModelController.crewID);
                                                                              await _liveCrewModelController.deleteInvitation_crew(crewID: _liveCrewModelController.crewID, applyUid: applyDocs[index]['uid']);
                                                                              await _liveCrewModelController.getCurrnetCrew(_liveCrewModelController.crewID);
                                                                              CustomFullScreenDialog.cancelDialog();
                                                                            }else{
                                                                              Get.dialog(AlertDialog(
                                                                                contentPadding: EdgeInsets.only(
                                                                                    bottom: 0,
                                                                                    left: 20,
                                                                                    right: 20,
                                                                                    top: 30),
                                                                                elevation: 0,
                                                                                shape: RoundedRectangleBorder(
                                                                                    borderRadius:
                                                                                    BorderRadius.circular(
                                                                                        10.0)),
                                                                                buttonPadding:
                                                                                EdgeInsets.symmetric(
                                                                                    horizontal: 20,
                                                                                    vertical: 0),
                                                                                content: Text(
                                                                                  '이미 다른 크루에 참여중입니다.',
                                                                                  style: TextStyle(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontSize: 15),
                                                                                ),
                                                                                actions: [
                                                                                  Row(
                                                                                    children: [
                                                                                      TextButton(
                                                                                          onPressed: () async {
                                                                                            Navigator.pop(context);
                                                                                            Navigator.pop(context);
                                                                                          },
                                                                                          child: Text(
                                                                                            '확인',
                                                                                            style: TextStyle(
                                                                                              fontSize: 15,
                                                                                              color: Color(
                                                                                                  0xff3D83ED),
                                                                                              fontWeight: FontWeight
                                                                                                  .bold,
                                                                                            ),
                                                                                          )),
                                                                                    ],
                                                                                    mainAxisAlignment: MainAxisAlignment
                                                                                        .center,
                                                                                  )
                                                                                ],
                                                                              ));
                                                                            }
                                                                          }catch(e){
                                                                            Navigator.pop(context);
                                                                          }

                                                                        },
                                                                        child: Text(
                                                                          '확인',
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 15,
                                                                              fontWeight:
                                                                              FontWeight.bold),
                                                                        ),
                                                                        style: TextButton.styleFrom(
                                                                            splashFactory: InkRipple.splashFactory,
                                                                            elevation: 0,
                                                                            minimumSize: Size(100, 56),
                                                                            backgroundColor: Color(0xff3D83ED),
                                                                            padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                }, child: Text('수락', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFffffff)),),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(0xFF3D83ED),
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8)),
                                                ),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                );
              }
              else if (snapshot.connectionState == ConnectionState.waiting) {}
              return Container();
            }

        );
      }
                  else if (snapshot.connectionState == ConnectionState.waiting) {}
                  return Container();
                }
                ),
            SizedBox(
              height: 24,
            ),
            Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
              child: Column(
                children: [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('liveCrew')
                        .where('memberUidList', arrayContains: _userModelController.uid!)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
                      if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
                        return Container(
                          width: _size.width,
                          height: 140,
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFFF1F3F3),
                        ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 93,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('가입된 크루가 없습니다',
                                        style: TextStyle(
                                            color: Color(0xFF777777),
                                            fontSize: 14
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                    Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Color(0xFFDEDEDE)
                                        ),
                                        width: 90,
                                        height: 90,
                                      child: ExtendedImage.asset(
                                        'assets/imgs/profile/img_crew_profile_none.png',
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(7),
                                        width: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                              ],
                            ),
                          ),
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

                              for (var crewLogo in crewLogoList) {
                                if (crewLogo.crewColor == crewDoc['crewColor']) {
                                  assetMyCrew = crewLogo.crewLogoAsset;
                                  break;
                                }
                              }

                              return GestureDetector(
                                onTap: () async {
                                  CustomFullScreenDialog.showDialog();
                                  await _liveCrewModelController.getCurrnetCrew(crewDoc['crewID']);
                                  CustomFullScreenDialog.cancelDialog();
                                  Get.to(()=>CrewDetailPage_screen());
                                },
                                child: Container(
                                  height: crewDoc['notice'] == '' ? 140 : 204,
                                  width: _size.width,
                                  decoration: BoxDecoration(
                                    color: Color(crewDoc['crewColor']),
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 22, right: 22),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              height: 93,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 4),
                                                    child: Text(crewDoc['crewName'],
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      color: Color(0xFFFFFFFF),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 20
                                                    ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 12),
                                                  Row(
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('크루원(명)',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Color(0xFFFFFFFF).withOpacity(0.7)
                                                          ),
                                                          ),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: <TextSpan>[
                                                                TextSpan(
                                                                  text: '${(crewDoc['memberUidList'] as List).length}',
                                                                  style: GoogleFonts.bebasNeue(color: Color(0xFFFFFFFF), fontSize: 28),
                                                                ),],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        width: 28,
                                                      ),
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('라이브ON(명)',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Color(0xFFFFFFFF).withOpacity(0.7)
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: <TextSpan>[
                                                                TextSpan(
                                                                  text: '$liveUserCount',
                                                                  style: GoogleFonts.bebasNeue(color: Color(0xFFFFFFFF), fontSize: 28),
                                                                ),],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),

                                                ],
                                              ),
                                            ),
                                            (crewDoc['profileImageUrl'].isNotEmpty)
                                                ? GestureDetector(
                                              onTap: () {
                                                Get.to(() => ProfileImagePage(
                                                    CommentProfileUrl: crewDoc['profileImageUrl']));
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      spreadRadius: 0,
                                                      blurRadius: 12,
                                                      offset: Offset(0, 2), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                  width: 90,
                                                  height: 90,
                                                  child: ExtendedImage.network(
                                                    crewDoc['profileImageUrl'],
                                                    enableMemoryCache: true,
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.circular(12),
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
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      spreadRadius: 0,
                                                      blurRadius: 12,
                                                      offset: Offset(0, 2), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                width: 90,
                                                height: 90,
                                                child: ExtendedImage.asset(
                                                  assetMyCrew,
                                                  enableMemoryCache: true,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(12),
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if(crewDoc['notice'] != '')
                                        Padding(
                                          padding: const EdgeInsets.only(top: 24),
                                          child: Container(
                                            width: _size.width,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF000000).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8)),
                                              child: Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: Row(
                                                  children: [
                                                    ExtendedImage.asset(
                                                      'assets/imgs/icons/icon_notice.png',
                                                      enableMemoryCache: true,
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                                    SizedBox(width: 10,),
                                                    Expanded(
                                                      child: Text(crewDoc['notice'],
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13
                                                      ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        )
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
                  )

                ],
              ),
            ),
            SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_userModelController.resortNickname } 크루 랭킹 TOP3',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (){
                      Get.to(()=> RankingCrewAllScreen());
                    },
                    child: Text('전체 랭킹',
                      style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFFF2F3F4),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8,),
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/imgs/icons/icon_nodata.png',
                                scale: 4,
                                width: 64,
                                height: 64,
                              ),
                              SizedBox(
                                height: 6,
                              ),Text('개설된 크루가 없습니다.', style: TextStyle(
                                  color: Color(0xFF949494)
                              ),),
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.data!.docs.isNotEmpty) {
                      final crewDocs = snapshot.data!.docs;

                      if (crewDocs.isNotEmpty) {
                        for (var crewLogo in crewLogoList) {
                          if (crewLogo.crewColor == crewDocs[0]['crewColor']) {
                            assetTop1 = crewLogo.crewLogoAsset;
                            break;
                          }
                        }
                      }

                      if (crewDocs.length > 1) {
                        for (var crewLogo in crewLogoList) {
                          if (crewLogo.crewColor == crewDocs[1]['crewColor']) {
                            assetTop2 = crewLogo.crewLogoAsset;
                            break;
                          }
                        }
                      }

                      if (crewDocs.length > 2) {
                        for (var crewLogo in crewLogoList) {
                          if (crewLogo.crewColor == crewDocs[2]['crewColor']) {
                            assetTop3 = crewLogo.crewLogoAsset;
                            break;
                          }
                        }
                      }


                      return  Row(
                        children: [
                          if(crewDocs.length > 0)
                            GestureDetector(
                              onTap:() async{
                                CustomFullScreenDialog.showDialog();
                                await _liveCrewModelController.getCurrnetCrew(crewDocs[0]['crewID']);
                                CustomFullScreenDialog.cancelDialog();
                                Get.to(()=>CrewDetailPage_screen());
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(crewDocs[0]['crewColor']),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                height: 154,
                                width: _size.width / 3 - 12,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    (crewDocs[0]['profileImageUrl'].isNotEmpty)
                                        ? Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              spreadRadius: 0,
                                              blurRadius: 8,
                                              offset: Offset(0, 4), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        width: 58,
                                        height: 58,
                                        child: ExtendedImage.network(
                                          crewDocs[0]['profileImageUrl'],
                                          enableMemoryCache: true,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(7),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ))
                                        : Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            spreadRadius: 0,
                                            blurRadius: 8,
                                            offset: Offset(0, 4), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: ExtendedImage.asset(
                                        assetTop1,
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(7),
                                        width: 58,
                                        height: 58,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(height: 14),
                                    ExtendedImage.asset(
                                      'assets/imgs/icons/icon_crown_1.png',
                                      enableMemoryCache: true,
                                      width: 28,
                                      height: 28,
                                      fit: BoxFit.cover,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(crewDocs[0]['crewName'],
                                        style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          SizedBox(width: 8),
                          if(crewDocs.length > 1)
                            Expanded(
                              child: GestureDetector(
                                onTap:() async{
                                  CustomFullScreenDialog.showDialog();
                                  await _liveCrewModelController.getCurrnetCrew(crewDocs[1]['crewID']);
                                  CustomFullScreenDialog.cancelDialog();
                                  Get.to(()=>CrewDetailPage_screen());
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(crewDocs[1]['crewColor']),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  height: 154,
                                  width: _size.width / 3 - 12,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      (crewDocs[1]['profileImageUrl'].isNotEmpty)
                                          ? Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                spreadRadius: 0,
                                                blurRadius: 8,
                                                offset: Offset(0, 4), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          width: 58,
                                          height: 58,
                                          child: ExtendedImage.network(
                                            crewDocs[1]['profileImageUrl'],
                                            enableMemoryCache: true,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(7),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ))
                                          : Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              spreadRadius: 0,
                                              blurRadius: 8,
                                              offset: Offset(0, 4), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: ExtendedImage.asset(
                                          assetTop2,
                                          enableMemoryCache: true,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(7),
                                          width: 58,
                                          height: 58,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(height: 14),
                                      ExtendedImage.asset(
                                        'assets/imgs/icons/icon_crown_2.png',
                                        enableMemoryCache: true,
                                        width: 28,
                                        height: 28,
                                        fit: BoxFit.cover,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(crewDocs[1]['crewName'],
                                          style: TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13
                                          ),
                                          overflow: TextOverflow.ellipsis,
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
                                onTap:() async{
                                  CustomFullScreenDialog.showDialog();
                                  await _liveCrewModelController.getCurrnetCrew(crewDocs[2]['crewID']);
                                  CustomFullScreenDialog.cancelDialog();
                                  Get.to(()=>CrewDetailPage_screen());
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(crewDocs[2]['crewColor']),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  height: 154,
                                  width: _size.width / 3 - 12,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      (crewDocs[2]['profileImageUrl'].isNotEmpty)
                                          ? Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                spreadRadius: 0,
                                                blurRadius: 8,
                                                offset: Offset(0, 4), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          width: 58,
                                          height: 58,
                                          child: ExtendedImage.network(
                                            crewDocs[2]['profileImageUrl'],
                                            enableMemoryCache: true,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(7),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ))
                                          : Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              spreadRadius: 0,
                                              blurRadius: 8,
                                              offset: Offset(0, 4), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: ExtendedImage.asset(
                                          assetTop3,
                                          enableMemoryCache: true,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(7),
                                          width: 58,
                                          height: 58,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(height: 14),
                                      ExtendedImage.asset(
                                        'assets/imgs/icons/icon_crown_3.png',
                                        enableMemoryCache: true,
                                        width: 28,
                                        height: 28,
                                        fit: BoxFit.cover,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(crewDocs[2]['crewName'],
                                          style: TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/imgs/icons/icon_nodata.png',
                              scale: 4,
                              width: 64,
                              height: 64,
                            ),
                            SizedBox(
                              height: 6,
                            ),Text('개설된 크루가 없습니다.', style: TextStyle(
                                color: Color(0xFF949494)
                            ),),
                          ],
                        ),
                      ),
                    );
                  }
              ),
            ),
            SizedBox(height: 32),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16,bottom: 72),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_userModelController.resortNickname } 베이스 크루',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      ElevatedButton(
                        onPressed: (){
                          Get.to(()=> LiveCrewListMoreScreen());
                        },
                        child: Text('전체 리스트',
                          style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Color(0xFFF2F3F4),
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2)),
                      ),
                    ],
                  ),
                  Container(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('liveCrew')
                            .where('baseResort', isEqualTo: _userModelController.favoriteResort!)
                            .orderBy('resistDate', descending: true)
                            .limit(5)
                            .snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/imgs/icons/icon_nodata.png',
                                      scale: 4,
                                      width: 64,
                                      height: 64,
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),Text('개설된 크루가 없습니다.', style: TextStyle(
                                        color: Color(0xFF949494)
                                    ),),
                                  ],
                                ),
                              ),
                            );
                          } else if (snapshot.data!.docs.isNotEmpty) {
                            final crewDocs = snapshot.data!.docs;

                            return Container(
                              height: crewDocs.length * 64.0,
                              child: Column(
                                children: crewDocs.map((doc) {

                                  for (var crewLogo in crewLogoList) {
                                    if (crewLogo.crewColor == doc['crewColor']) {
                                      assetBases = crewLogo.crewLogoAsset;
                                      break;
                                    }
                                  }

                                  return GestureDetector(
                                    onTap: () async {
                                      CustomFullScreenDialog.showDialog();
                                      await _liveCrewModelController.getCurrnetCrew(doc['crewID']);
                                      CustomFullScreenDialog.cancelDialog();
                                      Get.to(() => CrewDetailPage_screen());
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Container(
                                        height: 64,
                                        width: MediaQuery.of(context).size.width,
                                        child: Row(
                                          children: [
                                            (doc['profileImageUrl'].isNotEmpty)
                                                ? Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: Color(doc['crewColor']),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: ExtendedImage.network(
                                                  doc['profileImageUrl'],
                                                  enableMemoryCache: true,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(6),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            )
                                                : Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: Color(doc['crewColor']),
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
                                            SizedBox(width: 15),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 2),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    doc['crewName'],
                                                    style: TextStyle(fontSize: 15, color: Color(0xFF111111)),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  Text(
                                                    '${doc['crewLeader']} / ${(doc['memberUidList'] as List).length}명',
                                                    style: TextStyle(fontSize: 13, color: Color(0xFF949494)),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );


                          }
                          else if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/imgs/icons/icon_nodata.png',
                                    scale: 4,
                                    width: 64,
                                    height: 64,
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),Text('개설된 크루가 없습니다.', style: TextStyle(
                                      color: Color(0xFF949494)
                                  ),),
                                ],
                              ),
                            ),
                          );
                        }
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}

