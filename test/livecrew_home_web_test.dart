import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_home_sections_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_filter_chips_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_top_carousel_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _crew(
  String name, {
  int? memberCount,
  int? slopes,
  int? resorts,
  num? score,
  int? liveonToday,
  int? liveonSeason,
  double? ratio,
  int resortId = 13,
}) =>
    {
      'crew_id': name.hashCode & 0xffff,
      'crew_name': name,
      'crew_logo_url': null,
      'color': '0XFF68A1F6',
      'description': '$name 소개',
      'base_resort_id': resortId,
      'base_resort_nickname': '휘닉스',
      'member_count': memberCount,
      'occupied_slope_count': slopes,
      'resort_count': resorts,
      'today_score': score,
      'liveon_today_count': liveonToday,
      'liveon_season_count': liveonSeason,
      'ratio': ratio,
      'count': memberCount,
    };

/// 실측 응답과 같은 모양(비시즌: `liveon_today`·`today_score`가 0개).
CrewHomeModel _home({
  bool offSeason = true,
  bool withResorts = true,
  int resortCrewCount = 30,
}) =>
    CrewHomeModel.fromJson({
      'top': {
        'newest_crews': [_crew('ㅂㅂㅂㅂㅂ', memberCount: 1)],
        'liveon_today': offSeason ? [] : [_crew('스타크', liveonToday: 12)],
        'slope_occupied': [
          _crew('스타크', memberCount: 224, slopes: 123),
          _crew('GOM', memberCount: 184, slopes: 91),
        ],
        'diverse_resort': [_crew('팀스키에이트', memberCount: 46, resorts: 12)],
        'today_score': offSeason ? [] : [_crew('스타크', score: 951.5)],
      },
      'middle': {
        'by_resort': withResorts
            ? [
                {
                  'resort_id': 13,
                  'resort_nickname': '휘닉스',
                  'resort_fullname': '휘닉스파크',
                  'crews': [
                    for (var i = 0; i < resortCrewCount; i++) _crew('휘닉스크루$i'),
                  ],
                },
                {
                  'resort_id': 6,
                  'resort_nickname': '곤지암',
                  'resort_fullname': '곤지암리조트',
                  'crews': [_crew('곤지암크루', resortId: 6)],
                },
              ]
            : [],
        'most_members': [
          for (var i = 0; i < 30; i++) _crew('멤버크루$i', memberCount: 100 - i),
        ],
        'liveon_season': [_crew('스타크', liveonSeason: 190)],
        'ski_majority': [
          _crew('아주스키WESKI', memberCount: 39, ratio: 1.0),
          _crew('팀킬', memberCount: 14, ratio: 0.6429),
          _crew('ClubMSG', memberCount: 33, ratio: 0.6061),
          _crew('딱칠십', memberCount: 20, ratio: 0.7),
        ],
        'board_majority': [_crew('삐뽀삐뽀', memberCount: 42, ratio: 1.0)],
      },
      'bottom': {'crew_talks': []},
    });

