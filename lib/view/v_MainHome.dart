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
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
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
  final ResortHomeViewModel _resortHomeViewModel = Get.find<ResortHomeViewModel>();

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
                      Image.asset('assets/imgs/icons/icon_community_off.png', width: 32, height: 32),
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
                      Image.asset('assets/imgs/icons/icon_community_on.png', width: 32, height: 32),
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
      // 자동 라이브온 툴팁 (하단 탭바 "더보기" 아이콘 위)
      if (_resortHomeViewModel.shouldShowAutoLiveOnTooltip)
        Positioned(
          bottom: bottomPadding + tabBarHeight + 8,
          right: 8,
          child: _buildAutoLiveOnTooltip(),
        ),
      ],
    ));
  }

  /// 자동 라이브온 설정 툴팁 위젯
  Widget _buildAutoLiveOnTooltip() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _dismissTooltip();
        // 더보기 탭으로 이동
        _MainHomeViewModel.onItemTapped(4);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 말풍선 본체
          Container(
            padding: const EdgeInsets.only(left: 12, right: 6, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: SDSColor.gray900,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '자동 라이브 설정을 변경할 수 있어요',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 13,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _dismissTooltip();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: SDSColor.gray500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 말풍선 꼬리 (삼각형, 아래를 가리킴)
          Padding(
            padding: const EdgeInsets.only(right: 34),
            child: CustomPaint(
              size: const Size(10, 6),
              painter: _TooltipDownArrowPainter(),
            ),
          ),
        ],
      ),
    );
  }

  /// 툴팁 닫기
  void _dismissTooltip() {
    _resortHomeViewModel.markAutoLiveOnTooltipShown();
  }
}

/// 툴팁 화살표 페인터 (아래를 가리키는 삼각형)
class _TooltipDownArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SDSColor.gray900
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)  // 아래 꼭지점
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
