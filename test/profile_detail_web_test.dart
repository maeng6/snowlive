import 'package:com.snowlive/core/model/m_friendDetail.dart';
import 'package:com.snowlive/core/model/m_friendsTalk.dart';
import 'package:com.snowlive/web/view/profile/w_profile_calendar_web.dart';
import 'package:com.snowlive/web/view/profile/w_profile_guestbook_web.dart';
import 'package:com.snowlive/web/view/profile/w_profile_widgets_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_card_web.dart';
import 'package:com.snowlive/web/widget/w_web_section_link_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _slope(String name, int count, double ratio) =>
    {'slope': name, 'count': count, 'ratio': ratio};

FriendDetailModel _detail({bool empty = false}) => FriendDetailModel.fromJson({
      'friend_user_info': {
        'user_id': 750,
        'display_name': '전일권',
        'profile_image_url_user': null,
        'crew_name': '올두맹',
        'crew_id': 334,
        'state_msg': '상태메시지는 여기에',
        'favorite_resort': '휘닉스파크',
        'favorite_resort_id': 13,
        'within_boundary': false,
        'reveal_wb': true,
        'hide_profile': false,
        'are_we_friend': false,
        'best_friend': false,
        'skiorboard': '스노보드',
        'sex': '남자',
      },
      'season_ranking_info': {
        'count_info': empty
            ? []
            : [
                _slope('스패', 135, 1.0),
                _slope('파노', 102, 0.75),
                _slope('펭귄', 57, 0.42),
              ],
        'time_info': empty ? [0, 0, 0, 0, 0, 0, 0, 0, 0] : [57, 102, 135, 36, 15, 0, 0, 0, 0],
        'overall_total_score': 49540.4,
        'overall_total_count': empty ? 0 : 135,
        'overall_rank': 24,
        'overall_rank_percentage': 0.01,
        'overall_tier_icon_url': null,
        'tier_name_kor': '그랜드마스터',
        'tier_name_eng': 'grandmaster',
      },
      'calender_info': empty
          ? []
          : [
              {
                'date': '2026-03-13',
                'daily_total_count': 23,
                'daily_info': [_slope('스패', 23, 1.0)],
                'time_info': [0, 5, 11, 7, 0, 0, 0, 0, 0],
              },
              {
                'date': '2026-03-12',
                'daily_total_count': 1,
                'daily_info': [_slope('파노', 1, 1.0)],
                'time_info': [0, 1, 0, 0, 0, 0, 0, 0, 0],
              },
            ],
    });

FriendsTalk _talk(String author, String content) => FriendsTalk.fromJson({
      'friends_talk_id': 1,
      'author_user_id': 14134,
      'friend_user_id': 750,
      'content': content,
      'count': 0,
      'report': 0,
      'update_time': '2026-03-12T10:00:00.000',
      'upload_time': '2026-03-12T10:00:00.000',
      'author_info': {
        'user_id': 14134,
        'display_name': author,
        'profile_image_url_user': '',
        'crew_name': 'GOM',
        'favorite_resort_nickname': '휘닉스',
      },
    });

