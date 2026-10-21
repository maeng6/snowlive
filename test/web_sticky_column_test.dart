// 목록 옆 카드가 "같이 올라가다 상단에서 멈추는" 동작.
// 라이딩 기록 카드(#/riding-cards)의 우측 시즌 카드가 이걸 쓴다.
import 'package:com.snowlive/web/widget/w_web_sticky_column_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const topGap = 24.0;
  const listHeight = 2000.0;
  const panelHeight = 300.0;
  const viewportHeight = 600.0;

  final listKey = GlobalKey();
  final panelKey = GlobalKey();
  late ScrollController controller;

  Future<void> pump(WidgetTester tester) async {
    controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(800, viewportHeight));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              // 카드 위에 있는 머리말(제목·탭 자리) — 기준점이 0이 아니게 둔다.
              const SizedBox(height: 200, child: ColoredBox(color: Colors.amber)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(key: listKey, height: listHeight),
                  ),
                  SizedBox(
                    width: 220,
                    child: WebStickyColumn(
                      controller: controller,
                      boundsKey: listKey,
                      topGap: topGap,
                      child: SizedBox(
                        key: panelKey,
                        height: panelHeight,
                        child: const ColoredBox(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  double panelTop(WidgetTester tester) => tester.getRect(find.byKey(panelKey)).top;

  testWidgets('상단에 닿기 전에는 페이지와 같이 올라간다', (tester) async {
    await pump(tester);
    expect(panelTop(tester), 200, reason: '처음에는 머리말 아래 제자리');

    controller.jumpTo(100);
    await tester.pump();
    expect(panelTop(tester), 100, reason: '100만큼 스크롤했으면 그만큼 올라가 있어야 한다');
  });

  testWidgets('상단(여백 24)에 닿으면 멈추고 목록만 계속 흐른다', (tester) async {
    await pump(tester);

    // 카드 윗변이 화면 위 24에 닿는 지점 = 200 - 24 = 176
    controller.jumpTo(176);
    await tester.pump();
    expect(panelTop(tester), closeTo(topGap, 0.5));

    // 더 스크롤해도 제자리에 멈춰 있다.
    controller.jumpTo(600);
    await tester.pump();
    expect(panelTop(tester), closeTo(topGap, 0.5));

    controller.jumpTo(1200);
    await tester.pump();
    expect(panelTop(tester), closeTo(topGap, 0.5));
  });

  testWidgets('목록이 끝나면 더 내려가지 않는다(빈 공간에 혼자 뜨지 않게)', (tester) async {
    await pump(tester);

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();

    // 멈춤 한계 = 목록 높이 - 카드 높이. 그 이상 밀리면 목록 아래로 빠진다.
    final listBottom = tester.getRect(find.byKey(listKey)).bottom;
    expect(tester.getRect(find.byKey(panelKey)).bottom,
        lessThanOrEqualTo(listBottom + 0.5));
  });

  testWidgets('목록이 카드보다 짧으면 고정하지 않는다', (tester) async {
    controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(800, viewportHeight));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final shortListKey = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              const SizedBox(height: 700),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: SizedBox(key: shortListKey, height: 100)),
                  SizedBox(
                    width: 220,
                    child: WebStickyColumn(
                      controller: controller,
                      boundsKey: shortListKey,
                      topGap: topGap,
                      child: SizedBox(
                        key: panelKey,
                        height: panelHeight,
                        child: const ColoredBox(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final before = tester.getRect(find.byKey(panelKey)).top;
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    final after = tester.getRect(find.byKey(panelKey)).top;

    // 고정되지 않고 스크롤한 만큼 그대로 올라간다.
    expect(before - after, closeTo(controller.position.maxScrollExtent, 0.5));
  });
}
