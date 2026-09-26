import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_page_header_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 목업 실측 522. 사람 목록이라 넓히면 이름과 우측 버튼이 과하게 벌어진다.
const double kFriendContentMaxWidth = 520;

/// 친구 하위 화면(설정 / 요청 관리 / 차단 관리)이 공유하는 골격.
///
/// `← 제목` 한 줄 + 폭 제한된 중앙 컬럼. 셸(WebAppShell)이 상단바·사이드바를 이미
/// 그리므로 자체 `Scaffold`/`AppBar`는 두지 않는다.
class FriendPageScaffoldWeb extends StatelessWidget {
  final String title;
  final Widget child;

  /// pop할 히스토리가 없을 때(URL 직접 진입·새로고침) 대신 갈 곳.
  final String fallbackRoute;

  const FriendPageScaffoldWeb({
    super.key,
    required this.title,
    required this.child,
    this.fallbackRoute = WebRoutes.friend,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      color: SDSColor.snowliveWhite,
      // 서브 페이지 공통 여백(중고거래 상세·폼 기준).
      padding: webSubPagePadding(context),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kFriendContentMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 서브 페이지 공통 헤더(뒤로 30 + 12 + bold 30).
                WebPageHeader(
                  title: title,
                  onBack: () => goBackOr(context, fallbackRoute),
                ),
                const SizedBox(height: SDSSpacing.lg),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// pop 가능하면 pop, 아니면 [fallbackRoute]로.
///
/// URL로 바로 들어오거나 새로고침한 뒤에는 pop할 히스토리가 없어 `Get.back()`이
/// 아무 일도 하지 않는다(커뮤니티·중고거래 상세와 같은 처리).
void goBackOr(BuildContext context, String fallbackRoute) {
  if (Navigator.of(context).canPop()) {
    Get.back();
  } else {
    Get.offAllNamed(fallbackRoute);
  }
}
