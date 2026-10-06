import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_alarmcenter..dart';
import 'package:com.snowlive/core/model/m_alarmCenterList.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/alarm/v_alarmCenter_web.dart';
import 'package:com.snowlive/web/viewmodel/alarm/vm_alarmCenter_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_nav_items.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

const int _me = 100;
const int _myCrew = 334;

Map<String, dynamic> _json(
  int id, {
  int kind = AlarmKind.friendRequest,
  bool active = true,
  int? pkFleamarket,
  int? pkCommunity,
  int? pkReplyFleamarket,
  int? pkReplyCommunity,
  int? crewLeader,
  String? textMain,
  String? textSub,
}) =>
    {
      'alarmcenter_id': id,
      'alarminfo': {
        'alarminfo_id': kind,
        'alarminfo_name': '알림종류$kind',
        'alarm_text': '님이 알림을 보냈어요.',
      },
      'date': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
      'active': active,
      'other_user_info': {'user_id': 7, 'display_name': '스노우', 'profile_image_url_user': ''},
      'pk_fleamarket': pkFleamarket,
      'pk_community': pkCommunity,
      'pk_reply_fleamarket': pkReplyFleamarket,
      'pk_reply_community': pkReplyCommunity,
      'crew_leader_user_id': crewLeader,
      'text_main': textMain,
      'text_sub': textSub,
    };

AlarmCenterModel _alarm(int id, {int kind = AlarmKind.friendRequest, bool active = true,
        int? pkFleamarket, int? pkCommunity, int? pkReplyFleamarket, int? pkReplyCommunity,
        int? crewLeader}) =>
    AlarmCenterModel.fromJson(_json(id,
        kind: kind,
        active: active,
        pkFleamarket: pkFleamarket,
        pkCommunity: pkCommunity,
        pkReplyFleamarket: pkReplyFleamarket,
        pkReplyCommunity: pkReplyCommunity,
        crewLeader: crewLeader));

/// 서버 대신 쓰는 가짜 API. 페이지는 `url`(null = 첫 페이지)로 고른다.
class _FakeAlarmAPI implements AlarmCenterAPI {
  Map<String?, Map<String, dynamic>> pages = {};
  bool failList = false;
  bool failUpdate = false;
  bool failDelete = false;
  final List<int> updated = [];
  final List<int> deleted = [];

  @override
  Future<ApiResponse> fetchAlarmCenterList({required int userId, int? alarminfoId, String? url}) async {
    if (failList) return ApiResponse.error({'detail': 'x'});
    return ApiResponse.success(pages[url] ?? {'count': 0, 'next': null, 'results': []});
  }

  @override
  Future<ApiResponse> updateAlarmCenter(int alarmCenterId, Map<String, dynamic> body) async {
    updated.add(alarmCenterId);
    return failUpdate ? ApiResponse.error({'detail': 'x'}) : ApiResponse.success({});
  }

  @override
  Future<ApiResponse> deleteAlarmCenter(int alarmCenterId) async {
    deleted.add(alarmCenterId);
    return failDelete ? ApiResponse.error({'detail': 'x'}) : ApiResponse.success({});
  }
}

