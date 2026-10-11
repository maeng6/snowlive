import 'package:com.snowlive/web/view/liveTalk/w_livetalk_step_modal_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_upload_flow_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkUpload_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// 라이브톡 올리기 — `사진 없이 글만 올리기` 경로.
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

  for (final width in <double>[1440, 800, 375]) {
    testWidgets('${width.toInt()}: `사진 없이 글만 올리기`는 카드 안쪽에 여유를 두고 앉는다', (tester) async {
      await openFlow(tester, width);
      expect(tester.takeException(), isNull);
      final entry = tester.getRect(find.text('사진 없이 글만 올리기'));
      final card = cardRect(tester);
      // 예전엔 카드 아래 끝에 붙어 있었다(여백 ~6).
      // 목업 카드 아래 여백: PC 40 / 태블릿 25 (모바일 시트는 10 + 안전영역).
      final minGap = switch (width) { >= 1024 => 36.0, >= 768 => 24.0, _ => 18.0 };
      expect(card.bottom - entry.bottom, greaterThanOrEqualTo(minGap));
      expect(find.text('이미지 없이 글만 올리기'), findsNothing);
    });

    testWidgets('${width.toInt()}: 1단계 → 글만 올리기 → 사진 추가 칸, 카드 높이가 그대로다', (tester) async {
      await openFlow(tester, width);
      final step0 = cardRect(tester).height;

      await tester.tap(find.text('사진 없이 글만 올리기'));
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
    await tester.tap(find.text('사진 없이 글만 올리기'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.text('전체공개'), findsOneWidget);
    expect(cardRect(tester).height, closeTo(step0, 0.5));
  });

  testWidgets('사진을 고른 뒤 `글만 올리기`를 누르면 사진을 빼고 넘어간다', (tester) async {
    await openFlow(tester, 1440);
    vm.setPickedImage(XFile('blob:http://localhost/p'));
    await tester.pump();
    drainImageErrors(tester);
    await tester.tap(find.text('사진 없이 글만 올리기'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(vm.hasPickedImage, isFalse);
    expect(find.text('사진 없이 글만 올려요.'), findsOneWidget);
  });
}
