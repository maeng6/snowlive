import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/bulletin/v_bulletin_Screen.dart';
import 'package:snowlive3/screens/comments/v_liveTalk_Screen.dart';
import 'package:snowlive3/screens/resort/v_resortHome.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
import '../controller/vm_loginController.dart';
import '../controller/vm_noticeController.dart';
import '../controller/vm_userModelController.dart';
import 'fleaMarket/v_fleaMarket_List_Screen.dart';
import 'fleaMarket/v_fleaMarket_Screen.dart';
import 'more/v_moreTab.dart';

class MainHome extends StatefulWidget {

  MainHome({Key? key, this.uid}) : super(key: key);
  String? uid;
  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int _currentPage = 0;
  var _stream;
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
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
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
    NoticeController _noticeController = Get.find<NoticeController>();
    UserModelController _userModelController = Get.find<UserModelController>();
    //TODO: Dependency Injection************************************************

    _noticeController.getIsNewNotice();

    return Scaffold(
        bottomNavigationBar:
        FutureBuilder(
          future: _userModelController.getCurrentUser(_userModelController.uid),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return BottomNavigationBar(
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
                  icon: Image.asset(
                    'assets/imgs/icons/icon_bul_off.png',
                    scale: 4,
                  ),
                  activeIcon:
                  Image.asset('assets/imgs/icons/icon_bul_on.png', scale: 4),
                  label: 'Brand',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      SizedBox(width: 3),
                      Icon(Icons.brightness_1,
                          size: 6.0,
                          color: (_userModelController.newChat == true)
                              ? Color(0xFFD32F2F)
                              : Colors.white),
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
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/imgs/icons/icon_livetalk_off.png',
                    scale: 4,
                  ),
                  activeIcon: Image.asset('assets/imgs/icons/icon_livetalk_on.png',
                      scale: 4),
                  label: 'Weather',
                ),
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
                        child: new Icon(Icons.brightness_1,
                            size: 7.0,
                            color: (_noticeController.isNewNotice == true)
                                ? Color(0xFFD32F2F)
                                : Colors.white),
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
                        child: new Icon(Icons.brightness_1,
                            size: 7.0,
                            color: (_noticeController.isNewNotice == true)
                                ? Color(0xFFD32F2F)
                                : Colors.white),
                      )
                    ],
                  ),
                  label: 'More',
                ),
              ],
              showUnselectedLabels: false,
              showSelectedLabels: false,
            );
            },
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: changePage,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ResortHome(),
            BulletinScreen(),
            FleaMarketScreen(),
            CommentTile_liveTalk_resortHome(),
            MoreTab(),
          ],
        ));
  }
}
