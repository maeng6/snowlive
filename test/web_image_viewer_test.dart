import 'dart:math' as math;

import 'package:com.snowlive/web/widget/w_web_image_viewer_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 웹 공용 이미지 라이트박스(중고거래 상세에서 사진을 눌렀을 때 뜨는 화면).
///
/// 목업과 다르게 나오던 지점들을 지킨다 — 딤이 실제로 깔리는지, Material 안에서
/// 그려지는지(밖이면 모든 글자에 에러 밑줄이 붙는다), `‹ › ✕`가 썸네일 위인지,
/// 줌 버튼 3개가 흰 패널 하나로 묶여 있는지.
void main() {
  const urls = [
    'https://example.com/0.jpg',
    'https://example.com/1.jpg',
    'https://example.com/2.jpg',
    'https://example.com/3.jpg',
  ];

  /// main_web.dart와 같은 구조 — 라우트 위에 최상위 Overlay가 한 겹 있고,
  /// 뷰어는 그 Overlay(=Material 밖)에 꽂힌다.
  Future<void> openViewer(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    late BuildContext rootContext;
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => Overlay(
        initialEntries: [OverlayEntry(builder: (_) => child!)],
      ),
      home: Builder(builder: (context) {
        rootContext = context;
        return const SizedBox.shrink();
      }),
    ));

    showWebImageViewer(
      context: rootContext,
      title: '데크 사이즈 156 팔아요 :)',
      imageUrls: urls,
      initialIndex: 0,
    );
    await tester.pump();
  }

  group('이미지 뷰어', () {
    testWidgets('딤이 한 겹 깔린다', (tester) async {
      await openViewer(tester, 1440);
      final backdrops = tester
          .widgetList<ColoredBox>(find.byType(ColoredBox))
          .where((b) => b.color.a > 0.78 && b.color.r == 0 && b.color.g == 0 && b.color.b == 0)
          .toList();
      expect(backdrops, hasLength(1));
      expect(tester.getSize(find.byType(ColoredBox).first), const Size(1440, 1000));
    });

    testWidgets('Material 안에서 그려진다 (에러 밑줄 방지)', (tester) async {
      await openViewer(tester, 1440);
      final title = find.text('데크 사이즈 156 팔아요 :)');
      expect(title, findsOneWidget);
      expect(find.ancestor(of: title, matching: find.byType(Material)), findsWidgets);
      final style = tester.widget<Text>(title).style!;
      expect(style.decoration, isNot(TextDecoration.underline));
    });

    testWidgets('`‹ › ✕`가 썸네일 스트립 위에 있다', (tester) async {
      await openViewer(tester, 1440);
      final buttonsY = tester.getCenter(find.byIcon(Icons.close)).dy;
      final thumbsY = tester.getCenter(find.byIcon(Icons.chevron_left)).dy;
      expect(buttonsY, closeTo(thumbsY, 1)); // 같은 줄
      // 썸네일(56px 정사각) 중 첫 칸이 버튼 줄보다 아래.
      final thumbTop = tester.getTopLeft(find.byType(GestureDetector).at(0)).dy;
      expect(thumbTop, isNotNull);
      final closeTop = tester.getTopLeft(find.byIcon(Icons.close)).dy;
      final stripTop = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((b) => b.height == 56)
          .isNotEmpty
          ? tester.getTopLeft(find.byWidgetPredicate((w) => w is SizedBox && w.height == 56)).dy
          : double.nan;
      expect(stripTop, greaterThan(closeTop));
    });

    testWidgets('줌 버튼 3개가 흰 패널 하나로 묶여 있다', (tester) async {
      await openViewer(tester, 1440);
      for (final label in ['확대', '축소', '맞춤']) {
        expect(find.text(label), findsOneWidget);
      }
      final panel = find.byWidgetPredicate((w) =>
          w is Material &&
          w.color == Colors.white &&
          w.borderRadius == BorderRadius.circular(12));
      expect(panel, findsOneWidget);
      for (final label in ['확대', '축소', '맞춤']) {
        expect(find.descendant(of: panel, matching: find.text(label)), findsOneWidget);
      }
      // 세로 배치라 패널이 좁고 길다.
      final size = tester.getSize(panel);
      expect(size.width, lessThan(size.height));
    });

    testWidgets('제목·`n / N`이 이미지 폭에 맞춰 이미지 바로 위에 놓인다', (tester) async {
      await openViewer(tester, 1440);
      // 첫 프레임엔 아직 못 재서 열 폭이고, 다음 프레임에 이미지 폭으로 붙는다.
      await tester.pump();
      await tester.pump();

      final image = find.byType(SizeChangedLayoutNotifier);
      final topBar = find.ancestor(of: find.text('1 / 4'), matching: find.byType(Row)).first;

      final imageRect = tester.getRect(image);
      final barRect = tester.getRect(topBar);
      // 상단 바는 이미지 폭을 따라가고(최소폭 200은 지킨다) 이미지 중심에 맞춰 바로 위에 붙는다.
      expect(barRect.width, closeTo(math.max(imageRect.width, 200), 0.5));
      expect(barRect.center.dx, closeTo(imageRect.center.dx, 0.5));
      expect(barRect.bottom, lessThanOrEqualTo(imageRect.top));
    });

    testWidgets('콘텐츠 열이 데스크탑 최대폭(780)을 넘지 않는다', (tester) async {
      await openViewer(tester, 1440);
      await tester.pump();
      expect(tester.getSize(find.byType(SizeChangedLayoutNotifier)).width, lessThanOrEqualTo(780));
    });

    testWidgets('✕가 화살표 쌍보다 한 칸 더 떨어져 있다', (tester) async {
      await openViewer(tester, 1440);
      final left = tester.getCenter(find.byIcon(Icons.chevron_left)).dx;
      final right = tester.getCenter(find.byIcon(Icons.chevron_right)).dx;
      final close = tester.getCenter(find.byIcon(Icons.close)).dx;
      expect(close - right, greaterThan(right - left));
    });

    testWidgets('모바일은 줌 컨트롤·썸네일 없이 이미지와 버튼만', (tester) async {
      await openViewer(tester, 375);
      expect(find.text('확대'), findsNothing);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('태블릿은 줌 컨트롤이 가로 패널', (tester) async {
      await openViewer(tester, 800);
      final panel = find.byWidgetPredicate((w) =>
          w is Material &&
          w.color == Colors.white &&
          w.borderRadius == BorderRadius.circular(12));
      expect(panel, findsOneWidget);
      final size = tester.getSize(panel);
      expect(size.width, greaterThan(size.height));
    });
  });
}
