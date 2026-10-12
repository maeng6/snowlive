import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_riding_stats_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 크루홈 `크루 라이딩 통계` — 모바일에서 두 카드가 같은 폭이어야 한다.
void main() {
  SeasonRankingInfo season({required bool empty}) => SeasonRankingInfo.fromJson({
        'total_slope_count': empty ? 0 : 120,
        'count_info': empty
            ? <Map<String, dynamic>>[]
            : [
                {'slope': '파노라마', 'count': 70},
                {'slope': '챌린지', 'count': 50},
              ],
        'time_info': [0, 1, 2, 3, 4, 5, 6, 7, 8],
      });

  Future<void> pumpAt(WidgetTester tester, double width, SeasonRankingInfo info) async {
    tester.view.physicalSize = Size(width, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CrewHomeRidingStatsWeb(season: info, crewName: 'MISTRAL'),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  /// 총 라이딩 횟수 카드 = `총 라이딩 횟수` 글자를 품은 가장 가까운 파란 카드.
  Rect slopeCard(WidgetTester tester) => tester.getRect(find
      .ancestor(of: find.text('총 라이딩 횟수'), matching: find.byType(Container))
      .first);

  for (final empty in [true, false]) {
    testWidgets('모바일: 총 라이딩 ${empty ? '0회' : '있음'}이어도 카드가 아래 카드와 같은 폭', (tester) async {
      await pumpAt(tester, 375, season(empty: empty));
      expect(tester.takeException(), isNull);
      final slope = slopeCard(tester);
      final time = tester.getRect(find.byType(CrewTimeCountCard));
      // 2026-10-12 QA: 0회일 때 안내 문구 폭만큼 줄어 가운데로 몰렸다.
      expect(slope.width, closeTo(time.width, 0.5));
      expect(slope.left, closeTo(time.left, 0.5));
      expect(slope.width, closeTo(375 - 32, 0.5));
    });
  }
}
