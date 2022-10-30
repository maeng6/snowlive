import 'package:flutter/material.dart';
import 'package:snowlive3/screens/resort/v_resortHome.dart';
import 'brand/v_brandHome.dart';
import 'more/v_moreTab.dart';
import 'more/v_resortTab.dart';

class MainHome extends StatefulWidget {

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int _currentPage=0;


  void changePage(pageIndex){
    setState(() {
      _currentPage =pageIndex;
      var controller = PrimaryScrollController.of(context);
      controller?.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentPage,
          onTap:  changePage,
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
                'assets/imgs/icons/icon_resort_off.png',
                scale: 4,
              ),
              activeIcon: Image.asset(
                  'assets/imgs/icons/icon_resort_on.png',
                  scale: 4),
              label: 'Weather',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/imgs/icons/icon_more_off.png',
                scale: 4,
              ),
              activeIcon: Image.asset(
                  'assets/imgs/icons/icon_more_on.png',
                  scale: 4),
              label: 'More',
            ),
          ],
          showUnselectedLabels: false,
          showSelectedLabels: false,
        ),
        body: IndexedStack(
          index: _currentPage,
          children: [
            ResortHome(),
            BrandWebBody(),
            resortTab(),
            MoreTab(),
          ],
        )
    );
  }
}