void main() {
  group('순수 로직', () {
    test('그 달의 일수', () {
      expect(profileDaysInMonth(2026, 1), 31);
      expect(profileDaysInMonth(2026, 2), 28);
      expect(profileDaysInMonth(2028, 2), 29);
      expect(profileDaysInMonth(2026, 12), 31);
    });

    test('시간대 카운트는 서버 Map을 9칸 순서 리스트로 만든다', () {
      final detail = _detail();
      expect(profileTimeCounts(detail.seasonRankingInfo.timeInfo),
          [57, 102, 135, 36, 15, 0, 0, 0, 0]);
      // 키가 없어도 길이는 9다.
      expect(profileTimeCounts(null), List.filled(9, 0));
      expect(profileTimeCounts({'10-12': 3}), [0, 0, 3, 0, 0, 0, 0, 0, 0]);
    });

    test('슬로프 최댓값', () {
      expect(ProfileRidingStatsWeb.maxCountOf(_detail().seasonRankingInfo.countInfo), 135);
      expect(ProfileRidingStatsWeb.maxCountOf(const []), 0);
    });
  });

  group('버튼 높이 (웹 데스크탑 density)', () {
    // 웹(데스크탑)에서 Flutter 기본 테마는 VisualDensity.compact다 →
    // ButtonStyleButton이 패딩을 상하좌우 4씩 깎아 **36이어야 할 버튼이 28**이 된다.
    // 테스트 기본값(android=standard)은 이 버그를 숨기므로 테마로 직접 재현한다.
    testWidgets('`전체 슬로프 보기`는 36 높이를 지킨다', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(visualDensity: VisualDensity.compact),
        home: Scaffold(
          body: Center(
            child: WebSectionLinkButton(label: '전체 슬로프 보기', onTap: () {}),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final size = tester.getSize(find.byType(WebSectionLinkButton));
      expect(size.height, 36);
    });
  });

  group('태블릿(800)', () {
    // 목업(1:2423)에는 뒤로가기가 없지만 웹에는 필요하다 → 윗줄로 빼지 않고
    // **프로필 사진 왼쪽**에 넣는다(사용자 확정). 윗줄이면 헤더가 내려가 다른
    // 서브 페이지와 상단 여백이 어긋난다.
    testWidgets('뒤로가기는 헤더 줄 안, 프로필 사진 왼쪽에 선다', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      const backKey = Key('back');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ProfileHeaderWeb(
            info: _detail().friendUserInfo,
            leading: const SizedBox(key: backKey, width: 30, height: 30),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final back = tester.getRect(find.byKey(backKey));
      final avatar = tester.getRect(find.byType(WebAvatar).first);
      // 뒤로가기는 콘텐츠 좌측선에서 시작하고, 아바타는 그 오른쪽 3.
      expect(back.left, 0);
      expect(avatar.left, back.right + 3);
      // 같은 줄 — 세로 중심이 같다.
      expect(back.center.dy, closeTo(avatar.center.dy, 0.5));
    });

    // 태블릿은 PC 목업 폭(874)으로 묶지 않고 페이지 여백만 두고 꽉 채운다.
    // 768~1023 구간이라 1000폭에서 묶이면 양옆 여백만 커진다.
    testWidgets('1000폭에서 콘텐츠가 874로 묶이지 않는다', (tester) async {
      tester.view.physicalSize = const Size(1000, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ProfileRankBarWeb(
              leading: const Text('내 랭킹'),
              score: 49540,
              rank: 24,
              tierName: '그랜드 마스터',
              tierIconUrl: null,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      // 바가 좌우 여백 20만 빼고 꽉 찬다(= 960).
      expect(tester.getSize(find.byType(ProfileRankBarWeb)).width, 960);
    });

    testWidgets('통계 카드가 태블릿에서도 2열로 선다', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final season = _detail().seasonRankingInfo;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProfileRidingStatsWeb(
              totalCount: season.overallTotalCount,
              slopes: season.countInfo,
              timeCounts: profileTimeCounts(season.timeInfo),
              ownerName: '전일권',
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final leftCard = tester.getTopLeft(find.text('총 라이딩 횟수'));
      final rightCard = tester.getTopLeft(find.text('시간대별 기록'));
      // 같은 줄(위 선이 같다) + 오른쪽 카드가 실제로 오른쪽에 있다.
      expect(leftCard.dy, closeTo(rightCard.dy, 0.5));
      expect(rightCard.dx, greaterThan(leftCard.dx + 300));
    });
  });

  group('모바일(375) 전체 슬로프', () {
    // 크루홈과 같은 동작 — 좁은 화면에서는 팝업 대신 그 자리에서 펼친다.
    // 버튼이 있고 없고에 따라 제목이 위아래로 튀면 안 된다(제목 줄 높이 36 고정).
    testWidgets('버튼이 없어도 제목 위치가 그대로다', (tester) async {
      tester.view.physicalSize = const Size(375, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      Future<double> titleTop(int slopeCount) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProfileRidingStatsWeb(
                totalCount: 135,
                slopes: [
                  for (var i = 1; i <= slopeCount; i++)
                    SlopeCountInfo.fromJson(_slope('슬로프$i', 100 - i, 1.0)),
                ],
                timeCounts: const [57, 102, 135, 36, 15, 0, 0, 0, 0],
                ownerName: '전일권',
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        return tester.getTopLeft(find.text('라이딩 통계')).dy;
      }

      // 9개 → 버튼 있음 / 3개 → 모바일에서는 버튼이 사라진다.
      final withButton = await titleTop(9);
      expect(find.text('전체 슬로프 보기'), findsOneWidget);
      final withoutButton = await titleTop(3);
      expect(find.text('전체 슬로프 보기'), findsNothing);
      expect(withoutButton, withButton);
    });

    testWidgets('`전체 슬로프 보기`를 누르면 목록이 아래로 펼쳐진다', (tester) async {
      tester.view.physicalSize = const Size(375, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      // 상한(7)보다 많아야 펼칠 거리가 생긴다.
      final slopes = [
        for (var i = 1; i <= 9; i++)
          SlopeCountInfo.fromJson(_slope('슬로프$i', 100 - i, 1.0)),
      ];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProfileRidingStatsWeb(
              totalCount: 135,
              slopes: slopes,
              timeCounts: const [57, 102, 135, 36, 15, 0, 0, 0, 0],
              ownerName: '전일권',
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      // 기본은 상위 7개까지만.
      expect(find.text('슬로프7'), findsOneWidget);
      expect(find.text('슬로프8'), findsNothing);

      await tester.tap(find.text('전체 슬로프 보기'));
      await tester.pumpAndSettle();
      expect(find.text('슬로프9'), findsOneWidget);
      expect(find.text('슬로프 접기'), findsOneWidget);

      await tester.tap(find.text('슬로프 접기'));
      await tester.pumpAndSettle();
      expect(find.text('슬로프8'), findsNothing);
    });
  });

  group('모바일 시간대별 기록', () {
    // 9칸이 가로로 밀려나지 않고 **한 화면에** 들어와야 한다(앱과 같은 모양).
    for (final width in [375.0, 320.0]) {
      testWidgets('${width.toInt()}폭에서 가로 스크롤 없이 9칸이 다 보인다', (tester) async {
        tester.view.physicalSize = Size(width, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final season = _detail().seasonRankingInfo;
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ProfileRidingStatsWeb(
                  totalCount: season.overallTotalCount,
                  slopes: season.countInfo,
                  timeCounts: profileTimeCounts(season.timeInfo),
                  ownerName: '전일권',
                ),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        // 라벨이 두 줄로 접혀 9개가 모두 그려진다.
        expect(find.textContaining('00-'), findsOneWidget);
        expect(find.textContaining('22-'), findsOneWidget);
        // 가로 스크롤 뷰로 빠지지 않는다.
        final scrollables = tester
            .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView))
            .where((s) => s.scrollDirection == Axis.horizontal);
        expect(scrollables, isEmpty);
      });
    }
  });

  group('랭킹 바 높이', () {
    // 스켈레톤이 같은 값(모바일 78 / 그 외 54)으로 자리를 잡는다 — 둘이 어긋나면
    // 로딩이 끝나는 순간 화면이 튄다.
    for (final c in [(375.0, 78.0), (800.0, 54.0), (1440.0, 54.0)]) {
      testWidgets('${c.$1.toInt()}폭에서 ${c.$2.toInt()}', (tester) async {
        tester.view.physicalSize = Size(c.$1, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            // 실제 화면처럼 스크롤뷰 안(높이 무제한)에 둔다.
            body: SingleChildScrollView(
              child: ProfileRankBarWeb(
                leading: const Text('내 랭킹'),
                score: 49540,
                rank: 24,
                tierName: '그랜드 마스터',
                // 티어 아이콘(40)이 바 높이를 만든다 — null이면 자리가 사라진다.
                tierIconUrl: 'https://example.com/tier.png',
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(ProfileRankBarWeb)).height, c.$2);
      });
    }
  });

  group('일간 통계 월 네비게이션', () {
    // 라벨 폭을 안 박으면 `5월`(한 자리) ↔ `12월`(두 자리)에서 글자가 넓어지며
    // 좌우 화살표가 8px씩 밀린다(사용자 지적). 폭 고정 전에는 이 테스트가 실패한다.
    testWidgets('달이 바뀌어도 라벨 폭과 화살표 위치가 그대로다', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      Future<(double, double, double)> measure(DateTime month, String label) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: ProfileDailyCalendarWeb(
              month: month,
              countsByDay: const {},
              selectedDay: null,
              today: DateTime(2026, 5, 13),
              onSelectDay: (_) {},
              onPrevMonth: () {},
              onNextMonth: () {},
            ),
          ),
        ));
        await tester.pumpAndSettle();
        final arrows = find.byType(SvgPicture);
        return (
          tester.getSize(find.text(label)).width,
          tester.getTopLeft(arrows.at(0)).dx,
          tester.getTopRight(arrows.at(1)).dx,
        );
      }

      final may = await measure(DateTime(2026, 5), '2026년 5월');
      final dec = await measure(DateTime(2026, 12), '2026년 12월');
      expect(may, dec, reason: '5월=$may 12월=$dec');
    });
  });

  group('레이아웃 (1440 · 800 · 375)', () {
    Future<void> pumpAt(WidgetTester tester, double width, Widget child) async {
      tester.view.physicalSize = Size(width, 1600);
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
      testWidgets('헤더가 ${width.toInt()}폭에서 그려진다', (tester) async {
        await pumpAt(tester, width, ProfileHeaderWeb(info: _detail().friendUserInfo));
        expect(tester.takeException(), isNull);
        expect(find.text('전일권'), findsOneWidget);
        // 프로필 팝업과 같은 순서(리조트 · 크루).
        expect(find.text('휘닉스파크 · 올두맹'), findsOneWidget);
        expect(find.text('상태메시지는 여기에'), findsOneWidget);
      });

      testWidgets('넓은 폭에서 소속줄이 액션 버튼 바로 옆에 붙는다 (${width.toInt()})', (tester) async {
        if (width < 768) return; // 모바일은 가운데 정렬이라 해당 없음
        const actionKey = Key('action');
        await pumpAt(
          tester,
          width,
          ProfileHeaderWeb(
            info: _detail().friendUserInfo,
            action: const SizedBox(key: actionKey, width: 90, height: 36),
          ),
        );
        final affiliationRight = tester.getTopRight(find.text('휘닉스파크 · 올두맹')).dx;
        final actionLeft = tester.getTopLeft(find.byKey(actionKey)).dx;
        final actionRight = tester.getTopRight(find.byKey(actionKey)).dx;
        // 버튼은 오른쪽 끝(패딩 16)에, 소속줄은 버튼과 붙어 있어야 한다.
        expect(actionRight, closeTo(width - 16, 1));
        // 소속줄 오른쪽 끝 ~ 버튼 왼쪽: 화살표(16+4) + 간격(16) 정도.
        expect(actionLeft - affiliationRight, lessThan(60));
        expect(tester.takeException(), isNull);
      });

      testWidgets('파란 랭킹 바가 ${width.toInt()}폭에서 그려진다', (tester) async {
        final season = _detail().seasonRankingInfo;
        await pumpAt(
          tester,
          width,
          ProfileRankBarWeb(
            leading: const Text('내 랭킹'),
            score: season.overallTotalScore,
            rank: season.overallRank,
            tierName: season.tierNameKor,
            tierIconUrl: null,
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('49,540'), findsOneWidget);
        expect(find.text('24'), findsOneWidget);
        expect(find.text('개인 점수'), findsOneWidget);
        expect(find.text('그랜드마스터'), findsOneWidget);
      });

      testWidgets('라이딩 통계가 ${width.toInt()}폭에서 그려진다', (tester) async {
        final season = _detail().seasonRankingInfo;
        await pumpAt(
          tester,
          width,
          ProfileRidingStatsWeb(
            totalCount: season.overallTotalCount,
            slopes: season.countInfo,
            timeCounts: profileTimeCounts(season.timeInfo),
            ownerName: '전일권',
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('135회'), findsOneWidget);
        expect(find.text('스패'), findsOneWidget);
        expect(find.text('시간대별 기록'), findsOneWidget);
      });

      testWidgets('캘린더가 ${width.toInt()}폭에서 그려진다', (tester) async {
        await pumpAt(
          tester,
          width,
          ProfileDailyCalendarWeb(
            month: DateTime(2026, 3),
            countsByDay: const {12: 1, 13: 23},
            selectedDay: 13,
            today: DateTime(2026, 3, 13),
            onSelectDay: (_) {},
            onPrevMonth: () {},
            onNextMonth: () {},
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('2026년 3월'), findsOneWidget);
        // 기록이 있는 날은 횟수를 함께 적는다(13일의 `23` + 23일 칸 = 2개).
        expect(find.text('23'), findsNWidgets(2));
        expect(find.text('31'), findsOneWidget);
      });
    }

    testWidgets('캘린더 칸은 열 폭을 채운 둥근 사각형이다 (알약 모양 회귀 방지)', (tester) async {
      await pumpAt(
        tester,
        1440,
        ProfileDailyCalendarWeb(
          month: DateTime(2026, 3),
          countsByDay: const {12: 1, 13: 23},
          selectedDay: 13,
          today: DateTime(2026, 3, 13),
          onSelectDay: (_) {},
          onPrevMonth: () {},
          onNextMonth: () {},
        ),
      );
      final cell = tester.getSize(
        find
            .byWidgetPredicate((w) => w is SizedBox && w.height == 52 && w.width == double.infinity)
            .first,
      );
      // 목업(1:8090) — 칸 46×52, 칸 사이 6(스트립 열 폭 52 - 좌우 패딩 3*2).
      expect(cell.width, 46);
      expect(cell.height, 52);
    });

    testWidgets('캘린더에서 기록이 있는 날만 누를 수 있다', (tester) async {
      final tapped = <int>[];
      await pumpAt(
        tester,
        1440,
        ProfileDailyCalendarWeb(
          month: DateTime(2026, 3),
          countsByDay: const {12: 1, 13: 23},
          selectedDay: 13,
          today: DateTime(2026, 3, 13),
          onSelectDay: tapped.add,
          onPrevMonth: () {},
          onNextMonth: () {},
        ),
      );
      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
      expect(tapped, [12]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('이미 친구면 버튼이 아니라 앱과 같은 표시로 그린다', (tester) async {
      // 카드 안에서는 Column(center)이라 폭이 늘어나지 않는다 — 같은 조건을 만든다.
      await pumpAt(
        tester,
        1440,
        const Align(
          alignment: Alignment.centerLeft,
          child: WebProfileStateBadge(label: '내 친구', isPositive: true),
        ),
      );
      expect(find.text('내 친구'), findsOneWidget);
      // 앱 프로필(v_friendDetail)과 같은 68×34 알약 · 체크 아이콘 없음.
      expect(tester.getSize(find.byType(WebProfileStateBadge)), const Size(68, 34));
      expect(find.byIcon(Icons.check), findsNothing);
      // 누를 수 있는 것처럼 보이면 안 된다.
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(InkWell), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('방명록 목록과 빈 상태', (tester) async {
      await pumpAt(
        tester,
        375,
        ProfileGuestbookListWeb(
          talks: [_talk('직진유석', '스타크 화이팅!')],
          canDelete: (_) => false,
          canReport: (_) => false,
          onDelete: (_) async => true,
          onReport: (_) async => throw UnimplementedError(),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('직진유석'), findsOneWidget);
      expect(find.text('스타크 화이팅!'), findsOneWidget);

      await pumpAt(
        tester,
        375,
        ProfileGuestbookListWeb(
          talks: const [],
          canDelete: (_) => false,
          canReport: (_) => false,
          onDelete: (_) async => true,
          onReport: (_) async => throw UnimplementedError(),
          emptyHint: '로그인이 필요해요.',
        ),
      );
      expect(find.text('방명록에 안부 인사를 남겨보세요!'), findsOneWidget);
      expect(find.text('로그인이 필요해요.'), findsOneWidget);
    });

    testWidgets('잠긴 방명록 입력줄은 눌러도 전송하지 않고 안내만 한다', (tester) async {
      var locked = 0;
      await pumpAt(
        tester,
        375,
        ProfileGuestbookInputWeb(
          controller: TextEditingController(),
          onSubmit: null,
          onLockedTap: () => locked++,
        ),
      );
      await tester.tap(find.text('방명록을 남겨주세요'));
      await tester.pumpAndSettle();
      expect(locked, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('기록이 없으면 통계 카드에 빈 문구를 보여준다', (tester) async {
      final season = _detail(empty: true).seasonRankingInfo;
      await pumpAt(
        tester,
        800,
        ProfileRidingStatsWeb(
          totalCount: season.overallTotalCount,
          slopes: season.countInfo,
          timeCounts: profileTimeCounts(season.timeInfo),
          ownerName: '전일권',
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('0회'), findsOneWidget);
      // 슬로프·시간대별 **두 카드가 각자** 빈 상태를 보여준다(크루홈과 같은 처리).
      expect(find.text('라이딩 기록이 없어요'), findsNWidgets(2));
    });
  });
}
