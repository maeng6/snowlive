// 웹 토스트는 전체가 하나로 통일돼 있다(사용자 확정): 검정 80% 배경 · 흰 글자 ·
// 상단바 아래 16 · 제목 Bold / 본문 Regular, 그리고 등장·퇴장 애니메이션.
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_desktop_topbar.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// 토스트를 띄울 화면을 세우고, 띄우는 함수를 돌려준다.
  Future<void Function({String? title})> pumpHost(WidgetTester tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        ctx = context;
        return const Scaffold(body: SizedBox.expand());
      }),
    ));
    return ({String? title}) =>
        showWebToast(ctx, '저장했어요', title: title);
  }

  Finder pill() => find.ancestor(
        of: find.text('저장했어요'),
        matching: find.byType(Material),
      );

  testWidgets('검정 80% 알약 · 흰 글자 · 상단바 아래 16', (tester) async {
    final show = await pumpHost(tester);
    show();
    await tester.pumpAndSettle();

    final material = tester.widget<Material>(pill().first);
    expect(material.color, SDSColor.snowliveBlack.withValues(alpha: 0.8));

    final text = tester.widget<Text>(find.text('저장했어요'));
    expect(text.style?.color, SDSColor.snowliveWhite);
    expect(text.style?.fontSize, kWebToastFontSize);
    // 제목이 없으면 한 줄이고 그 한 줄은 Bold다.
    expect(text.style?.fontWeight, SDSTextStyle.bold.fontWeight);

    expect(
      tester.getRect(pill().first).top,
      closeTo(kGnbDesktopTopBarHeight + kWebToastTopGap, 0.5),
    );
  });

  testWidgets('제목을 주면 윗줄 Bold · 아랫줄 Regular', (tester) async {
    final show = await pumpHost(tester);
    show(title: '완료');
    await tester.pumpAndSettle();

    expect(tester.widget<Text>(find.text('완료')).style?.fontWeight,
        SDSTextStyle.bold.fontWeight);
    expect(tester.widget<Text>(find.text('저장했어요')).style?.fontWeight,
        SDSTextStyle.regular.fontWeight);
    // 두 줄 모두 같은 크기(굵기로만 구분).
    expect(tester.widget<Text>(find.text('완료')).style?.fontSize,
        kWebToastFontSize);
  });

  testWidgets('위에서 내려오며 나타나고, 시간이 지나면 올라가며 사라진다',
      (tester) async {
    final show = await pumpHost(tester);
    show();

    // 등장 직후엔 투명하고 위로 밀려 있다.
    await tester.pump();
    final startOpacity = tester.widget<Opacity>(
        find.ancestor(of: pill().first, matching: find.byType(Opacity)).first);
    expect(startOpacity.opacity, lessThan(0.2));
    final startTop = tester.getRect(pill().first).top;

    await tester.pump(kWebToastFadeIn);
    expect(
      tester.widget<Opacity>(
        find.ancestor(of: pill().first, matching: find.byType(Opacity)).first,
      ).opacity,
      closeTo(1, 0.01),
    );
    expect(tester.getRect(pill().first).top, greaterThan(startTop),
        reason: '위에서 아래로 내려와 제자리에 선다');

    // 표시 시간이 지나면 퇴장 애니메이션을 타고 걷힌다.
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('저장했어요'), findsOneWidget, reason: '아직 사라지는 중');
    await tester.pumpAndSettle();
    expect(find.text('저장했어요'), findsNothing);
  });
}
