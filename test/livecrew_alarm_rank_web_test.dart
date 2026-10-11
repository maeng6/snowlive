import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/core/model/m_crewMemberList.dart';
import 'package:com.snowlive/core/model/m_crewMemberRankingList.dart';
import 'package:com.snowlive/core/model/m_fleamarket.dart';
import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_widgets_web.dart' show CrewRoleBadge;
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_header_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_member_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewSetting_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

CrewMember _member(String name, String role) => CrewMember.fromJson({
      'user_info': {
        'user_id': name.hashCode,
        'display_name': name,
        'favorite_resort_nickname': '휘팍',
      },
      'status': role,
    });

CrewRanking _ranked(int i) => CrewRanking.fromJson({
      'user_id': i,
      'display_name': '멤버$i',
      'total_score': 100.0 - i,
      // 서버 overall_rank는 전체 랭킹이라 크루 순위와 다르다 — 화면은 이 값을 쓰지 않는다.
      'overall_rank': 900 + i,
    });

Fleamarket _flea(int i) => Fleamarket.fromJson({
      'flea_id': i,
      'title': '물건 $i',
      'price': 10000,
      'status': '판매중',
      'photos': [],
    });

Future<void> _pumpAt(WidgetTester tester, double width, Widget child) async {
  tester.view.physicalSize = Size(width, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(GetMaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(16), child: child))),
  ));
  await tester.pump();
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  group('멤버 화면 역할 배지', () {
    for (final width in <double>[1440, 375]) {
      testWidgets('${width.toInt()}: 크루장 배지가 닉네임 바로 오른쪽', (tester) async {
        await _pumpAt(
          tester,
          width,
          SizedBox(
            width: 400,
            child: CrewMemberProfileRowWeb(member: _member('스노우', kCrewRoleLeader), onTap: () {}),
          ),
        );
        expect(tester.takeException(), isNull);
        final name = tester.getRect(find.text('스노우'));
        final badge = tester.getRect(find.byType(CrewRoleBadge));
        final row = tester.getRect(find.byType(CrewMemberProfileRowWeb));
        expect(badge.left, greaterThanOrEqualTo(name.right));
        expect(badge.left - name.right, lessThan(12)); // 붙어 있다(행 끝이 아니다)
        expect(row.right - badge.right, greaterThan(100));
      });
    }

    testWidgets('긴 닉네임은 말줄임되고 배지는 그대로 보인다', (tester) async {
      await _pumpAt(
        tester,
        375,
        SizedBox(
          width: 220,
          child: CrewMemberProfileRowWeb(
            member: _member('아주아주아주아주긴닉네임입니다', kCrewRoleManager),
            onTap: () {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(CrewRoleBadge), findsOneWidget);
      final badge = tester.getRect(find.byType(CrewRoleBadge));
      expect(badge.right, lessThanOrEqualTo(tester.getRect(find.byType(CrewMemberProfileRowWeb)).right));
    });

    testWidgets('크루원은 배지가 없다', (tester) async {
      await _pumpAt(tester, 1440,
          SizedBox(width: 400, child: CrewMemberProfileRowWeb(member: _member('일반', kCrewRoleMember), onTap: () {})));
      expect(find.byType(CrewRoleBadge), findsNothing);
    });
  });

  group('TOP 10 순위', () {
    testWidgets('순위 칸에 목록 순서 번호를 그린다(overall_rank 아님)', (tester) async {
      await _pumpAt(
        tester,
        1440,
        SizedBox(
          width: 420,
          child: Column(children: [
            for (var i = 0; i < 3; i++) CrewMemberRankedRowWeb(rank: i + 1, member: _ranked(i), onTap: () {}),
          ]),
        ),
      );
      expect(tester.takeException(), isNull);
      for (final n in ['1', '2', '3']) {
        expect(find.text(n), findsOneWidget);
      }
      expect(find.text('900'), findsNothing);
      // 순위는 아바타(행) 왼쪽.
      expect(tester.getRect(find.text('1')).right,
          lessThanOrEqualTo(tester.getRect(find.byType(CrewMemberRowWeb).first).left));
    });
  });

  group('가입 신청 권한(알림 종)', () {
    test('크루장 · 허가 권한 운영진만', () {
      expect(crewCanManageApplications(role: kCrewRoleLeader, permissionJoin: false), isTrue);
      expect(crewCanManageApplications(role: kCrewRoleManager, permissionJoin: true), isTrue);
      expect(crewCanManageApplications(role: kCrewRoleManager, permissionJoin: false), isFalse);
      expect(crewCanManageApplications(role: kCrewRoleMember, permissionJoin: true), isFalse);
      expect(crewCanManageApplications(role: '', permissionJoin: true), isFalse);
    });

    final info = CrewDetailInfo.fromJson({'crew_id': 334, 'crew_name': '올두맹', 'color': '#3D83ED'});
    const bell = 'assets/imgs/icons/icon_alarm_resortHome.png';
    Finder bellFinder() =>
        find.byWidgetPredicate((w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName == bell);

    testWidgets('권한이 없으면 종이 없다(앱과 같다 — 예전 "준비 중" 종 제거)', (tester) async {
      await _pumpAt(tester, 1440, CrewHomeHeaderWeb(info: info, showSettings: true));
      expect(tester.takeException(), isNull);
      expect(bellFinder(), findsNothing);
    });

    testWidgets('권한이 있으면 종, 누르면 콜백', (tester) async {
      var tapped = 0;
      await _pumpAt(
        tester,
        1440,
        CrewHomeHeaderWeb(
          info: info,
          showSettings: true,
          showAlarm: true,
          alarmUserId: 100, // 테스트엔 Firestore가 없다 → 배지 없이 종만
          onAlarmTap: () => tapped++,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(bellFinder(), findsOneWidget);
      await tester.tap(bellFinder());
      expect(tapped, 1);
      expect(find.byKey(const ValueKey('crew-alarm-new')), findsNothing);
    });
  });

  group('홈 중고거래 점 개수', () {
    int dots(WidgetTester tester) => tester
        .widgetList<Container>(find.descendant(of: find.byType(HomeFleamarketWeb), matching: find.byType(Container)))
        .where((c) => c.constraints?.maxWidth == 6 && c.constraints?.maxHeight == 6)
        .length;

    for (final (width, perPage) in [(1440.0, 6), (800.0, 4), (375.0, 2)]) {
      testWidgets('${width.toInt()}: 30개여도 최대 $kHomeFleamarketMaxPages페이지', (tester) async {
        await _pumpAt(
          tester,
          width,
          HomeFleamarketWeb(items: [for (var i = 0; i < 30; i++) _flea(i)], isLoading: false),
        );
        while (tester.takeException() != null) {} // 카드 이미지(테스트 HttpClient 400)
        expect(dots(tester), kHomeFleamarketMaxPages);
        expect(find.text('물건 0'), findsOneWidget);
        expect(find.text('물건 ${perPage * kHomeFleamarketMaxPages}'), findsNothing);
      });
    }

    testWidgets('적으면 그대로(5개 · PC = 1페이지, 점 없음)', (tester) async {
      await _pumpAt(tester, 1440,
          HomeFleamarketWeb(items: [for (var i = 0; i < 5; i++) _flea(i)], isLoading: false));
      while (tester.takeException() != null) {}
      expect(dots(tester), 0);
    });
  });
}
