import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/view/home/w_home_quick_menu_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_current_route_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// 홈 퀵메뉴(태블릿·모바일) — 항목·구성·글자 잘림.
void main() {
  setUp(() {
    Get.testMode = true;
    currentRouteWeb.value = '/home';
  });
  tearDown(Get.reset);

  Future<void> pump(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              // 홈 좌우 여백(태블릿 20 / 모바일 16)을 뺀 실제 콘텐츠 폭.
              width: width - (width >= 768 ? 40 : 32),
              child: const HomeQuickMenuWeb(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  const labels = ['중고거래', '각종소식', '커뮤니티', '라이브톡', '랭킹', '라이브크루'];

  for (final width in [375.0, 768.0, 1000.0]) {
    testWidgets('폭 $width — 6개 항목이 모두 보이고 넘치지 않는다', (tester) async {
      await pump(tester, width);
      for (final label in labels) {
        expect(find.text(label), findsOneWidget, reason: '$label @ $width');
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('폭 $width — 글자가 칸을 넘지 않는다', (tester) async {
      await pump(tester, width);
      final strip = tester.getRect(find.byType(HomeQuickMenuWeb));
      for (final label in labels) {
        final rect = tester.getRect(find.text(label));
        expect(rect.left, greaterThanOrEqualTo(strip.left - 0.5), reason: label);
        expect(rect.right, lessThanOrEqualTo(strip.right + 0.5), reason: label);
      }
    });
  }

  testWidgets('모바일은 3개씩 두 줄, 태블릿은 한 줄', (tester) async {
    await pump(tester, 375);
    // 두 줄 → 첫 항목과 네 번째 항목의 y가 다르다.
    expect(
      tester.getTopLeft(find.text('라이브톡')).dy,
      greaterThan(tester.getTopLeft(find.text('중고거래')).dy),
    );
    expect(
      tester.getSize(find.byType(HomeQuickMenuWeb)).height,
      closeTo(HomeQuickMenuWeb.rowHeight * 2 + 1, 0.5),
    );

    await pump(tester, 768);
    expect(
      tester.getTopLeft(find.text('라이브톡')).dy,
      closeTo(tester.getTopLeft(find.text('중고거래')).dy, 0.5),
    );
    expect(
      tester.getSize(find.byType(HomeQuickMenuWeb)).height,
      closeTo(HomeQuickMenuWeb.rowHeight, 0.5),
    );
  });

  testWidgets('배경은 gray50', (tester) async {
    await pump(tester, 375);
    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(HomeQuickMenuWeb),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, SDSColor.gray50);
  });
}
