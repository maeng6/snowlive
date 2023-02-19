import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/comments/v_liveTalk_Screen.dart';
import 'package:snowlive3/screens/resort/v_resortHome.dart';
import '../controller/vm_loginController.dart';
import '../controller/vm_noticeController.dart';
import 'brand/v_brandHome.dart';
import 'fleaMarket/v_fleaMarket_Screen.dart';
import 'more/v_moreTab.dart';

class MainHome extends StatefulWidget {

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int _currentPage=0;

  PageController _pageController = PageController();


  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  void changePage(int index){
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    //TODO: Dependency Injection************************************************
    Get.put(NoticeController(), permanent: true);
    NoticeController _noticeController = Get.find<NoticeController>();
    //TODO: Dependency Injection************************************************

    _noticeController.getIsNewNotice();

    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentPage,
          onTap:  _onItemTapped,
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
                'assets/imgs/icons/icon_brand_off.png',
                scale: 4,
              ),
              activeIcon: Image.asset(
                  'assets/imgs/icons/icon_brand_on.png',
                  scale: 4),
              label: 'Brand',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/imgs/icons/icon_market_off.png',
                scale: 4,
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
              activeIcon: Image.asset(
                  'assets/imgs/icons/icon_livetalk_on.png',
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
                  Positioned(  // draw a red marble
                    top: 2,
                    right: 0.0,
                    child: new Icon(Icons.brightness_1, size: 7.0,
                        color: Color(0xFFD32F2F)),
                  )
                ],
              ),
              activeIcon: Stack(
                children: [
                  Image.asset(
                      'assets/imgs/icons/icon_more_on.png',
                      scale: 4),
                  Positioned(  // draw a red marble
                    top: 2,
                    right: 0.0,
                    child: new Icon(Icons.brightness_1, size: 7.0,
                        color: Color(0xFFD32F2F)),
                  )

                ],
              ),
              label: 'More',
            ),
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
                BrandWebBody(),
                FleaMarketScreen(),
                CommentTile_liveTalk_resortHome(),
                MoreTab(),
          ],
        )
    );
  }
}
