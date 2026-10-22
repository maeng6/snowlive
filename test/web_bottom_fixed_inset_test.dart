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
}
