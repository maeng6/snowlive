import 'package:com.snowlive/view/bulletin/v_community_main.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketMain.dart';
import 'package:com.snowlive/view/moreTab/v_moreTab_main.dart';
import 'package:com.snowlive/view/ranking/v_ranking_Home.dart';
import 'package:com.snowlive/view/v_resortHome.dart';
import 'package:com.snowlive/viewmodel/vm_mainHome.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainHomeView extends StatelessWidget {
  final MainHomeViewModel _MainHomeViewModel = Get.find<MainHomeViewModel>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: true,
          showUnselectedLabels: true,
          backgroundColor: Colors.white,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
          currentIndex: _MainHomeViewModel.currentPage!,
          onTap: _MainHomeViewModel.onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  ImageIcon(
                    AssetImage('assets/imgs/icons/icon_home_off.png'),
                    size: 36,
                    color: Color(0xFF444444),
                  ),
                ],
              ),
              activeIcon: Stack(
                children: [
                  ImageIcon(
                    AssetImage('assets/imgs/icons/icon_home_on.png'),
                    size: 36,
                    color: Color(0xFF444444),
                  ),
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
                ],
              ),
              activeIcon: Stack(
                children: [
                  ImageIcon(
                    AssetImage('assets/imgs/icons/icon_more_on.png'),
                    size: 36,
                    color: Color(0xFF444444),
                  ),
                ],
              ),
              label: '더보기',
            ),
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
          controller: _MainHomeViewModel.pageController,
          onPageChanged: _MainHomeViewModel.changePage,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ResortHomeView(),
            FleaMarketMainView(),
            RankingHomeView(),
            CommunityMainView(),
            MoreTabMainView()
            // MoreTab(),
          ],
        )
    ));
  }
}
