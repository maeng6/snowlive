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
      // 사이드바는 콘텐츠 옆에 붙고, 화면이 좁아지면 콘텐츠 폭만 줄어든다.
      return Container(
        color: SDSColor.snowliveWhite,
        // 좌우 40(디자인 가이드 공통), 상단 58(피그마 32:17109).
        padding: const EdgeInsets.fromLTRB(
            kFleamarketDesktopHPad, 58, kFleamarketDesktopHPad, SDSSpacing.xl),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                // 콘텐츠 1280(홈과 동일) + 간격 40 + 사이드바 240.
                maxWidth: kHomeMaxContentWidth -
                    kFleamarketDesktopHPad * 2 +
                    kFleamarketDesktopHPad +
                    kFleamarketSidebarWidth,
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FleamarketHeaderWeb(),
                        FleamarketGridWeb(),
                      ],
                    ),
                  ),
                  // 콘텐츠 ↔ 사이드바 간격 40.
                  SizedBox(width: kFleamarketDesktopHPad),
                  FleamarketSidebarWeb(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(SDSSpacing.md, SDSSpacing.md, SDSSpacing.md, kFleamarketBottomBarHeight),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  FleamarketHeaderWeb(),
                  FleamarketGridWeb(),
                ],
              ),
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
