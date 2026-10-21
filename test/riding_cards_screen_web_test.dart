// 라이딩 기록 카드 **화면 전체** 배치(PC 65:36714 / 태블릿 65:40630).
//
// 타일 단위 검증은 `riding_cards_web_test.dart`에 있고, 여기서는 폭에 따라
// 시즌 카드가 우측 열 ↔ 상단으로 바뀌는 것과 그 간격을 실측한다.
import 'package:com.snowlive/core/model/m_dailyRidingCard.dart';
import 'package:com.snowlive/core/model/m_seasonRidingCard.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_ridingCard.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/view/ranking/v_ridingCards_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ridingcard_season_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ridingcard_tiles_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// 로그인 확인은 Firebase를 부른다 → 테스트에서는 결과만 정해 준다.
class _FakeAuth extends AuthCheckViewModelWeb {
  @override
  Future<void> checkAuth() async => statusRx.value = WebAuthStatus.authenticated;
}

DailyRidingCard _daily(String date, int id) => DailyRidingCard.fromJson({
      'card_id': id,
      'user_id': 1,
      'date': date,
      'weekday': '금요일',
      'total_slope_count': 7,
      'total_distance': 18,
      'top_speed': 24.6,
      'avg_slope': 48.3,
      'rider_title': '슬로프눈팅중 턴스페셜리스트',
    });

