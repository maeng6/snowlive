import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/view/community/v_community_main.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketMain.dart';
import 'package:com.snowlive/view/moreTab/v_moreTab_main.dart';
import 'package:com.snowlive/view/ranking/v_ranking_Home.dart';
import 'package:com.snowlive/view/resortHome/v_resortHome.dart';
import 'package:com.snowlive/viewmodel/vm_mainHome.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainHomeView extends StatelessWidget {
  final MainHomeViewModel _MainHomeViewModel = Get.find<MainHomeViewModel>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: SDSColor.gray50,
                width: 1
              )
            )
          ),
          child: Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              showSelectedLabels: true,
              showUnselectedLabels: true,
              enableFeedback: false,
              backgroundColor: Colors.white,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              currentIndex: _MainHomeViewModel.currentPage!,
              onTap: _MainHomeViewModel.onItemTapped,
              items: [
                BottomNavigationBarItem(
                  backgroundColor: Colors.transparent,
                  icon: Stack(
                    children: [
                      ImageIcon(
                        AssetImage('assets/imgs/icons/icon_home_off.png'),
                        size: 36,
                        color: SDSColor.gray900,
                      ),
                    ],
                  ),
                  activeIcon: Stack(
                    children: [
                      ImageIcon(
                        AssetImage('assets/imgs/icons/icon_home_on.png'),
                        size: 36,
                        color: SDSColor.gray900,
                      ),
                    ],
                  ),
                  label: '홈',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.transparent,

                  icon: ImageIcon(
                    AssetImage('assets/imgs/icons/icon_market_off.png'),
                    size: 36,
                    color: SDSColor.gray900,
                  ),
                  activeIcon: ImageIcon(
                    AssetImage('assets/imgs/icons/icon_market_on.png'),
                    size: 36,
                    color: SDSColor.gray900,
                  ),
                  label: '스노우마켓',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.transparent,
                  icon: ImageIcon(
                    AssetImage('assets/imgs/icons/icon_discover_off.png'),
                    size: 36,
                    color: SDSColor.gray900,
                  ),
                  activeIcon: ImageIcon(
                    AssetImage('assets/imgs/icons/icon_discover_on.png'),
                    size: 36,
                    color: SDSColor.gray900,
                  ),
                  label: '랭킹',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.transparent,
                  icon: Stack(
                    children: [
                      ImageIcon(
                        AssetImage('assets/imgs/icons/icon_community_off.png'),
                        size: 36,
                        color: SDSColor.gray900,
                      ),
                    ],
                  ),
                  activeIcon: ImageIcon(
                    AssetImage('assets/imgs/icons/icon_community_on.png'),
                    size: 36,
                    color: SDSColor.gray900,
                  ),
                  label: '커뮤니티',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.transparent,
                  icon: Stack(
                    children: [
                      ImageIcon(
                        AssetImage('assets/imgs/icons/icon_more_off.png'),
                        size: 36,
                        color: SDSColor.gray900,
                      ),
                    ],
                  ),
                  activeIcon: Stack(
                    children: [
                      ImageIcon(
                        AssetImage('assets/imgs/icons/icon_more_on.png'),
                        size: 36,
                        color: SDSColor.gray900,
                      ),
                    ],
                  ),
                  label: '더보기',
                ),
              ],
              unselectedLabelStyle: SDSTextStyle.regular.copyWith(
                color: SDSColor.gray900,
                fontSize: 11,
              ),
              selectedItemColor: SDSColor.gray900,
              unselectedItemColor: SDSColor.gray900,
              selectedLabelStyle: SDSTextStyle.bold.copyWith(
                color: SDSColor.gray900,
                fontSize: 11,
              ),
            ),
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
          ],
        )
    ));
  }
}
