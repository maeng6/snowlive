import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv.dart';
import 'package:com.snowlive/web/view/home/w_home_banner_web.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart';
import 'package:com.snowlive/web/view/home/w_home_weather_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// 홈 화면의 가공 로직. 배너 on/off, 날씨 아이콘 판정, 크루 카드 매핑, 캐러셀 분할.
void main() {
  setUpAll(initializeDateFormatting);

  group('배너', () {
    test('visible이 켜진 배너만 노출한다', () {
      final banners = homeVisibleBanners({
        'imageUrl': ['a.png', 'b.png', 'c.png'],
        'landingUrl': ['https://a', '', 'https://c'],
        'visible': [true, false, true],
      });
      expect(banners.map((b) => b.imageUrl), ['a.png', 'c.png']);
      expect(banners.first.landingUrl, 'https://a');
    });

    test('배열 길이가 어긋나도 안전하다 (visible 없으면 숨김)', () {
      final banners = homeVisibleBanners({
        'imageUrl': ['a.png', 'b.png'],
        'landingUrl': ['https://a'],
        'visible': [true],
      });
      expect(banners, hasLength(1));
      expect(banners.first.landingUrl, 'https://a');
    });

    test('문서가 없거나 비어 있으면 빈 목록', () {
      expect(homeVisibleBanners(null), isEmpty);
      expect(homeVisibleBanners(const {}), isEmpty);
    });

    test('롤링 간격은 앱과 같은 5초', () {
      expect(kHomeBannerInterval, const Duration(seconds: 5));
    });
  });

  group('날씨', () {
    test('강수 없음 + 낮 + 맑음 → 해', () {
      expect(
        homeWeatherIconAsset(pty: '0', sky: '1', now: DateTime(2026, 1, 1, 12)),
        'assets/imgs/weather/icon_weather_sun.png',
      );
    });

    test('강수 없음 + 낮 + 흐림(4) → 구름', () {
      expect(
        homeWeatherIconAsset(pty: '0', sky: '4', now: DateTime(2026, 1, 1, 12)),
        'assets/imgs/weather/icon_weather_cloud.png',
      );
    });

    test('강수 없음 + 밤 → 달', () {
      expect(
        homeWeatherIconAsset(pty: '0', sky: '1', now: DateTime(2026, 1, 1, 22)),
        'assets/imgs/weather/icon_weather.png',
      );
      expect(
        homeWeatherIconAsset(pty: '0', sky: '1', now: DateTime(2026, 1, 1, 6)),
        'assets/imgs/weather/icon_weather.png',
      );
    });

    test('눈(3)은 눈, 나머지 강수는 비', () {
      final snow = homeWeatherIconAsset(pty: '3', sky: '1', now: DateTime(2026, 1, 1, 12));
      final rain = homeWeatherIconAsset(pty: '1', sky: '1', now: DateTime(2026, 1, 1, 12));
      final shower = homeWeatherIconAsset(pty: '4', sky: '1', now: DateTime(2026, 1, 1, 12));
      expect(snow, 'assets/imgs/weather/icon_weather_snow.png');
      expect(rain, 'assets/imgs/weather/icon_weather_rain.png');
      expect(shower, 'assets/imgs/weather/icon_weather_rain.png');
    });

    test('기온은 정수로 반올림하고, 값이 없으면 -', () {
      expect(homeTempLabel('23.4'), '23');
      expect(homeTempLabel('-2.6'), '-3');
      expect(homeTempLabel('-'), '-');
      expect(homeTempLabel(null), '-');
    });

    test('날짜 라벨은 목업 형식', () {
      expect(homeWeatherDateLabel(DateTime(2024, 12, 21)), '2024.12.21 (토)');
      expect(homeTodayBadgeLabel(DateTime(2027, 1, 14)), '2027. 01. 14');
    });

    test('기본 리조트는 자주 가는 스키장, 없으면 휘닉스', () {
      final phoenix = homeDefaultResort(null);
      expect(phoenix.resortNickname, '휘닉스');

      final first = homeResorts.first;
      expect(homeDefaultResort(first.index).resortName, first.resortName);
    });
  });

  group('우리 크루는요', () {
    CrewHomeModel buildHome() => CrewHomeModel(
          newestCrews: [
            CrewCard(crewId: 1, crewName: '올두맹', color: '0XFF00C7A0'),
          ],
          mostMembers: [
            CrewCard(crewId: 2, crewName: '스타크', crewLogoUrl: 'logo.png', color: '0XFF68A1F6'),
          ],
          crewTalks: [
            LiveTalk(
              livetalkId: 10,
              crewId: 1,
              secret: false,
              description: '신규 크루 올두맹을 소개합니다\n90년생 친구들과 휘닉스 파크에서\n보드를 즐겨 타는 크루에요',
            ),
            LiveTalk(
              livetalkId: 11,
              crewId: 2,
              secret: false,
              imageUrl: 'photo.png',
              description: '안녕하세요! 스타크에요',
            ),
            // 비공개는 걸러진다.
            LiveTalk(livetalkId: 12, crewId: 2, secret: true, description: '비밀 소식'),
          ],
        );

    test('공개 크루톡만 카드가 된다', () {
      final cards = homeCrewCards(buildHome());
      expect(cards, hasLength(2));
      expect(cards.map((c) => c.title), [
        '신규 크루 올두맹을 소개합니다',
        '안녕하세요! 스타크에요',
      ]);
    });

    test('본문 첫 줄이 제목, 나머지가 설명', () {
      final card = homeCrewCards(buildHome()).first;
      expect(card.title, '신규 크루 올두맹을 소개합니다');
      expect(card.description, '90년생 친구들과 휘닉스 파크에서 보드를 즐겨 타는 크루에요');
    });

    test('신규 크루면 NEW, 사진이 없으면 imageUrl은 null (크루 색 + 기본 로고로 그린다)', () {
      final cards = homeCrewCards(buildHome());
      expect(cards[0].isNew, isTrue);
      expect(cards[0].imageUrl, isNull);
      expect(cards[0].crewColor, '0XFF00C7A0');

      expect(cards[1].isNew, isFalse);
      expect(cards[1].imageUrl, 'photo.png');
      expect(cards[1].crewLogoUrl, 'logo.png');
    });

    test('집계가 없으면 빈 목록', () => expect(homeCrewCards(null), isEmpty));
  });

  group('캐러셀', () {
    test('페이지 크기대로 끊는다', () {
      expect(homeCarouselPages([1, 2, 3, 4, 5], 2), [
        [1, 2],
        [3, 4],
        [5],
      ]);
      expect(homeCarouselPages([1, 2, 3], 6), [
        [1, 2, 3],
      ]);
      expect(homeCarouselPages(<int>[], 3), isEmpty);
    });
  });

  group('오픈 채팅 상수', () {
    test('말풍선은 5초, 스크롤 임계값은 양수', () {
      expect(kHomeChatBubbleDuration, const Duration(seconds: 5));
      expect(kHomeChatCollapseOffset, greaterThan(0));
    });
  });

  group('배너 위젯', () {
    Future<void> pumpBanner(
      WidgetTester tester, {
      required List<HomeBanner> banners,
      required bool isLoaded,
      double width = 1440,
    }) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HomeBannerWeb(banners: banners, isLoaded: isLoaded),
        ),
      ));
    }

    testWidgets('켜진 배너가 없으면 영역을 감춘다 (앱과 동일)', (tester) async {
      await pumpBanner(tester, banners: const [], isLoaded: true);
      expect(find.byType(AspectRatio), findsNothing);
    });

    testWidgets('문서를 받기 전에는 자리를 잡는다', (tester) async {
      await pumpBanner(tester, banners: const [], isLoaded: false);
      expect(find.byType(AspectRatio), findsOneWidget);
    });

    testWidgets('배너가 2장 이상이면 인디케이터가 보인다', (tester) async {
      await pumpBanner(
        tester,
        banners: const [
          HomeBanner(imageUrl: 'a.png', landingUrl: 'https://a'),
          HomeBanner(imageUrl: 'b.png', landingUrl: ''),
        ],
        isLoaded: true,
      );
      expect(find.byType(AspectRatio), findsOneWidget);
      // 점 2개(6x6).
      final dots = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.constraints?.maxWidth == 6)
          .length;
      expect(dots, 2);
    });

    testWidgets('배너가 1장이면 인디케이터가 없다', (tester) async {
      await pumpBanner(
        tester,
        banners: const [HomeBanner(imageUrl: 'a.png', landingUrl: '')],
        isLoaded: true,
      );
      final dots = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.constraints?.maxWidth == 6)
          .length;
      expect(dots, 0);
    });
  });

  group('오늘의 랭킹 위젯', () {
    RankingUser user(int i) => RankingUser(
          userId: i,
          displayName: '라이더$i',
          resortNickname: '휘닉스',
          crewName: '중앙대 보드 동아리',
          overallTotalScore: 15000 - i * 1000,
        )..rankChange = i.isEven ? 1 : -1;

    Future<void> pumpRanking(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HomeTodayRankingWeb(
              today: DateTime(2027, 1, 14),
              indiv: [for (var i = 0; i < 8; i++) user(i)],
              crew: const [],
              isLoading: false,
            ),
          ),
        ),
      ));
    }

    testWidgets('데스크탑은 제목·날짜·안내가 좌측 열에, 카드가 그 오른쪽에 놓인다', (tester) async {
      await pumpRanking(tester, 1440);

      final title = tester.getRect(find.text('오늘의 랭킹'));
      final badge = tester.getRect(find.text('2027. 01. 14'));
      final note = tester.getRect(find.text('오늘의 랭킹은\n10분마다 순위가 업데이트돼요'));
      final firstRow = tester.getRect(find.text('라이더0'));

      // 날짜 배지는 제목 아래, 안내는 그보다 아래(좌측 열 맨 아래).
      expect(badge.top, greaterThan(title.bottom - 1));
      expect(note.top, greaterThan(badge.bottom));
      // 카드는 좌측 열보다 오른쪽.
      expect(firstRow.left, greaterThan(title.right));
    });

    testWidgets('점수 옆 화살표는 상승 ▲ / 하락 ▼', (tester) async {
      await pumpRanking(tester, 1440);
      expect(find.byIcon(Icons.arrow_drop_up), findsNWidgets(4));
      expect(find.byIcon(Icons.arrow_drop_down), findsNWidgets(4));
      expect(find.text('15,000점'), findsOneWidget);
    });

    testWidgets('변동 데이터가 없으면 화살표를 그리지 않는다', (tester) async {
      tester.view.physicalSize = const Size(1440, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HomeTodayRankingWeb(
              today: DateTime(2027, 1, 14),
              indiv: [
                RankingUser(userId: 1, displayName: '라이더', overallTotalScore: 100),
              ],
              crew: const [],
              isLoading: false,
            ),
          ),
        ),
      ));
      expect(find.byIcon(Icons.arrow_drop_up), findsNothing);
      expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    });

    testWidgets('태블릿은 제목이 위, 카드가 아래', (tester) async {
      await pumpRanking(tester, 900);
      final title = tester.getRect(find.text('오늘의 랭킹'));
      final firstRow = tester.getRect(find.text('라이더0'));
      expect(firstRow.top, greaterThan(title.bottom));
    });
  });

  group('푸터', () {
    Future<void> pumpFooter(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: HomeFooterWeb()),
        ),
      ));
    }

    testWidgets('GNB와 같은 로고 에셋을 쓴다', (tester) async {
      await pumpFooter(tester, 1440);
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(
        (svg.bytesLoader as SvgAssetLoader).assetName,
        'assets/imgs/logos/snowlive_logo_black_web.svg',
      );
    });

    testWidgets('Contact 3열 + 채널 문구', (tester) async {
      await pumpFooter(tester, 1440);
      expect(find.text('Contact'), findsNWidgets(3));
      expect(find.text('Instagram'), findsNWidgets(3));
      expect(find.text('Kakao'), findsNWidgets(3));
      expect(find.text('X'), findsOneWidget);
      expect(find.text('TikTok'), findsOneWidget);
    });

    testWidgets('스토어 배지 2개가 가로로 나란히, 로고보다 오른쪽', (tester) async {
      await pumpFooter(tester, 1440);
      final appStore = tester.getRect(find.text('App Store'));
      final googlePlay = tester.getRect(find.text('Google Play'));
      final logo = tester.getRect(find.byType(SvgPicture));

      expect(appStore.left, greaterThan(logo.right));
      // 같은 줄, App Store가 먼저.
      expect(googlePlay.center.dy, closeTo(appStore.center.dy, 1));
      expect(googlePlay.left, greaterThan(appStore.left));
    });

    testWidgets('저작권과 약관 링크', (tester) async {
      await pumpFooter(tester, 1440);
      expect(find.textContaining('134CreativeLab. All rights reserved.'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Use'), findsOneWidget);
    });

    testWidgets('모바일은 로고가 좌측 정렬되고 세로로 쌓인다', (tester) async {
      await pumpFooter(tester, 375);
      final logo = tester.getRect(find.byType(SvgPicture));
      final contact = tester.getRect(find.text('Contact').first);
      expect(logo.left, lessThan(40));
      expect(contact.top, greaterThan(logo.bottom));
    });
  });

  group('날씨 바', () {
    Future<void> pumpWeather(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HomeWeatherBarWeb(
            resort: homeDefaultResort(null),
            weather: const {
              'temp': '18',
              'wind': '1.3',
              'wet': '85',
              'rain': '0',
              'maxTemp': '23',
              'minTemp': '10',
              'pty': '0',
              'sky': '1',
            },
            onResortSelected: (_) {},
          ),
        ),
      ));
    }

    testWidgets('1440에서는 지표 4개가 펼쳐진다', (tester) async {
      await pumpWeather(tester, 1440);
      expect(find.text('바람'), findsOneWidget);
      expect(find.text('최저/최고'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('1024에서는 접히고 `+`로 펼친다 (넘치지 않는다)', (tester) async {
      await pumpWeather(tester, 1024);
      expect(find.text('바람'), findsNothing);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('바람'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('모바일은 링크 라벨이 잘리지 않는다', (tester) async {
      await pumpWeather(tester, 375);
      for (final label in ['네이버 날씨', '실시간 웹캠', '슬로프 현황', '셔틀버스']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(tester.takeException(), isNull);
    });
  });
}
