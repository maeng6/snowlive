import 'package:com.snowlive/controller/vm_bulletinRoomController.dart';
import 'package:com.snowlive/controller/vm_commentController.dart';
import 'package:com.snowlive/screens/LiveCrew/v_liveCrewHome.dart';
import 'package:com.snowlive/screens/bulletin/Crew/v_bulletin_Crew_List_Detail.dart';
import 'package:com.snowlive/screens/bulletin/Room/v_bulletin_Room_List_Detail.dart';
import 'package:com.snowlive/screens/comments/v_noUserScreen.dart';
import 'package:com.snowlive/screens/comments/v_reply_Screen.dart';
import 'package:com.snowlive/screens/more/friend/v_friendDetailPage.dart';
import 'package:com.snowlive/screens/resort/v_noPageScreen.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:com.snowlive/controller/vm_timeStampController.dart';
import 'package:com.snowlive/screens/more/v_noticeDetailPage.dart';

import '../../controller/vm_alarmCenterController.dart';
import '../../controller/vm_bulletinCrewController.dart';
import '../../controller/vm_userModelController.dart';
import '../more/friend/invitation/v_invitation_Screen_friend.dart';


class AlarmCenter extends StatefulWidget {
  const AlarmCenter({Key? key}) : super(key: key);

  @override
  State<AlarmCenter> createState() => _AlarmCenterState();
}

class _AlarmCenterState extends State<AlarmCenter> {

  bool edit = false;

