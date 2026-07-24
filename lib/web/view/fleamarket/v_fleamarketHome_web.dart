import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_bottombar_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_grid_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_header_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_sidebar_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_sidebar.dart';
import 'package:flutter/material.dart';

/// 1440px 기준 GNB(240)/좌우 여백(32*2)을 뺀, "중고거래 리스트 영역 + 우측 사이드바"를
/// 하나로 묶은 기준 폭. 화면이 1440보다 넓어져도 이 블록 전체가 이 폭에서 고정된 채
/// 가운데로 오고, 우측 사이드바는 계속 리스트 영역 옆에 붙어 있는다(화면 끝으로 가지 않음).
/// 화면 끝까지 붙는 건 GNB(좌)와 로그인/회원가입(우, 상단바)뿐이다.
const double kFleamarketContentMaxWidth =
    WebBreakpoints.maxContentWidth - kGnbSidebarWidth - (SDSSpacing.xl * 2);

/// 중고거래 웹 홈(목록) 화면.
class FleamarketHomeView extends StatelessWidget {
  const FleamarketHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return Container(
        color: SDSColor.snowliveWhite,
        padding: const EdgeInsets.fromLTRB(SDSSpacing.xl, 32, SDSSpacing.xl, SDSSpacing.xl),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kFleamarketContentMaxWidth),
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
