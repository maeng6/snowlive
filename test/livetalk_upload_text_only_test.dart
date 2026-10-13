import 'package:com.snowlive/web/view/liveTalk/w_livetalk_step_modal_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_upload_flow_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkUpload_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// 라이브톡 올리기 — **사진 없이 글만 올리는** 경로.
/// 예전에는 1단계에 `사진 없이 글만 올리기` 버튼이 따로 있었는데, 안내 문구에 녹이고
/// 다음 버튼을 늘 활성으로 바꿨다(사용자 확정). 그 동작을 여기서 못 박는다.
void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  late LiveTalkUploadViewModelWeb vm;

  /// main_web.dart와 같은 구조(라우트 위 최상위 Overlay)에 플로우를 띄운다.
  Future<void> openFlow(WidgetTester tester, double width, {int? crewId}) async {
    tester.view.physicalSize = Size(width, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    vm = Get.put(LiveTalkUploadViewModelWeb());

    late BuildContext rootContext;
    await tester.pumpWidget(GetMaterialApp(
      builder: (context, child) => Overlay(initialEntries: [OverlayEntry(builder: (_) => child!)]),
      home: Builder(builder: (context) {
        rootContext = context;
        return const SizedBox.shrink();
      }),
    ));
    showLiveTalkUploadFlow(context: rootContext, userId: 1, crewId: crewId);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// 카드(PC·태블릿) 또는 시트(모바일) — 흰 Material 중 가장 바깥 것.
  Rect cardRect(WidgetTester tester) {
    final card = find.byWidgetPredicate((w) =>
        w is Material &&
        w.color == Colors.white &&
        (w.borderRadius == BorderRadius.circular(16) ||
            w.borderRadius == const BorderRadius.vertical(top: Radius.circular(16))));
    return tester.getRect(card.first);
  }

  void drainImageErrors(WidgetTester tester) {
    Object? e;
    while ((e = tester.takeException()) != null) {
      expect('$e', contains('HTTP request failed'), reason: '$e');
    }
  }

  /// 1단계의 진행 버튼 — PC·태블릿은 `›` 원형, 모바일 시트는 `다음` 알약이다.
  Finder nextButton(double width) =>
      width < 768 ? find.text('다음') : find.byIcon(Icons.chevron_right);

  for (final width in <double>[1440, 800, 375]) {
    testWidgets('${width.toInt()}: 안내 문구가 사진 없이도 올릴 수 있다고 알려준다', (tester) async {
      await openFlow(tester, width);
      expect(tester.takeException(), isNull);
      expect(find.textContaining('사진 없이 글만 올려도 괜찮아요'), findsOneWidget);
      // 따로 있던 버튼은 없앴다.
      expect(find.text('사진 없이 글만 올리기'), findsNothing);
    });

    testWidgets('${width.toInt()}: 사진을 안 골라도 다음으로 넘어간다, 카드 높이도 그대로', (tester) async {
      await openFlow(tester, width);
      final step0 = cardRect(tester).height;

      await tester.tap(nextButton(width));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.text('사진 추가'), findsOneWidget);
      expect(find.text('0 / $kLiveTalkMaxLength'), findsOneWidget);
      expect(cardRect(tester).height, closeTo(step0, 0.5));

      // 글을 쓰면 글자 수가 따라온다.
      await tester.enterText(find.byType(TextField), '오늘 설질 최고');
      await tester.pump();
      expect(find.text('8 / $kLiveTalkMaxLength'), findsOneWidget);

      // 사진을 넣으면 같은 자리가 썸네일이 되고(높이 그대로), ✕로 빼면 다시 사진 추가 칸.
      vm.setPickedImage(XFile('blob:http://localhost/p'));
      await tester.pump();
      drainImageErrors(tester);
      expect(find.text('사진 추가'), findsNothing);
      expect(cardRect(tester).height, closeTo(step0, 0.5));
      await tester.tap(find.byKey(const ValueKey('livetalk-remove-photo')));
      await tester.pump();
      expect(vm.hasPickedImage, isFalse);
      expect(find.text('사진 추가'), findsOneWidget);
      // 쓰던 글은 남아 있다.
      expect(find.text('오늘 설질 최고'), findsOneWidget);
    });
  }

  testWidgets('크루톡도 두 단계 높이가 같다(공개범위 줄 포함)', (tester) async {
    await openFlow(tester, 1440, crewId: 334);
    final step0 = cardRect(tester).height;
    await tester.tap(nextButton(1440));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.text('전체공개'), findsOneWidget);
    expect(cardRect(tester).height, closeTo(step0, 0.5));
  });

  testWidgets('고른 사진은 다음 단계로 그대로 따라간다', (tester) async {
    await openFlow(tester, 1440);
    vm.setPickedImage(XFile('blob:http://localhost/p'));
    await tester.pump();
    drainImageErrors(tester);
    await tester.tap(nextButton(1440));
    await tester.pump(const Duration(milliseconds: 300));
    drainImageErrors(tester);
    // 예전 `글만 올리기` 버튼은 사진을 빼고 넘어갔지만, 다음 버튼은 그대로 들고 간다.
    expect(vm.hasPickedImage, isTrue);
    expect(find.text('글 내용을 입력하세요.'), findsOneWidget);
  });
}
