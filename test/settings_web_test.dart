import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/view/settings/v_settings_web.dart';
import 'package:com.snowlive/web/viewmodel/settings/vm_settings_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// 설정 화면 — 목업의 그룹·줄 구성과 폭별 뒤로가기 유무.
void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(UserViewModel());
    // AuthCheckViewModelWeb은 onInit에서 Firebase를 부른다 → 화면 렌더에 필요 없으니
    // 등록하지 않는다(로그아웃/탈퇴를 실제로 누르는 테스트는 여기 범위가 아니다).
    Get.put(SettingsViewModelWeb());
  });

  tearDown(Get.reset);

  Future<void> pumpSettings(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SettingsViewWeb())));
    await tester.pump();
  }

  testWidgets('그룹 4개와 줄 10개가 목업 순서대로 있다', (tester) async {
    await pumpSettings(tester, 1440);

    for (final group in ['친구', '중고거래', '약관', '계정']) {
      expect(find.text(group), findsOneWidget, reason: group);
    }
    const labels = [
      '친구 추가 요청',
      '차단한 친구 목록',
      '키워드/카테고리 알림 설정',
      '이용약관',
      '개인정보 처리방침',
      '위치 정보 이용약관',
      '오픈소스 라이선스',
      '멤버십 관리',
      '로그아웃',
      '회원탈퇴',
    ];
    for (final label in labels) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    // 모든 줄에 `>`가 붙는다(목업).
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(labels.length));

    // 그룹 순서 확인 — 위에서 아래로.
    final friend = tester.getRect(find.text('친구 추가 요청')).top;
    final flea = tester.getRect(find.text('키워드/카테고리 알림 설정')).top;
    final terms = tester.getRect(find.text('이용약관')).top;
    final account = tester.getRect(find.text('멤버십 관리')).top;
    expect(friend, lessThan(flea));
    expect(flea, lessThan(terms));
    expect(terms, lessThan(account));
  });

  testWidgets('데스크탑은 뒤로가기가 없고 태블릿·모바일에는 있다', (tester) async {
    await pumpSettings(tester, 1440);
    expect(find.byIcon(Icons.arrow_back), findsNothing);

    await pumpSettings(tester, 900);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await pumpSettings(tester, 375);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('목록은 좌측 정렬 고정폭이다 (넓은 화면에서 늘어나지 않는다)', (tester) async {
    await pumpSettings(tester, 1440);
    final row = tester.getRect(find.text('친구 추가 요청'));
    // 좌측 여백(24) 근처에서 시작하고, 우측은 화면 끝까지 가지 않는다.
    expect(row.left, lessThan(40));
    expect(tester.getRect(find.byIcon(Icons.chevron_right).first).right, lessThan(700));
  });

  testWidgets('배경은 흰색이다', (tester) async {
    await pumpSettings(tester, 1440);
    // 상위(GetMaterialApp/Scaffold)에도 ColoredBox가 있어 설정 화면 안쪽 것을 찾는다.
    final box = tester.widget<ColoredBox>(
      find.descendant(of: find.byType(SettingsViewWeb), matching: find.byType(ColoredBox)).first,
    );
    expect(box.color, const Color(0xFFFFFFFF));
  });
}
