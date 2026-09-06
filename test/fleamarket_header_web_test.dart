import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_header_web.dart'
    show kFleamarketTabs;
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 중고거래 헤더의 **모바일 탭 드롭다운**.
///
/// 좁은 폭에서 하위 탭 5개를 한 줄에 다 두면 카테고리/거래장소 필터와 겹쳐서,
/// 모바일에서는 `전체 ⌄` 드롭다운 하나로 접고 목록은 공용 메뉴로 띄운다.
/// 헤더 위젯 자체는 GetX VM 4개(네트워크 포함)를 요구해 테스트에서 띄울 수 없으므로,
/// 드롭다운이 쓰는 **공용 메뉴 + 탭 값 목록** 조합을 같은 방식으로 검증한다.
void main() {
  group('중고거래 모바일 탭 드롭다운', () {
    /// `_TabDropdown._open()`과 동일한 호출.
    Widget trigger({required void Function(String?) onPicked}) {
      final link = LayerLink();
      return CompositedTransformTarget(
        link: link,
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () async {
              onPicked(await showWebFilterMenu<String>(
                context: context,
                link: link,
                values: kFleamarketTabs,
                labelOf: (t) => t,
                centerSheetOnTablet: true,
              ));
            },
            behavior: HitTestBehavior.opaque,
            child: const Text('전체'),
          ),
        ),
      );
    }

    Future<void> pumpAt(WidgetTester tester, double width, Widget child) async {
      tester.view.physicalSize = Size(width, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Align(alignment: Alignment.topLeft, child: child)),
      ));
      await tester.pumpAndSettle();
    }

    test('탭 목록이 목업 5종 그대로다', () {
      expect(kFleamarketTabs, ['전체', '스키', '스노보드', '찜 목록', '내 게시글']);
    });

    for (final width in [375.0, 800.0]) {
      testWidgets('${width.toInt()}폭에서 탭 5개가 모두 뜨고 고른 값이 돌아온다', (tester) async {
        String? picked;
        await pumpAt(tester, width, trigger(onPicked: (v) => picked = v));

        await tester.tap(find.text('전체'));
        await tester.pumpAndSettle();

        // 트리거의 `전체`와 메뉴의 `전체`가 함께 있으니 2개.
        expect(find.text('전체'), findsNWidgets(2));
        for (final tab in kFleamarketTabs.skip(1)) {
          expect(find.text(tab), findsOneWidget);
        }

        await tester.tap(find.text('스노보드'));
        await tester.pumpAndSettle();
        expect(picked, '스노보드');
      });
    }

    testWidgets('메뉴를 열어도 레이아웃 예외가 없다', (tester) async {
      await pumpAt(tester, 375, trigger(onPicked: (_) {}));
      await tester.tap(find.text('전체'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
