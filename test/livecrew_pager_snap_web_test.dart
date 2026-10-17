import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_list_grid_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 좁은 폭 크루 목록 — **스와이프는 한 번에 한 칸**(열 피치)만 움직인다.
/// 스냅 애니메이션이 끝날 만큼만 시간을 흘린다(셔머 때문에 pumpAndSettle 금지).
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
}

void main() {
  List<CrewCard> crews() => [
    for (var i = 0; i < 40; i++)
      CrewCard.fromJson({
        'crew_id': i + 1,
        'crew_name': '크루$i',
        'crew_logo_url': null,
        'color': '0XFF68A1F6',
        'base_resort_id': 13,
        'base_resort_nickname': '휘닉스',
        'member_count': 10 + i,
      }),
  ];

  Future<ScrollableState> pumpPager(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LiveCrewListGridWeb(crews: crews(), onCrewTap: (_) {}),
          ),
        ),
      ),
    );
    // ⚠️ pumpAndSettle은 끝나지 않는다 — 로고 자리의 스켈레톤 셔머가 무한 애니메이션이다.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    return tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(LiveCrewListGridWeb),
        matching: find.byType(Scrollable),
      ),
    );
  }

  for (final width in [375.0, 800.0]) {
    testWidgets('폭 $width — 스와이프는 한 번에 한 칸씩만 움직인다', (tester) async {
      final scrollable = await pumpPager(tester, width);
      expect(scrollable.position.pixels, 0);

      // 한 번 튕기면 바로 옆 열에 붙는다. 그 값이 곧 열 피치다.
      await tester.fling(
        find.byType(LiveCrewListGridWeb),
        const Offset(-120, 0),
        3000,
      );
      await _settle(tester);
      final pitch = scrollable.position.pixels;
      expect(pitch, greaterThan(0), reason: '한 칸 넘어가야 한다');

      // 세게 튕겨도 한 칸만 — 여러 칸을 지나쳤다 되돌아오지 않는다.
      await tester.fling(
        find.byType(LiveCrewListGridWeb),
        const Offset(-300, 0),
        8000,
      );
      await _settle(tester);
      expect(
        scrollable.position.pixels,
        closeTo(pitch * 2, 1),
        reason: '피치 $pitch 기준 두 칸째',
      );

      // 반대로 튕기면 한 칸 뒤로.
      await tester.fling(
        find.byType(LiveCrewListGridWeb),
        const Offset(300, 0),
        8000,
      );
      await _settle(tester);
      expect(scrollable.position.pixels, closeTo(pitch, 1));
    });

    testWidgets('폭 $width — 살짝 끌었다 놓으면 원래 열로 돌아온다(어중간하게 안 선다)',
        (tester) async {
      final scrollable = await pumpPager(tester, width);
      await tester.drag(find.byType(LiveCrewListGridWeb), const Offset(-24, 0));
      await _settle(tester);
      expect(scrollable.position.pixels, closeTo(0, 1));
    });
  }
}
