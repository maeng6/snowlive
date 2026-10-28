import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/view/friend/v_friendHome_web.dart';
import 'package:com.snowlive/web/view/location/v_liveMap_web.dart';
import 'package:com.snowlive/web/viewmodel/paid/vm_paidVisibility_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 웹 친구 허브 — 앱처럼 `친구 목록`과 `실시간 위치`를 한 곳에서 탭으로 본다.
/// (상단바의 친구 아이콘·GNB `친구` 메뉴가 모두 이 화면으로 온다.)
/// 각 탭 본문은 기존 화면([FriendHomeViewWeb]·[LiveMapViewWeb])을 그대로 재사용한다.
class FriendsHubViewWeb extends StatelessWidget {
  const FriendsHubViewWeb({super.key});

  @override
  Widget build(BuildContext context) {
    // 유료기능 출시 전(테스트 대상 외)에는 '실시간 위치' 탭 없이 친구 목록만 보인다.
    // 위치공유는 이번 시즌 내부 테스트 중이라 플래그로 전면 숨김.
    return Obx(() {
      // ⚠️ 관측값(isVisible)을 **항상 먼저** 읽어 Obx에 등록한다. locationShareEnabled가
      // const false라 `||`로 앞에 두면 단락되어 관측값을 안 읽고 'improper use of Obx'로 터진다.
      final visible = PaidVisibilityControllerWeb.isVisible;
      if (!visible || !PaidVisibilityControllerWeb.locationShareEnabled) {
        return const FriendHomeViewWeb();
      }
      return _buildTabbed();
    });
  }

  Widget _buildTabbed() {
    return DefaultTabController(
      length: 2,
      child: Container(
        color: SDSColor.snowliveWhite,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: SDSColor.snowliveWhite,
                border: Border(bottom: BorderSide(color: SDSColor.gray100)),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: SDSColor.snowliveBlue,
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: SDSColor.gray900,
                  unselectedLabelColor: SDSColor.gray500,
                  labelStyle: SDSTextStyle.bold.copyWith(fontSize: 15),
                  unselectedLabelStyle: SDSTextStyle.bold.copyWith(fontSize: 15),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 18),
                  splashFactory: NoSplash.splashFactory,
                  overlayColor:
                      const WidgetStatePropertyAll(Colors.transparent),
                  tabs: const [
                    Tab(text: '친구 목록'),
                    Tab(text: '실시간 위치'),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  FriendHomeViewWeb(),
                  LiveMapViewWeb(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
