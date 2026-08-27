import 'package:com.snowlive/core/model/m_dailyRidingCard.dart';
import 'package:com.snowlive/core/model/m_seasonRidingCard.dart';
import 'package:com.snowlive/web/view/ranking/riding_card_sections_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_riding_card_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ridingcard_detail_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ridingcard_season_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ridingcard_tiles_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DailyRidingCard _card(String date, {int id = 1, int count = 17}) =>
    DailyRidingCard.fromJson({
      'card_id': id,
      'user_id': 4514,
      'date': date,
      'weekday': '일요일',
      'total_slope_count': count,
      'total_distance': 18,
      'slope_counts_by_name': {'스패': 23},
      'most_ridden_slope': '스패',
      'most_ridden_count': 23,
      'top_speed': 24.6,
      'avg_slope': 48.3,
      'rider_title': '슬로프눈팅중 턴스페셜리스트',
      'resorts': ['휘닉스'],
    });

void main() {
  group('시즌 필터', () {
    test('시즌 문자열 → 시작 연도', () {
      expect(ridingCardSeasonStartYear('2526'), 2025);
      expect(ridingCardSeasonStartYear('2425'), 2024);
      expect(ridingCardSeasonStartYear('bad'), isNull);
    });

    test('데일리 카드는 시즌 범위(10월~다음 해 9월)로 걸러진다', () {
      // 데일리 목록 API에 시즌 파라미터가 없어서 웹이 날짜로 나눈다.
      expect(ridingCardIsInSeason('2025-10-01', '2526'), isTrue);
      expect(ridingCardIsInSeason('2026-03-22', '2526'), isTrue);
      expect(ridingCardIsInSeason('2026-09-30', '2526'), isTrue);
      expect(ridingCardIsInSeason('2026-10-01', '2526'), isFalse);
      expect(ridingCardIsInSeason('2025-09-30', '2526'), isFalse);
      expect(ridingCardIsInSeason(null, '2526'), isFalse);

      final cards = [
        _card('2026-03-22', id: 1),
        _card('2025-02-10', id: 2),
        _card('2026-01-05', id: 3),
      ];
      expect(
        ridingCardsForSeason(cards, '2526').map((c) => c.cardId).toList(),
        [1, 3],
      );
      expect(ridingCardsForSeason(cards, '2425').map((c) => c.cardId).toList(), [2]);
    });

    test('시즌 탭에 2324는 없다', () {
      expect(ridingCardSeasons().map((s) => s.dbSeason).toList(), ['2526', '2425']);
    });
  });

  group('월 그룹화·라벨', () {
    test('월도 카드도 최신순', () {
      final months = groupRidingCardsByMonth([
        _card('2026-01-05', id: 1),
        _card('2026-03-22', id: 2),
        _card('2026-03-01', id: 3),
      ]);
      expect(months.map((m) => m.title).toList(), ['3월', '1월']);
      expect(months.first.cards.map((c) => c.cardId).toList(), [2, 3]);
    });

    test('배지·목록 날짜 라벨', () {
      expect(ridingCardDayBadge('2026-03-22'), '22(일)');
      expect(ridingCardDayLabel('2026-03-22'), '22일 (일)');
      expect(ridingCardDayBadge(null), '');
    });

    test('저장 파일명', () {
      expect(ridingCardFileName('2026-03-22'), 'snowlive_riding_2026-03-22.png');
      expect(ridingCardFileName(null), 'snowlive_riding_card.png');
      expect(ridingCardSeasonFileName('2526'), 'snowlive_season_2526.png');
    });
  });

  group('시즌 카드 위젯', () {
    testWidgets('값이 있으면 지표를, 없으면 - 를 그린다', (tester) async {
      final card = SeasonRidingCard.fromJson({
        'user_id': 4514,
        'display_name': '딩동',
        'profile_image_url_user': '',
        'season': '2526',
        'total_slope_count': 1040,
        'total_distance': 886,
        'top_speed': 54,
        'avg_slope': 11.2,
      });

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: RidingCardSeasonWeb(card: card, seasonLabel: '25/26 시즌'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('1040'), findsOneWidget);
      expect(find.text('시즌 총 라이딩'), findsOneWidget);
      // 단위는 앱과 같이 km / ° / km/h 다(목업의 m 표기는 더미).
      expect(find.text('886'), findsOneWidget);
      expect(find.text('km'), findsOneWidget);
      expect(find.text('11.2'), findsOneWidget);
      expect(find.text('54'), findsOneWidget);
      expect(find.text('km/h'), findsOneWidget);

      final empty = SeasonRidingCard.fromJson({
        'user_id': 4514,
        'season': '2425',
        'total_slope_count': 0,
        'total_distance': 0,
        'top_speed': 0,
        'avg_slope': 0,
      });
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: RidingCardSeasonWeb(card: empty, seasonLabel: '24/25 시즌'),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('-'), findsNWidgets(4)); // 총 라이딩 + 지표 3개
    });
  });

  group('그리드·목록 타일 (1440 · 800 · 375)', () {
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
      testWidgets('그리드 카드가 ${width.toInt()}폭에서 날짜 배지까지 그려진다', (tester) async {
        await pumpAt(
          tester,
          width,
          SizedBox(
            width: width / 4,
            child: RidingCardGridTileWeb(
              card: _card('2026-03-22'),
              cardType: 0,
              displayName: '치자나무',
              profileImageUrl: null,
              onTap: () {},
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('22(일)'), findsOneWidget);
        expect(find.text('치자나무'), findsOneWidget);
        expect(find.text('오늘 총 라이딩'), findsOneWidget);
      });

      testWidgets('목록 행이 ${width.toInt()}폭에서 그려진다', (tester) async {
        var tapped = 0;
        await pumpAt(
          tester,
          width,
          RidingCardListTileWeb(
            card: _card('2026-03-22'),
            cardType: 1,
            displayName: '치자나무',
            profileImageUrl: null,
            onTap: () => tapped++,
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('22일 (일)'), findsOneWidget);
        expect(find.text('총 17회 라이딩'), findsOneWidget);
        // 썸네일 카드 안에도 같은 칭호가 들어 있어 2개다.
        expect(find.text('슬로프눈팅중 턴스페셜리스트'), findsWidgets);
        await tester.tap(find.text('22일 (일)'));
        expect(tapped, 1);
      });
    }

    testWidgets('칭호 길이가 달라도 썸네일은 같은 오른쪽 끝에 붙는다 (정렬 회귀)', (tester) async {
      DailyRidingCard withTitle(String title) => DailyRidingCard.fromJson({
            'card_id': title.length,
            'date': '2026-03-22',
            'weekday': '일요일',
            'total_slope_count': 17,
            'total_distance': 18,
            'slope_counts_by_name': {'스패': 3},
            'most_ridden_slope': '스패',
            'most_ridden_count': 3,
            'top_speed': 24.6,
            'avg_slope': 48.3,
            'rider_title': title,
          });

      tester.view.physicalSize = const Size(1000, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              RidingCardListTileWeb(
                card: withTitle('짧은칭호'),
                cardType: 0,
                displayName: '치자나무',
                profileImageUrl: null,
                onTap: () {},
              ),
              RidingCardListTileWeb(
                card: withTitle('아주아주 긴 칭호 슬로프눈팅중 턴스페셜리스트'),
                cardType: 0,
                displayName: '치자나무',
                profileImageUrl: null,
                onTap: () {},
              ),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // ⚠️ Spacer + Flexible이 남는 폭을 반씩 나눠 가지면 이 값이 행마다 달라진다(실측 버그).
      final tiles = find.byType(RidingCardListTileWeb);
      final firstRight = tester.getTopRight(find.byType(LiveTalkRidingCardWeb).at(0)).dx;
      final secondRight = tester.getTopRight(find.byType(LiveTalkRidingCardWeb).at(1)).dx;
      expect(tiles, findsNWidgets(2));
      expect(firstRight, secondRight);
      expect(tester.takeException(), isNull);
    });

    testWidgets('상세 팝업에서 스킨을 바꿀 수 있다', (tester) async {
      var cardType = 0;
      var swaps = 0;

      // 카드(320×508) + 버튼들이 다 보이는 높이여야 버튼을 누를 수 있다.
      tester.view.physicalSize = const Size(900, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showRidingCardDetail(
                context,
                card: _card('2026-03-22'),
                displayName: '치자나무',
                cardTypeOf: () => cardType,
                onSwapCardType: () async {
                  swaps++;
                  cardType = cardType == 0 ? 1 : 0;
                },
              ),
              child: const Text('열기'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('이미지 저장'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pumpAndSettle();
      expect(swaps, 1);
      expect(cardType, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('카드 스킨별 구성 (앱과 동일)', () {
    DailyRidingCard cardWithSlopes() => DailyRidingCard.fromJson({
          'card_id': 9,
          'user_id': 4514,
          'date': '2026-02-10',
          'weekday': '화요일',
          'total_slope_count': 12,
          'total_distance': 11,
          'slope_counts_by_name': {
            '퓨리3': 5,
            '스패': 3,
            '챔피온': 2,
            '환타지': 1,
            '펭귄': 1,
          },
          'most_ridden_slope': '퓨리3',
          'most_ridden_count': 5,
          'top_speed': 34,
          'avg_slope': 12.9,
          'rider_title': '롱턴연습중인 눈구경러',
        });

    Future<void> pumpCard(WidgetTester tester, int cardType) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: LiveTalkRidingCardWeb(
              card: cardWithSlopes(),
              cardType: cardType,
              displayName: '지저스키',
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('0번은 기록 5종을 보여준다', (tester) async {
      await pumpCard(tester, 0);
      expect(tester.takeException(), isNull);
      expect(find.text('오늘 총 라이딩'), findsOneWidget);
      expect(find.text('최다 슬로프'), findsOneWidget);
      expect(find.text('라이딩 거리'), findsOneWidget);
      expect(find.text('평균 경사도'), findsOneWidget);
      expect(find.text('최고 속도'), findsOneWidget);
      // 슬로프 리스트 구성은 나오지 않는다.
      expect(find.text('라이딩 슬로프'), findsNothing);
    });

    testWidgets('1번은 슬로프 리스트 구성으로 바뀐다', (tester) async {
      await pumpCard(tester, 1);
      expect(tester.takeException(), isNull);
      // 총 라이딩 + 최다 슬로프(큰 글씨) + 나머지 슬로프 이름들 + 라벨.
      expect(find.text('12'), findsOneWidget);
      expect(find.text('오늘 총 라이딩'), findsOneWidget);
      expect(find.text('라이딩 슬로프'), findsOneWidget);
      expect(find.text('퓨리3'), findsOneWidget);
      expect(find.text('스패'), findsOneWidget);
      // 0번 구성의 라벨은 사라진다.
      expect(find.text('평균 경사도'), findsNothing);
      expect(find.text('최고 속도'), findsNothing);
    });

    test('2줄 계산은 넘치는 만큼만 접는다', () {
      const style = TextStyle(fontSize: 14);
      // 넉넉한 폭이면 전부 들어간다.
      expect(
        ridingCardSlopeCountForTwoLines(
          slopes: ['스패', '챔피온'],
          maxWidth: 1000,
          style: style,
          spacing: 8,
        ),
        2,
      );
      // 폭이 좁으면 일부만 남기고 나머지는 `+N`으로 접는다.
      final narrow = ridingCardSlopeCountForTwoLines(
        slopes: List.filled(20, '아주긴슬로프이름'),
        maxWidth: 120,
        style: style,
        spacing: 8,
      );
      expect(narrow, lessThan(20));
      expect(narrow, greaterThanOrEqualTo(0));
    });
  });
}
