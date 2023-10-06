import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/screens/LiveCrew/CreateOnboarding/v_FirstPage_createCrew.dart';
import 'package:com.snowlive/screens/LiveCrew/v_crewDetailPage_screen.dart';
import 'package:com.snowlive/screens/LiveCrew/v_searchCrewPage.dart';
import 'package:com.snowlive/screens/v_MainHome.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import '../../../../controller/vm_userModelController.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../../controller/vm_liveCrewModelController.dart';
import '../../more/friend/v_friendDetailPage.dart';
import '../invitation/v_invitation_Screen_crew.dart';

class Setting_delegation extends StatefulWidget {
  const Setting_delegation({Key? key}) : super(key: key);

  @override
  State<Setting_delegation> createState() => _Setting_delegationState();
}

class _Setting_delegationState extends State<Setting_delegation> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
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
          '크루장 위임',
          style: TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: _statusBarSize + 94,
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('user')
                    .where('liveCrew', isEqualTo: _liveCrewModelController.crewID)
                    .snapshots(),
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
          ),
          SafeArea(
            child: Positioned(
              bottom: 0,
              child: Container(
                width: _size.width,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text('크루장을 위임할 멤버를 선택해주세요.',
                      style: TextStyle(
                          color: Color(0xFF949494),
                          fontSize: 13
                      ),),
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
