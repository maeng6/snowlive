import 'package:com.snowlive/core/model/m_crewRecordRoom.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_record_scaffold_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_record_widgets_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 월별 날짜 카드 레일이 콘텐츠 폭 **밖으로 비져나가** 화면 끝까지 흐르는지 본다.
/// 눈으로 확인하기 어려운 값(비져나간 폭·레일 양 끝 패딩)이라 테스트로 못 박는다.
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

  Future<void> pumpAt(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: CrewRecordScaffoldWeb(
        title: '시즌 기록실',
        fallbackRoute: '/',
        maxWidth: contentWidth,
        child: CrewRecordMonthList(
          records: records(10),
          crewName: 'ALLDOMAN',
          resortName: '휘닉스파크',
          now: DateTime(2026, 1, 15),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('넓은 화면: 레일이 뷰포트 전체 폭을 쓰고, 콘텐츠 블록은 가운데 그대로', (tester) async {
    // GNB 오른쪽 영역이 1239인 상황(1440 창 - 사이드바 200 - 보더 1).
    await pumpAt(tester, 1239);

    final railRect = tester.getRect(find.byType(CrewRecordRailBleed));
    final listRect = tester.getRect(
      find.descendant(of: find.byType(CrewRecordRailBleed), matching: find.byType(ListView)),
    );

    // 래퍼는 콘텐츠 폭에 머물고(레이아웃을 밀지 않는다), 실제 레일만 넓어진다.
    expect(railRect.width, contentWidth);
    expect(listRect.left, 0);
    expect(listRect.width, 1239);
  });

  testWidgets('좁은 화면: 콘텐츠가 상한보다 작으면 페이지 여백만큼만 비져나간다', (tester) async {
    // 콘텐츠(874)보다 좁은 영역 → Center 잉여가 0이라 bleed = 페이지 여백(PC 40).
    await pumpAt(tester, 900);

    final listRect = tester.getRect(
      find.descendant(of: find.byType(CrewRecordRailBleed), matching: find.byType(ListView)),
    );
    expect(listRect.left, 0);
    expect(listRect.width, 900);
  });

  testWidgets('레일 양 끝 패딩이 비져나간 폭과 같다(첫 카드가 콘텐츠 좌측선에 선다)', (tester) async {
    await pumpAt(tester, 1239);

    final listView = tester.widget<ListView>(
      find.descendant(of: find.byType(CrewRecordRailBleed), matching: find.byType(ListView)),
    );
    // bleed = 페이지 여백 40 + (실측폭 1159 - 콘텐츠 874) / 2 = 182.5
    expect(listView.padding, const EdgeInsets.symmetric(horizontal: 182.5));

    // 첫 카드 왼쪽이 콘텐츠 블록 왼쪽과 같은 세로선에 있는지.
    final cardRect = tester.getRect(find.byType(CrewRecordDayCard).first);
    final railRect = tester.getRect(find.byType(CrewRecordRailBleed));
    expect(cardRect.left, railRect.left);
  });
}
