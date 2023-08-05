import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/controller/vm_liveMapController.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
import '../../../controller/vm_userModelController.dart';
import '../../model/m_crewLogoModel.dart';
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
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  LiveMapController _liveMapController = Get.find<LiveMapController>();
  //TODO: Dependency Injection**************************************************

  var assetCrew;

  Map? crewRankingMap;

  @override
  Widget build(BuildContext context) {

    final Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          backgroundColor: Color(0xFFFFFFFF),
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

        for (var crewLogo in crewLogoList) {
          if (crewLogo.crewColor == crewDocs[0]['crewColor']) {
            assetCrew = crewLogo.crewLogoAsset;
            break;
          }
        }


        return Container(
        width: _size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
              color: Color(crewDocs[0]['crewColor']),
              padding: EdgeInsets.only(top: 20, bottom: 16),
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
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          spreadRadius: 0,
                                          blurRadius: 16,
                                          offset: Offset(0, 2), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    width: 80,
                                    height: 80,
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
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        spreadRadius: 0,
                                        blurRadius: 16,
                                        offset: Offset(0, 2), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  width: 80,
                                  height: 80,
                                  child: ExtendedImage.asset(
                                    assetCrew,
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
                                padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8), // 텍스트와 테두리 간의 패딩
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xFFFFFFFF).withOpacity(0.5),
                                      width: 0.9), // 테두리 색상과 두께
                                  borderRadius: BorderRadius.circular(30.0), // 테두리 모서리 둥글게
                                ),
                                child: Text(
                                  '${_resortModelController.getResortName(crewDocs[0]['baseResortNickName'])}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFFFFF)
                                  ),
                                ),
                              )

                            ],
                          ),
                          SizedBox(
                            height: 20,
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
                                  SizedBox(
                                    height: 2,
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
                              SizedBox(height: 30,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '크루원(명)',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFFFFFFF).withOpacity(0.7)
                                        ),),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          // StreamBuilder(
                                          //     stream: FirebaseFirestore.instance
                                          //         .collection('liveCrew')
                                          //         .where('crewID', isEqualTo: _liveCrewModelController.crewID)
                                          //         .snapshots(),
                                          //     builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                          //       if (snapshot.connectionState == ConnectionState.waiting) {
                                          //         return Center(
                                          //           child: CircularProgressIndicator(),
                                          //         );
                                          //       } else if (snapshot.hasError) {
                                          //         return Text('Error: ${snapshot.error}');
                                          //       } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                          //         final crewDocs = snapshot.data!.docs;
                                          //         List memberList = crewDocs[0]['memberUidList'];
                                          //         return StreamBuilder(
                                          //           stream: FirebaseFirestore.instance
                                          //               .collection('user')
                                          //               .where('uid', whereIn: memberList)
                                          //               .where('isOnLive', isEqualTo: true)
                                          //               .snapshots(),
                                          //           builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                          //             if (snapshot.connectionState == ConnectionState.waiting) {
                                          //               return Center(
                                          //                 child: CircularProgressIndicator(),
                                          //               );
                                          //             } else if (snapshot.hasError) {
                                          //               return Text('Error: ${snapshot.error}');
                                          //             } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                          //               final liveMembersCount = snapshot.data!.docs.length;
                                          //               return  Text('$liveMembersCount',
                                          //                 style: GoogleFonts.bebasNeue(
                                          //                     color: Color(0xFFFFFFFF),
                                          //                     fontSize: 28
                                          //                 ),
                                          //               );
                                          //             } else {
                                          //               return Text('0',
                                          //                 style: GoogleFonts.bebasNeue(
                                          //                     color: Color(0xFFFFFFFF),
                                          //                     fontSize: 28
                                          //                 ),
                                          //               );
                                          //             }
                                          //           },
                                          //         );
                                          //       }
                                          //       return Container();
                                          //     }
                                          // ),
                                          // SizedBox(width: 4),
                                          // Padding(
                                          //   padding: const EdgeInsets.only(bottom: 4),
                                          //   child: Text('/',
                                          //   style: GoogleFonts.bebasNeue(
                                          //     fontSize: 16,
                                          //     color: Color(0xFFFFFFFF),
                                          //     fontWeight: FontWeight.bold
                                          //   ),
                                          //   ),
                                          // ),
                                          // SizedBox(width: 2),
                                          Text('${memberUidList.length}',
                                          style: GoogleFonts.bebasNeue(
                                            color: Color(0xFFFFFFFF),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '크루랭킹',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFFFFFFF).withOpacity(0.7)
                                        ),),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('liveCrew')
                                            .orderBy('totalScore', descending: true)
                                            .snapshots(),
                                        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          } else if (snapshot.hasError) {
                                            return Text('Error: ${snapshot.error}');
                                          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {

                                            final crewDocs = snapshot.data!.docs;
                                            crewRankingMap =  _liveMapController.calculateRankCrewAll2(crewDocs: crewDocs);

                                            return Row(
                                              children: [
                                                Text('${crewRankingMap!['${_liveCrewModelController.crewID}']}',
                                                  style: GoogleFonts.bebasNeue(
                                                      color: Color(0xFFFFFFFF),
                                                      fontSize: 28
                                                  ),
                                                ),
                                                // SizedBox(width: 3,),
                                                // Text('/',
                                                //   style: GoogleFonts.bebasNeue(
                                                //       fontSize: 16,
                                                //       color: Color(0xFFFFFFFF),
                                                //       fontWeight: FontWeight.bold
                                                //   ),
                                                // ),
                                                // Text('${crewDocs.length}',
                                                //   style: GoogleFonts.bebasNeue(
                                                //       color: Color(0xFFFFFFFF),
                                                //       fontSize: 28
                                                //   ),
                                                // ),
                                              ],
                                            );
                                          } else {
                                            return Text('-',
                                              style: TextStyle(
                                                  color: Color(0xFFFFFFFF),
                                                  fontSize: 28
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '창단일',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFFFFFFF).withOpacity(0.7)
                                        ),),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '$year',
                                            style: GoogleFonts.bebasNeue(
                                                color: Color(0xFFFFFFFF),
                                                fontSize: 28
                                            ),),
                                          SizedBox(width: 4,),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Text('/',
                                              style: GoogleFonts.bebasNeue(
                                                  fontSize: 16,
                                                  color: Color(0xFFFFFFFF),
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 4,),
                                          Text(
                                            '$month',
                                            style: GoogleFonts.bebasNeue(
                                                color: Color(0xFFFFFFFF),
                                                fontSize: 28
                                            ),),
                                          SizedBox(width: 4,),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Text('/',
                                              style: GoogleFonts.bebasNeue(
                                                  fontSize: 16,
                                                  color: Color(0xFFFFFFFF),
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 4,),
                                          Text(
                                            '$day',
                                            style: GoogleFonts.bebasNeue(
                                                color: Color(0xFFFFFFFF),
                                                fontSize: 28
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


              Container(
                color: Color(0xFFF1F3F3),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    if(memberUidList.contains(_userModelController.uid) && crewDocs[0]['notice'] != '')
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: Container(
                          width: _size.width,
                          decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF000000).withOpacity(0.1), // 그림자의 색상
                                  blurRadius: 12, // 그림자의 흐릿한 정도
                                  offset: Offset(0, 2), // 그림자의 위치
                                ),
                              ]
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
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
                                  SizedBox(height: 5),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Container(
                          width: _size.width,
                          decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF000000).withOpacity(0.1), // 그림자의 색상
                                  blurRadius: 12, // 그림자의 흐릿한 정도
                                  offset: Offset(0, 2), // 그림자의 위치
                                ),
                              ]
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
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
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          '크루 소개가 없습니다',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF949494)
                                          ),),
                                      ),
                                    ),
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
                    SizedBox(height: 12,),
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
                                  color: Color(0xFF000000).withOpacity(0.1), // 그림자의 색상
                                  blurRadius: 6, // 그림자의 흐릿한 정도
                                  offset: Offset(0, 2), // 그림자의 위치
                                ),
                              ]
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 24),
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
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                          final crewDocs = snapshot.data!.docs;
                                          List memberList = crewDocs[0]['memberUidList'];
                                          return StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('Ranking')
                                                .doc('${_seasonController.currentSeason}')
                                                .collection('${_liveCrewModelController.baseResort}')
                                                .where('uid', whereIn: memberList)
                                                .orderBy('totalScore', descending: true)
                                                .limit(3)
                                                .snapshots(),
                                            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return Center(
                                                  child: CircularProgressIndicator(),
                                                );
                                              } else if (snapshot.hasError) {
                                                return Text('Error: ${snapshot.error}');
                                              } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                                final memberScoreDocs = snapshot.data!.docs;
                                                int? memberlength;
                                                if(memberScoreDocs.length<3){
                                                  memberlength = memberScoreDocs.length;
                                                } else {
                                                  memberlength = 3;
                                                }
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    if(memberlength>0)
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            SizedBox(height: 10,),
                                                            Container(
                                                                height: 132,
                                                                child:  StreamBuilder(
                                                                    stream: FirebaseFirestore.instance
                                                                        .collection('user')
                                                                        .where('uid', isEqualTo: memberScoreDocs[0]['uid'])
                                                                        .snapshots(),
                                                                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                                        return Center(
                                                                          child: CircularProgressIndicator(),
                                                                        );
                                                                      } else if (snapshot.hasError) {
                                                                        return Text('Error: ${snapshot.error}');
                                                                      } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                                                        final memberUserDocs = snapshot.data!.docs;
                                                                        return Container(
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            children: [
                                                                              (memberUserDocs[0]['profileImageUrl'].isNotEmpty)
                                                                                  ? GestureDetector(
                                                                                onTap: () {
                                                                                  Get.to(() => FriendDetailPage(uid: memberUserDocs[0]['uid'], favoriteResort: memberUserDocs[0]['favoriteResort'],));
                                                                                },
                                                                                child: Container(
                                                                                    width: 80,
                                                                                    height: 80,
                                                                                    child: ExtendedImage.network(
                                                                                      memberUserDocs[0]['profileImageUrl'],
                                                                                      enableMemoryCache: true,
                                                                                      shape: BoxShape.circle,
                                                                                      borderRadius: BorderRadius.circular(8),
                                                                                      width: 80,
                                                                                      height: 80,
                                                                                      fit: BoxFit.cover,
                                                                                    )),
                                                                              )
                                                                                  : GestureDetector(
                                                                                onTap: () {
                                                                                  Get.to(() => FriendDetailPage(uid: memberUserDocs[0]['uid'], favoriteResort: memberUserDocs[0]['favoriteResort'],));
                                                                                },
                                                                                child: Container(
                                                                                  width: 80,
                                                                                  height: 80,
                                                                                  child: ExtendedImage.asset(
                                                                                    'assets/imgs/profile/img_profile_default_circle.png',
                                                                                    enableMemoryCache: true,
                                                                                    shape: BoxShape.circle,
                                                                                    borderRadius: BorderRadius.circular(8),
                                                                                    width: 80,
                                                                                    height: 80,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                              ),

                                                                              SizedBox(
                                                                                height: 12,
                                                                              ),
                                                                              Text('${memberUserDocs[0]['displayName']}',
                                                                                style: TextStyle(
                                                                                    fontSize: 15,
                                                                                    color: Color(0xFF111111)
                                                                                ),),
                                                                              SizedBox(
                                                                                height: 2,
                                                                              ),
                                                                              // Text('베이스 : ${memberUserDocs[0]['resortNickname']}'),
                                                                              Text('${memberScoreDocs[0]['totalScore']}점',
                                                                                style: TextStyle(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Color(0xFF111111)
                                                                                ),),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }
                                                                      return Container();
                                                                    }
                                                                )
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    if(memberlength>1)
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            SizedBox(height: 10,),
                                                            Container(
                                                                height: 132,
                                                                child:  StreamBuilder(
                                                                    stream: FirebaseFirestore.instance
                                                                        .collection('user')
                                                                        .where('uid', isEqualTo: memberScoreDocs[1]['uid'])
                                                                        .snapshots(),
                                                                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                                        return Center(
                                                                          child: CircularProgressIndicator(),
                                                                        );
                                                                      } else if (snapshot.hasError) {
                                                                        return Text('Error: ${snapshot.error}');
                                                                      } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                                                        final memberUserDocs = snapshot.data!.docs;
                                                                        return Container(
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.only(left: 10, right: 10),
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                (memberUserDocs[0]['profileImageUrl'].isNotEmpty)
                                                                                    ? GestureDetector(
                                                                                  onTap: () {
                                                                                    Get.to(() => FriendDetailPage(uid: memberUserDocs[0]['uid'], favoriteResort: memberUserDocs[0]['favoriteResort'],));
                                                                                  },
                                                                                  child: Container(
                                                                                      width: 80,
                                                                                      height: 80,
                                                                                      child: ExtendedImage.network(
                                                                                        memberUserDocs[0]['profileImageUrl'],
                                                                                        enableMemoryCache: true,
                                                                                        shape: BoxShape.circle,
                                                                                        borderRadius: BorderRadius.circular(8),
                                                                                        width: 80,
                                                                                        height: 80,
                                                                                        fit: BoxFit.cover,
                                                                                      )),
                                                                                )
                                                                                    : GestureDetector(
                                                                                  onTap: () {
                                                                                    Get.to(() => FriendDetailPage(uid: memberUserDocs[0]['uid'], favoriteResort: memberUserDocs[0]['favoriteResort'],));
                                                                                  },
                                                                                  child: Container(
                                                                                    width: 80,
                                                                                    height: 80,
                                                                                    child: ExtendedImage.asset(
                                                                                      'assets/imgs/profile/img_profile_default_circle.png',
                                                                                      enableMemoryCache: true,
                                                                                      shape: BoxShape.circle,
                                                                                      borderRadius: BorderRadius.circular(8),
                                                                                      width: 80,
                                                                                      height: 80,
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 12,
                                                                                ),
                                                                                Text('${memberUserDocs[0]['displayName']}',
                                                                                  style: TextStyle(
                                                                                      fontSize: 15,
                                                                                      color: Color(0xFF111111)
                                                                                  ),),
                                                                                SizedBox(
                                                                                  height: 2,
                                                                                ),
                                                                                // Text('베이스 : ${memberUserDocs[0]['resortNickname']}'),
                                                                                Text('${memberScoreDocs[1]['totalScore']}점',
                                                                                  style: TextStyle(
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Color(0xFF111111)
                                                                                  ),),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }
                                                                      return Container();
                                                                    }
                                                                )
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    if(memberlength>2)
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            SizedBox(height: 10,),
                                                            Container(
                                                                height: 132,
                                                                child:  StreamBuilder(
                                                                    stream: FirebaseFirestore.instance
                                                                        .collection('user')
                                                                        .where('uid', isEqualTo: memberScoreDocs[2]['uid'])
                                                                        .snapshots(),
                                                                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                                        return Center(
                                                                          child: CircularProgressIndicator(),
                                                                        );
                                                                      } else if (snapshot.hasError) {
                                                                        return Text('Error: ${snapshot.error}');
                                                                      } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                                                        final memberUserDocs = snapshot.data!.docs;
                                                                        return Container(
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.only(left: 10, right: 10),
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                (memberUserDocs[0]['profileImageUrl'].isNotEmpty)
                                                                                    ? GestureDetector(
                                                                                  onTap: () {
                                                                                    Get.to(() => FriendDetailPage(uid: memberUserDocs[0]['uid'], favoriteResort: memberUserDocs[0]['favoriteResort'],));
                                                                                  },
                                                                                  child: Container(
                                                                                      width: 80,
                                                                                      height: 80,
                                                                                      child: ExtendedImage.network(
                                                                                        memberUserDocs[0]['profileImageUrl'],
                                                                                        enableMemoryCache: true,
                                                                                        shape: BoxShape.circle,
                                                                                        borderRadius: BorderRadius.circular(8),
                                                                                        width: 80,
                                                                                        height: 80,
                                                                                        fit: BoxFit.cover,
                                                                                      )),
                                                                                )
                                                                                    : GestureDetector(
                                                                                  onTap: () {
                                                                                    Get.to(() => FriendDetailPage(uid: memberUserDocs[0]['uid'], favoriteResort: memberUserDocs[0]['favoriteResort'],));
                                                                                  },
                                                                                  child: Container(
                                                                                    width: 80,
                                                                                    height: 80,
                                                                                    child: ExtendedImage.asset(
                                                                                      'assets/imgs/profile/img_profile_default_circle.png',
                                                                                      enableMemoryCache: true,
                                                                                      shape: BoxShape.circle,
                                                                                      borderRadius: BorderRadius.circular(8),
                                                                                      width: 80,
                                                                                      height: 80,
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Text('${memberUserDocs[0]['displayName']}',
                                                                                  style: TextStyle(
                                                                                      fontSize: 15,
                                                                                      color: Color(0xFF111111)
                                                                                  ),),
                                                                                SizedBox(
                                                                                  height: 2,
                                                                                ),
                                                                                // Text('베이스 : ${memberUserDocs[0]['resortNickname']}'),
                                                                                Text('${memberScoreDocs[2]['totalScore']}점',
                                                                                  style: TextStyle(
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Color(0xFF111111)
                                                                                  ),),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }
                                                                      return Container();
                                                                    }
                                                                )
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                  ],
                                                );

                                              } else {
                                                return Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                                                    child: Text(
                                                      '랭킹에 참여중인 크루원이 없습니다',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Color(0xFF949494)
                                                      ),),
                                                  ),
                                                );
                                              }
                                            },
                                          );
                                        }
                                        return Container();
                                      }
                                  ),

                                ],
                              ),
                            ),
                          ),

                        ),
                      ),
                    if(memberUidList.contains(_userModelController.uid))
                    SizedBox(height: 12,),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Container(
                        width: _size.width,
                        decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF000000).withOpacity(0.1), // 그림자의 색상
                                blurRadius: 6, // 그림자의 흐릿한 정도
                                offset: Offset(0, 2), // 그림자의 위치
                              ),
                            ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '라이딩 통계',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF111111),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('liveCrew')
                                      .where('crewID', isEqualTo: _liveCrewModelController.crewID)
                                      .snapshots(),
                                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                    if (!snapshot.hasData || snapshot.data == null) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.data!.docs.isNotEmpty) {
                                      final crewDocs = snapshot.data!.docs;
                                      Map<String, dynamic>? passCountData =
                                      crewDocs[0]['passCountData'] as Map<String, dynamic>?;
                                      if (passCountData == null || passCountData.isEmpty) {
                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 30, bottom: 20),
                                            child: Text(
                                              '슬로프 이용기록이 없습니다',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF949494)
                                              ),),
                                          ),
                                        );
                                      } else {
                                        List<Map<String, dynamic>> barData = _liveMapController.calculateBarDataPassCount(passCountData);
                                        return Container(
                                          margin: EdgeInsets.only(top: 6),
                                          child: Center(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: barData.length < 4 ? 40 : 0),
                                              width: _size.width,
                                              height: 214,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(top: 6),
                                                    child: barData.isEmpty
                                                        ? Center(child: Text('데이터가 없습니다'))
                                                        : SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                          child: Container(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              barData.length < 2
                                                                  ? MainAxisAlignment.center
                                                                  : MainAxisAlignment.spaceBetween,
                                                              children: barData.map((data) {
                                                                String slopeName = data['slopeName'];
                                                                int passCount = data['passCount'];
                                                                double barHeightRatio = data['barHeightRatio'];
                                                                Color barColor = Color(crewDocs[0]['crewColor']);
                                                                return Container(
                                                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                                                  width: barData.length < 5 ? _size.width / 5 - 10 : _size.width / 5 - 28,
                                                                  height: 195,
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      Text(
                                                                        passCount != 0 ? '$passCount' : '',
                                                                        style: TextStyle(
                                                                          fontSize: 13,
                                                                          color: Color(0xFF111111),
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 4),
                                                                      Container(
                                                                        width: 58,
                                                                        height: 140 * barHeightRatio,
                                                                        child: Container(
                                                                          width: 58,
                                                                          height: 140 * barHeightRatio,
                                                                          decoration: BoxDecoration(
                                                                            color: Color(crewDocs[0]['crewColor']),
                                                                            borderRadius: BorderRadius.only(
                                                                              topRight: Radius.circular(4),
                                                                              topLeft: Radius.circular(4),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 10),
                                                                      Text(
                                                                        slopeName,
                                                                        style: TextStyle(fontSize: 12, color: Color(0xFF111111)),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ),
                                                          ),
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );

                                      }
                                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    } else {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 30, bottom: 20),
                                          child: Text(
                                            '슬로프 이용기록이 없습니다',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF949494)
                                            ),),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                      ),
                    ),
                    SizedBox(height: 12,),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Container(
                        width: _size.width,
                        decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF000000).withOpacity(0.1), // 그림자의 색상
                                blurRadius: 6, // 그림자의 흐릿한 정도
                                offset: Offset(0, 2), // 그림자의 위치
                              ),
                            ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 24),
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '시간대별 라이딩 횟수',
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

                                      if (snapshot.hasError) {
                                        return Text("오류가 발생했습니다");
                                      }

                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Lottie.asset('assets/json/loadings_wht_final.json');
                                      }

                                      if (snapshot.data?.docs.first.data()['passCountTimeData'] != null) {
                                        Map<String, dynamic> passCountTimeData = snapshot.data?.docs.first.data()['passCountTimeData'];
                                        bool areAllValuesZero = _liveMapController.areAllSlotValuesZero(passCountTimeData);
                                        if (areAllValuesZero) {
                                          return Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 30, bottom: 20),
                                              child: Text(
                                                '슬로프 이용기록이 없습니다',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF949494)
                                                ),),
                                            ),
                                          );
                                        }
                                      }

                                      Map<String, dynamic>? data = snapshot.data?.docs.first.data();

                                      Map<String, dynamic>? passCountTimeData =
                                      data?['passCountTimeData'] as Map<String, dynamic>?;
                                      List<Map<String, dynamic>> barData = _liveMapController.calculateBarDataSlot(passCountTimeData);

                                      return Container(
                                        height: 210,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                child:
                                                barData.isEmpty ?
                                                Center(child: Text('데이터가 없습니다'))
                                                    : Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: barData.map((data) {
                                                    String slotName = data['slotName'];
                                                    int passCount = data['passCount'];
                                                    double barHeightRatio = data['barHeightRatio'];
                                                    Color barColor = Color(crewDocs[0]['crewColor']).withOpacity(0.4);
                                                    return Container(
                                                      margin: EdgeInsets.symmetric(horizontal: 5),
                                                      width: 25,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            passCount != 0 ? '$passCount' : '',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              color: Color(0xFF111111),
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Container(
                                                            width: 25,
                                                            height: 140 * barHeightRatio,
                                                            child: Container(
                                                              width: 25,
                                                              height: 140 * barHeightRatio,
                                                              decoration: BoxDecoration(
                                                                color: barColor,
                                                                borderRadius: BorderRadius.only(
                                                                  topRight: Radius.circular(4),
                                                                  topLeft: Radius.circular(4),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 3),
                                                            child: Container(
                                                              child: Text(
                                                                _resortModelController.getSlotName(slotName),
                                                                style: TextStyle(fontSize: 12, color: Color(0xFF111111)),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );


                                                  }).toList(),
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),
                                      );
                                    }
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ),
              Container(
                width: _size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
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
                      SizedBox(height: 16),
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

                          if (galleryUrlList.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40, bottom: 10),
                                child: Text(
                                  '이미지가 없습니다',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF949494)
                                  ),),
                              ),
                            );
                          }

                          return GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: galleryUrlList.length > 6 ? 6 : galleryUrlList.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 1, // Horizontal gap
                              mainAxisSpacing: 1, // Vertical gap
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
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
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
                                                      contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10.0)),
                                                      buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
                                                                    color: Color(0xff377EEA),
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                )),
                                                          ],
                                                          mainAxisAlignment: MainAxisAlignment.center,
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
                                  color: Color(crewDocs[0]['crewColor']),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: TextButton.styleFrom(
                                splashFactory: InkRipple.splashFactory,
                                elevation: 0,
                                minimumSize: Size(100, 56),
                                backgroundColor: Color(crewDocs[0]['crewColor']).withOpacity(0.2),
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
                                  '연결된 SNS 계정이 없습니다.',
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
                                              color: Color(0xff377EEA),
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
                            'SNS 바로가기',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                              splashFactory: InkRipple.splashFactory,
                              elevation: 0,
                              minimumSize: Size(100, 56),
                              backgroundColor: Color(crewDocs[0]['crewColor']),
                              padding: EdgeInsets.symmetric(horizontal: 0)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

