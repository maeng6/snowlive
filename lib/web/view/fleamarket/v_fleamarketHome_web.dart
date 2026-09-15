import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_bottombar_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_grid_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_header_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_sidebar_web.dart';
import 'package:com.snowlive/web/view/home/v_home_web.dart' show kHomeMaxContentWidth;
import 'package:com.snowlive/web/widget/gnb/w_gnb_sidebar.dart';
import 'package:flutter/material.dart';

/// PC 콘텐츠 좌우 여백 — 디자인 가이드 확정값(웹 공통 40).
const double kFleamarketDesktopHPad = 40;

/// 1440px 기준 GNB(240)/좌우 여백(40*2)을 뺀, "중고거래 리스트 영역 + 우측 사이드바"를
/// 하나로 묶은 기준 폭. 화면이 1440보다 넓어져도 이 블록 전체가 이 폭에서 고정된 채
/// 가운데로 오고, 우측 사이드바는 계속 리스트 영역 옆에 붙어 있는다(화면 끝으로 가지 않음).
/// 화면 끝까지 붙는 건 GNB(좌)와 로그인/회원가입(우, 상단바)뿐이다.
const double kFleamarketContentMaxWidth =
    WebBreakpoints.maxContentWidth - kGnbSidebarWidth - (kFleamarketDesktopHPad * 2);

/// 중고거래 웹 홈(목록) 화면.
class FleamarketHomeView extends StatelessWidget {
  const FleamarketHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      // 구조: [콘텐츠(최대 1280) + 40 + 사이드바(240)] 블록 전체를 가운데 정렬.
      // 사이드바는 콘텐츠 옆에 붙고, 화면이 좁아지면 콘텐츠 폭이 줄어들되
      // 사이드바도 1440→1024 구간에서 240→200으로 선형으로 함께 줄어든다.
      final double screenWidth = MediaQuery.sizeOf(context).width;
      final double sidebarWidth = (200 +
              (screenWidth - WebBreakpoints.desktop) /
                  (WebBreakpoints.maxContentWidth - WebBreakpoints.desktop) *
                  (kFleamarketSidebarWidth - 200))
          .clamp(200.0, kFleamarketSidebarWidth);

      return Container(
        color: SDSColor.snowliveWhite,
        child: SingleChildScrollView(
          // 좌우 40(디자인 가이드 공통), 상단 58(피그마 32:17109).
          // 패딩은 스크롤뷰 **안쪽**에 둔다 — 바깥에 두면 스크롤바가 브라우저
          // 우측 끝이 아니라 콘텐츠 안쪽(40px 들어온 자리)에 뜬다.
          padding: const EdgeInsets.fromLTRB(
              kFleamarketDesktopHPad, 58, kFleamarketDesktopHPad, SDSSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                // 콘텐츠 1280(홈과 동일) + 간격 40 + 사이드바 240.
                maxWidth: kHomeMaxContentWidth -
                    kFleamarketDesktopHPad * 2 +
                    kFleamarketDesktopHPad +
                    kFleamarketSidebarWidth,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FleamarketHeaderWeb(),
                        FleamarketGridWeb(),
                      ],
                    ),
                  ),
                  // 콘텐츠 ↔ 사이드바 간격 40.
                  const SizedBox(width: kFleamarketDesktopHPad),
                  FleamarketSidebarWeb(width: sidebarWidth),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 태블릿(피그마 32:8799): 콘텐츠 좌우/상단 여백 20. 모바일은 기존 16 유지.
    final bool isTablet = context.screenType == WebScreenType.tablet;
    final double hPad = isTablet ? 20 : SDSSpacing.md;

    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          SingleChildScrollView(
            // 여백은 전부 스크롤 영역 **안쪽**에 둔다 — 상단은 바깥에 두면
            // 스크롤된 콘텐츠가 상단바 아래가 아니라 여백 경계에서 잘려 보이고,
            // 좌우는 바깥에 두면 스크롤바가 브라우저 우측 끝이 아니라 콘텐츠
            // 안쪽에 뜬다. 하단 여백은 페이드 바가 콘텐츠를 덮는 구조라
            // 바 높이만큼 확보한다.
            // 상단 여백은 태블릿·모바일 공통 20 (요청 — 모바일 좌우는 16이지만
            // 상단만 20).
            padding: EdgeInsets.fromLTRB(
              hPad,
              20,
              hPad,
              kFleamarketBottomBarHeight + SDSSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                FleamarketHeaderWeb(),
                FleamarketGridWeb(),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FleamarketBottomBarWeb(),
          ),
        ],
      ),
    );
  }
}
