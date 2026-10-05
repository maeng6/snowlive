import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_page_header_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 기록 화면들이 공유하는 골격. 셸(WebAppShell)이 상단바·사이드바를 그리므로
/// 자체 `Scaffold`/`AppBar`는 두지 않는다(다른 크루 하위 화면과 동일).
class CrewRecordScaffoldWeb extends StatelessWidget {
  final String title;
  final Widget child;
  final double maxWidth;

  /// 뒤로 갈 화면이 없을 때(URL 직접 진입) 갈 곳.
  final String fallbackRoute;

  const CrewRecordScaffoldWeb({
    super.key,
    required this.title,
    required this.child,
    required this.fallbackRoute,
    this.maxWidth = 1136,
  });

  void _goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Get.back();
      return;
    }
    Get.offAllNamed(fallbackRoute);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: SDSColor.snowliveWhite,
      // ⚠️ 페이지 여백은 **스크롤 영역 안쪽**에 둔다(웹 공통) — 바깥 Container에 주면
      // 스크롤바가 여백 안쪽에 생겨 브라우저 오른쪽 끝에 붙지 않는다.
      child: SingleChildScrollView(
        padding: webSubPagePadding(context),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 서브 페이지 공통 헤더(뒤로 30 + 12 + bold 30).
                WebPageHeader(title: title, onBack: () => _goBack(context)),
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
