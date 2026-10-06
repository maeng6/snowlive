import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:com.snowlive/web/view/home/w_home_hero_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
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
    // `banner/home` 문서는 `slides` 배열(슬라이드마다 맵)이다.
    test('visible이 켜진 슬라이드만 노출한다', () {
      final banners = homeVisibleBanners({
        'slides': [
          {'imageUrl': 'a.png', 'landingUrl': 'https://a', 'visible': true},
          {'imageUrl': 'b.png', 'landingUrl': '', 'visible': false},
          {'imageUrl': 'c.png', 'landingUrl': 'https://c', 'visible': true},
        ],
      });
      expect(banners.map((b) => b.imageUrl), ['a.png', 'c.png']);
      expect(banners.first.landingUrl, 'https://a');
    });

    test('visible이 없거나 사진이 없는 슬라이드는 숨긴다', () {
      final banners = homeVisibleBanners({
        'slides': [
          {'imageUrl': 'a.png'}, // visible 없음 → 숨김
          {'imageUrl': '', 'visible': true}, // 사진 없음 → 숨김
          {'imageUrl': 'c.png', 'visible': true, 'title': '첫 줄\\n둘째 줄'},
          'not a map',
        ],
      });
      expect(banners, hasLength(1));
      expect(banners.single.imageUrl, 'c.png');
      // 콘솔에서 넣은 `\n` 문자는 실제 줄바꿈으로 바뀐다.
      expect(banners.single.title, '첫 줄\n둘째 줄');
      // 빈 문자열·누락은 null.
      expect(banners.single.subtitle, isNull);
    });

    test('문서가 없거나 slides가 없으면 빈 목록', () {
      expect(homeVisibleBanners(null), isEmpty);
      expect(homeVisibleBanners(const {}), isEmpty);
      expect(homeVisibleBanners(const {'slides': 'oops'}), isEmpty);
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
    test('말풍선은 3초 동안, 최대 3개까지 쌓인다', () {
      expect(kHomeChatBubbleDuration, const Duration(seconds: 3));
      expect(kHomeChatMaxBubbles, 3);
      expect(kHomeChatCollapseOffset, greaterThan(0));
    });
  });

  group('히어로(배너) 위젯', () {
    Future<void> pumpHero(
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
          body: HomeHeroWeb(banners: banners, isLoaded: isLoaded),
        ),
      ));
    }

    /// 히어로는 **첫 장 사진이 준비될 때까지** 스켈레톤을 유지한다. 테스트 환경의
    /// 네트워크 이미지는 400으로 실패하므로, 그 실패(=준비 완료 처리)가 끝나길 기다리고
    /// 이미지 실패 리포트는 비운다.
    Future<void> settleFirstImage(WidgetTester tester) async {
      await tester.pump(); // 첫 프레임 뒤 콜백 실행
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      while (tester.takeException() != null) {}
    }

    int dotCount(WidgetTester tester) => tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => c.constraints?.maxWidth == 6)
        .length;

    testWidgets('문서를 받기 전에는 스켈레톤으로 자리를 잡는다', (tester) async {
      await pumpHero(tester, banners: const [], isLoaded: false);
      await tester.pump();
      expect(find.byType(SkeletonBox), findsOneWidget);
    });

    testWidgets('운영 배너가 없으면 기본 슬라이드를 보여준다', (tester) async {
      await pumpHero(tester, banners: const [], isLoaded: true);
      await settleFirstImage(tester);
      expect(find.byType(SkeletonBox), findsNothing);
      expect(find.textContaining('스노우라이브와 함께하는'), findsOneWidget);
      // 한 장뿐이라 인디케이터는 없다.
      expect(dotCount(tester), 0);
    });

    testWidgets('배너가 2장 이상이면 인디케이터가 보인다', (tester) async {
      await pumpHero(
        tester,
        banners: const [
          HomeBanner(imageUrl: 'https://example.com/a.png', landingUrl: 'https://a'),
          HomeBanner(imageUrl: 'https://example.com/b.png', landingUrl: ''),
        ],
        isLoaded: true,
      );
      await settleFirstImage(tester);
      expect(find.byType(SkeletonBox), findsNothing);
      expect(dotCount(tester), 2);
    });

    testWidgets('배너가 1장이면 인디케이터가 없다', (tester) async {
      await pumpHero(
        tester,
        banners: const [HomeBanner(imageUrl: 'https://example.com/a.png', landingUrl: '')],
        isLoaded: true,
      );
      await settleFirstImage(tester);
      expect(find.byType(SkeletonBox), findsNothing);
      expect(dotCount(tester), 0);
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

    /// 등락 화살표는 10x8 라운드 삼각형(CustomPaint)으로 그린다.
    Finder arrowFinder() => find.byWidgetPredicate(
          (w) => w is CustomPaint && w.size == const Size(10, 8),
        );

    testWidgets('점수 옆에 등락 화살표가 붙는다 (상승 4 + 하락 4)', (tester) async {
      await pumpRanking(tester, 1440);
      expect(arrowFinder(), findsNWidgets(8));
      expect(find.textContaining('15,000'), findsOneWidget);
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
      expect(
        find.byWidgetPredicate((w) => w is CustomPaint && w.size == const Size(10, 8)),
        findsNothing,
      );
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

    /// 이 에셋을 그리는 SvgPicture를 찾는다(푸터에는 로고 외 스토어 배지도 있다).
    Finder svgAsset(String assetName) => find.byWidgetPredicate(
          (w) =>
              w is SvgPicture &&
              w.bytesLoader is SvgAssetLoader &&
              (w.bytesLoader as SvgAssetLoader).assetName == assetName,
        );

    // 넓은·태블릿 분기 경계 부근 — Contact 3열이 남은 폭보다 크면 줄어들어야 한다
    // (예전엔 Row의 비flex 자식이라 FittedBox가 무효여서 그대로 넘칠 수 있었다).
    for (final width in <double>[661, 700, 760, 880, 920, 1024, 1440]) {
      testWidgets('푸터 폭 $width — 넘치지 않고 Contact가 배지 왼쪽에 붙는다', (tester) async {
        await pumpFooter(tester, width);
        expect(tester.takeException(), isNull);
        final contact = tester.getRect(find.text('Contact').last);
        final appStore = tester.getRect(svgAsset('assets/imgs/logos/badge_app_store.svg'));
        // 모바일 분기는 세로로 쌓이므로 가로 관계를 보지 않는다.
        if ((contact.top - appStore.top).abs() < 60) {
          expect(contact.right, lessThanOrEqualTo(appStore.left));
        }
      });
    }

    testWidgets('GNB와 같은 로고 에셋을 쓴다', (tester) async {
      await pumpFooter(tester, 1440);
      expect(svgAsset('assets/imgs/logos/snowlive_logo_black_web.svg'), findsOneWidget);
    });

    testWidgets('Contact 3열 + 채널 문구', (tester) async {
      await pumpFooter(tester, 1440);
      expect(find.text('Contact'), findsNWidgets(3));
      expect(find.text('Instagram'), findsNWidgets(3));
      expect(find.text('Kakao'), findsNWidgets(3));
      expect(find.text('X'), findsOneWidget);
      expect(find.text('TikTok'), findsOneWidget);
    });

    testWidgets('공식 스토어 배지 2개가 가로로 나란히, 로고보다 오른쪽', (tester) async {
      await pumpFooter(tester, 1440);
      final appStore = tester.getRect(svgAsset('assets/imgs/logos/badge_app_store.svg'));
      final googlePlay = tester.getRect(svgAsset('assets/imgs/logos/badge_google_play.svg'));
      final logo = tester.getRect(svgAsset('assets/imgs/logos/snowlive_logo_black_web.svg'));

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

    testWidgets('모바일은 로고가 좌측 정렬되고 세로로 쌓인다 (넘치지 않는다)', (tester) async {
      await pumpFooter(tester, 375);
      final logo = tester.getRect(svgAsset('assets/imgs/logos/snowlive_logo_black_web.svg'));
      final contact = tester.getRect(find.text('Contact').first);
      expect(logo.left, lessThan(40));
      expect(contact.top, greaterThan(logo.bottom));
      // Contact 3열이 좁은 폭에서 가로로 넘치지 않아야 한다.
      expect(tester.takeException(), isNull);
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

    testWidgets('1440에서는 지표 4개가 펼쳐진다 (접기 버튼 없음)', (tester) async {
      await pumpWeather(tester, 1440);
      expect(find.text('바람'), findsOneWidget);
      expect(find.text('최저/최고'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
      expect(tester.takeException(), isNull);
    });

    /// 날씨 바가 **실제로 받는 폭**을 [barWidth]로 고정해서 띄운다.
    /// 데스크탑(≥1024)은 사이드바·패딩을 빼면 뷰포트보다 훨씬 좁은 폭을 받는다
    /// (1024 뷰포트 → 744). 그 상황을 그대로 재현하려고 뷰포트와 바 폭을 따로 준다.
    Future<void> pumpBar(
      WidgetTester tester, {
      required double viewport,
      required double barWidth,
      ResortModel? resort,
      Map<String, dynamic>? weather,
    }) async {
      tester.view.physicalSize = Size(viewport, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: barWidth,
              child: HomeWeatherBarWeb(
                resort: resort ?? homeDefaultResort(null),
                weather: weather ??
                    const {
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
          ),
        ),
      ));
    }

    /// 접힌 카드(태블릿 구성)가 첫 링크를 덮지 않는지. 다른 구성이면 겹칠 수 없다.
    void expectCardDoesNotCoverLinks(WidgetTester tester, String reason) {
      final cards = find.byType(AnimatedContainer);
      if (cards.evaluate().isEmpty) return;
      final card = tester.getRect(cards.first);
      final link = tester.getRect(find.text('네이버 날씨'));
      expect(card.overlaps(link), isFalse, reason: '$reason — 카드 $card / 링크 $link');
    }

    // 가장 긴 리조트명 + 자리수가 가장 많은 날씨 값(최악 조건).
    final longestResort = homeResorts.reduce(
      (a, b) => (a.resortName ?? '').length >= (b.resortName ?? '').length ? a : b,
    );
    const extremeWeather = {
      'temp': '-15',
      'wind': '12.5',
      'wet': '100',
      'rain': '30',
      'maxTemp': '-12',
      'minTemp': '-20',
      'pty': '0',
      'sky': '1',
    };

    // 데스크탑(사이드바 포함) 실제 바 폭: 1024 → 744, 1056 → 776, 1200 → 920,
    // 1280 → 1000, 1320 → 1040, 1440 → 1160. 태블릿은 뷰포트 − 40.
    const desktopBarWidths = <double>[744, 776, 920, 1000, 1040, 1160];
    const tabletBarWidths = <double>[728, 760, 775, 860, 983];

    for (final barWidth in desktopBarWidths) {
      testWidgets('데스크탑 바 폭 $barWidth — 넘치지 않고 카드가 링크를 덮지 않는다', (tester) async {
        await pumpBar(tester, viewport: 1440, barWidth: barWidth);
        expect(tester.takeException(), isNull);
        expectCardDoesNotCoverLinks(tester, 'bar $barWidth');
      });

      testWidgets('데스크탑 바 폭 $barWidth — 가장 긴 리조트명 + 극단값에서도 안전', (tester) async {
        await pumpBar(
          tester,
          viewport: 1440,
          barWidth: barWidth,
          resort: longestResort,
          weather: extremeWeather,
        );
        expect(tester.takeException(), isNull);
        expectCardDoesNotCoverLinks(tester, 'bar $barWidth (${longestResort.resortName})');
      });
    }

    for (final barWidth in tabletBarWidths) {
      testWidgets('태블릿 바 폭 $barWidth — 접힘·펼침 모두 넘치지 않는다', (tester) async {
        await pumpBar(
          tester,
          viewport: 900,
          barWidth: barWidth,
          resort: longestResort,
          weather: extremeWeather,
        );
        expect(tester.takeException(), isNull);
        expectCardDoesNotCoverLinks(tester, 'bar $barWidth');

        // 펼친 상태도 확인한다(카드가 전체폭으로 길어지며 지표 창 360이 붙는다).
        final chip = find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 40 && w.height == 40,
        );
        if (chip.evaluate().isNotEmpty) {
          await tester.tap(chip.first);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'bar $barWidth 펼침');
        }
      });
    }

    testWidgets('넓으면 PC 한 줄, 좁으면 카드+링크, 더 좁으면 세로 스택', (tester) async {
      // 넓음 → PC 한 줄(접힘 카드가 없다).
      // 테스트 글꼴은 숫자·영문도 1em 폭이라 실제 글꼴보다 넓게 잡힌다 → 여유 있게 1600.
      // (실제 글꼴 기준 전환점은 브라우저 실측으로 확인한다.)
      await pumpBar(tester, viewport: 1440, barWidth: 1600);
      expect(find.byType(AnimatedContainer), findsNothing);
      expect(find.text('바람'), findsOneWidget);

      // 중간 → 카드 + 링크가 한 줄(링크가 카드 오른쪽).
      await pumpBar(tester, viewport: 1440, barWidth: 1000);
      final card = tester.getRect(find.byType(AnimatedContainer).first);
      final link = tester.getRect(find.text('네이버 날씨'));
      expect(link.left, greaterThanOrEqualTo(card.right));

      // 아주 좁음 + 긴 이름 → 세로 스택(링크가 카드 아래).
      await pumpBar(
        tester,
        viewport: 1440,
        barWidth: 600,
        resort: longestResort,
        weather: extremeWeather,
      );
      expect(find.byType(AnimatedContainer), findsNothing);
      final name = tester.getRect(find.text(longestResort.resortName!));
      final stackedLink = tester.getRect(find.text('네이버 날씨'));
      expect(stackedLink.top, greaterThan(name.bottom));
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
