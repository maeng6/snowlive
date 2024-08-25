import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/liveCrew/vm_liveCrewModelController.dart';
import 'package:com.snowlive/controller/user/vm_userModelController.dart';
import 'package:com.snowlive/screens/LiveCrew/v_crewDetailPage_screen.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';

import '../../controller/liveCrew/vm_streamController_liveCrew.dart';
import '../../model_2/m_crewLogoModel.dart';

class LiveCrewListMoreScreen extends StatefulWidget {
  const LiveCrewListMoreScreen({Key? key}) : super(key: key);

  @override
  State<LiveCrewListMoreScreen> createState() => _LiveCrewListMoreScreenState();
}

class _LiveCrewListMoreScreenState extends State<LiveCrewListMoreScreen> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  StreamController_liveCrew _streamController_liveCrew = Get.find<StreamController_liveCrew>();
  //TODO: Dependency Injection**************************************************

  var assetBases;

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
        stream: _streamController_liveCrew.setupStreams_liveCrew_liveCrewList_more(),
        builder: (
            context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/imgs/icons/icon_nodata.png',
                    scale: 4,
                    width: 73,
                    height: 73,
                  ),
                  SizedBox(height: 6,),
                  Text('해당 스키장에 개설된 크루가 없습니다.',
                    style: TextStyle(
                        color: Color(0xFF949494)
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.data!.docs.isNotEmpty) {
            final crewDocs = snapshot.data!.docs;
            return ListView.builder( // ListView.builder로 변경
              itemCount: crewDocs.length,
              itemBuilder: (context, index) {
                final doc = crewDocs[index];
                for (var crewLogo in crewLogoList) {
                  if (crewLogo.crewColor == doc['crewColor']) {
                    assetBases = crewLogo.crewLogoAsset;
                    break;
                  }
                }

                return Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: ()async{
                      CustomFullScreenDialog.showDialog();
                      await _userModelController.getCurrentUser_crew(_userModelController.uid);
                      await _liveCrewModelController.getCurrrentCrew(doc['crewID']);
                      CustomFullScreenDialog.cancelDialog();
                      Get.to(() => CrewDetailPage_screen());
                    },
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
                                color: Color(0xFFDFECFF),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: ExtendedImage.network(
                                doc['profileImageUrl'],
                                enableMemoryCache: true,
                                cacheHeight: 150,
                                shape: BoxShape.rectangle,
                                borderRadius:
                                BorderRadius.circular(6),
                                fit: BoxFit.cover,
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
                                child: ExtendedImage.network(
                                  assetBases,
                                  enableMemoryCache: true,
                                  cacheHeight: 100,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc['crewName'],
                                    style: TextStyle(
                                        fontSize: 15, color: Color(0xFF111111)),
                                  ),
                                  if (doc['description'].isNotEmpty)
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        doc['description'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 12, color: Color(0xFF949494)),
                                      ),
                                    ),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/imgs/icons/icon_nodata.png',
                  scale: 4,
                  width: 73,
                  height: 73,
                ),
                SizedBox(height: 6,),
                Text('해당 스키장에 개설된 크루가 없습니다.',
                  style: TextStyle(
                      color: Color(0xFF949494)
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