void main() {
  group('상단 섹션', () {
    test('5개가 정해진 순서로 만들어진다', () {
      final sections = crewHomeSections(_home());
      expect(sections.map((s) => s.kind).toList(), [
        CrewHomeSectionKind.slopeOccupied,
        CrewHomeSectionKind.newest,
        CrewHomeSectionKind.liveonToday,
        CrewHomeSectionKind.diverseResort,
        CrewHomeSectionKind.todayScore,
      ]);
    });

    test('슬로프 섹션 제목은 오늘이 아니라 이번 시즌이다', () {
      final slope = crewHomeSections(_home()).first;
      expect(slope.title, contains('이번 시즌'));
      expect(slope.title, isNot(contains('오늘')));
      // 1위 강조는 목업대로 첫 섹션만.
      expect(slope.highlightFirst, isTrue);
      expect(
        crewHomeSections(_home()).skip(1).every((s) => !s.highlightFirst),
        isTrue,
      );
    });

    test('비시즌에 비는 섹션도 목록에 남고 안내 문구를 갖는다', () {
      final sections = crewHomeSections(_home());
      final today = sections.where((s) =>
          s.kind == CrewHomeSectionKind.liveonToday ||
          s.kind == CrewHomeSectionKind.todayScore);
      expect(today.length, 2);
      for (final s in today) {
        expect(s.crews, isEmpty);
        expect(s.emptyMessage, contains('오늘'));
      }
      // 시즌이 되면 채워진다.
      final inSeason = crewHomeSections(_home(offSeason: false));
      expect(
        inSeason.firstWhere((s) => s.kind == CrewHomeSectionKind.todayScore).crews,
        isNotEmpty,
      );
    });
  });

  group('스키/보드 70% 기준', () {
    test('서버가 섞어 보내는 70% 미만을 걸러낸다', () {
      final home = _home();
      // 서버 원본에는 0.6061·0.6429가 들어 있다(실측).
      expect(home.skiMajority.length, 4);
      final filtered = crewMajorityCrews(home.skiMajority);
      expect(filtered.map((c) => c.crewName).toList(), ['아주스키WESKI', '딱칠십']);
      // 경계값 0.7은 포함이다.
      expect(kCrewMajorityMinRatio, 0.7);
    });

    test('비율이 없는 항목은 기준을 못 만족한 것으로 본다', () {
      expect(crewMajorityCrews([CrewCard(crewName: '비율없음')]), isEmpty);
    });
  });

  group('칩', () {
    test('1단은 확정된 5종 순서', () {
      final chips = crewHomeChips(_home());
      expect(chips.map((c) => c.label).toList(), [
        '스키장별',
        '멤버 많은 순',
        '이번 시즌 라이브온 많이 한 순',
        '스키가 많은 크루',
        '보드가 많은 크루',
      ]);
    });

    test('목록이 비면 그 칩을 만들지 않는다', () {
      final chips = crewHomeChips(_home(withResorts: false));
      expect(chips.any((c) => c.kind == CrewHomeChipKind.byResort), isFalse);
    });

    test('2단은 크루가 있는 스키장만', () {
      final resortChips = crewHomeResortChips(_home());
      expect(resortChips.map((c) => c.label).toList(), ['휘닉스파크', '곤지암리조트']);
      expect(resortChips.first.kind, CrewHomeChipKind.resort);
    });

    test('칩별 목록 매핑', () {
      final home = _home();
      List<CrewCard> of(CrewHomeChipKind kind) => crewsForChip(
            home,
            crewHomeChips(home).firstWhere((c) => c.kind == kind),
          );
      // `스키장별`은 1단 자체에 목록이 없다(2단에서 고른다).
      expect(of(CrewHomeChipKind.byResort), isEmpty);
      expect(of(CrewHomeChipKind.mostMembers).length, 30);
      expect(of(CrewHomeChipKind.liveonSeason).single.crewName, '스타크');
      expect(of(CrewHomeChipKind.ski).length, 2); // 70% 필터 적용
      expect(of(CrewHomeChipKind.board).single.crewName, '삐뽀삐뽀');
      expect(
        crewsForChip(home, crewHomeResortChips(home).first).length,
        30,
      );
    });

    test('순위 칩은 상위 30개 안내 대상, 스키장 칩은 전체보기 대상', () {
      final home = _home();
      final chips = crewHomeChips(home);
      final members = chips.firstWhere((c) => c.kind == CrewHomeChipKind.mostMembers);
      final resort = crewHomeResortChips(home).first;
      expect(crewHomeChipIsRankedTop(members), isTrue);
      expect(crewHomeChipIsRankedTop(resort), isFalse);
      expect(crewHomeListIsCapped(resort, crewsForChip(home, resort)), isTrue);
      // 30개가 안 되면 잘린 게 아니다.
      final small = crewHomeResortChips(_home(resortCrewCount: 5)).first;
      expect(crewHomeListIsCapped(small, crewsForChip(_home(resortCrewCount: 5), small)), isFalse);
    });
  });

  group('레이아웃 (1440 · 800 · 375)', () {
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

    for (final width in [1440.0, 800.0, 375.0]) {
      testWidgets('캐러셀이 ${width.toInt()}폭에서 그려진다', (tester) async {
        final section = crewHomeSections(_home()).first;
        await pumpAt(
          tester,
          width,
          LiveCrewTopCarouselWeb(
            title: section.title,
            subtitle: section.subtitle,
            emptyMessage: section.emptyMessage,
            crews: section.crews,
            highlightFirst: section.highlightFirst,
            onCrewTap: (_) {},
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text(section.subtitle), findsOneWidget);
        expect(find.text('스타크'), findsOneWidget);
      });

      testWidgets('빈 섹션은 ${width.toInt()}폭에서 안내 문구를 보여준다', (tester) async {
        final section = crewHomeSections(_home())
            .firstWhere((s) => s.kind == CrewHomeSectionKind.todayScore);
        await pumpAt(
          tester,
          width,
          LiveCrewTopCarouselWeb(
            title: section.title,
            subtitle: section.subtitle,
            emptyMessage: section.emptyMessage,
            crews: section.crews,
            onCrewTap: (_) {},
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text(section.emptyMessage), findsOneWidget);
      });

      testWidgets('칩 2단이 ${width.toInt()}폭에서 그려진다', (tester) async {
        final home = _home();
        final chips = crewHomeChips(home);
        final resortChips = crewHomeResortChips(home);
        await pumpAt(
          tester,
          width,
          LiveCrewFilterChipsWeb(
            chips: chips,
            selected: chips.first,
            onSelected: (_) {},
            resortChips: resortChips,
            selectedResort: resortChips.first,
            onResortSelected: (_) {},
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('스키장별'), findsOneWidget);
        expect(find.text('휘닉스파크'), findsOneWidget);
      });
    }

    testWidgets('스키장별이 아닌 칩을 고르면 2단이 없다', (tester) async {
      final home = _home();
      final chips = crewHomeChips(home);
      await pumpAt(
        tester,
        1440,
        LiveCrewFilterChipsWeb(
          chips: chips,
          selected: chips[1], // 멤버 많은 순
          onSelected: (_) {},
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('멤버 많은 순'), findsOneWidget);
      expect(find.text('휘닉스파크'), findsNothing);
    });
  });
}
