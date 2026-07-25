import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_desktop_topbar.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_drawer.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_sidebar.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_topbar.dart';
import 'package:com.snowlive/web/widget/w_app_download_banner_web.dart';
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
        body: SizedBox.expand(
          child: Stack(
            children: [
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: Column(
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
              ),
              const Positioned(
                left: 16,
                bottom: 16,
                width: 240,
                height: 64,
                child: AppDownloadBannerWeb(),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      endDrawer: const WebGnbDrawer(),
      appBar: const WebGnbTopbar(),
      body: Column(
        children: [
          const TopLoadingBar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
