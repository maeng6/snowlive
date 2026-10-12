import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/view/friend/v_friendHome_web.dart';
import 'package:com.snowlive/web/view/location/v_liveMap_web.dart';
import 'package:flutter/material.dart';

/// 웹 친구 허브 — 앱처럼 `친구 목록`과 `실시간 위치`를 한 곳에서 탭으로 본다.
/// (상단바의 친구 아이콘·GNB `친구` 메뉴가 모두 이 화면으로 온다.)
/// 각 탭 본문은 기존 화면([FriendHomeViewWeb]·[LiveMapViewWeb])을 그대로 재사용한다.
class FriendsHubViewWeb extends StatelessWidget {
  const FriendsHubViewWeb({super.key});

  @override
  Widget build(BuildContext context) {
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
