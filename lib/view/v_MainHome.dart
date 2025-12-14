import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/view/community/v_community_main.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketMain.dart';
import 'package:com.snowlive/view/moreTab/v_moreTab_main.dart';
import 'package:com.snowlive/view/ranking/v_ranking_Home.dart';
import 'package:com.snowlive/view/resortHome/v_resortHome.dart';
import 'package:com.snowlive/view/v_slmkScreen.dart';
import 'package:com.snowlive/viewmodel/vm_mainHome.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/viewmodel/vm_eventAlarm.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainHomeView extends StatelessWidget {
  final MainHomeViewModel _MainHomeViewModel = Get.find<MainHomeViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final EventAlarmViewModel _eventAlarmViewModel = Get.find<EventAlarmViewModel>();

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
              onTap: (index) {
                if (index == 2) {
                  // 스라마켓 탭 클릭 시 별도 처리
                  FirebaseAnalytics.instance.logEvent(
                    name: 'visit_slmk',
                    parameters: {
                      'user_id': _userViewModel.user.user_id,
                      'user_name': _userViewModel.user.display_name,
                    },
                  );

                  Get.to(() => SlmkScreen())!.then((result) {
                    if (result != null && result is int) {
                      _MainHomeViewModel.onItemTapped(result); // 예: 홈으로 복귀
                    }
                  });

                  return; // 🔥 슬마켓은 PageView 이동 방지
                }

                // 슬마켓 외 페이지 전환
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
                  icon: Image.asset('assets/imgs/icons/icon_b_tabbar_slmk.png', width: 32, height: 32),
                  activeIcon: Image.asset('assets/imgs/icons/icon_b_tabbar_slmk.png', width: 32, height: 32),
                  label: '스라마켓',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.transparent,
                  icon: Image.asset('assets/imgs/icons/icon_discover_off.png', width: 32, height: 32),
                  activeIcon: Image.asset('assets/imgs/icons/icon_discover_on.png', width: 32, height: 32),
                  label: '랭킹',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.transparent,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset('assets/imgs/icons/icon_more_off.png', width: 32, height: 32),
                      if (_eventAlarmViewModel.hasNewEvent.value)
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
                      Image.asset('assets/imgs/icons/icon_more_on.png', width: 32, height: 32),
                      if (_eventAlarmViewModel.hasNewEvent.value)
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
            ResortHomeView(),       // index 0
            FleaMarketMainView(),   // index 1
            RankingHomeView(),      // index 3
            MoreTabMainView(),      // index 4
          ],
        )
    ));
  }
}
