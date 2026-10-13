import 'package:com.snowlive/core/model/m_crewRecordRoom.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_record_scaffold_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_record_widgets_web.dart';
import 'package:com.snowlive/web/widget/w_web_edge_fade_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 월별 날짜 카드 레일 — **콘텐츠 폭 안에 머물고**, 양 끝 그라데이션은 그쪽에 더 볼 게
/// 있을 때만 켜진다. 한때 화면 끝까지 흘렸다가 되돌린 부분이라 테스트로 못 박는다.
void main() {
  const double contentWidth = 874;

  List<CrewRidingRecord> records(int count) => [
        for (var d = 1; d <= count; d++)
          CrewRidingRecord(
            date: '2026-01-${d.toString().padLeft(2, '0')}',
            totalScore: 100,
            totalCount: 10,
            memberCount: 3,
            timeInfo: const [1, 2, 3, 4, 5, 6, 7, 8, 9],
            todayMemberInfo: const [],
          )..timeCountInfo = const {
              '00-08': 1, '08-10': 2, '10-12': 3, '12-14': 4, '14-16': 5,
              '16-18': 6, '18-20': 7, '20-22': 8, '22-00': 9,
            },
      ];

  Future<void> pumpAt(WidgetTester tester, double width, {int count = 10}) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: CrewRecordScaffoldWeb(
        title: '시즌 기록실',
        fallbackRoute: '/',
        maxWidth: contentWidth,
        child: CrewRecordMonthList(
          records: records(count),
          crewName: 'ALLDOMAN',
          resortName: '휘닉스파크',
          now: DateTime(2026, 1, 15),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Rect railRect(WidgetTester tester) => tester.getRect(find.byType(CrewRecordRail));

  Finder listIn(Finder rail) =>
      find.descendant(of: rail, matching: find.byType(ListView));

  testWidgets('레일이 콘텐츠 폭 밖으로 나가지 않는다', (tester) async {
    // GNB 오른쪽 영역이 1239인 상황(1440 창 - 사이드바 200 - 보더 1).
    await pumpAt(tester, 1239);

    final rail = railRect(tester);
    final list = tester.getRect(listIn(find.byType(CrewRecordRail)));

    expect(rail.width, contentWidth);
    // 레일과 목록이 같은 자리에 선다 — 양옆으로 비져나가지 않는다.
    expect(list.left, rail.left);
    expect(list.width, contentWidth);
  });

  testWidgets('레일에 양 끝 패딩을 두지 않는다(첫 카드가 콘텐츠 좌측선)', (tester) async {
    await pumpAt(tester, 1239);

    final listView = tester.widget<ListView>(listIn(find.byType(CrewRecordRail)));
    expect(listView.padding, isNull);

    final cardLeft = tester.getRect(find.byType(CrewRecordDayCard).first).left;
    expect(cardLeft, railRect(tester).left);
  });

  testWidgets('처음에는 오른쪽 그라데이션만 켜진다', (tester) async {
    await pumpAt(tester, 1239);

    final fade = tester.widget<WebEdgeFade>(
      find.descendant(of: find.byType(CrewRecordRail), matching: find.byType(WebEdgeFade)),
    );
    expect(fade.showStart, isFalse, reason: '맨 앞이라 왼쪽은 덮지 않는다');
    expect(fade.showEnd, isTrue, reason: '오른쪽에 카드가 더 있다');
  });

  testWidgets('일자를 누르면 그 카드가 레일 가운데에 선다', (tester) async {
    await pumpAt(tester, 1239, count: 20);

    // 가운데쯤 날짜(10일)를 누른다 — 양 끝 clamp에 걸리지 않는 위치.
    // 숫자 `10`은 카드 안 점수·차트에도 있어 **일자 줄 안쪽**으로 좁힌다.
    await tester.tap(find.descendant(
      of: find.byType(CrewRecordDayNumberRow),
      matching: find.text('10'),
    ));
    await tester.pumpAndSettle();

    final rail = railRect(tester);
    final card = tester.getRect(
      find.byWidgetPredicate((w) => w is CrewRecordDayCard && w.date.day == 10),
    );
    // 카드 중심과 레일 중심이 1px 안쪽으로 맞는다.
    expect((card.center.dx - rail.center.dx).abs(), lessThan(1));
  });

  testWidgets('맨 앞 날짜는 왼쪽 끝에 선다(가운데로 끌어오지 않는다)', (tester) async {
    await pumpAt(tester, 1239, count: 20);

    await tester.tap(find.descendant(
      of: find.byType(CrewRecordDayNumberRow),
      matching: find.text('1'),
    ));
    await tester.pumpAndSettle();

    final rail = railRect(tester);
    final card = tester.getRect(find.byType(CrewRecordDayCard).first);
    // 스크롤 원점이라 왼쪽 그라데이션도 꺼져 있어 가려지지 않는다.
    expect(card.left, rail.left);
  });

  testWidgets('고른 날짜만 Bold가 된다', (tester) async {
    await pumpAt(tester, 1239, count: 20);

    Finder dayText(String label) => find.descendant(
          of: find.byType(CrewRecordDayNumberRow),
          matching: find.text(label),
        );
    FontWeight? weightOf(String label) =>
        tester.widget<Text>(dayText(label)).style?.fontWeight;

    final before = weightOf('10');
    await tester.tap(dayText('10'));
    await tester.pumpAndSettle();

    expect(weightOf('10'), isNot(before), reason: '고른 날짜는 굵어진다');
    expect(weightOf('11'), before, reason: '나머지는 그대로');
  });

  testWidgets('카드가 폭에 다 들어가면 그라데이션을 켜지 않는다', (tester) async {
    // 342 * 2 + 12 = 696 < 874 → 스크롤할 것이 없다.
    await pumpAt(tester, 1239, count: 2);

    final fade = tester.widget<WebEdgeFade>(
      find.descendant(of: find.byType(CrewRecordRail), matching: find.byType(WebEdgeFade)),
    );
    expect(fade.showStart, isFalse);
    expect(fade.showEnd, isFalse);
  });
}
