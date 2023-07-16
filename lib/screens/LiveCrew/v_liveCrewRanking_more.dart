import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/LiveCrew/v_crewDetailPage_screen.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';


class LiveCrewRankingMoreScreen extends StatefulWidget {
  const LiveCrewRankingMoreScreen({Key? key}) : super(key: key);

  @override
  State<LiveCrewRankingMoreScreen> createState() => _LiveCrewRankingMoreScreen();
}

class _LiveCrewRankingMoreScreen extends State<LiveCrewRankingMoreScreen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
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
        title: Text('전체 랭킹',
          style: TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('liveCrew')
              .orderBy('totalScore', descending: true)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {}
            else if (snapshot.data!.docs.isNotEmpty) {
              final crewDocsTotal = snapshot.data!.docs;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  child: ListView.builder(
                    itemCount: crewDocsTotal.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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
                              '${crewDocsTotal[index].get('totalScore').toString()}점',
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
                ),
              );
            }
            else if (snapshot.connectionState == ConnectionState.waiting) {}
            return Center();
          }),
    );
  }
}
