import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/LiveCrew/CreateOnboarding/v_FirstPage_createCrew.dart';
import 'package:snowlive3/screens/LiveCrew/v_crewDetailPage_screen.dart';
import 'package:snowlive3/screens/LiveCrew/v_searchCrewPage.dart';
import 'package:snowlive3/screens/v_MainHome.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
import '../../../controller/vm_userModelController.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../controller/vm_liveCrewModelController.dart';
import '../more/friend/v_friendDetailPage.dart';
import 'invitation/v_invitation_Screen_crew.dart';

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
          '리더 위임',
          style: TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: _statusBarSize + 58,
          ),
          Text('리더를 위임할 멤버를 선택해주세요.',
          style: TextStyle(
            color: Colors.grey
          ),),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('user')
                .where('liveCrew', arrayContains: _liveCrewModelController.crewID)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Center();
              } else if (snapshot.data!.docs.isNotEmpty) {
                final crewMemberDocs = snapshot.data!.docs;
                return Expanded(
                  child: ListView.builder(
                    itemCount: crewMemberDocs.length,
                    itemBuilder: (BuildContext context, int index) {
                      if(crewMemberDocs[index]['uid'] != _userModelController.uid)
                        return Column(
                          children: [
                            Container(
                              height: 64,
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                                onTap: () {},
                                title: Row(
                                  children: [
                                    (crewMemberDocs[index]['profileImageUrl'].isNotEmpty)
                                        ? GestureDetector(
                                      onTap: () async{
                                        Get.to(() => FriendDetailPage(uid:crewMemberDocs[index]['uid']));
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
                                        Get.to(() => FriendDetailPage(uid:crewMemberDocs[index]['uid']));
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
                            if (index != crewMemberDocs.length - 1)
                              Container(
                                color: Color(0xFFF5F5F5),
                                height: 1,
                                width: _size.width -32,
                              ),
                            Divider(
                              thickness: 1,
                            )
                          ],
                        );
                    },
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Container();
            },
          )
        ],
      )
    );
  }
}
