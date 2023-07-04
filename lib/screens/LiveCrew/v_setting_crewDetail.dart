import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/screens/LiveCrew/v_liveCrewHome.dart';
import 'package:snowlive3/screens/LiveCrew/v_setting_delegation.dart';
import 'package:snowlive3/screens/more/friend/v_friendDetailPage.dart';
import 'package:snowlive3/screens/v_MainHome.dart';
import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';
import '../comments/v_profileImageScreen.dart';

class Setting_crewDetail extends StatelessWidget {
  Setting_crewDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: Dependency Injection**************************************************
    LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
    UserModelController _userModelController = Get.find<UserModelController>();
    //TODO: Dependency Injection**************************************************
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [

          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .where('applyCrewList', arrayContains: _liveCrewModelController.crewID)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {}
                else if (snapshot.data!.docs.isNotEmpty) {
                  final applyDocs = snapshot.data!.docs;
                  return Column(
                    children: [
                      Text('가입 신청 리스트'),
                      Container(
                        height: 180,
                        child: ListView.builder(
                        padding: EdgeInsets.only(left: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: applyDocs.length,
                            itemBuilder: (BuildContext context, int index) {
                          return Container(
                            width: 150,
                            color: Color(0xFFEEEEF5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                (applyDocs[index]['profileImageUrl'].isNotEmpty)
                                    ? GestureDetector(
                                  onTap: () {
                                    Get.to(() => FriendDetailPage(uid: applyDocs[index]['uid']));
                                  },
                                  child: Container(
                                      width: 50,
                                      height: 50,
                                      child: ExtendedImage.network(
                                        applyDocs[index]['profileImageUrl'],
                                        enableMemoryCache: true,
                                        shape: BoxShape.circle,
                                        borderRadius: BorderRadius.circular(8),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )),
                                )
                                    : GestureDetector(
                                  onTap: () {
                                    Get.to(() => FriendDetailPage(uid: applyDocs[index]['uid']));
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    child: ExtendedImage.asset(
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
                                Text('${applyDocs[index]['displayName']}'),
                                Text('베이스 : ${applyDocs[index]['resortNickname']}'),
                                Container(
                                  width: 134,
                                  child: Row(
                                    children: [
                                      ElevatedButton(
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
                                                                      color: Colors.white,
                                                                      fontSize: 15,
                                                                      fontWeight: FontWeight.bold),
                                                                ),
                                                                style: TextButton.styleFrom(
                                                                    splashFactory: InkRipple
                                                                        .splashFactory,
                                                                    elevation: 0,
                                                                    minimumSize: Size(100, 56),
                                                                    backgroundColor: Color(0xff555555),
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
                                                                    if(applyDocs[index]['liveCrew'] == null || _userModelController.liveCrew == ''){
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
                                                                                          0xff377EEA),
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
                                                                    backgroundColor: Color(0xff2C97FB),
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
                                        }, child: Text('수락', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFFFFFFF)),),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF3D83ED),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8)),
                                        ),),
                                      SizedBox(width: 6,),
                                      ElevatedButton(
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
                                                                      color: Colors.white,
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
                                                                    Color(0xff555555),
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
                                                                    splashFactory: InkRipple
                                                                        .splashFactory,
                                                                    elevation: 0,
                                                                    minimumSize:
                                                                    Size(100, 56),
                                                                    backgroundColor:
                                                                    Color(0xff2C97FB),
                                                                    padding:
                                                                    EdgeInsets.symmetric(
                                                                        horizontal: 0)),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                        }, child: Text('거절', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF949494)),),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFFFFFFF),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8)),
                                            side: BorderSide(
                                                color: Color(0xFFDEDEDE)
                                            )
                                        ),),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          );
                            }
                        ),
                      ),
                    ],
                  );
                }
                else if (snapshot.connectionState == ConnectionState.waiting) {}
                return Container();
              }

          ),
          Container(
            height: 50,
            child: ListView(
              children: [
                (_liveCrewModelController.leaderUid == _userModelController.uid)
                ? ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {
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
                                    '라이브 크루를 삭제하시겠습니까?',
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
                                                color: Colors.white,
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
                                              Color(0xff555555),
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
                                            if(_liveCrewModelController.memberUidList!.length == 1) {
                                              try {
                                                Navigator.pop(context);
                                                CustomFullScreenDialog.showDialog();
                                                await _liveCrewModelController
                                                    .deleteCrew(crewID: _liveCrewModelController.crewID);
                                                CustomFullScreenDialog.cancelDialog();
                                                Get.to(() => MainHome(uid: _userModelController.uid));
                                              } catch (e) {
                                                print('삭제 오류');
                                                Navigator.pop(context);
                                              }
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
                                                  '모든 회원을 내보낸 뒤에 삭제할 수 있습니다.',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 15),
                                                ),
                                                actions: [
                                                  Row(
                                                    children: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                            '확인',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: Color(
                                                                  0xFF949494),
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          )),
                                                    ],
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                  )
                                                ],
                                              ));

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
                                              splashFactory: InkRipple
                                                  .splashFactory,
                                              elevation: 0,
                                              minimumSize:
                                              Size(100, 56),
                                              backgroundColor:
                                              Color(0xff2C97FB),
                                              padding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 0)),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  title: Text(
                    '크루 삭제',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF111111)),
                  ),
                  trailing: Image.asset(
                    'assets/imgs/icons/icon_arrow_g.png',
                    height: 24,
                    width: 24,
                  ),
                )
                : ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {
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
                                    '라이브 크루를 탈퇴하시겠습니까?',
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
                                                color: Colors.white,
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
                                              Color(0xff555555),
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
                                              await _liveCrewModelController.deleteCrewMember(crewID: _liveCrewModelController.crewID, memberUid: _userModelController.uid);
                                              CustomFullScreenDialog.cancelDialog();
                                              Get.to(()=>MainHome(uid: _userModelController.uid));
                                            }catch(e){
                                              print('삭제 오류');
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
                                              splashFactory: InkRipple
                                                  .splashFactory,
                                              elevation: 0,
                                              minimumSize:
                                              Size(100, 56),
                                              backgroundColor:
                                              Color(0xff2C97FB),
                                              padding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 0)),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  title: Text(
                    '크루 탈퇴',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF111111)),
                  ),
                  trailing: Image.asset(
                    'assets/imgs/icons/icon_arrow_g.png',
                    height: 24,
                    width: 24,
                  ),
                ),
              ],
            ),
          ),
          if(_liveCrewModelController.leaderUid == _userModelController.uid)
          Container(
            height: 200,
            child: ListView(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            color: Colors.white,
                            height: 200,
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
                                    '리더 권한을 위임하면 되돌릴 수 없으며,\n위임하는 즉시 적용됩니다.\n계속하시겠습니까?',
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
                                                color: Colors.white,
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
                                              Color(0xff555555),
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
                                            Navigator.pop(context);
                                            Get.to(()=>Setting_delegation());
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
                                              splashFactory: InkRipple
                                                  .splashFactory,
                                              elevation: 0,
                                              minimumSize:
                                              Size(100, 56),
                                              backgroundColor:
                                              Color(0xff2C97FB),
                                              padding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 0)),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  title: Text(
                    '크루 리더 위임',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF111111)),
                  ),
                  trailing: Image.asset(
                    'assets/imgs/icons/icon_arrow_g.png',
                    height: 24,
                    width: 24,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
