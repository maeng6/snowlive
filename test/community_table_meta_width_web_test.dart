import 'package:com.snowlive/web/view/community/w_community_row_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 표(커뮤니티·각종소식) 메타 열 폭 — **끝 글자가 잘리지 않는지**.
///
/// 작성일 열이 잘려 '일'이 안 보이던 버그의 회귀 테스트. 열 폭은 그 페이지의 값이
/// 아니라 형식상 최악값(가장 넓은 숫자)으로 잡고, 브라우저 글자 배율도 반영한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final scalers = <TextScaler>[
    TextScaler.noScaling,
    const TextScaler.linear(1.15),
    const TextScaler.linear(1.3),
    const TextScaler.linear(1.5),
  ];

  test('작성일 열은 어떤 날짜·배율에서도 글자보다 넓다', () {
    for (final scaler in scalers) {
      final width = metaColumnWidth(
        samples: [worstCaseDateSample(scaler)],
        headerText: '작성일',
        textScaler: scaler,
      );

      // 헤더 글자('작성일')가 먼저 잘리던 케이스.
      expect(
        measureWebTextWidth('작성일', webTableHeaderStyle, textScaler: scaler),
        lessThanOrEqualTo(width),
        reason: '헤더 · 배율 $scaler',
      );

      // 모든 달·일 조합(숫자 폭이 제각각이다)에서 값도 들어가야 한다.
      for (var month = 1; month <= 12; month++) {
        for (final day in [1, 9, 10, 18, 28, 30]) {
          final label = communityDateLabelOf(DateTime(2026, month, day));
          expect(
            measureWebTextWidth(label, webTableMetaStyle, textScaler: scaler),
            lessThanOrEqualTo(width),
            reason: '$label · 배율 $scaler',
          );
        }
      }
    }
  });

  test('조회수 열은 자릿수가 같은 어떤 숫자보다 넓다', () {
    for (final scaler in scalers) {
      final width = metaColumnWidth(
        samples: [worstCaseNumberSample(const ['9999'], scaler)],
        headerText: '조회수',
        textScaler: scaler,
      );
      for (final value in ['1000', '8888', '4444', '2026', '7777']) {
        expect(
          measureWebTextWidth(value, webTableMetaStyle, textScaler: scaler),
          lessThanOrEqualTo(width),
          reason: '$value · 배율 $scaler',
        );
      }
    }
  });

  testWidgets('열 폭은 배율에 따라 커진다(캐시되지 않는다)', (tester) async {
    Future<CommunityMetaWidths> widthsAt(double scale) async {
      late CommunityMetaWidths captured;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Builder(
            builder: (context) {
              captured = CommunityMetaWidths.skeletonOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return captured;
    }

    final normal = await widthsAt(1.0);
    final large = await widthsAt(1.5);
    expect(large.date, greaterThan(normal.date));
    expect(large.author, greaterThan(normal.author));
    expect(large.views, greaterThan(normal.views));
  });

  testWidgets('메타 셀은 폭이 모자라도 자르지 않는다', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          // 일부러 글자보다 좁은 칸에 넣는다 — 잘리면 ellipsis/clip이 걸린다.
          child: SizedBox(
            width: 10,
            child: webTableNoClipText('2026. 10. 16', webTableMetaStyle),
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('2026. 10. 16'));
    expect(text.overflow, TextOverflow.visible);
    expect(text.softWrap, isFalse);
  });
}
