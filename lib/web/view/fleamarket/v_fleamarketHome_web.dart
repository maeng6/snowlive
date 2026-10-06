import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_bottombar_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_grid_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_header_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_sidebar_web.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart' show HomeFooterWeb;
import 'package:com.snowlive/web/widget/w_web_sticky_footer_scroll_web.dart';
import 'package:com.snowlive/web/widget/w_web_sticky_sidebar_web.dart';
import 'package:flutter/material.dart';

/// PC 콘텐츠 좌우 여백 — 디자인 가이드 확정값(웹 공통 40).
const double kFleamarketDesktopHPad = 40;

/// 중고거래 웹 홈(목록) 화면.
class FleamarketHomeView extends StatefulWidget {
  const FleamarketHomeView({super.key});

  @override
  State<FleamarketHomeView> createState() => _FleamarketHomeViewState();
}

class _FleamarketHomeViewState extends State<FleamarketHomeView> {
  /// 사이드바를 스크롤에 맞춰 상단에 붙이려면 페이지 스크롤을 직접 잡아야 한다.
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      // 구조: [콘텐츠(최대 1280) + 40 + 사이드바(240)] 블록 전체를 가운데 정렬.
      // 사이드바는 콘텐츠 옆에 붙고, 화면이 좁아지면 콘텐츠 폭이 줄어들되
      // 사이드바도 1440→1024 구간에서 240→200으로 선형으로 함께 줄어든다.
      final double screenWidth = MediaQuery.sizeOf(context).width;
      final double sidebarWidth =
          (200 +
                  (screenWidth - WebBreakpoints.desktop) /
                      (WebBreakpoints.maxContentWidth - WebBreakpoints.desktop) *
                      (kWebSidebarWidth - 200))
              .clamp(200.0, kWebSidebarWidth);

      // 목록 1280(웹 공통) + 간격 40 + 사이드바 220 = 1540.
      const blockConstraints = BoxConstraints(
        maxWidth: kWebDesktopListMaxWidth + kFleamarketDesktopHPad + kWebSidebarWidth,
      );

      return Container(
        color: SDSColor.snowliveWhite,
        // 콘텐츠가 짧으면 푸터가 뷰포트 하단에 붙는다(공통 골격).
        // 패딩은 스크롤뷰 **안쪽**에 둔다 — 바깥에 두면 스크롤바가 브라우저
        // 우측 끝이 아니라 콘텐츠 안쪽(40px 들어온 자리)에 뜬다.
        child: WebStickyFooterScroll(
          controller: _scrollController,
          padding: webHomePagePadding(context),
          content: Center(
            child: ConstrainedBox(
              constraints: blockConstraints,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [FleamarketHeaderWeb(), FleamarketGridWeb()],
                    ),
                  ),
                  // 콘텐츠 ↔ 사이드바 간격 40.
                  const SizedBox(width: kFleamarketDesktopHPad),
                  // 스크롤을 내리면 사이드바가 화면 상단 30에 멈춰 따라붙고
                  // 목록만 올라간다(라이브톡·커뮤니티와 동일). 상단 오프셋은
                  // 바깥에 둬야 sticky가 그 여백까지 밀지 않는다.
                  Padding(
                    padding: const EdgeInsets.only(top: kFleamarketSidebarTopOffset),
                    child: WebStickySidebar(
                      controller: _scrollController,
                      naturalTop: webHomePagePadding(context).top + kFleamarketSidebarTopOffset,
                      child: FleamarketSidebarWeb(width: sidebarWidth),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 홈과 동일한 푸터. 콘텐츠 ↔ 푸터 120(홈과 동일) — 기존대로 블록 폭.
          footer: Center(
            child: ConstrainedBox(
              constraints: blockConstraints,
              child: const Column(children: [SizedBox(height: 120), HomeFooterWeb()]),
            ),
          ),
        ),
      );
    }

    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          WebStickyFooterScroll(
            // 여백은 전부 스크롤 영역 **안쪽**에 둔다 — 상단은 바깥에 두면
            // 스크롤된 콘텐츠가 상단바 아래가 아니라 여백 경계에서 잘려 보이고,
            // 좌우는 바깥에 두면 스크롤바가 브라우저 우측 끝이 아니라 콘텐츠
            // 안쪽에 뜬다. 하단 여백은 페이드 바가 콘텐츠를 덮는 구조라
            // 바 높이만큼 확보한다.
            padding: webHomePagePadding(
              context,
              bottom: kFleamarketBottomBarHeight + SDSSpacing.md,
            ),
            content: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [FleamarketHeaderWeb(), FleamarketGridWeb()],
            ),
            // 홈과 동일한 푸터. 좁은 폭은 여백 80.
            footer: const Column(children: [SizedBox(height: 80), HomeFooterWeb()]),
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: FleamarketBottomBarWeb()),
        ],
      ),
    );
  }
}