void main() {
  late RidingCardViewModel vm;

  setUp(() {
    Get.testMode = true;
    // user_id가 없으면 화면이 서버 조회를 하지 않는다 → 아래에서 넣은 값이 유지된다.
    Get.put(UserViewModel());
    Get.put<AuthCheckViewModelWeb>(_FakeAuth());
    vm = Get.put(RidingCardViewModel());
    // 2월 5장(그리드 둘째 줄까지) + 1월 1장.
    vm.dailyRidingCardList.assignAll([
      _daily('2026-02-28', 1),
      _daily('2026-02-21', 2),
      _daily('2026-02-14', 3),
      _daily('2026-02-07', 4),
      _daily('2026-02-01', 5),
      _daily('2026-01-17', 6),
    ]);
    vm.seasonRidingCard.value = SeasonRidingCard.fromJson({
      'user_id': 1,
      'display_name': '치자나무',
      'season': '2526',
      'total_slope_count': 3493,
      'total_distance': 939230,
      'top_speed': 24.6,
      'avg_slope': 48.3,
    });
  });

  tearDown(Get.reset);

  Future<void> pumpAt(WidgetTester tester, double width) async {
    // ⚠️ `setSurfaceSize`는 MediaQuery 폭을 바꾸지 않는다(기본 800으로 돈다) —
    // 폭별 분기를 보는 테스트는 view를 직접 세팅해야 한다(다른 웹 테스트와 같은 방식).
    tester.view.physicalSize = Size(width, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: RidingCardsViewWeb()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('PC(1440) — 시즌 카드는 목록 오른쪽, 블록 760', (tester) async {
    await pumpAt(tester, 1440);
    expect(tester.takeException(), isNull);

    final title = tester.getRect(find.text('라이딩 기록 카드'));
    final card = tester.getRect(find.byType(RidingCardSeasonWeb));
    final row = tester.getRect(find.byType(RidingCardListTileWeb).first);

    // 카드는 목록 오른쪽에 있고, 둘을 합친 블록은 760(목록 480 + 간격 60 + 카드 220).
    expect(card.left, greaterThan(row.right));
    expect(card.width, closeTo(220, 0.5));
    expect(row.width, closeTo(480, 0.5));
    expect(card.right - row.left, closeTo(760, 0.5));
    // 콘텐츠는 가운데 정렬 — 좌우가 같은 만큼 남는다.
    expect(row.left - 0, closeTo(1440 - card.right, 1.0));
    // 타이틀은 목록과 같은 좌측선에서 시작한다.
    expect(title.left, closeTo(row.left, 0.5));
  });

  testWidgets('태블릿(800) — 시즌 카드가 목록 위 가운데, 목록은 전체 폭', (tester) async {
    await pumpAt(tester, 800);
    expect(tester.takeException(), isNull);

    final card = tester.getRect(find.byType(RidingCardSeasonWeb));
    final row = tester.getRect(find.byType(RidingCardListTileWeb).first);

    // 카드가 목록보다 위에 있다(세로로 쌓인다).
    expect(card.bottom, lessThan(row.top));
    // 카드 220, 화면 가운데.
    expect(card.width, closeTo(220, 0.5));
    expect(card.center.dx, closeTo(400, 0.5));
    // 목록은 좌우 여백 20을 뺀 전체 폭.
    expect(row.left, closeTo(20, 0.5));
    expect(row.width, closeTo(760, 0.5));
  });

  testWidgets('태블릿은 화면이 넓어져도 목록이 폭을 그대로 채운다', (tester) async {
    await pumpAt(tester, 1000);
    expect(tester.takeException(), isNull);

    final row = tester.getRect(find.byType(RidingCardListTileWeb).first);
    final card = tester.getRect(find.byType(RidingCardSeasonWeb));

    // 760에 갇히지 않고 좌우 여백 20만 남긴다.
    expect(row.left, closeTo(20, 0.5));
    expect(row.width, closeTo(960, 0.5));
    // 시즌 카드는 그대로 220이고 화면 가운데.
    expect(card.width, closeTo(220, 0.5));
    expect(card.center.dx, closeTo(500, 0.5));
  });

  /// 카드(그리드) 보기 — 목업 PC 65:36714 / 태블릿 65:41916.
  /// 둘 다 4열이고 간격이 목록 폭에 비례한다(480→9·12, 760→14.3·19.1).
  Future<void> switchToGrid(WidgetTester tester) async {
    await tester.tap(find.byType(RidingCardGridTileWeb).evaluate().isEmpty
        ? find.byWidgetPredicate((w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName.contains('icon_view_card'))
        : find.byType(RidingCardGridTileWeb).first);
    await tester.pumpAndSettle();
  }

  testWidgets('PC(1440) 카드 보기 — 4열 · 열 간격 12(목업 9 대신 확정값)', (tester) async {
    await pumpAt(tester, 1440);
    await switchToGrid(tester);

    final tiles = find.byType(RidingCardGridTileWeb);
    expect(tiles, findsWidgets);
    final first = tester.getRect(tiles.at(0));
    final second = tester.getRect(tiles.at(1));
    expect(first.width, closeTo(111, 0.5));
    expect(second.left - first.right, closeTo(12, 0.5));
  });

  testWidgets('태블릿(800) 카드 보기 — 4열 · 카드 179.3 · 열 간격 14.3', (tester) async {
    await pumpAt(tester, 800);
    await switchToGrid(tester);

    final tiles = find.byType(RidingCardGridTileWeb);
    final first = tester.getRect(tiles.at(0));
    final second = tester.getRect(tiles.at(1));
    expect(first.width, closeTo(179.3, 0.5));
    expect(second.left - first.right, closeTo(14.25, 0.5));
    // 4열이 목록 폭(760)을 꽉 채운다.
    expect(first.left, closeTo(20, 0.5));
  });

  /// 모바일 목업 65:43841(목록) · 65:45787(카드).
  testWidgets('모바일(375) — 카드 220 가운데 · 목록 전폭 · 월 제목 18', (tester) async {
    await pumpAt(tester, 375);
    expect(tester.takeException(), isNull);

    final card = tester.getRect(find.byType(RidingCardSeasonWeb));
    final row = tester.getRect(find.byType(RidingCardListTileWeb).first);
    final month = tester.widget<Text>(find.text('2월'));

    expect(card.width, closeTo(220, 0.5));
    expect(card.center.dx, closeTo(187.5, 0.5));
    expect(row.left, closeTo(16, 0.5));
    expect(row.width, closeTo(343, 0.5));
    // 월 제목은 앱과 같은 18(PC·태블릿은 24).
    expect(month.style?.fontSize, 18);
  });

  testWidgets('모바일(375) 카드 보기 — 3열 · 카드 110 · 줄 간격 11', (tester) async {
    await pumpAt(tester, 375);
    await switchToGrid(tester);

    final tiles = find.byType(RidingCardGridTileWeb);
    final first = tester.getRect(tiles.at(0));
    final second = tester.getRect(tiles.at(1));
    final fourth = tester.getRect(tiles.at(3));

    expect(first.width, closeTo(110.3, 0.5));
    expect(second.left - first.right, closeTo(6, 0.5));
    // 넷째 카드가 둘째 줄 첫 칸 — 줄 간격 11.
    expect(fourth.left, closeTo(first.left, 0.5));
    expect(fourth.top - first.bottom, closeTo(11, 0.5));
  });

  testWidgets('태블릿(800) — 제목·탭·카드 간격이 목업과 같다', (tester) async {
    await pumpAt(tester, 800);

    final title = tester.getRect(find.text('라이딩 기록 카드'));
    final tab = tester.getRect(find.text('25/26시즌'));
    final card = tester.getRect(find.byType(RidingCardSeasonWeb));

    // 좌우 여백 20 · 상단 20.
    expect(title.left, closeTo(20, 0.5));
    expect(title.top, closeTo(20, 1.0));
    // 제목 ↔ 탭 30, 탭 ↔ 카드 42.
    expect(tab.top - title.bottom, closeTo(30, 2.0));
    expect(card.top - tab.bottom, closeTo(42, 2.0));
  });
}
