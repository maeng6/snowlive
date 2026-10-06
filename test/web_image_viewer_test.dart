import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_image_viewer_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 웹 공용 이미지 라이트박스(중고거래 상세에서 사진을 눌렀을 때 뜨는 화면).
///
/// 딤이 실제로 깔리는지, Material 안에서 그려지는지(밖이면 모든 글자에 에러 밑줄이
/// 붙는다), 그리고 폭별 배치(데스크탑·태블릿 = 상단 바 + 양끝 화살표 + 가로 줌 알약,
/// 모바일 = 세로 스택 + 하단 `‹ › ✕`)를 지킨다.
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

    // ── 데스크탑·태블릿: 네이버 부동산식 배치(hoon_0.15.8) ──
    // 제목·`n / N`·✕는 뷰포트 상단 바, `‹ ›`는 뷰포트 양끝 세로 중앙,
    // 이미지(정사각 무대) → 줌 알약 → 썸네일 순으로 한 열(최대 780)에 놓인다.

    /// 줌 컨트롤 — 흰 스타디움 패널 하나에 아이콘 3개(이름은 툴팁).
    Finder zoomPanel() => find.byWidgetPredicate((w) =>
        w is Material &&
        w.color == Colors.white &&
        w.borderRadius == BorderRadius.circular(999));

    /// 이미지는 실측된 무대 사각형에 그린다(첫 프레임은 비어 있다).
    Future<Rect> stageRect(WidgetTester tester) async {
      await tester.pump();
      await tester.pump();
      return tester.getRect(find.byType(WebNetworkImage).first);
    }

    for (final width in <double>[1440, 800]) {
      testWidgets('${width.toInt()}: 상단 바 — 제목 좌 · `n / N` 중앙 · ✕ 우', (tester) async {
        await openViewer(tester, width);
        final title = tester.getRect(find.text('데크 사이즈 156 팔아요 :)'));
        final counter = tester.getRect(find.text('1 / 4'));
        final close = tester.getRect(find.byIcon(Icons.close));
        expect(counter.center.dx, closeTo(width / 2, 1));
        expect(title.left, lessThan(counter.left));
        expect(close.left, greaterThan(counter.right));
        // 셋 다 같은 줄(뷰포트 상단).
        expect(title.center.dy, closeTo(counter.center.dy, 1));
        expect(close.center.dy, closeTo(counter.center.dy, 1));
        expect(counter.top, lessThan(100));
      });

      testWidgets('${width.toInt()}: `‹ ›`가 뷰포트 양끝 세로 중앙에 붙는다', (tester) async {
        await openViewer(tester, width);
        final left = tester.getCenter(find.byIcon(Icons.chevron_left));
        final right = tester.getCenter(find.byIcon(Icons.chevron_right));
        expect(left.dx, lessThan(80));
        expect(right.dx, greaterThan(width - 80));
        expect(left.dy, closeTo(500, 1));
        expect(right.dy, closeTo(500, 1));
      });

      testWidgets('${width.toInt()}: 이미지 → 줌 알약(가로) → 썸네일 순, 무대는 정사각 최대 780', (tester) async {
        await openViewer(tester, width);
        final stage = await stageRect(tester);
        expect(stage.width, closeTo(stage.height, 0.5));
        expect(stage.width, lessThanOrEqualTo(780));
        expect(stage.center.dx, closeTo(width / 2, 1));

        final panel = zoomPanel();
        expect(panel, findsOneWidget);
        final panelRect = tester.getRect(panel);
        expect(panelRect.width, greaterThan(panelRect.height));
        expect(panelRect.center.dx, closeTo(width / 2, 1));
        expect(panelRect.top, greaterThanOrEqualTo(stage.bottom));
        for (final label in ['확대', '축소', '맞춤']) {
          expect(find.descendant(of: panel, matching: find.byTooltip(label)), findsOneWidget);
        }

        // 썸네일 4장이 줌 알약 아래.
        final thumbs = find.byWidgetPredicate((w) => w is WebNetworkImage && w.width == 64);
        expect(thumbs, findsNWidgets(urls.length));
        expect(tester.getRect(thumbs.first).top, greaterThan(panelRect.bottom));
      });
    }

    testWidgets('모바일: 줌 컨트롤 없이 제목·카운터 위, `‹ › ✕`는 맨 아래', (tester) async {
      await openViewer(tester, 375);
      await tester.pump();
      expect(zoomPanel(), findsNothing);

      final title = tester.getRect(find.text('데크 사이즈 156 팔아요 :)'));
      final counter = tester.getRect(find.text('1 / 4'));
      // 제목 위, 카운터 아래로 세로로 쌓이고 둘 다 가운데.
      expect(counter.top, greaterThan(title.bottom));
      expect(counter.center.dx, closeTo(375 / 2, 1));

      final left = tester.getCenter(find.byIcon(Icons.chevron_left));
      final right = tester.getCenter(find.byIcon(Icons.chevron_right));
      final close = tester.getCenter(find.byIcon(Icons.close));
      expect(left.dy, closeTo(close.dy, 1));
      expect(right.dy, closeTo(close.dy, 1));
      expect(close.dy, greaterThan(counter.bottom));
      // ✕는 화살표 쌍보다 한 칸 더 떨어져 있다(16 / 32).
      expect(close.dx - right.dx, greaterThan(right.dx - left.dx));
    });
  });
}
