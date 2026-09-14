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
    await tester.pump();

    expect(find.text('첫번째'), findsOneWidget);

    // 5초 + 애니메이션 시간 경과 → 두번째 슬라이드.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('두번째'), findsOneWidget);
  });
}
