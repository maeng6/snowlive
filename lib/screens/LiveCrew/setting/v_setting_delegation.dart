import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import '../../../controller/vm_liveCrewModelController.dart';
import '../../../controller/vm_streamController_liveCrew.dart';
import '../../more/friend/v_friendDetailPage.dart';

class Setting_delegation extends StatefulWidget {
  const Setting_delegation({Key? key}) : super(key: key);

  @override
  State<Setting_delegation> createState() => _Setting_delegationState();
}

class _Setting_delegationState extends State<Setting_delegation> {

  //TODO: Dependency Injection**************************************************
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  StreamController_liveCrew _streamController_liveCrew = Get.find<StreamController_liveCrew>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: GestureDetector(
          child: Image.asset(
            'assets/imgs/icons/icon_snowLive_back.png',
            scale: 4,
            width: 26,
            height: 26,
          ),
          onTap: () {
            Get.back();
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          '위임할 크루원 선택',
          style: TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: _statusBarSize + 58,
          ),
          StreamBuilder(
            stream: _streamController_liveCrew.setupStreams_liveCrew_setting_delegation(),
            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Center();
              } else if (snapshot.data!.docs.isNotEmpty) {
                final crewMemberDocs = snapshot.data!.docs;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Transform.translate(
                      offset: Offset(0,-100),
                      child: ListView.builder(
                        itemCount: crewMemberDocs.length,
                        itemBuilder: (BuildContext context, int index) {
                            return (crewMemberDocs[index]['uid'] != _liveCrewModelController.leaderUid)
                              ?Column(
                              children: [
                                Container(
                                  height: 64,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0),
                                    onTap: () async{
                                        Get.dialog(
                                            AlertDialog(
                                          contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                          buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                          content: Text(
                                            '${crewMemberDocs[index]['displayName']}에게\n크루장을 위임하시겠습니까?',
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
                                                      await _liveCrewModelController.crewLeaderDelegation_crewDoc(
                                                          memberUid: crewMemberDocs[index]['uid'],
                                                          memberDisplayName: crewMemberDocs[index]['displayName'],
                                                          crewID: _liveCrewModelController.crewID);
                                                      CustomFullScreenDialog.cancelDialog();
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                      Get.back();
                                                    },
                                                    child: Text(
                                                      '위임',
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
                                    title: Row(
                                      children: [
                                        (crewMemberDocs[index]['profileImageUrl'].isNotEmpty)
                                            ? GestureDetector(
                                          onTap: () async{
                                            Get.to(() => FriendDetailPage(uid:crewMemberDocs[index]['uid'], favoriteResort: crewMemberDocs[index]['favoriteResort'],));
                                          },
                                          child: Container(
                                              width: 50,
                                              height: 50,
                                              child: ExtendedImage.network(
                                                crewMemberDocs[index]['profileImageUrl'],
                                                enableMemoryCache: true,
                                                shape: BoxShape.circle,
                                                borderRadius: BorderRadius.circular(8),
                                                width: 50,
                                                height: 50,
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
                                              )),
                                        )
                                            : GestureDetector(
                                          onTap: () async{
                                            Get.to(() => FriendDetailPage(uid:crewMemberDocs[index]['uid'], favoriteResort: crewMemberDocs[index]['favoriteResort'],));
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
                                        SizedBox(width: 15,),
                                        Text(
                                          crewMemberDocs[index]['displayName'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 16,
                                            color: Color(0xFF111111),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                if (index != crewMemberDocs.length - 1)
                                  Container(
                                    color: Color(0xFFF5F5F5),
                                    height: 1,
                                    width: _size.width -32,
                                  ),
                                SizedBox(
                                  height: 8,
                                )
                              ],
                            )
                            : SizedBox();
                        },
                      ),
                    ),
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Container();
            },
          ),
        ],
      )
    );
  }
}
