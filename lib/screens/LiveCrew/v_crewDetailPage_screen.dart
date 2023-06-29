import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:snowlive3/screens/LiveCrew/invitation/v_invitation_Screen_crew.dart';
import 'package:snowlive3/screens/LiveCrew/v_crewDetailPage_home.dart';
import 'package:snowlive3/screens/LiveCrew/v_crewDetailPage_member.dart';
import 'package:snowlive3/screens/LiveCrew/v_setting_crewDetail.dart';
import 'package:snowlive3/screens/more/friend/invitation/v_inviteListPage_friend.dart';
import 'package:snowlive3/screens/more/friend/invitation/v_invitedListPage_friend.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

import '../../../controller/vm_userModelController.dart';
import '../../controller/vm_liveCrewModelController.dart';

class CrewDetailPage_screen extends StatefulWidget {
  CrewDetailPage_screen({Key? key,}) : super(key: key);


  @override
  State<CrewDetailPage_screen> createState() => _CrewDetailPage_screenState();
}

class _CrewDetailPage_screenState extends State<CrewDetailPage_screen> {
  int counter = 0;
  List<bool> isTap = [
    true,
    false,
  ];

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  //TODO: Dependency Injection**************************************************

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppBar(
              actions: [
                if(_liveCrewModelController.memberUidList!.contains(_userModelController.uid))
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('user')
                        .where('uid', isEqualTo: _userModelController.uid!)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
                      if (!snapshot.hasData || snapshot.data == null) {}
                      else if (snapshot.data!.docs.isNotEmpty) {
                        final myDocs = snapshot.data!.docs;
                        List whoInviteMe = myDocs[0]['whoInviteMe'];
                        return  Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: IconButton(
                                  onPressed: (){
                                    Get.to(Setting_crewDetail());
                                  },
                                  icon: Image.asset(
                                    'assets/imgs/icons/icon_settings.png',
                                    scale: 4,
                                    width: 26,
                                    height: 26,
                                  ),
                                ),
                              ),
                              Positioned(  // draw a red marble
                                top: 10,
                                left: 32,
                                child: new Icon(Icons.brightness_1, size: 6.0,
                                    color:
                                    (whoInviteMe.length >0)
                                        ?Color(0xFFD32F2F):Colors.white),
                              )
                            ],
                          ),
                        );
                      }
                      else if (snapshot.connectionState == ConnectionState.waiting) {}
                      return Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: IconButton(
                          onPressed: (){
                            Get.to(Setting_crewDetail());
                          },
                          icon: Image.asset(
                            'assets/imgs/icons/icon_settings.png',
                            scale: 4,
                            width: 26,
                            height: 26,
                          ),
                        ),
                      );
                    }),
              ],
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
              iconTheme: IconThemeData(size: 26, color: Colors.black87),
              centerTitle: true,
              titleSpacing: 0,
              title: Text(
                '라이브 크루',
                style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
            )
          ],
        ),
      ),
      body:
      SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 44,
              child: Container(
                width: _size.width,
                height: 1,
                color: Color(0xFFECECEC),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                height: 40,
                                child: ElevatedButton(
                                  child: Text(
                                    '홈',
                                    style: TextStyle(
                                        color: (isTap[0])
                                            ? Color(0xFF111111)
                                            : Color(0xFFc8c8c8),
                                        fontWeight: (isTap[0])
                                            ? FontWeight.bold
                                        : FontWeight.normal,
                                        fontSize: 16),
                                  ),
                                  onPressed: () async{
                                    HapticFeedback.lightImpact();
                                    print('크루 홈으로 전환');
                                    setState(() {
                                      isTap[0] = true;
                                      isTap[1] = false;
                                    });
                                    print('crewID: ${_liveCrewModelController.crewID}');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(top: 0),
                                    minimumSize: Size(40, 10),
                                    backgroundColor: Color(0xFFFFFFFF),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 90,
                              height: 3,
                              color:
                              (isTap[0]) ? Color(0xFF111111) : Colors.transparent,
                            )
                          ],
                        ),
                      ),
                      if(_liveCrewModelController.memberUidList!.contains(_userModelController.uid))
                      Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                height: 40,
                                child: ElevatedButton(
                                  child: Text(
                                    '멤버',
                                    style: TextStyle(
                                        color: (isTap[1])
                                            ? Color(0xFF111111)
                                            : Color(0xFFc8c8c8),
                                        fontWeight:
                                        (isTap[1])
                                            ? FontWeight.bold
                                        : FontWeight.normal,
                                        fontSize: 16),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    print('크루 멤버 목록으로 전환');
                                    setState(() {
                                      isTap[0] = false;
                                      isTap[1] = true;
                                    });
                                    print('crewID: ${_liveCrewModelController.crewID}');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(top: 0),
                                    minimumSize: Size(40, 10),
                                    backgroundColor: Color(0xFFFFFFFF),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 90,
                              height: 3,
                              color:
                              (isTap[1]) ? Color(0xFF111111) : Colors.transparent,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  if(isTap[0]==true)
                    Expanded(child: CrewDetailPage_home()),
                  if(isTap[1]==true)
                    Expanded(child: CrewDetailPage_member()),
                ],
              ),
            ),
          ],
        ),
      )


    );
  }
}

