// 셸의 오픈채팅은 전 페이지 위에 떠 있어서, 하단 고정 UI(플로팅 바·입력창)가
// 있는 화면에서는 보내기 버튼 같은 것을 덮는다 → 그런 화면에서만 그 위로 16 비킨다.
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/view/home/w_home_open_chat_web.dart';
import 'package:com.snowlive/web/viewmodel/home/vm_openChat_web.dart';
import 'package:com.snowlive/web/viewmodel/paid/vm_paidVisibility_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_current_route_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_web_shell.dart';
import 'package:com.snowlive/web/widget/w_web_bottom_fixed_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// 오픈채팅 VM은 onInit에서 Firestore를 구독한다 → 구독만 없앤 대역.
class _NoFirestoreOpenChat extends OpenChatViewModelWeb {
  @override
  void start() {}
}

void main() {
  const barHeight = 64.0;
  const screenHeight = 800.0;

  setUp(() {
    Get.testMode = true;
    Get.put(UserViewModel());
    Get.put(PaidVisibilityControllerWeb());
    Get.put<OpenChatViewModelWeb>(_NoFirestoreOpenChat());
    currentRouteWeb.value = '/fleamarket';
  });

  tearDown(() {
    webBottomFixedInset.value = 0;
    Get.reset();
  });

  Future<void> pumpShell(WidgetTester tester, {required bool withBottomBar}) async {
    tester.view.physicalSize = const Size(375, screenHeight);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: WebAppShell(
        child: Stack(
          children: [
            const Center(child: Text('페이지')),
            if (withBottomBar)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: WebBottomFixedBar(
                  child: SizedBox(height: barHeight, child: ColoredBox(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  /// 오픈채팅 아래쪽 여백(화면 바닥까지).
  double chatBottomGap(WidgetTester tester) =>
      screenHeight - tester.getRect(find.byType(HomeOpenChatWeb)).bottom;

  testWidgets('하단 고정 UI가 없으면 기존대로 16', (tester) async {
    await pumpShell(tester, withBottomBar: false);
    expect(webBottomFixedInset.value, 0);
    expect(chatBottomGap(tester), closeTo(16, 0.5));
  });

  testWidgets('하단 고정 UI가 있으면 그 위 16으로 올라간다', (tester) async {
    await pumpShell(tester, withBottomBar: true);
    expect(webBottomFixedInset.value, barHeight);
    expect(chatBottomGap(tester), closeTo(barHeight + 16, 0.5));
  });

  testWidgets('그 화면을 떠나면 다시 내려온다', (tester) async {
    await pumpShell(tester, withBottomBar: true);
    expect(chatBottomGap(tester), closeTo(barHeight + 16, 0.5));

    await pumpShell(tester, withBottomBar: false);
    await tester.pumpAndSettle();
    expect(webBottomFixedInset.value, 0, reason: '떠날 때 등록이 풀려야 한다');
    expect(chatBottomGap(tester), closeTo(16, 0.5));
  });

  // 셸이 라우트 Navigator를 감싸는 구조라, 바가 있는 화면 위로 다른 화면을
  // push하면 아래 화면이 **계속 mounted로 남는다** → mount 여부만 보면 바가 없는
  // 화면에서도 오픈채팅이 올라간 채로 떠 있었다(실제 버그).
  testWidgets('바 있는 화면 위로 push하면 내려오고, 돌아오면 다시 올라간다',
      (tester) async {
    tester.view.physicalSize = const Size(375, screenHeight);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      home: WebAppShell(
        // 셸 **안쪽**에 Navigator를 둬 실제 구조와 같게 만든다.
        child: Navigator(
          key: navKey,
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => const Stack(
              children: [
                Center(child: Text('바 있는 화면')),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: WebBottomFixedBar(
                    child: SizedBox(
                        height: barHeight,
                        child: ColoredBox(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(webBottomFixedInset.value, barHeight);

    // 바가 없는 화면을 위에 push — 아래 화면은 mounted로 남아 있다.
    navKey.currentState!.push(MaterialPageRoute(
      builder: (_) => const Scaffold(body: Center(child: Text('바 없는 화면'))),
    ));
    await tester.pumpAndSettle();
    // 라우트 신호는 GetMaterialApp의 routingCallback이 갱신한다 → 테스트에서 직접.
    currentRouteWeb.value = '/pushed';
    await tester.pumpAndSettle();

    expect(find.text('바 없는 화면'), findsOneWidget);
    expect(webBottomFixedInset.value, 0,
        reason: '위에 다른 화면이 떠 있으면 아래 바는 가리지 않는다');
    expect(chatBottomGap(tester), closeTo(16, 0.5));

    // 돌아오면 다시 올라간다.
    navKey.currentState!.pop();
    await tester.pumpAndSettle();
    currentRouteWeb.value = '/fleamarket';
    await tester.pumpAndSettle();

    expect(webBottomFixedInset.value, barHeight);
    expect(chatBottomGap(tester), closeTo(barHeight + 16, 0.5));
  });
}
