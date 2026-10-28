// 가입 완료 모달의 앱 다운로드 QR.
//
// 예전에는 앱스토어·구글플레이 QR을 **두 장** 띄웠다. QR 하나에는 URL 하나만 들어가고
// 스캔하는 기기는 화면을 띄운 기기와 달라서, 화면 쪽에서 UA로 갈라 한 장만 띄우면
// 아이폰으로 스캔했는데 Play 스토어가 열렸기 때문이다.
// 지금은 딥링크 한 장이다 — 스캔한 기기가 직접 접속하므로 서버가 그 기기로 분기한다.
import 'package:com.snowlive/web/util/web_external_links.dart';
import 'package:com.snowlive/web/view/onboarding/w_onboarding_complete_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  /// 모달은 최상위 Overlay에 직접 꽂히므로 그 구조 그대로 띄운다.
  Future<void> pumpModal(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Overlay(initialEntries: [
        OverlayEntry(builder: (context) {
          ctx = context;
          return const SizedBox.expand();
        }),
      ]),
    ));
    showOnboardingCompleteModal(ctx, displayName: '홍길동');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  for (final width in [1440.0, 800.0]) {
    testWidgets('${width.toInt()}폭 — 앱 다운로드 QR은 딥링크 한 장', (tester) async {
      await pumpModal(tester, width);

      expect(find.byType(QrImageView), findsOneWidget,
          reason: '스토어별 2장이 아니라 딥링크 1장이어야 한다');
      // QrImageView는 data를 private으로 들고 있어 위젯에서 읽을 수 없다 →
      // 주소 자체는 상수로 고정한다(화면은 이 상수만 참조한다).
      expect(kAppDeepLinkUrl, 'https://app.snowlive.kr/');
    });
  }

  testWidgets('모바일 카드는 QR 대신 다운로드 버튼 — 스캔할 기기가 곧 보는 기기다',
      (tester) async {
    await pumpModal(tester, 375);
    expect(find.byType(QrImageView), findsNothing);
    expect(find.text('앱 다운로드'), findsOneWidget);
  });

  testWidgets('PC 카드는 QR이 한 장이 되면서 팝업 표준 폭으로 돌아왔다', (tester) async {
    await pumpModal(tester, 1440);
    // 카드 폭 288 — 예전에는 QR 2장 때문에 390이었다.
    final card = tester.getSize(find.ancestor(
      of: find.byType(QrImageView),
      matching: find.byType(ConstrainedBox),
    ).last);
    expect(card.width, lessThanOrEqualTo(288));
  });
}
