import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/public/vm_bottomTabBarController.dart';
import 'package:com.snowlive/controller/login/vm_loginController.dart';
import 'package:com.snowlive/screens/Ranking/v_Ranking_Home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/screens/resort/v_resortHome.dart';
import '../controller/alarm/vm_noticeController.dart';
import '../controller/home/vm_streamController_resortHome.dart';
import '../controller/user/vm_userModelController.dart';
import 'bulletin/v_bulletin_Screen.dart';
import 'fleaMarket/v_fleaMarket_Screen.dart';
import 'more/v_moreTab.dart';

class MainHome extends StatefulWidget {

  MainHome({Key? key,required this.uid}) : super(key: key);
  String? uid;

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {

  //TODO: Dependency Injection************************************************
  StreamController_ResortHome _streamController_ResortHome = Get.find<StreamController_ResortHome>();
  //TODO: Dependency Injection************************************************


  late LoginController _loginController;
  late UserModelController _userModelController;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _alarmStream;

  @override
  void initState() {
    _loginController = Get.find<LoginController>();
    _userModelController = Get.find<UserModelController>();
    _alarmStream = _streamController_ResortHome.alarmStream.value;
    deviceIdendtificate();
    super.initState();

  }

  Future<void> deviceIdendtificate() async{
    await _loginController.deviceIdentificate(uid: _userModelController.uid);
}

  @override
  Widget build(BuildContext context) {

    //TODO: Dependency Injection************************************************
    Get.put(NoticeController(), permanent: true);
    Get.put(BottomTabBarController(),permanent: true);
    UserModelController _userModelController = Get.find<UserModelController>();
    BottomTabBarController _bottomTabBarController = Get.find<BottomTabBarController>();
    PageControllerManager _pageControllerManager = Get.find<PageControllerManager>();
    //TODO: Dependency Injection************************************************


    return Obx(()=>Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: true,
          showUnselectedLabels: true,
          backgroundColor: Colors.white,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
          currentIndex: _bottomTabBarController.currentPage!,
          onTap: _bottomTabBarController.onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  ImageIcon(
                      AssetImage('assets/imgs/icons/icon_home_off.png'),
                    size: 36,
                    color: Color(0xFF444444),
                  ),
                  Positioned(
                    // draw a red marble
                      top: 2,
                      right: 0.0,
                      child: StreamBuilder(
                        stream: _alarmStream,
                        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return  SizedBox.shrink();
                          }
                          else if (snapshot.data!.docs.isNotEmpty) {

                            final alarmDocs = snapshot.data!.docs;
                            if(alarmDocs[0]['alarmCenter'] == true){
                              return new Icon(Icons.brightness_1,
                                  size: 7.0,
                                  color:  Color(0xFFD32F2F));
                            }else {
                              return SizedBox.shrink();
                            }
                          }
                          else if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox.shrink();
                          }
                          return SizedBox.shrink();

                        },
                      )
                  )
                ],
              ),
              activeIcon:
              Stack(
                children: [
                  ImageIcon(
                    AssetImage( 'assets/imgs/icons/icon_home_on.png'),
                    size: 36,
                    color: Color(0xFF444444),
                  ),
                  Positioned(
                    // draw a red marble
                      top: 2,
                      right: 0.0,
                      child: StreamBuilder(
                        stream: _alarmStream,
                        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return  SizedBox.shrink();
                          }
                          else if (snapshot.data!.docs.isNotEmpty) {

                            final alarmDocs = snapshot.data!.docs;
                            if(alarmDocs[0]['alarmCenter'] == true){
                              return new Icon(Icons.brightness_1,
                                  size: 7.0,
                                  color:  Color(0xFFD32F2F));
                            }else {
                              return SizedBox.shrink();
                            }
                          }
                          else if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox.shrink();
                          }
                          return SizedBox.shrink();

                        },
                      )
                  )
                ],
              ),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/imgs/icons/icon_market_off.png'),
                size: 36,
                color: Color(0xFF444444),
              ),
              activeIcon: ImageIcon(
                AssetImage('assets/imgs/icons/icon_market_on.png'),
                size: 36,
                color: Color(0xFF444444),
              ),
              label: '스노우마켓',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/imgs/icons/icon_discover_off.png'),
                size: 36,
                color: Color(0xFF444444),
              ),
              activeIcon: ImageIcon(
                AssetImage('assets/imgs/icons/icon_discover_on.png'),
                size: 36,
                color: Color(0xFF444444),
              ),
              label: '랭킹',
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
                  ImageIcon(
                    AssetImage('assets/imgs/icons/icon_community_off.png'),
                    size: 36,
                    color: Color(0xFF444444),
                  ),
                ],
              ),
              activeIcon: ImageIcon(
                AssetImage('assets/imgs/icons/icon_community_on.png'),
                size: 36,
                color: Color(0xFF444444),
              ),
              label: '커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  ImageIcon(
                    AssetImage('assets/imgs/icons/icon_more_off.png'),
                    size: 36,
                    color: Color(0xFF444444),
                  ),
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
                            return  SizedBox.shrink();
                          }
                          else if (snapshot.data!.docs.isNotEmpty) {

                            final alarmDocs = snapshot.data!.docs;
                            if(alarmDocs[0]['newInvited_friend'] == true || alarmDocs[0]['newInvited_crew'] == true){
                              return new Icon(Icons.brightness_1,
                                  size: 7.0,
                                  color:  Color(0xFFD32F2F));
                            }else {
                              return SizedBox.shrink();
                            }
                          }
                          else if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox.shrink();
                          }
                          return SizedBox.shrink();

                        },
                      )
                  )
                ],
              ),
              activeIcon: Stack(
                children: [
                  ImageIcon(
                  AssetImage('assets/imgs/icons/icon_more_on.png'),
                  size: 36,
                    color: Color(0xFF444444),
                ),
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
                            return  SizedBox.shrink();
                          }
                          else if (snapshot.data!.docs.isNotEmpty) {

                            final alarmDocs = snapshot.data!.docs;
                            if(alarmDocs[0]['newInvited_friend'] == true || alarmDocs[0]['newInvited_crew'] == true){
                            return new Icon(Icons.brightness_1,
                                size: 7.0,
                                color:  Color(0xFFD32F2F));
                            }else {
                              return SizedBox.shrink();
                            }
    }
                          else if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox.shrink();
                          }
                          return SizedBox.shrink();

                        },
                      )
                  )
                ],
              ),
              label: '더보기',
            ), //모어
          ],
          unselectedLabelStyle: TextStyle(
            color: Color(0xFF222222),
            fontSize: 11,
            fontWeight: FontWeight.normal,
          ),
          selectedItemColor: Color(0xFF222222),
          unselectedItemColor: Color(0xFF222222),
          selectedLabelStyle: TextStyle(
            color: Color(0xFF222222),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: PageView(
          controller: _pageControllerManager.pageController,
          onPageChanged: _bottomTabBarController.changePage,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ResortHome(),
            FleaMarketScreen(),
            RankingHome(),
            BulletinScreen(tap_1: _bottomTabBarController.tap_4, tap_2: _bottomTabBarController.tap_5),
            MoreTab(),
          ],
        )
    ));
  }
}