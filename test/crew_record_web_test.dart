import 'package:com.snowlive/core/model/m_crewRecordRoom.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_record_sections_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_record_widgets_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

CrewRidingRecord _record(String date, {int count = 10, List<int>? timeInfo, int members = 2}) {
  return CrewRidingRecord.fromJson({
    'date': date,
    'total_score': 1234.56,
    'total_count': count,
    'member_count': members,
    'within_boundary_count': 0,
    'time_info': timeInfo ?? [0, 1, 2, 3, 4, 5, 6, 7, 8],
    'today_member_info': [
      for (var i = 0; i < members; i++)
        {
          'user_id': i + 1,
          'display_name': '멤버$i',
          'profile_image_url_user': null,
          'within_boundary': false,
          'reveal_wb': true,
          'total_score': 100.4,
        },
    ],
  });
}

void main() {
  group('순수 로직', () {
    test('시즌 탭에 서버가 거부하는 23/24는 없다', () {
      final seasons = crewRecordSeasons();
      expect(seasons.map((s) => s.dbSeason).toList(), ['2526', '2425']);
      expect(seasons.any((s) => s.dbSeason == kUnsupportedRecordSeason), isFalse);
    });

    test('연도 탭은 올해부터 2025까지 내림차순', () {
      expect(crewRecordYears(2026), [2026, 2025]);
      expect(crewRecordYears(2025), [2025]);
      // 시스템 시계가 과거로 잡혀도 빈 목록이 되지 않는다.
      expect(crewRecordYears(2024), [2025]);
    });

    test('월 그룹핑은 서버 순서(내림차순)를 유지한다', () {
      final months = groupCrewRecordsByMonth([
        _record('2026-03-22'),
        _record('2026-03-01'),
        _record('2026-01-31'),
        _record('2025-12-05'),
        // 날짜를 못 읽는 항목은 버린다.
        CrewRidingRecord.fromJson({'date': null, 'time_info': [0, 0, 0, 0, 0, 0, 0, 0, 0]}),
      ]);
      expect(months.map((m) => m.key).toList(), ['2026-03', '2026-01', '2025-12']);
      expect(months.first.title, '3월');
      expect(months.first.records.length, 2);
    });

    test('일자 칩 활성 판정은 응답에 있는 날짜만', () {
      final month = groupCrewRecordsByMonth([
        _record('2026-01-31'),
        _record('2026-01-01'),
      ]).single;
      expect(crewRecordDaysWithRecord(month), {1, 31});
      expect(crewRecordDaysInMonth(2026, 1), 31);
      expect(crewRecordDaysInMonth(2026, 2), 28);
      expect(crewRecordDaysInMonth(2028, 2), 29);
      expect(crewRecordDaysInMonth(2026, 12), 31);
    });

    test('시간대 카운트는 항상 9칸', () {
      expect(crewRecordTimeCounts(_record('2026-01-01')).length, 9);
    });

    test('짧거나 없는 time_info는 파싱 전에 9칸으로 채운다 (모델 RangeError 방지)', () {
      // 보정 없이 그대로 파싱하면 모델이 timeInfo![2]를 읽어 RangeError를 던진다.
      expect(
        () => CrewRidingRecord.fromJson({'date': '2026-01-02', 'time_info': [1, 2]}),
        throwsRangeError,
      );

      final raw = withCrewRecordTimeInfo([
        {'date': '2026-01-02', 'time_info': [1, 2]},
        {'date': '2026-01-03'},
      ]);
      final parsed = CrewRecordRoomResponse.fromJson(raw).records;
      expect(crewRecordTimeCounts(parsed[0]), [1, 2, 0, 0, 0, 0, 0, 0, 0]);
      expect(crewRecordTimeCounts(parsed[1]), List.filled(9, 0));
    });

    test('날짜 라벨은 목업 표기 `15일(토)` (로케일 초기화에 의존하지 않는다)', () {
      expect(crewRecordDayLabel(DateTime(2026, 1, 3)), '3일(토)');
      expect(crewRecordDayLabel(DateTime(2026, 1, 4)), '4일(일)');
      expect(crewRecordDayLabel(DateTime(2026, 1, 15)), '15일(목)');
    });

    test('오늘 배지 판정은 연·월·일이 같을 때만', () {
      expect(crewRecordIsToday(DateTime(2026, 1, 15), DateTime(2026, 1, 15, 23)), isTrue);
      expect(crewRecordIsToday(DateTime(2026, 1, 15), DateTime(2026, 1, 16)), isFalse);
      expect(crewRecordIsToday(DateTime(2026, 1, 15), DateTime(2025, 1, 15)), isFalse);
    });

    test('페이지 번호창은 5개를 유지하며 밀린다', () {
      expect(crewRecordPageWindow(1, 3), [1, 2, 3]);
      expect(crewRecordPageWindow(1, 10), [1, 2, 3, 4, 5]);
      expect(crewRecordPageWindow(5, 10), [3, 4, 5, 6, 7]);
      expect(crewRecordPageWindow(10, 10), [6, 7, 8, 9, 10]);
    });
  });

  group('레이아웃 (1440 · 800 · 375)', () {
    final records = [
      _record('2026-03-22', members: 5),
      _record('2026-03-01'),
      _record('2026-01-15', timeInfo: [0, 0, 0, 0, 0, 0, 0, 0, 0], members: 0),
    ];

    Future<void> pumpAt(WidgetTester tester, double width, Widget child) async {
      tester.view.physicalSize = Size(width, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    Widget monthList() => CrewRecordMonthList(
          records: records,
          crewName: '스타크',
          resortName: '휘닉스파크',
          // `오늘` 배지가 데이터에 걸리도록 고정한다.
          now: DateTime(2026, 3, 22),
        );

    for (final width in [1440.0, 800.0, 375.0]) {
      testWidgets('월 섹션이 ${width.toInt()}폭에서 오버플로 없이 그려진다', (tester) async {
        await pumpAt(tester, width, monthList());
        expect(tester.takeException(), isNull);
        expect(find.text('3월'), findsOneWidget);
        expect(find.text('1월'), findsOneWidget);
        // 카드는 접히지 않고 항상 펼쳐진 채 가로로 나열된다(목업).
        expect(find.text('22일(일)'), findsOneWidget);
        expect(find.text('총 점수'), findsWidgets);
        expect(find.text('라이딩 횟수'), findsWidgets);
        expect(find.text('시간대별 라이딩 횟수'), findsWidgets);
        // `오늘` 배지는 오늘 날짜 카드에만.
        expect(find.text('오늘'), findsOneWidget);
      });
    }

    for (final width in [1440.0, 800.0, 375.0]) {
      testWidgets('로딩 스켈레톤이 ${width.toInt()}폭에서 카드 크기로 그려진다', (tester) async {
        await pumpAt(tester, width, const CrewRecordListSkeleton());
        expect(tester.takeException(), isNull);
        // 실제 카드와 같은 크기여야 로딩 중임이 눈에 보인다. 가로 목록이라 화면에
        // 들어가는 만큼만 만들어진다(1440=3장, 800=2장, 375=1장).
        final boxes = tester.widgetList<SkeletonBox>(find.byType(SkeletonBox)).where(
              (b) => b.height == kCrewRecordCardHeight && b.width == kCrewRecordCardWidth,
            );
        expect(boxes, isNotEmpty);
      });
    }

    testWidgets('일자 줄은 그 달의 모든 날을 숫자로 보여준다', (tester) async {
      await pumpAt(tester, 1440, monthList());
      // 3월(31일) + 1월(31일) → 같은 숫자가 두 번씩 나온다.
      expect(find.text('31'), findsNWidgets(2));
      expect(find.text('30'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('멤버 아바타 스택은 4명까지 얼굴 + 나머지는 `+ N 멤버`', (tester) async {
      await pumpAt(tester, 1440, monthList());
      expect(find.text('+ 1 멤버'), findsOneWidget); // 5명 → 얼굴 4 + 1
      expect(find.text('2 멤버'), findsWidgets); // 2명 → 전원 얼굴
      expect(find.text('라이딩 멤버 없음'), findsOneWidget); // 0명
    });

    testWidgets('아바타 스택을 누르면 라이딩 멤버 팝업이 열린다', (tester) async {
      await pumpAt(tester, 1440, monthList());
      await tester.tap(find.text('+ 1 멤버'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('라이딩 멤버 5명'), findsOneWidget);
      expect(find.text('멤버0'), findsOneWidget);
    });

    for (final width in [1440.0, 800.0, 375.0]) {
      testWidgets('요약 카드가 ${width.toInt()}폭에서 그려진다', (tester) async {
        await pumpAt(
          tester,
          width,
          CrewRecordSummaryCard(
            overallRank: 1,
            totalScore: 281886.4,
            onOpenRanking: () {},
            isMobile: width < 768,
          ),
        );
        expect(tester.takeException(), isNull);
        // 목업대로 천단위 구분을 넣는다(앱은 구분 없이 찍는다).
        expect(find.text('281,886'), findsOneWidget);
        expect(find.text('크루원 시즌 랭킹'), findsOneWidget);
      });
    }
  });
}
