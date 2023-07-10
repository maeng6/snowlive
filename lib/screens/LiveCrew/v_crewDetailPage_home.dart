import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';
import 'package:snowlive3/screens/v_webPage.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../controller/vm_userModelController.dart';
import '../../controller/vm_timeStampController.dart';
import '../more/friend/v_friendDetailPage.dart';

class CrewDetailPage_home extends StatefulWidget {
  CrewDetailPage_home({Key? key, }) : super(key: key);

  @override
  State<CrewDetailPage_home> createState() => _CrewDetailPage_homeState();
}

class _CrewDetailPage_homeState extends State<CrewDetailPage_home> {

  //TODO: Dependency Injection**************************************************
  SeasonController _seasonController = Get.find<SeasonController>();
  UserModelController _userModelController = Get.find<UserModelController>();
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {

    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          backgroundColor: Color(0xFFDEDEDE),
          extendBodyBehindAppBar: true,
          body: StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('liveCrew')
        .where('crewID', isEqualTo: _liveCrewModelController.crewID )
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if (!snapshot.hasData || snapshot.data == null) {}
      else if (snapshot.data!.docs.isNotEmpty) {
        final crewDocs = snapshot.data!.docs;
        final List memberUidList = crewDocs[0]['memberUidList'];

        DateTime date = crewDocs[0]['resistDate'].toDate();
        String year = DateFormat('yy').format(date);
        String month = DateFormat('MM').format(date);
        String day = DateFormat('dd').format(date);

        return Container(
        width: _size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
              color: Color(crewDocs[0]['crewColor']),
              padding: EdgeInsets.only(top: 30, bottom: 16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              (crewDocs[0]['profileImageUrl'].isNotEmpty)
                                  ? GestureDetector(
                                onTap: () {
                                  Get.to(() => ProfileImagePage(
                                      CommentProfileUrl: crewDocs[0]['profileImageUrl']));
                                },
                                child: Container(
                                    width: 96,
                                    height: 96,
                                    child: ExtendedImage.network(
                                      crewDocs[0]['profileImageUrl'],
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
                              Container(
                                padding: EdgeInsets.only(top: 1, bottom: 1, left: 8, right: 8), // 텍스트와 테두리 간의 패딩
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xFFFFFFFF),
                                      width: 0.9), // 테두리 색상과 두께
                                  borderRadius: BorderRadius.circular(30.0), // 테두리 모서리 둥글게
                                ),
                                child: Text(
                                  '${_resortModelController.getResortName(crewDocs[0]['baseResortNickName'])}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFFFFF)
                                  ),
                                ),
                              )

                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${crewDocs[0]['crewName']}',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFFFFFF),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    '${crewDocs[0]['crewLeader']}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFFFFFFF)
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                              SizedBox(height: 40,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '크루원(명)',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFD7BCF9)
                                        ),),
                                      Row(
                                        children: [
                                          Text('1',
                                          style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 28
                                          ),
                                          ),
                                          SizedBox(width: 3,),
                                          Text('/',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF000000),
                                            fontWeight: FontWeight.bold
                                          ),
                                          ),
                                          SizedBox(width: 3,),
                                          Text('${memberUidList.length}',
                                          style: TextStyle(
                                            color: Color(0xFF000000),
                                            fontSize: 28
                                          ),
                                          )
                                        ],
                                      ),
                                      // RichText(
                                      //   text: TextSpan(
                                      //     children: <TextSpan>[
                                      //       TextSpan(
                                      //         text: '1',
                                      //         style: TextStyle(
                                      //             color: Color(0xFFFFFFFF),
                                      //             fontSize: 28),
                                      //       ),
                                      //       TextSpan(
                                      //           text: ' / ',
                                      //           style: TextStyle(fontSize: 16, color: Colors.black,)
                                      //       ),
                                      //       TextSpan(
                                      //         text: '${memberUidList.length}',
                                      //         style: TextStyle(color: Colors.black, fontSize: 28),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '크루랭킹',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFD7BCF9)
                                        ),),
                                      Text(
                                        '1',
                                        style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFFFFFF)
                                        ),),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '창단일',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFD7BCF9)
                                        ),),
                                      Row(
                                        children: [
                                          Text(
                                            '$year',
                                            style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFFFFFF)
                                            ),),
                                          SizedBox(width: 3,),
                                          Text('/',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFFFFFFFF),
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          SizedBox(width: 3,),
                                          Text(
                                            '$month',
                                            style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFFFFFF)
                                            ),),
                                          SizedBox(width: 3,),
                                          Text('/',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFFFFFFFF),
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          SizedBox(width: 3,),
                                          Text(
                                            '$day',
                                            style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFFFFFF)
                                            ),),
                                        ],
                                      ),

                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25,),
              if(memberUidList.contains(_userModelController.uid))
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    width: _size.width,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // 그림자의 색상
                          blurRadius: 2, // 그림자의 흐릿한 정도
                          offset: Offset(1, 0), // 그림자의 위치
                        ),
                      ]
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('공지사항',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF111111),
                              fontWeight: FontWeight.bold
                            ),
                            ),
                            SizedBox(height: 5,),
                            if(crewDocs[0]['notice'] == '')
                            Text(
                                '공지사항이 없습니다',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF111111)
                                ),),
                            Text(
                              '${crewDocs[0]['notice']}',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF111111)
                              ),),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if(!memberUidList.contains(_userModelController.uid))
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Container(
                    width: _size.width,
                    decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // 그림자의 색상
                            blurRadius: 2, // 그림자의 흐릿한 정도
                            offset: Offset(1, 0), // 그림자의 위치
                          ),
                        ]
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('크루소개',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF111111),
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            SizedBox(height: 5,),
                            if(crewDocs[0]['description'] == '')
                              Text(
                                '크루소개가 없습니다',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF111111)
                                ),),
                            Text(
                              '${crewDocs[0]['description']}',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF111111)
                              ),),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if(memberUidList.contains(_userModelController.uid))
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Container(
                    width: _size.width,
                    decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // 그림자의 색상
                            blurRadius: 2, // 그림자의 흐릿한 정도
                            offset: Offset(1, 0), // 그림자의 위치
                          ),
                        ]
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '크루원 랭킹 TOP 3',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF111111),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('liveCrew')
                                    .where('crewID', isEqualTo: _liveCrewModelController.crewID)
                                    .snapshots(),
                                builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                  if (!snapshot.hasData || snapshot.data == null) {}
                                  else if (snapshot.data!.docs.isNotEmpty) {
                                    final crewDocs = snapshot.data!.docs;
                                    List memberList = crewDocs[0]['memberUidList'];
                                    return StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('Ranking')
                                        .doc('${_seasonController.currentSeason}')
                                        .collection('${_liveCrewModelController.baseResort}')
                                        .where('uid', whereIn: memberList)
                                        .orderBy('totalScore', descending: false)
                                        .snapshots(),
                                        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                          if (!snapshot.hasData || snapshot.data == null) {}
                                          else if (snapshot.data!.docs.isNotEmpty) {
                                            final memberScoreDocs = snapshot.data!.docs;
                                            int? memberlength;
                                            if(memberScoreDocs.length<3){
                                              memberlength = memberScoreDocs.length;
                                            }else{
                                              memberlength = 3;
                                            }
                                            return Padding(
                                              padding: EdgeInsets.only(left: 16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 180,
                                                    child: ListView.builder(
                                                        scrollDirection: Axis.horizontal,
                                                        itemCount: memberlength,
                                                        itemBuilder: (BuildContext context, int index) {
                                                          return StreamBuilder(
                                                              stream: FirebaseFirestore.instance
                                                                  .collection('user')
                                                                  .where('uid', isEqualTo: memberScoreDocs[index]['uid'])
                                                                  .snapshots(),
                                                              builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                                                if (!snapshot.hasData || snapshot.data == null) {
                                                                } else if (snapshot.data!.docs.isNotEmpty) {
                                                                  final memberUserDocs = snapshot.data!.docs;
                                                                  return Container(
                                                                    width: 150,
                                                                    color: Color(0xFFEEEEF5),
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        (memberUserDocs[0]['profileImageUrl'].isNotEmpty)
                                                                            ? GestureDetector(
                                                                          onTap: () {
                                                                            Get.to(() => FriendDetailPage(uid: memberUserDocs[0]['uid']));
                                                                          },
                                                                          child: Container(
                                                                              width: 50,
                                                                              height: 50,
                                                                              child: ExtendedImage.network(
                                                                                memberUserDocs[0]['profileImageUrl'],
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
                                                                            Get.to(() => FriendDetailPage(uid: memberUserDocs[0]['uid']));
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
                                                                        Text('${memberUserDocs[0]['displayName']}'),
                                                                        Text('베이스 : ${memberUserDocs[0]['resortNickname']}'),
                                                                        Text('점수 : ${memberScoreDocs[index]['totalScore']}'),
                                                                      ],
                                                                    ),
                                                                  );
                                                                } else if (snapshot.connectionState == ConnectionState.waiting) {
                                                                }return Center(
                                                                  child: CircularProgressIndicator(),
                                                                );
                                                              });
                                                        }
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          else if (snapshot.connectionState == ConnectionState.waiting) {}
                                          return Text('랭킹에 참여중인 크루원이 없습니다.');
                                    });
                                  }
                                  else if (snapshot.connectionState == ConnectionState.waiting) {}
                                  return Container();
                                }
                            ),
                          ],
                        ),
                      ),
                    ),

                  ),
                ),
              SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Container(
                  width: _size.width,
                  decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // 그림자의 색상
                          blurRadius: 2, // 그림자의 흐릿한 정도
                          offset: Offset(1, 0), // 그림자의 위치
                        ),
                      ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '슬로프별 라이딩 통계',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF111111),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text('슬로프별 라이딩 통계 넣어야함')
                        ],
                      ),
                    ),
                  ),

                ),
              ),
              SizedBox(height: 15,),
              Container(
                width: _size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '크루 갤러리',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF111111),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('liveCrew')
                            .where('crewID', isEqualTo: _liveCrewModelController.crewID)
                            .snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('이미지 로드 실패');
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          List<String> galleryUrlList = [];
                          snapshot.data!.docs.forEach((doc) {
                            galleryUrlList.addAll(List<String>.from(doc['galleryUrlList']));
                          });

                          return GridView.builder(
                            shrinkWrap: true,
                            itemCount: galleryUrlList.length > 6 ? 6 : galleryUrlList.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 5, // Horizontal gap
                              mainAxisSpacing: 5, // Vertical gap
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              String imageUrl = galleryUrlList.reversed.toList()[index];
                              return ExtendedImage.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                cache: true,
                                loadStateChanged: (ExtendedImageState state) {
                                  switch (state.extendedImageLoadState) {
                                    case LoadState.loading:
                                      return Center(child: CircularProgressIndicator());
                                    case LoadState.completed:
                                      return null;
                                    case LoadState.failed:
                                      return Icon(Icons.error);
                                    default:
                                      return null;
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),


              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: [
                    if(memberUidList.contains(_userModelController.uid) == false)
                    Expanded(
                      child:
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: ElevatedButton(
                          onPressed:
                              () {
                            if(_userModelController.liveCrew!.isEmpty || _userModelController.liveCrew == ''){
                              Get.dialog(AlertDialog(
                                contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                content: Text(
                                  '가입신청을 하시겠습니까?',
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
                                            if(_userModelController.applyCrewList!.contains(_liveCrewModelController.crewID)){
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
                                                      '이미 요청중입니다.',
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
                                                } else{
                                                CustomFullScreenDialog.showDialog();
                                                await _liveCrewModelController.updateInvitation_crew(crewID: _liveCrewModelController.crewID);
                                                await _liveCrewModelController.updateInvitationAlarm_crew(leaderUid: _liveCrewModelController.leaderUid);
                                                await _userModelController.getCurrentUser(_userModelController.uid);
                                                CustomFullScreenDialog.cancelDialog();
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                                }
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
                            }else{
                              Get.dialog(AlertDialog(
                                contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                content: Text('라이브 크루는 1개만 가입할 수 있습니다.',
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
                                            Get.back();
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
                          child: Text(
                            '가입하기',
                            style: TextStyle(
                                color: Color(0xff772ED3),
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                              splashFactory: InkRipple.splashFactory,
                              elevation: 0,
                              minimumSize: Size(100, 56),
                              backgroundColor: Color(0xffE8D7FF),
                              padding: EdgeInsets.symmetric(horizontal: 0)),
                        ),
                      ),
                    ),
                    Expanded(
                      child:
                      ElevatedButton(
                        onPressed:
                            () {
                          if(_liveCrewModelController.sns!.isNotEmpty && _liveCrewModelController.sns != '' ) {
                          _liveCrewModelController.otherShare(contents: '${_liveCrewModelController.sns}');
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
                                '연결된 카카오 오픈채팅이 없습니다.',
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
                            },
                        child: Text(
                          '카카오 오픈채팅',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                            splashFactory: InkRipple.splashFactory,
                            elevation: 0,
                            minimumSize: Size(100, 56),
                            backgroundColor: Color(0xff772ED3),
                            padding: EdgeInsets.symmetric(horizontal: 0)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      );
      }
      else if (snapshot.connectionState == ConnectionState.waiting) {}
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    ),
        )
      );
  }
}



// if (!snapshot.hasData || snapshot.data == null) {}
// else if (snapshot.data!.docs.isNotEmpty) {
// Column(
// children: [
//
// ],
// );
// }
// else if (snapshot.connectionState == ConnectionState.waiting) {}
// return Center(
// child: CircularProgressIndicator(),
// );