  //TODO: Dependency Injection**************************************************
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  UserModelController _userModelController = Get.find<UserModelController>();
  BulletinRoomModelController _bulletinRoomModelController = Get.find<BulletinRoomModelController>();
  BulletinCrewModelController _bulletinCrewModelController = Get.find<BulletinCrewModelController>();
  AlarmCenterController _alarmCenterController = Get.find<AlarmCenterController>();
  CommentModelController _commentModelController = Get.find<CommentModelController>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
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
        title: Text('알림',
          style: TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child:
            (edit == false)
            ? GestureDetector(
                onTap: (){
                  setState(() {
                    edit = true;
                  });
                },
                child: Row(
                  children: [
                    Text('편집',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3D83ED)),
                    ),
                  ],
                )
            )
            :Row(
              children: [
                GestureDetector(
                  onTap: (){
                    Get.dialog(AlertDialog(
                      contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      content: Text(
                        '알림메세지를 모두 삭제하시겠습니까?',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      actions: [
                        Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  '취소',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF949494),
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            TextButton(
                                onPressed: () async {
                                  CustomFullScreenDialog.showDialog();
                                  await _alarmCenterController.deleteAlarm_All(receiverUid: _userModelController.uid);
                                  CustomFullScreenDialog.cancelDialog();
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  '확인',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF3D83ED),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ))
                          ],
                          mainAxisAlignment: MainAxisAlignment.end,
                        )
                      ],
                    ));
                  },
                  child: Text('모두 지우기',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3D83ED)),
                  ),
                ),
                SizedBox(width: 14,),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      edit = false;
                    });
                  },
                  child: Text('닫기',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111111)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('alarmCenter')
            .doc('${_userModelController.uid}')
            .collection('alarmCenter')
            .orderBy('timeStamp', descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {

          Size _size = MediaQuery.of(context).size;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
            child: CircularProgressIndicator(),
          );}
          if (snapshot.hasError) {
            return Container(
              color: Colors.white,
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty ) {
            return Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ExtendedImage.asset(
                      'assets/imgs/icons/icon_alarm_nodata.png',
                      enableMemoryCache: true,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(7),
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "새로운 알림이 없어요",
                      style: TextStyle(
                        color: Color(0xFF949494),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final alarmCenterDocs = snapshot.data!.docs;
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ListView.builder(
                itemCount: alarmCenterDocs.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      if (edit == false) {
                        if (alarmCenterDocs[index].get('category') == '친구요청') {
                          Get.to(() => InvitationScreen_friend());
                        }
                        if ( alarmCenterDocs[index].get('category') == '라이브톡'
                            || alarmCenterDocs[index].get('category') == '라이브톡익명') {

                          try {
                            CustomFullScreenDialog.showDialog();
                            await _commentModelController.getCurrentLiveTalk(
                                uid: alarmCenterDocs[index].get('liveTalk_uid'),
                                commentCount: alarmCenterDocs[index].get('liveTalk_commentCount'));
                            CustomFullScreenDialog.cancelDialog();
                            Get.to(() =>
                                ReplyScreen(
                                  replyUid: _commentModelController.uid,
                                  replyCount: _commentModelController.commentCount,
                                  replyImage: _commentModelController.profileImageUrl,
                                  replyDisplayName: _commentModelController.displayName,
                                  replyResortNickname: _commentModelController.resortNickname,
                                  comment: _commentModelController.comment,
                                  commentTime: _commentModelController.timeStamp,
                                  kusbf: _commentModelController.kusbf,
                                  replyLiveTalkImageUrl: _commentModelController.livetalkImageUrl,
                                ));
                          }catch(e){
                            CustomFullScreenDialog.cancelDialog();
                            Get.to(() => NoPageScreen());
                          }
                        }
                        if (alarmCenterDocs[index].get('category') == '크루 가입신청') {
                          Get.to(() => LiveCrewHome());
                        }
                        if (alarmCenterDocs[index].get('category') == '시즌방 게시글') {
                          try {
                            CustomFullScreenDialog.showDialog();
                            await _bulletinRoomModelController.getCurrentBulletinRoom(
                                uid: alarmCenterDocs[index].get('bulletinRoomUid'),
                                bulletinRoomCount: alarmCenterDocs[index].get('bulletinRoomCount')
                            );
                            CustomFullScreenDialog.cancelDialog();
                            Get.to(() => Bulletin_Room_List_Detail());
                          }catch(e){
                            CustomFullScreenDialog.cancelDialog();
                            Get.to(() => NoPageScreen());
                          }
                        }
                        if (alarmCenterDocs[index].get('category') == '단톡방·동호회 글') {
                          try {
                            CustomFullScreenDialog.showDialog();
                            await _bulletinCrewModelController.getCurrentBulletinCrew(
                                uid: alarmCenterDocs[index].get('bulletinCrewUid'),
                                bulletinCrewCount: alarmCenterDocs[index].get('bulletinCrewCount')
                            );
                            CustomFullScreenDialog.cancelDialog();
                            Get.to(() => Bulletin_Crew_List_Detail());
                          }catch(e){
                            CustomFullScreenDialog.cancelDialog();
                            Get.to(() => NoPageScreen());
                          }
                        }
                        if (alarmCenterDocs[index].get('category') == '친구톡') {
                          try {
                            Get.to(() =>
                                FriendDetailPage(
                                    uid: _userModelController.uid,
                                    favoriteResort: _userModelController
                                        .favoriteResort
                                ));
                          }catch(e){
                            Get.to(() => NoUserScreen());
                          }
                        }
                      } else {
                        await _alarmCenterController.deleteAlarm(
                            receiverUid: alarmCenterDocs[index].get('receiverUid'),
                            senderUid: alarmCenterDocs[index].get('senderUid'),
                            category: alarmCenterDocs[index].get('category'),
                            alarmCount: alarmCenterDocs[index].get('alarmCount')
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          if(_userModelController.uid != alarmCenterDocs[index].get('senderUid'))
                            Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if((alarmCenterDocs[index].get('category') == '라이브톡'))
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ExtendedImage.asset(
                                        'assets/imgs/icons/icon_alarm_livetalk.png',
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(7),
                                        width: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                  if((alarmCenterDocs[index].get('category') == '라이브톡익명'))
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ExtendedImage.asset(
                                        'assets/imgs/icons/icon_alarm_livetalk.png',
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(7),
                                        width: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                  if((alarmCenterDocs[index].get('category') == '시즌방 게시글'))
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ExtendedImage.asset(
                                        'assets/imgs/icons/icon_alarm_community.png',
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(7),
                                        width: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                  if((alarmCenterDocs[index].get('category') == '단톡방·동호회 글'))
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ExtendedImage.asset(
                                        'assets/imgs/icons/icon_alarm_community.png',
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(7),
                                        width: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                  if((alarmCenterDocs[index].get('category') == '친구요청'))
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ExtendedImage.asset(
                                        'assets/imgs/icons/icon_alarm_friend.png',
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(7),
                                        width: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                  if((alarmCenterDocs[index].get('category') == '크루 가입신청'))
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ExtendedImage.asset(
                                        'assets/imgs/icons/icon_alarm_crew.png',
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(7),
                                        width: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                  if((alarmCenterDocs[index].get('category') == '친구톡'))
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ExtendedImage.asset(
                                        'assets/imgs/icons/icon_alarm_friend.png',
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(7),
                                        width: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Container(
                                          constraints: BoxConstraints(
                                              maxWidth:
                                              (edit == false)
                                                  ? _size.width - 68
                                                  : _size.width - 98),
                                          child: Text(
                                            alarmCenterDocs[index].get('msg'),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal,
                                                color: Color(0xFF111111)
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      if((alarmCenterDocs[index].get('category') == '라이브톡')
                                          || (alarmCenterDocs[index].get('category') == '라이브톡익명')
                                          || (alarmCenterDocs[index].get('category') == '시즌방 게시글')
                                          || (alarmCenterDocs[index].get('category') == '단톡방·동호회 글')
                                      )
                                      Container(
                                        constraints: BoxConstraints(
                                            maxWidth:
                                            (edit == false)
                                                ? _size.width - 68
                                                : _size.width - 98),
                                        child: Text(
                                          '"${alarmCenterDocs[index].get('originContent')}"',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal,
                                              color: Color(0xFF949494)
                                          ),
                                        ),
                                      ),
                                      if((alarmCenterDocs[index].get('category') == '라이브톡')
                                          || (alarmCenterDocs[index].get('category') == '라이브톡익명')
                                          || (alarmCenterDocs[index].get('category') == '시즌방 게시글')
                                          || (alarmCenterDocs[index].get('category') == '단톡방·동호회 글')
                                      )
                                      SizedBox(
                                        height: 8,
                                      ),
                                      if((alarmCenterDocs[index].get('category') == '라이브톡')
                                          || (alarmCenterDocs[index].get('category') == '라이브톡익명')
                                          || (alarmCenterDocs[index].get('category') == '시즌방 게시글')
                                          || (alarmCenterDocs[index].get('category') == '단톡방·동호회 글')
                                      )
                                        Container(
                                          constraints: BoxConstraints(
                                              maxWidth:
                                              (edit == false)
                                                  ? _size.width - 68
                                                  : _size.width - 98),
                                          child: Text(
                                            '${alarmCenterDocs[index].get('content')}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF111111)
                                            ),
                                          ),
                                        ),
                                      if((alarmCenterDocs[index].get('category') == '라이브톡')
                                          || (alarmCenterDocs[index].get('category') == '라이브톡익명')
                                          || (alarmCenterDocs[index].get('category') == '시즌방 게시글')
                                          || (alarmCenterDocs[index].get('category') == '단톡방·동호회 글')
                                      )
                                      SizedBox(
                                        height: 4,
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(_timeStampController.getAgoTime(
                                          alarmCenterDocs[index].get('timeStamp')),
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFF949494),
                                            fontSize: 13
                                        ),),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              (edit == false)
                                  ? SizedBox.shrink()
                                  : Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: ExtendedImage.asset(
                                    'assets/imgs/icons/icon_profile_delete.png',
                                    scale: 5,
                              width: 20),
                                  ),
                            ],
                          ),
                          if (alarmCenterDocs.length != index + 1)
                            Divider(
                              height: 40,
                              color: Color(0xFFffffff),
                              thickness: 0.5,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
        },
      ),
    );
  }
}
