import 'package:com.snowlive/web/view/liveCrew/w_crewhome_header_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 크루 홈 요약 바 — `멤버(명)` 칸을 누르면 전체 멤버 화면으로 간다.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, {double width = 1200}) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  }

  testWidgets('멤버 칸을 누르면 콜백이 온다 (데스크탑)', (tester) async {
    var taps = 0;
    await pump(
      tester,
      CrewHomeSummaryBarWeb(
        memberCount: 1,
        overallRank: 255,
        totalScore: 100,
        onMembersTap: () => taps++,
      ),
    );

    await tester.tap(find.text('멤버(명)'));
    expect(taps, 1);
  });

  testWidgets('멤버 칸을 누르면 콜백이 온다 (모바일 세로 배치)', (tester) async {
    var taps = 0;
    await pump(
      tester,
      CrewHomeSummaryBarWeb(
        memberCount: 1,
        overallRank: 255,
        totalScore: 100,
        onMembersTap: () => taps++,
      ),
      width: 375,
    );

    await tester.tap(find.text('멤버(명)'));
    expect(taps, 1);
  });

  testWidgets('다른 지표는 탭 대상이 아니다', (tester) async {
    var taps = 0;
    await pump(
      tester,
      CrewHomeSummaryBarWeb(
        memberCount: 1,
        overallRank: 255,
        totalScore: 100,
        onMembersTap: () => taps++,
      ),
    );

    await tester.tap(find.text('통합 랭킹'), warnIfMissed: false);
    await tester.tap(find.text('총 점수'), warnIfMissed: false);
    expect(taps, 0);
  });
}
