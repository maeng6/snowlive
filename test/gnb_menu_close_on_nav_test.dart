// 모바일 웹 메뉴 패널(더보기)은 라우트가 아니라 **셸의 Stack 위층**이다.
// 패널 위에서 뜬 팝업(아바타 탭 → 프로필 미리보기 → `프로필 보러가기`)이 화면을
// 바꿔도 패널이 그대로 덮고 있어, 이동이 안 된 것처럼 보였다.
// 라우트 변경과 공용 네비 신호 양쪽으로 닫히는지 지킨다.
import 'package:com.snowlive/web/widget/gnb/w_gnb_current_route_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_drawer.dart';
import 'package:com.snowlive/web/widget/gnb/w_web_shell.dart';
import 'package:flutter/material.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/web_profile_nav_web.dart';
import 'package:com.snowlive/web/viewmodel/paid/vm_paidVisibility_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(UserViewModel());
    Get.put(PaidVisibilityControllerWeb());
  });
  tearDown(Get.reset);

  testWidgets('라우트가 바뀌면 메뉴 패널이 닫힌다 (모바일)', (tester) async {
    tester.view.physicalSize = const Size(375, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    currentRouteWeb.value = '/';

    await tester.pumpWidget(const MaterialApp(
      home: WebAppShell(child: Center(child: Text('페이지'))),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(WebGnbMenuPanel), findsNothing);

    // 햄버거(AnimatedIcon menu_close를 가진 IconButton)를 눌러 패널을 연다
    final hamburger = find.ancestor(
        of: find.byType(AnimatedIcon), matching: find.byType(IconButton));
    expect(hamburger, findsOneWidget, reason: '햄버거 버튼을 찾아야 한다');
    await tester.tap(hamburger);
    await tester.pumpAndSettle();
    expect(find.byType(WebGnbMenuPanel), findsOneWidget, reason: '패널이 열려야 한다');
    print('햄버거 탭 후 패널 열림 = true');

    // 패널 위 팝업이 Get.toNamed 한 것과 같은 상황 — 라우트만 바뀐다
    currentRouteWeb.value = '/user-profile';
    await tester.pumpAndSettle();
    final closed = find.byType(WebGnbMenuPanel).evaluate().isEmpty;
    print('라우트 변경 후 패널 닫힘 = $closed');
    expect(closed, isTrue);
  });

  testWidgets('같은 라우트로 교체돼도(프로필→프로필) 패널이 닫힌다', (tester) async {
    tester.view.physicalSize = const Size(375, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    currentRouteWeb.value = '/user-profile';

    await tester.pumpWidget(const MaterialApp(
      home: WebAppShell(child: Center(child: Text('프로필'))),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.ancestor(
        of: find.byType(AnimatedIcon), matching: find.byType(IconButton)));
    await tester.pumpAndSettle();
    expect(find.byType(WebGnbMenuPanel), findsOneWidget);

    // 라우트명은 그대로 — 공용 헬퍼의 이동 신호만 올라간다
    webRouteNavigationTick.value++;
    await tester.pumpAndSettle();
    final closed = find.byType(WebGnbMenuPanel).evaluate().isEmpty;
    print('같은 라우트 교체 후 패널 닫힘 = $closed');
    expect(closed, isTrue);
  });
}
