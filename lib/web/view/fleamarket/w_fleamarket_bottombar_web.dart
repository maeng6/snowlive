import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketAlert_web.dart' show openFleamarketAlert;
import 'package:com.snowlive/web/widget/w_web_floating_bottombar_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double kFleamarketBottomBarHeight = kWebFloatingBottomBarHeight;

/// 태블릿/모바일 전용 하단 고정 2버튼 바.
/// 페이드/버튼 규격은 공용 [WebFloatingBottomBar]/[WebBottomBarButton]에 있다.
class FleamarketBottomBarWeb extends StatelessWidget {
  const FleamarketBottomBarWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return WebFloatingBottomBar(
      child: Row(
        children: [
          // 데스크탑은 사이드바에 이 버튼이 있다. 좁은 폭에서는 사이드바가 없으므로
          // 여기가 유일한 진입점이다.
          // 공통 색 규칙: 보조(키워드 알림)는 연회색 채움, 주(물품 올리기)는
          // PC 사이드바와 같은 브랜드 블루. PC/태블릿/모바일 동일.
          Expanded(
            child: WebBottomBarButton(
              label: '키워드 알림 설정',
              background: SDSColor.gray100,
              foreground: SDSColor.gray900,
              // 미로그인이면 페이지 대신 로그인 유도 팝업(공통 처리).
              onTap: () => openFleamarketAlert(context),
            ),
          ),
          const SizedBox(width: SDSSpacing.sm),
          Expanded(
            child: WebBottomBarButton(
              label: '중고거래 물품 올리기',
              background: SDSColor.snowliveBlue,
              foreground: SDSColor.snowliveWhite,
              onTap: () => Get.toNamed(WebRoutes.fleamarketUpload),
            ),
          ),
        ],
      ),
    );
  }
}
