import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/view/friend/w_friend_page_scaffold_web.dart';
import 'package:com.snowlive/web/view/friend/w_friend_row_web.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart';
import 'package:com.snowlive/web/widget/w_web_settings_row_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// 친구 PC 화면 확정값(피그마 218:68049 / 68136 / 68333 / 68503 / 68675).
/// 눈으로만 맞춰 두면 다음 손질 때 조용히 틀어져서 수치를 여기 묶어 둔다.
Future<void> _pump(WidgetTester tester, Widget child, {double width = 1440}) async {
  tester.view.physicalSize = Size(width, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(GetMaterialApp(
    home: Scaffold(body: Center(child: child)),
  ));
  await tester.pump();
}

/// 스캐폴드는 화면 폭을 그대로 써야 해서 Center로 감싸지 않는다.
Future<void> _pumpFull(WidgetTester tester, Widget child, {required double width}) async {
  tester.view.physicalSize = Size(width, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: child)));
  await tester.pump();
}

/// 팝업은 Overlay에 꽂히므로 띄워 주는 버튼을 거쳐 연다.
Future<void> _openPopup(WidgetTester tester, Future<void> Function(BuildContext) open) async {
  await _pump(
    tester,
    Builder(
      builder: (context) => TextButton(onPressed: () => open(context), child: const Text('열기')),
    ),
  );
  await tester.tap(find.text('열기'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  group('박스 팝업', () {
    testWidgets('안내만 하는 팝업은 확인 한 개 · 파란 채움 없음(218:68675)', (tester) async {
      await _openPopup(
        tester,
        (context) => showWebBoxPopup(
          context: context,
          title: '검색하신 친구가 없습니다.',
          message: '닉네임 전체를 정확히 입력해 주세요.',
          primaryLabel: '확인',
          filledPrimary: false,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('검색하신 친구가 없습니다.'), findsOneWidget);
      expect(find.text('닉네임 전체를 정확히 입력해 주세요.'), findsOneWidget);
      expect(find.text('확인'), findsOneWidget);
      // 채움 버튼(ElevatedButton)이 아니어야 한다 — 안내만 하는 팝업이다.
      expect(find.byType(ElevatedButton), findsNothing);
      // 버튼 폭 240 = 카드 288 − 좌우 패딩 24*2.
      expect(tester.getSize(find.ancestor(of: find.text('확인'), matching: find.byType(TextButton)).first).width,
          240);
    });

    testWidgets('고르는 팝업은 파란 채움 + 아래 텍스트 버튼(218:68503)', (tester) async {
      await _openPopup(
        tester,
        (context) => showWebBoxPopup(
          context: context,
          title: '고기=해우네정육님을\n친구로 추가하시겠어요?',
          primaryLabel: '친구 추가하기',
          secondaryLabel: '다음에 하기',
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('친구 추가하기'), findsOneWidget);
      expect(find.text('다음에 하기'), findsOneWidget);
      // 주 버튼이 위, 부 버튼이 아래(세로 배치).
      expect(tester.getRect(find.text('친구 추가하기')).bottom,
          lessThan(tester.getRect(find.text('다음에 하기')).top));
    });
  });

  group('행 액션 버튼(218:68231)', () {
    testWidgets('흰 배경 + gray200 테두리 · 라운드 20 · ExtraBold 12', (tester) async {
      await _pump(tester, const FriendRowActionButton(label: '요청 취소'));

      expect(tester.takeException(), isNull);
      final material = tester.widget<Material>(
        find.descendant(of: find.byType(FriendRowActionButton), matching: find.byType(Material)).first,
      );
      expect(material.color, SDSColor.snowliveWhite);
      final shape = material.shape as RoundedRectangleBorder;
      expect(shape.side.color, SDSColor.gray200);
      expect(shape.borderRadius, BorderRadius.circular(20));

      final label = tester.widget<Text>(find.text('요청 취소'));
      expect(label.style?.fontSize, 12);
      expect(label.style?.fontWeight, SDSTextStyle.extraBold.fontWeight);
      expect(label.style?.color, SDSColor.gray900);
    });

    testWidgets('거절처럼 되돌릴 수 없는 동작만 글자가 빨갛다', (tester) async {
      await _pump(tester, const FriendRowActionButton(label: '거절', isDestructive: true));
      expect(tester.widget<Text>(find.text('거절')).style?.color, SDSColor.red);
    });
  });

  group('설정 행(218:68126)', () {
    testWidgets('친구 설정은 글줄 27 + 상하 8 = 피치 43', (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 520,
          child: WebSettingsRow(label: '차단한 친구 관리', verticalPadding: 8, onTap: () {}),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(WebSettingsRow)).height, 43);
      // 꺾쇠는 24 · #B7B7B7(gray400).
      final chevron = tester.widget<Icon>(find.byIcon(Icons.chevron_right));
      expect(chevron.size, 24);
      expect(chevron.color, SDSColor.gray400);
    });

    testWidgets('기본값(크루 설정)은 피치 51 그대로', (tester) async {
      await _pump(
        tester,
        SizedBox(width: 520, child: WebSettingsRow(label: '차단한 친구 관리', onTap: () {})),
      );
      expect(tester.getSize(find.byType(WebSettingsRow)).height, 51);
    });

    testWidgets('개수 배지는 파란 알약 · ExtraBold 12', (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 520,
          child: WebSettingsRow(
              label: '친구 요청 관리', badgeCount: 2, verticalPadding: 8, onTap: () {}),
        ),
      );

      expect(tester.takeException(), isNull);
      final badge = tester.widget<Text>(find.text('2'));
      expect(badge.style?.fontSize, 12);
      expect(badge.style?.fontWeight, SDSTextStyle.extraBold.fontWeight);
      expect(badge.style?.color, SDSColor.snowliveWhite);
      // 라벨 바로 오른쪽에 붙는다(꺾쇠 쪽으로 밀리지 않는다).
      expect(tester.getRect(find.text('2')).left,
          lessThan(tester.getRect(find.byIcon(Icons.chevron_right)).left));
    });

    testWidgets('개수가 0이면 배지를 그리지 않는다', (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 520,
          child: WebSettingsRow(
              label: '친구 요청 관리', badgeCount: 0, verticalPadding: 8, onTap: () {}),
        ),
      );
      expect(find.text('0'), findsNothing);
    });
  });

  group('콘텐츠 열 폭', () {
    // 자식은 스캐폴드 Column의 stretch를 타고 열 폭만큼 늘어난다 → 폭 측정용.
    const probe = SizedBox(key: Key('probe'), height: 10);

    testWidgets('PC 하위 화면은 알림·설정과 같은 800으로 묶는다', (tester) async {
      await _pumpFull(
        tester,
        const FriendPageScaffoldWeb(title: '설정', child: probe),
        width: 1440,
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(const Key('probe'))).width, 800);
    });

    testWidgets('태블릿은 좌우 여백 20만 두고 꽉 채운다', (tester) async {
      await _pumpFull(
        tester,
        const FriendPageScaffoldWeb(title: '설정', child: probe),
        width: 800,
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(const Key('probe'))).width, 800 - 20 * 2);
    });

    testWidgets('모바일은 좌우 여백 16만 두고 꽉 채운다', (tester) async {
      await _pumpFull(
        tester,
        const FriendPageScaffoldWeb(title: '설정', child: probe),
        width: 375,
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(const Key('probe'))).width, 375 - 16 * 2);
    });
  });
}
