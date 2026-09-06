import 'package:com.snowlive/core/model/m_friendDetail.dart';
import 'package:com.snowlive/core/model/m_friendsTalk.dart';
import 'package:com.snowlive/web/view/profile/w_profile_calendar_web.dart';
import 'package:com.snowlive/web/view/profile/w_profile_guestbook_web.dart';
import 'package:com.snowlive/web/view/profile/w_profile_widgets_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_card_web.dart';
import 'package:flutter/material.dart';
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
            .byWidgetPredicate((w) => w is SizedBox && w.height == 54 && w.width == double.infinity)
            .first,
      );
      // 스트립 열 폭 52 - 좌우 패딩 4 = 48 → 높이(54)와 비슷한 사각형.
      expect(cell.width, 48);
      expect(cell.height, 54);
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

    testWidgets('이미 친구면 버튼이 아니라 표시로 그린다', (tester) async {
      await pumpAt(tester, 1440, const WebProfileStateBadge(label: '친구', isPositive: true));
      expect(find.text('친구'), findsOneWidget);
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
          emptyHint: '안부 인사를 남기기 위해서는 먼저 친구가 되어야해요.',
        ),
      );
      expect(find.text('방명록에 안부 인사를 남겨보세요!'), findsOneWidget);
      expect(find.text('안부 인사를 남기기 위해서는 먼저 친구가 되어야해요.'), findsOneWidget);
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
      expect(find.text('라이딩 기록이 없어요'), findsOneWidget);
    });
  });
}