void _login({int? crewId = _myCrew}) {
  final user = Get.put(UserViewModel());
  user.updateUserModel_data(
      {'user_id': _me, 'crew_id': crewId, 'date_joined': '2024-01-01T00:00:00Z'});
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  group('알림 → 웹 이동', () {
    String? routeOf(AlarmCenterModel a, {int? me = _me, int? crew = _myCrew}) =>
        alarmTapTarget(a, myUserId: me, myCrewId: crew).route;
    String? messageOf(AlarmCenterModel a, {int? me = _me, int? crew = _myCrew}) =>
        alarmTapTarget(a, myUserId: me, myCrewId: crew).message;

    test('1 친구 요청 → 친구 요청 관리', () {
      expect(routeOf(_alarm(1, kind: AlarmKind.friendRequest)), WebRoutes.friendRequests);
    });

    test('2 방명록 → 내 프로필 방명록 탭', () {
      expect(routeOf(_alarm(1, kind: AlarmKind.guestbook)),
          '${WebRoutes.userProfile}?id=$_me&tab=${WebRoutes.userProfileTabGuestbook}');
    });

    test('3 크루 가입 신청 — 크루장이면 신청 목록, 아니면 권한 안내', () {
      expect(routeOf(_alarm(1, kind: AlarmKind.crewApply, crewLeader: _me)),
          '${WebRoutes.crewApplications}?id=$_myCrew');
      final notLeader = _alarm(1, kind: AlarmKind.crewApply, crewLeader: 999);
      expect(routeOf(notLeader), isNull);
      expect(messageOf(notLeader), '권한이 없어요.');
      // 크루장이었는데 지금 크루가 없으면(위임·탈퇴) 갈 곳이 없다.
      expect(messageOf(_alarm(1, kind: AlarmKind.crewApply, crewLeader: _me), crew: null),
          '권한이 없어요.');
    });

    test('4 중고거래 댓글 / 5 커뮤니티 댓글 → 글 상세', () {
      expect(routeOf(_alarm(1, kind: AlarmKind.fleamarketComment, pkFleamarket: 55)),
          '${WebRoutes.fleamarketDetail}?id=55');
      expect(routeOf(_alarm(1, kind: AlarmKind.communityComment, pkCommunity: 66)),
          '${WebRoutes.communityDetail}?id=66');
      expect(messageOf(_alarm(1, kind: AlarmKind.fleamarketComment)), '삭제된 게시글이에요.');
    });

    test('6 답글 — 채워진 pk_reply_* 쪽 게시판 상세', () {
      expect(
          routeOf(_alarm(1, kind: AlarmKind.reply, pkReplyCommunity: 9, pkCommunity: 66)),
          '${WebRoutes.communityDetail}?id=66');
      expect(
          routeOf(_alarm(1, kind: AlarmKind.reply, pkReplyFleamarket: 9, pkFleamarket: 55)),
          '${WebRoutes.fleamarketDetail}?id=55');
      expect(messageOf(_alarm(1, kind: AlarmKind.reply)), '삭제된 게시글이에요.');
    });

    test('모르는 종류는 이동도 안내도 없다', () {
      final t = alarmTapTarget(_alarm(1, kind: 99), myUserId: _me, myCrewId: _myCrew);
      expect(t.route, isNull);
      expect(t.message, isNull);
    });
  });

  group('뷰모델', () {
    late _FakeAlarmAPI api;
    late AlarmCenterViewModelWeb vm;

    setUp(() {
      _login();
      api = _FakeAlarmAPI();
      vm = AlarmCenterViewModelWeb(api: api);
    });

    test('첫 페이지 + 다음 페이지(겹치는 알림은 한 번만)', () async {
      api.pages = {
        null: {'next': 'p2', 'results': [_json(1), _json(2)]},
        'p2': {'next': null, 'results': [_json(2), _json(3)]},
      };
      await vm.refreshList();
      expect(vm.items.map((a) => a.alarmCenterId), [1, 2]);
      expect(vm.hasMore, isTrue);
      await vm.loadMore();
      expect(vm.items.map((a) => a.alarmCenterId), [1, 2, 3]);
      expect(vm.hasMore, isFalse);
    });

    test('목록 실패는 에러 상태', () async {
      api.failList = true;
      await vm.refreshList();
      expect(vm.hasError, isTrue);
      expect(vm.isLoaded, isFalse);
    });

    test('읽음 처리 — 성공하면 흐려지고, 실패하면 되돌린다', () async {
      api.pages = {null: {'next': null, 'results': [_json(1), _json(2)]}};
      await vm.refreshList();
      expect(await vm.markRead(vm.items[0]), isTrue);
      expect(vm.items[0].active, isFalse);
      expect(api.updated, [1]);

      api.failUpdate = true;
      expect(await vm.markRead(vm.items[1]), isFalse);
      expect(vm.items[1].active, isTrue);

      // 이미 읽은 알림은 다시 보내지 않는다.
      await vm.markRead(vm.items[0]);
      expect(api.updated, [1, 2]);
    });

    test('삭제 — 실패하면 원래 자리로 돌아온다', () async {
      api.pages = {null: {'next': null, 'results': [_json(1), _json(2), _json(3)]}};
      await vm.refreshList();
      expect(await vm.delete(vm.items[1]), isTrue);
      expect(vm.items.map((a) => a.alarmCenterId), [1, 3]);

      api.failDelete = true;
      expect(await vm.delete(vm.items[0]), isFalse);
      expect(vm.items.map((a) => a.alarmCenterId), [1, 3]);
    });
  });

  group('화면', () {
    late _FakeAlarmAPI api;

    Future<void> pumpAlarm(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      Get.put(AlarmCenterViewModelWeb(api: api));
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: AlarmCenterViewWeb())));
      await tester.pump(); // 첫 프레임 뒤 로드
      await tester.pump();
    }

    setUp(() {
      api = _FakeAlarmAPI()
        ..pages = {
          null: {
            'next': null,
            'results': [
              _json(1, kind: AlarmKind.crewApply, crewLeader: 999, textMain: '가입 신청'),
              _json(2,
                  kind: AlarmKind.communityComment,
                  pkCommunity: 66,
                  active: false,
                  textMain: '아주 긴 게시글 제목 ' * 10,
                  textSub: '댓글 본문 ' * 40),
            ],
          },
        };
    });

    testWidgets('비로그인은 로그인 안내', (tester) async {
      Get.put(UserViewModel());
      await pumpAlarm(tester, 1440);
      expect(find.text('로그인이 필요해요.'), findsOneWidget);
      expect(find.byType(AlarmRowWeb), findsNothing);
    });

    testWidgets('알림이 없으면 빈 상태', (tester) async {
      _login();
      api.pages = {};
      await pumpAlarm(tester, 1440);
      expect(find.text('알림이 없어요.'), findsOneWidget);
    });

    for (final width in <double>[1440, 800, 375]) {
      testWidgets('${width.toInt()}폭: 알림 줄이 넘치지 않고, 읽은 알림은 흐리다', (tester) async {
        _login();
        await pumpAlarm(tester, width);
        expect(tester.takeException(), isNull);
        expect(find.byType(AlarmRowWeb), findsNWidgets(2));
        expect(find.text('알림종류${AlarmKind.crewApply}'), findsOneWidget);

        double opacityOf(int index) => tester
            .widget<Opacity>(find.descendant(
                of: find.byType(AlarmRowWeb).at(index), matching: find.byType(Opacity)).first)
            .opacity;
        expect(opacityOf(0), 1);
        expect(opacityOf(1), closeTo(0.3, 0.001));
      });
    }

    testWidgets('데스크탑 ✕는 hover 때만, 터치 폭은 항상', (tester) async {
      _login();
      await pumpAlarm(tester, 1440);
      bool closeVisible(int index) => tester
          .widget<Visibility>(find.descendant(
              of: find.byType(AlarmRowWeb).at(index), matching: find.byType(Visibility)))
          .visible;
      expect(closeVisible(0), isFalse);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(AlarmRowWeb).first));
      await tester.pump();
      expect(closeVisible(0), isTrue);

      await pumpAlarm(tester, 375);
      expect(closeVisible(0), isTrue);
    });

    testWidgets('✕를 누르면 그 알림이 지워진다', (tester) async {
      _login();
      await pumpAlarm(tester, 375);
      await tester.tap(find.descendant(
          of: find.byType(AlarmRowWeb).first, matching: find.byIcon(Icons.close)));
      await tester.pump();
      expect(api.deleted, [1]);
      expect(find.byType(AlarmRowWeb), findsOneWidget);
      await tester.pump(const Duration(seconds: 4)); // 토스트 정리
    });

    testWidgets('크루장이 아닌 가입 신청 알림은 이동 없이 안내 + 읽음 처리', (tester) async {
      _login();
      await pumpAlarm(tester, 1440);
      await tester.tap(find.text('알림종류${AlarmKind.crewApply}'));
      await tester.pump();
      expect(find.text('권한이 없어요.'), findsOneWidget);
      expect(api.updated, [1]);
      await tester.pump(const Duration(seconds: 4));
    });
  });

  test('사이드바·드로어 2차 메뉴는 친구 / 알림 / 설정 순서, 알림만 빨간 점', () {
    expect(kGnbSecondaryItems.map((i) => i.label), ['친구', '알림', '설정']);
    final alarm = kGnbSecondaryItems[1];
    expect(alarm.routePrefix, WebRoutes.alarm);
    expect(alarm.showsAlarmDot, isTrue);
    expect(kGnbSecondaryItems.where((i) => i.showsAlarmDot), hasLength(1));
  });
}
