import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:com.snowlive/web/view/home/w_home_hero_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('히어로 캐러셀이 5초마다 다음 슬라이드로 롤링된다', (tester) async {
    const banners = [
      HomeBanner(imageUrl: 'https://x/1.png', landingUrl: '', title: '첫번째'),
      HomeBanner(imageUrl: 'https://x/2.png', landingUrl: '', title: '두번째'),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 400,
            child: HomeHeroWeb(banners: banners, isLoaded: true),
          ),
        ),
      ),
    );
    // 히어로는 첫 이미지 precache가 끝나야(성공·실패 무관) 스켈레톤을 걷는다.
    // 테스트 HttpClient는 항상 400이라 precache 실패 예외를 비워 준다.
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    while (tester.takeException() != null) {}

    expect(find.text('첫번째'), findsOneWidget);

    // 5초 + 애니메이션 시간 경과 → 두번째 슬라이드.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('두번째'), findsOneWidget);
  });
}
