import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/LiveCrew/v_crewDetailPage_screen.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

class LiveCrewListMoreScreen extends StatefulWidget {
  const LiveCrewListMoreScreen({Key? key}) : super(key: key);

  @override
  State<LiveCrewListMoreScreen> createState() => _LiveCrewListMoreScreenState();
}

class _LiveCrewListMoreScreenState extends State<LiveCrewListMoreScreen> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  LiveCrewModelController _liveCrewModelController =
  Get.find<LiveCrewModelController>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

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
        title: Text(
          '전체 크루 리스트',
          style: TextStyle(
            color: Color(0xFF111111),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('liveCrew')
            .where('baseResort', isEqualTo: _userModelController.favoriteResort!)
            .snapshots(),
        builder: (
            context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
            ) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('가입한 크루가 없습니다'),
            );
          } else if (snapshot.data!.docs.isNotEmpty) {
            final crewDocs = snapshot.data!.docs;
            return ListView.builder( // ListView.builder로 변경
              itemCount: crewDocs.length,
              itemBuilder: (context, index) {
                final doc = crewDocs[index];
                return GestureDetector(
                  onTap: () async {
                    CustomFullScreenDialog.showDialog();
                    await _liveCrewModelController.getCurrnetCrew(doc['crewID']);
                    CustomFullScreenDialog.cancelDialog();
                    Get.to(() => CrewDetailPage_screen());
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
                    child: Container(
                      width: _size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            (doc['profileImageUrl'].isNotEmpty)
                                ? Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Color(doc['crewColor']),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: ExtendedImage.network(
                                  doc['profileImageUrl'],
                                  enableMemoryCache: true,
                                  shape: BoxShape.rectangle,
                                  borderRadius:
                                  BorderRadius.circular(6),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                                : Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Color(doc['crewColor']),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: ExtendedImage.asset(
                                  'assets/imgs/profile/img_profile_default_.png',
                                  enableMemoryCache: true,
                                  shape: BoxShape.rectangle,
                                  borderRadius:
                                  BorderRadius.circular(6),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc['crewName'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF111111),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    '${doc['crewLeader']} / ${(doc['memberUidList'] as List).length}명',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF949494),
                                    ),
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
                  ),
                );
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Center(
            child: Text('가입한 크루가 없습니다'),
          );
        },
      ),
    );
  }
}
