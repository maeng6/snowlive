import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_liveMapController.dart';
import 'package:snowlive3/screens/Ranking/v_RankingScreen.dart';
import 'package:snowlive3/screens/comments/v_liveTalk_Screen.dart';
import 'package:snowlive3/screens/resort/v_resortHome.dart';
import '../controller/vm_noticeController.dart';
import '../controller/vm_userModelController.dart';
import 'fleaMarket/v_fleaMarket_Screen.dart';
import 'more/v_moreTab.dart';

class MainHome extends StatefulWidget {

  MainHome({Key? key,required this.uid}) : super(key: key);
  String? uid;
  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int _currentPage = 0;
  bool? wait;

  PageController _pageController = PageController();

  void _onItemTapped(int index) {
      _pageController.jumpToPage(index);
  }

  void changePage(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    //TODO: Dependency Injection************************************************
    Get.put(NoticeController(), permanent: true);
    Get.put(LiveMapController(), permanent: true);
    NoticeController _noticeController = Get.find<NoticeController>();
    UserModelController _userModelController = Get.find<UserModelController>();
    //TODO: Dependency Injection************************************************

    _noticeController.getIsNewNotice();

    return Obx(()=>Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentPage,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/imgs/icons/icon_home_off.png',
                scale: 4,
              ),
              activeIcon: Image.asset(
                'assets/imgs/icons/icon_home_on.png',
                scale: 4,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [

                  Positioned(
                    top: 3,
                    right: 3,
                    child: Icon(Icons.brightness_1,
                        size: 6.0,
                        color: Colors.white),
                  ),
                  Image.asset(
                    'assets/imgs/icons/icon_market_off.png',
                    scale: 4,
                  ),
                ],
              ),
              activeIcon: Image.asset(
                'assets/imgs/icons/icon_market_on.png',
                scale: 4,
              ),
              label: 'Flea',
            ), //브랜드
            if(_userModelController.favoriteResort == 12)
            BottomNavigationBarItem(
              icon: Stack(
                children: [

                  Positioned(
                    top: 3,
                    right: 3,
                    child: Icon(Icons.brightness_1,
                        size: 6.0,
                        color: Colors.white),
                  ),
                  Image.asset(
                    'assets/imgs/icons/icon_discover_off.png',
                    scale: 4,
                  ),
                ],
              ),
              activeIcon: Image.asset(
                'assets/imgs/icons/icon_discover_on.png',
                scale: 4,
              ),
              label: 'Ranking',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/imgs/icons/icon_livetalk_off.png',
                scale: 4,
              ),
              activeIcon: Image.asset('assets/imgs/icons/icon_livetalk_on.png',
                  scale: 4),
              label: 'LiveTalk',
            ), //라톡
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Image.asset(
                    'assets/imgs/icons/icon_more_off.png',
                    scale: 4,
                  ),
                  Positioned(
                    // draw a red marble
                    top: 2,
                    right: 0.0,
                    child:
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('newAlarm')
                          .where('uid', isEqualTo: _userModelController.uid!)
                          .snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return new Icon(Icons.brightness_1,
                              size: 7.0,
                              color: Colors.white);
                        }
                        else if (snapshot.data!.docs.isNotEmpty) {
                          final alarmDocs = snapshot.data!.docs;
                          return new Icon(Icons.brightness_1,
                              size: 7.0,
                              color: (alarmDocs[0]['newInvited_friend'] == true || alarmDocs[0]['newInvited_crew'] == true)
                                  ? Color(0xFFD32F2F)
                                  : Colors.white);
                        }
                        else if (snapshot.connectionState == ConnectionState.waiting) {
                          return new Icon(Icons.brightness_1,
                              size: 7.0,
                              color: Colors.white);
                        }
                        return new Icon(Icons.brightness_1,
                            size: 7.0,
                            color: Colors.white);

                      },
                    )
                  )
                ],
              ),
              activeIcon: Stack(
                children: [
                  Image.asset('assets/imgs/icons/icon_more_on.png', scale: 4),
                  Positioned(
                    // draw a red marble
                    top: 2,
                    right: 0.0,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('newAlarm')
                          .where('uid', isEqualTo: _userModelController.uid!)
                          .snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return new Icon(Icons.brightness_1,
                              size: 7.0,
                              color: Colors.white);
                        }
                        else if (snapshot.data!.docs.isNotEmpty) {
                          final alarmDocs = snapshot.data!.docs;
                          return new Icon(Icons.brightness_1,
                              size: 7.0,
                              color: (alarmDocs[0]['newInvited_friend'] == true || alarmDocs[0]['newInvited_crew'] == true)
                                  ? Color(0xFFD32F2F)
                                  : Colors.white);
                        }
                        else if (snapshot.connectionState == ConnectionState.waiting) {
                          return new Icon(Icons.brightness_1,
                              size: 7.0,
                              color: Colors.white);
                        }
                        return new Icon(Icons.brightness_1,
                            size: 7.0,
                            color: Colors.white);

                      },
                    )
                  )
                ],
              ),
              label: 'More',
            ), //모어
          ],
          showUnselectedLabels: false,
          showSelectedLabels: false,
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: changePage,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ResortHome(),
            FleaMarketScreen(),
            if(_userModelController.favoriteResort == 12)
            RankingScreen(),
            LiveTalkScreen(),
            MoreTab(),
          ],
        )));
  }
}