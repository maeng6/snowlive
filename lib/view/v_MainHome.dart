import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:com.snowlive/mobile/view/community/v_community_main.dart';
import 'package:com.snowlive/mobile/view/fleamarket/v_fleaMarketMain.dart';
import 'package:com.snowlive/view/moreTab/v_moreTab_main.dart';
import 'package:com.snowlive/mobile/view/ranking/v_ranking_Home.dart';
import 'package:com.snowlive/view/resortHome/v_resortHome.dart';
import 'package:com.snowlive/view/v_slmkScreen.dart';
import 'package:com.snowlive/viewmodel/vm_mainHome.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/viewmodel/community/vm_communityAlarm.dart';
import 'package:com.snowlive/viewmodel/vm_eventAlarm.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/core/viewmodel/community/vm_communityBulletinList.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MainHomeView extends StatefulWidget {
  @override
  State<MainHomeView> createState() => _MainHomeViewState();
}

class _MainHomeViewState extends State<MainHomeView> {
  final MainHomeViewModel _MainHomeViewModel = Get.find<MainHomeViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final EventAlarmViewModel _eventAlarmViewModel = Get.find<EventAlarmViewModel>();
  final CommunityAlarmViewModel _communityAlarmViewModel = Get.find<CommunityAlarmViewModel>();
  final ResortHomeViewModel _resortHomeViewModel = Get.find<ResortHomeViewModel>();
  final CommunityBulletinListViewModel _communityBulletinListViewModel = Get.find<CommunityBulletinListViewModel>();

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // 탭바 높이 (아이콘 32 + 라벨 11 + 패딩)
    const tabBarHeight = 56.0;

    return Obx(() => Stack(
      children: [
        Scaffold(
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
              onTap: (index) {
                // 커뮤니티 탭을 다시 누르면 스크롤 최상단으로 이동
                if (index == 2 && _MainHomeViewModel.currentPage == 2) {
                  _communityBulletinListViewModel.scrollToTop();
                }
                // 다른 탭에서 커뮤니티 탭으로 전환 시 칩 표시 상태 업데이트
                else if (index == 2 && _MainHomeViewModel.currentPage != 2) {
                  _communityBulletinListViewModel.updateChipsVisibility();
                }

                // 페이지 전환
                _MainHomeViewModel.onItemTapped(index);

                // GA 트래킹
                switch (index) {
                  case 0:
                    FirebaseAnalytics.instance.logEvent(name: 'visit_resortHome', parameters: {
                      'user_id': _userViewModel.user.user_id,
                      'user_name': _userViewModel.user.display_name,
                    });
                    break;
                  case 1:
                    FirebaseAnalytics.instance.logEvent(name: 'visit_fleaMarket', parameters: {
                      'user_id': _userViewModel.user.user_id,
                      'user_name': _userViewModel.user.display_name,
                    });
                    break;
                  case 2:
                    FirebaseAnalytics.instance.logEvent(name: 'visit_community', parameters: {
                      'user_id': _userViewModel.user.user_id,
                      'user_name': _userViewModel.user.display_name,
                    });
                    break;
                  case 3:
                    FirebaseAnalytics.instance.logEvent(name: 'visit_rankingHome', parameters: {
                      'user_id': _userViewModel.user.user_id,
                      'user_name': _userViewModel.user.display_name,
                    });
                    break;
                  case 4:
                    FirebaseAnalytics.instance.logEvent(name: 'visit_moreTab', parameters: {
                      'user_id': _userViewModel.user.user_id,
                      'user_name': _userViewModel.user.display_name,
                    });
                    break;
                }
              },
              items: [
                BottomNavigationBarItem(
                  backgroundColor: Colors.transparent,
                  icon: Image.asset('assets/imgs/icons/icon_home_off.png', width: 32, height: 32),
                  activeIcon: Image.asset('assets/imgs/icons/icon_home_on.png', width: 32, height: 32),
                  label: '홈',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.transparent,
                  icon: Image.asset('assets/imgs/icons/icon_market_off.png', width: 32, height: 32),
                  activeIcon: Image.asset('assets/imgs/icons/icon_market_on.png', width: 32, height: 32),
                  label: '중고거래',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.transparent,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SvgPicture.asset('assets/imgs/icons/icon_bottom_community_off.svg', width: 32, height: 32),
                      if (_communityAlarmViewModel.hasNewCommunity.value)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Color(0xFFEB5757),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  activeIcon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SvgPicture.asset('assets/imgs/icons/icon_bottom_community_on.svg', width: 32, height: 32),
                      if (_communityAlarmViewModel.hasNewCommunity.value)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Color(0xFFEB5757),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: '커뮤니티',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.transparent,
                  icon: Image.asset('assets/imgs/icons/icon_discover_off.png', width: 32, height: 32),
                  activeIcon: Image.asset('assets/imgs/icons/icon_discover_on.png', width: 32, height: 32),
                  label: '랭킹',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.transparent,
                  icon: Image.asset('assets/imgs/icons/icon_more_off.png', width: 32, height: 32),
                  activeIcon: Image.asset('assets/imgs/icons/icon_more_on.png', width: 32, height: 32),
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
            ResortHomeView(),       // index 0: 홈
            FleaMarketMainView(),   // index 1: 중고거래
            CommunityMainView(),    // index 2: 커뮤니티
            RankingHomeView(),      // index 3: 랭킹
            MoreTabMainView(),      // index 4: 더보기
          ],
        ),
      ),
      ],
    ));
  }
}
