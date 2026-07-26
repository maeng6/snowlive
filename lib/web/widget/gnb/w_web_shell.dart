import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_desktop_topbar.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_drawer.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_sidebar.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_topbar.dart';
import 'package:com.snowlive/web/widget/w_top_loading_bar_web.dart';
import 'package:flutter/material.dart';

/// 모든 웹 페이지를 감싸는 최상위 셸. 데스크탑에서는 좌측 사이드바,
/// 태블릿/모바일에서는 상단바+드로어로 GNB를 렌더링한다.
class WebAppShell extends StatelessWidget {
  final Widget child;

  const WebAppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;

    if (screenType == WebScreenType.desktop) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TopLoadingBar(),
            const WebGnbDesktopTopBar(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WebGnbSidebar(),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 진행바는 데스크탑과 동일하게 뷰포트 최상단에 둔다. Scaffold의 appBar 슬롯에
    // 상단바를 넣으면 진행바가 그 아래로 밀려서 최상단이 아니게 되므로, 상단바도
    // body Column 안으로 내린다(WebGnbTopbar 내부가 고정 높이라 그대로 동작한다).
    return Scaffold(
      endDrawer: const WebGnbDrawer(),
      body: Column(
        children: [
          const TopLoadingBar(),
          const WebGnbTopbar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
