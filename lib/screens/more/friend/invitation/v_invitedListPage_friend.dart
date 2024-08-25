import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import '../../../../controller/alarm/vm_alarmCenterController.dart';
import '../../../../controller/user/vm_userModelController.dart';
import '../../../../model_2/m_alarmCenterModel.dart';
import '../v_friendDetailPage.dart';

class InvitedListPage_friend extends StatefulWidget {
  const InvitedListPage_friend({Key? key}) : super(key: key);

  @override
  State<InvitedListPage_friend> createState() => _InvitedListPage_friendState();
}

class _InvitedListPage_friendState extends State<InvitedListPage_friend> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  AlarmCenterController _alarmCenterController = Get.find<AlarmCenterController>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('user')
              .where('whoIinvite', arrayContains: _userModelController.uid!)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              print(_userModelController.uid);
              print('null');
              return Center();
            } else if (snapshot.data!.docs.isNotEmpty) {
              final inviDocs = snapshot.data!.docs;
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 0),
                itemCount: inviDocs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Container(
                        height: 80,
                        child: Center(
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            leading:  (inviDocs[index]['profileImageUrl'].isNotEmpty)
                                ? GestureDetector(
                              onTap: () {
                                Get.to(() =>
                                    FriendDetailPage(uid: inviDocs[index]['uid'],
                                      favoriteResort: inviDocs[index]['favoriteResort'],));
                              },
                              child: Container(
                                width: 56,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                        fit: StackFit.loose,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: Color(0xFFDFECFF),
                                                borderRadius: BorderRadius.circular(50)
                                            ),
                                            alignment: Alignment.centerLeft,
                                            child: ExtendedImage.network(
                                              inviDocs[index]['profileImageUrl'],
                                              enableMemoryCache: true,
                                              shape: BoxShape.circle,
                                              borderRadius: BorderRadius.circular(8),
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              loadStateChanged: (ExtendedImageState state) {
                                                switch (state.extendedImageLoadState) {
                                                  case LoadState.loading:
                                                    return SizedBox.shrink();
                                                  case LoadState.completed:
                                                    return state.completedWidget;
                                                  case LoadState.failed:
                                                    return ExtendedImage.asset(
                                                      'assets/imgs/profile/img_profile_default_circle.png',
                                                      shape: BoxShape.circle,
                                                      borderRadius: BorderRadius.circular(20),
                                                      width: 24,
                                                      height: 24,
                                                      fit: BoxFit.cover,
                                                    ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                  default:
                                                    return null;
                                                }
                                              },
                                            ),
                                          ),
                                        ]),
                                  ],
                                ),
                              ),
                            )
                                : GestureDetector(
                              onTap: () {
                                Get.to(() =>
                                    FriendDetailPage(
                                      uid: inviDocs[index]['uid'],
                                      favoriteResort: inviDocs[index]['favoriteResort'],));
                              },
                              child: Container(
                                width: 56,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Stack(
                                      fit: StackFit.loose,
                                      children: [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: ExtendedImage.asset('assets/imgs/profile/img_profile_default_circle.png',
                                            enableMemoryCache:
                                            true,
                                            shape: BoxShape.circle,
                                            borderRadius:
                                            BorderRadius.circular(8),
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        (inviDocs[index]['isOnLive'] == true)
                                            ? Positioned(
                                          child: Image.asset(
                                            'assets/imgs/icons/icon_badge_live.png',
                                            width: 32,
                                          ),
                                          right: 0,
                                          bottom: 0,
                                        )
                                            : Container()
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            title: Transform.translate(
                              offset: Offset(-20, 0),
                              child: Text(
                                inviDocs[index]['displayName'],
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: Color(0xFF111111),
                                ),
                              ),
                            ),
                            trailing: Container(
                              width: 134,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
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
                                                    '친구로 등록하시겠습니까?',
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
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.showDialog();
                                                              await _userModelController.updateFriend(friendUid:inviDocs[index]['uid']);
                                                              await _userModelController.deleteInvitation(friendUid: inviDocs[index]['uid']);
                                                              await _userModelController.deleteInvitationAlarm_friend(uid:_userModelController.uid);
                                                              await _userModelController.getCurrentUser(_userModelController.uid);
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
                                    minimumSize: Size(58, 32),
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
                                                                await _userModelController.deleteInvitation(friendUid:inviDocs[index]['uid']);
                                                                await _userModelController.deleteInvitationAlarm_friend(uid:_userModelController.uid);
                                                                String? alarmCategory = AlarmCenterModel().alarmCategory[AlarmCenterModel.friendRequestKey];
                                                                await _alarmCenterController.deleteAlarm(
                                                                    receiverUid: _userModelController.uid,
                                                                    senderUid: inviDocs[index]['uid'],
                                                                    category: alarmCategory,
                                                                    alarmCount: 'friend'
                                                                );
                                                                await _userModelController.getCurrentUser(_userModelController.uid);
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
                                        minimumSize: Size(58, 32),
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
                          ),
                        ),
                      ),
                      if (index != inviDocs.length - 1)
                        Container(
                          color: Color(0xFFF5F5F5),
                          height: 1,
                          width: _size.width -32,
                        )
                    ],
                  );
                },
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return Container();
          },
        )

    );
  }
}
