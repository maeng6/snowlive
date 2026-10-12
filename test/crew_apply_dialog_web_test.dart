import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 크루 가입 신청 다이얼로그 — 기본 문구는 **힌트**(회색)이고, 비워두면 그 문구로 신청된다.
void main() {
  const defaultMessage = '안녕하세요. 크루 가입 신청합니다.';

  Future<Future<String?>> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    late BuildContext root;
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => Overlay(initialEntries: [OverlayEntry(builder: (_) => child!)]),
      home: Builder(builder: (c) {
        root = c;
        return const SizedBox.shrink();
      }),
    ));
    final result = showWebCrewApplyDialog(context: root, crewName: 'STN');
    await tester.pump();
    return result;
  }

  testWidgets('기본 문구는 입력된 글자가 아니라 힌트색 힌트다', (tester) async {
    await open(tester);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);
    expect(field.decoration!.hintText, defaultMessage);
    expect(field.decoration!.hintStyle!.color, SDSColor.gray400);
  });

  testWidgets('비워두고 신청하면 기본 문구로 신청된다', (tester) async {
    final result = await open(tester);
    await tester.tap(find.text('신청하기'));
    await tester.pump();
    expect(await result, defaultMessage);
  });

  testWidgets('직접 쓰면 쓴 내용으로 신청된다', (tester) async {
    final result = await open(tester);
    await tester.enterText(find.byType(TextField), '  보드 3년차입니다  ');
    await tester.tap(find.text('신청하기'));
    await tester.pump();
    expect(await result, '보드 3년차입니다');
  });

  testWidgets('취소는 null', (tester) async {
    final result = await open(tester);
    await tester.tap(find.text('취소'));
    await tester.pump();
    expect(await result, isNull);
  });
}
