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

import '../../widget/w_fullScreenDialog.dart';
import '../LiveCrew/v_crewDetailPage_screen.dart';
import '../more/friend/v_friendDetailPage.dart';

class RankingCrewScreen extends StatefulWidget {
  const RankingCrewScreen({Key? key}) : super(key: key);

  @override
  State<RankingCrewScreen> createState() => _RankingCrewScreenState();
}

class _RankingCrewScreenState extends State<RankingCrewScreen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  //TODO: Dependency Injection**************************************************

  int? myCrewRank;


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
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('liveCrew')
                            .orderBy('totalScore', descending: true)
                            .limit(3)
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
                                      'assets/imgs/icons/icon_rankin_crew_nodata.png',
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

                          final crewDocs = snapshot.data!.docs;

                          return Column(
                            children: [
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('상위 TOP 3 크루',
                                      style: TextStyle(
                                          color: Color(0xFF949494),
                                          fontSize: 12
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        if(crewDocs.length > 0)
                                          Expanded(
                                            child: GestureDetector(
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
                                                width: 107,
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
                                                          ),
                                                        )
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
                                                            'assets/imgs/profile/img_profile_default_.png',
                                                            enableMemoryCache: true,
                                                            shape: BoxShape.rectangle,
                                                            borderRadius: BorderRadius.circular(7),
                                                            width: 58,
                                                            height: 58,
                                                            fit: BoxFit.cover,
                                                          ),
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
                                                        crewDocs[0]['crewName'],
                                                        style: TextStyle(
                                                          color: Color(0xFFFFFFFF),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
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
                                                width: 107,
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
                                                          ),
                                                        )
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
                                                            'assets/imgs/profile/img_profile_default_.png',
                                                            enableMemoryCache: true,
                                                            shape: BoxShape.rectangle,
                                                            borderRadius: BorderRadius.circular(7),
                                                            width: 58,
                                                            height: 58,
                                                            fit: BoxFit.cover,
                                                          ),
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
                                                        crewDocs[1]['crewName'],
                                                        style: TextStyle(
                                                          color: Color(0xFFFFFFFF),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
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
                                                width: 107,
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
                                                          ),
                                                        )
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
                                                            'assets/imgs/profile/img_profile_default_.png',
                                                            enableMemoryCache: true,
                                                            shape: BoxShape.rectangle,
                                                            borderRadius: BorderRadius.circular(7),
                                                            width: 58,
                                                            height: 58,
                                                            fit: BoxFit.cover,
                                                          ),
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
                                                        crewDocs[2]['crewName'],
                                                        style: TextStyle(
                                                          color: Color(0xFFFFFFFF),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
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
                                    ),
                                    SizedBox(height: 40,),
                                    Text('전체 크루 랭킹',
                                      style: TextStyle(
                                          color: Color(0xFF111111),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    SizedBox(height: 18),
                                    StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('liveCrew')
                                            .orderBy('totalScore', descending: true)
                                            .snapshots(),
                                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                          if (!snapshot.hasData || snapshot.data == null) {}
                                          else if (snapshot.data!.docs.isNotEmpty) {
                                            final crewDocsTotal = snapshot.data!.docs;
                                            return Container(
                                              height: crewDocsTotal.length * 64,
                                              child: ListView.builder(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: crewDocsTotal.length,
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(bottom: 16),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          '${index + 1}',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 15,
                                                              color: Color(0xFF111111)
                                                          ),
                                                        ),
                                                        SizedBox(width: 14),
                                                        GestureDetector(
                                                          onTap: () async{
                                                            CustomFullScreenDialog.showDialog();
                                                            await _liveCrewModelController.getCurrnetCrew(crewDocsTotal[index]['crewID']);
                                                            CustomFullScreenDialog.cancelDialog();
                                                            Get.to(()=>CrewDetailPage_screen());
                                                          },
                                                          child: Container(
                                                            width: 48,
                                                            height: 48,
                                                            child:
                                                              (crewDocsTotal[index]['profileImageUrl'].isNotEmpty)
                                                                ? Container(
                                                                    width: 46,
                                                                    height: 46,
                                                                    decoration: BoxDecoration(
                                                                        color: Color(crewDocsTotal[index]['crewColor']),
                                                                        borderRadius: BorderRadius.circular(8)
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(2.0),
                                                                      child: ExtendedImage.network(
                                                                        crewDocsTotal[index]['profileImageUrl'],
                                                                        enableMemoryCache: true,
                                                                        shape: BoxShape.rectangle,
                                                                        borderRadius: BorderRadius.circular(6),
                                                                        fit: BoxFit.cover,
                                                                      ),
                                                                    ))
                                                                : Container(
                                                                  width: 46,
                                                                  height: 46,
                                                                  decoration: BoxDecoration(
                                                                      color: Color(crewDocsTotal[index]['crewColor']),
                                                                      borderRadius: BorderRadius.circular(8)
                                                                  ),
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(2.0),
                                                                    child: ExtendedImage.asset(
                                                                      'assets/imgs/profile/img_profile_default_.png',
                                                                      enableMemoryCache: true,
                                                                      shape: BoxShape.rectangle,
                                                                      borderRadius: BorderRadius.circular(6),
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
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
                                                                crewDocsTotal[index]['crewName'],
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    color: Color(0xFF111111)
                                                                ),
                                                              ),
                                                              Text(
                                                                crewDocsTotal[index]['crewLeader'],
                                                                style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: Color(0xFF949494)
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(child: SizedBox()),
                                                        Text(
                                                          crewDocsTotal[index].get('totalScore').toString(),
                                                          style: TextStyle(
                                                            color: Color(0xFF111111),
                                                            fontWeight: FontWeight.normal,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          }
                                          else if (snapshot.connectionState == ConnectionState.waiting) {}
                                          return Center();
                                        }),
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
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child:
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('liveCrew')
                          .orderBy('totalScore', descending: true)
                          .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {}
                        else if (snapshot.data!.docs.isNotEmpty) {
                          final crewDocs_total = snapshot.data!.docs;
                          var myCrew;
                          for (var myCrewDoc in crewDocs_total) {
                            if (myCrewDoc.id == _userModelController.liveCrew) {
                              myCrew = myCrewDoc;
                              break;
                            }
                          }
                          this.myCrewRank = crewDocs_total.indexOf(myCrew) + 1;
                          return  StreamBuilder<QuerySnapshot>(
                            stream:  FirebaseFirestore.instance
                                .collection('liveCrew')
                                .where('crewID', isEqualTo: _userModelController.liveCrew)
                                .snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData || snapshot.data == null) {}
                              else if (snapshot.data!.docs.isNotEmpty) {
                                final myCrewDocs = snapshot.data!.docs;
                                return Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        spreadRadius: 0,
                                        blurRadius: 6,
                                        offset: Offset(0, 0), // changes position of shadow
                                      ),],
                                    color: Color(myCrewDocs[0]['crewColor']),
                                  ),
                                  height: 80,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$myCrewRank',
                                          style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 14),
                                        GestureDetector(
                                          onTap: () async{
                                            CustomFullScreenDialog.showDialog();
                                            await _liveCrewModelController.getCurrnetCrew(myCrewDocs[0]['crewID']);
                                            CustomFullScreenDialog.cancelDialog();
                                            Get.to(()=>CrewDetailPage_screen());
                                          },
                                          child:  (myCrewDocs[0]['profileImageUrl'].isNotEmpty)
                                              ? Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                  color: Color(myCrewDocs[0]['crewColor']),
                                                  borderRadius: BorderRadius.circular(8)
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: ExtendedImage.network(
                                                  myCrewDocs[0]['profileImageUrl'],
                                                  enableMemoryCache: true,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(6),
                                                  fit: BoxFit.cover,
                                                ),
                                              ))
                                              : Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                                color: Color(myCrewDocs[0]['crewColor']),
                                                borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: ExtendedImage.asset(
                                                'assets/imgs/profile/img_profile_default_.png',
                                                enableMemoryCache: true,
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.circular(6),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 14),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 3),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${myCrewDocs[0]['crewName']}',
                                                style: TextStyle(
                                                  color: Color(0xFFFFFFFF),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 2,),
                                              Text(
                                                '${myCrewDocs[0]['crewLeader']}',
                                                style: TextStyle(
                                                  color: Color(0xFFFFFFFF),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(child: SizedBox()),
                                        Text(
                                          '${myCrewDocs[0]['totalScore']}',
                                          style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontWeight: FontWeight.normal,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              else if (snapshot.connectionState == ConnectionState.waiting) {}
                              return Center();
                            },
                          );
                        }
                        else if (snapshot.connectionState == ConnectionState.waiting) {}
                        return Center();





                      })




                ),

            ],
          ),
        ),
      ),
    );
  }
}
