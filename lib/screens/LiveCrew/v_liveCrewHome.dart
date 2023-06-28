import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/LiveCrew/CreateOnboarding/v_FirstPage_createCrew.dart';
import 'package:snowlive3/screens/LiveCrew/v_crewDetailPage.dart';
import 'package:snowlive3/screens/LiveCrew/v_searchCrewPage.dart';
import 'package:snowlive3/screens/more/friend/v_invitation_Screen.dart';
import 'package:snowlive3/screens/more/friend/v_setting_friendList.dart';
import 'package:snowlive3/screens/v_MainHome.dart';
import '../../../controller/vm_userModelController.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class LiveCrewHome extends StatefulWidget {
  const LiveCrewHome({Key? key}) : super(key: key);

  @override
  State<LiveCrewHome> createState() => _LiveCrewHomeState();
}

class _LiveCrewHomeState extends State<LiveCrewHome> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  //TODO: Dependency Injection**************************************************

  SpeedDial buildSpeedDial1() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      children: [
        SpeedDialChild(
            child: Icon(Icons.add),
            label: '만들기',
            onTap: (){
              Get.to(FirstPage_createCrew());
            },
        ),
        SpeedDialChild(
            child: Icon(Icons.add),
            label: '가입하기',
            onTap: () {

            }
        ),
      ],
    );
  }

  SpeedDial buildSpeedDial2() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      children: [
        SpeedDialChild(
            child: Icon(Icons.add),
            label: '가입하기',
            onTap: () {

            }
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      floatingActionButton: Transform.translate(
        offset: Offset(12, -4),
        child: SizedBox(
          width: 52,
          height: 52,
          child:
          (_userModelController.myCrew!.isEmpty || _userModelController.myCrew == '')
          ? buildSpeedDial1()
              : buildSpeedDial2()
      ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
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
                        IconButton(
                          onPressed: (){
                            Get.to(InvitationScreen());
                          },
                          icon: Image.asset(
                            'assets/imgs/icons/icon_noti_off.png',
                            scale: 4,
                            width: 26,
                            height: 26,
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
                return IconButton(
                  onPressed: (){
                    Get.to(InvitationScreen());
                  },
                  icon: Image.asset(
                    'assets/imgs/icons/icon_noti_off.png',
                    scale: 4,
                    width: 26,
                    height: 26,
                  ),
                );
              }),
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: IconButton(
              onPressed: (){
                Get.to(Setting_friendList());
              },
              icon: Image.asset(
                'assets/imgs/icons/icon_settings.png',
                scale: 4,
                width: 26,
                height: 26,
              ),
            ),
          )
        ],
        leading: GestureDetector(
          child: Image.asset(
            'assets/imgs/icons/icon_snowLive_back.png',
            scale: 4,
            width: 26,
            height: 26,
          ),
          onTap: () async{
            await Get.offAll(()=>MainHome(uid: _userModelController.uid));
          },
        ),
        elevation: 0.0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          '라이브 크루',
          style: TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child:
        Column(
          children: [
            SizedBox(
              height: _statusBarSize + 58,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => SearchCrewPage());
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Color(0xFFEFEFEF),
                  ),
                  height: 50,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Color(0xFF666666),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Text(
                            '라이브 크루 검색',
                            style:
                            TextStyle(fontSize: 15, color: Color(0xFF666666)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
                padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('가입한 크루'),
                  SizedBox(height: 20,),
                  Container(
                    height: 100,
                    width: _size.width,
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('liveCrew')
                            .where('memberUidList', arrayContains: _userModelController.uid!)
                            .snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
                          if (!snapshot.hasData || snapshot.data == null) {
                            return Center(
                              child: Text('가입한 크루가 없습니다'),
                            );
                          } else if (snapshot.data!.docs.isNotEmpty) {
                            final crewDocs = snapshot.data!.docs;
                            return  ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: crewDocs.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () async {
                                    Get.to(()=>CrewDetailPage(crewID: crewDocs[index]['crewID']));
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      color: Color(crewDocs[index]['crewColor']),
                                      child: Text(crewDocs[index]['crewName']),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          else if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Center(
                            child: Text('가입한 크루가 없습니다'),
                          );
                        }
                    ),
                  )
                ],
              ),
            ),

          ],
        ),
      )
    );
  }
}
