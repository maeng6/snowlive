import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_page_header_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 가로 레일이 좌우로 **비져나갈 수 있는 폭**.
///
/// 콘텐츠는 `Center` + `ConstrainedBox`로 가운데 묶여 있어서, 레일이 화면 끝까지 흐르려면
/// `페이지 여백 + Center가 남긴 잉여`만큼 바깥으로 넓혀야 한다. 그 값은 **스크롤 뷰포트 폭을
/// 재야** 알 수 있고 그걸 아는 건 스캐폴드뿐이라 여기서 계산해 내려보낸다.
///
/// ⚠️ `MediaQuery` 폭으로 대신 계산하면 안 된다 — PC는 왼쪽에 GNB 사이드바가 있고 폭이
/// 200↔69로 바뀌기까지 해서, 화면 폭 기준으로 넓히면 **사이드바 위에 카드가 그려진다**.
///
/// 스캐폴드 밖에서는 0이라 레일이 콘텐츠 폭에 그대로 머문다(테스트·다른 화면에서도 동작).
class CrewRecordBleed extends InheritedWidget {
  final double bleed;

  const CrewRecordBleed({super.key, required this.bleed, required super.child});

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CrewRecordBleed>()?.bleed ?? 0;

  @override
  bool updateShouldNotify(CrewRecordBleed oldWidget) => oldWidget.bleed != bleed;
}

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
        // ⚠️ LayoutBuilder는 패딩 **안쪽**에 둔다 — 여기서 받는 maxWidth가
        // `뷰포트 − 사이드바 − 좌우 패딩`이어야 bleed 계산이 맞는다.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double pagePadding = webSubPagePadding(context).left;
            final double innerWidth = constraints.maxWidth;
            // 화면이 좁으면 콘텐츠가 상한보다 작아진다 → 그때는 잉여가 0이다.
            final double contentWidth = maxWidth < innerWidth ? maxWidth : innerWidth;
            final double bleed = pagePadding + (innerWidth - contentWidth) / 2;

            return CrewRecordBleed(
              bleed: bleed,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 서브 페이지 공통 헤더(뒤로 30 + 12 + bold 30).
                      WebPageHeader(title: title, onBack: () => _goBack(context)),
                      // 헤더 ↔ 본문 30 (목업 — 타이틀 끝 151, 탭 줄 윗선 182).
                      const SizedBox(height: 30),
                      child,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
