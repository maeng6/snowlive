import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_card_web.dart';
import 'package:com.snowlive/web/widget/w_web_image_viewer_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_tap_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 웹의 모든 프로필 사진은 [WebProfileTap]을 거쳐 프로필 팝업을 띄운다.
/// 프로필 화면(개인·크루)에서만 팝업 대신 사진 확대([showWebPhotoViewer])를 붙인다.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: child))),
      );

  group('WebProfileTap', () {
    testWidgets('userId가 있으면 탭 대상이 된다', (tester) async {
      await pump(tester, const WebProfileTap(userId: 7, child: SizedBox(width: 40, height: 40)));
      expect(find.byType(MouseRegion), findsWidgets);
      final gesture = tester.widget<GestureDetector>(find.byType(GestureDetector));
      expect(gesture.onTap, isNotNull);
    });

    testWidgets('userId가 없으면 아무것도 감싸지 않는다', (tester) async {
      await pump(tester, const WebProfileTap(child: SizedBox(width: 40, height: 40)));
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('onTap이 있으면 팝업 대신 그 동작을 쓴다 (프로필 화면의 사진 확대)', (tester) async {
      var tapped = 0;
      await pump(
        tester,
        WebProfileTap(
          userId: 7,
          onTap: () => tapped++,
          child: const SizedBox(width: 40, height: 40),
        ),
      );
      await tester.tap(find.byType(GestureDetector));
      expect(tapped, 1);
    });
  });

  group('WebAvatar', () {
    testWidgets('userId를 넘기면 사진이 탭 대상이 된다', (tester) async {
      await pump(tester, const WebAvatar(url: null, size: 32, userId: 12));
      expect(tester.widget<WebProfileTap>(find.byType(WebProfileTap)).userId, 12);
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('userId가 없으면 탭하지 않는다 (행 전체가 팝업을 여는 목록)', (tester) async {
      await pump(tester, const WebAvatar(url: null, size: 32));
      expect(find.byType(GestureDetector), findsNothing);
    });
  });

  group('프로필 팝업 카드', () {
    testWidgets('팝업 안의 사진도 누르면 확대된다', (tester) async {
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => Overlay(
          initialEntries: [OverlayEntry(builder: (_) => child!)],
        ),
        home: const Scaffold(
          body: Center(
            child: WebProfileCard(
              data: WebProfileCardData(
                userId: 3,
                avatarUrl: 'https://example.com/me.jpg',
                displayName: '지저스키',
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.byType(WebAvatar));
      await tester.pump();
      // 확대 뷰어가 열렸다(카드 이름과 뷰어 제목이 같아 `1 / 1`로 확인한다).
      expect(find.text('1 / 1'), findsOneWidget);
    });

    testWidgets('사진이 없으면 탭하지 않는다', (tester) async {
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => Overlay(
          initialEntries: [OverlayEntry(builder: (_) => child!)],
        ),
        home: const Scaffold(
          body: Center(
            child: WebProfileCard(
              data: WebProfileCardData(userId: 3, displayName: '지저스키'),
            ),
          ),
        ),
      ));

      expect(
        tester.widget<WebProfileTap>(find.byType(WebProfileTap)).onTap,
        isNull,
      );
    });
  });

  group('showWebPhotoViewer', () {
    testWidgets('사진 한 장이면 화살표·썸네일 없이 확대해서 보여준다', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => Overlay(
          initialEntries: [OverlayEntry(builder: (_) => child!)],
        ),
        home: Builder(builder: (context) {
          ctx = context;
          return const SizedBox.shrink();
        }),
      ));

      showWebPhotoViewer(ctx, url: 'https://example.com/me.jpg', title: '지저스키');
      await tester.pump();

      expect(find.text('지저스키'), findsOneWidget);
      expect(find.text('1 / 1'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('사진이 없으면 열지 않는다', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => Overlay(
          initialEntries: [OverlayEntry(builder: (_) => child!)],
        ),
        home: Builder(builder: (context) {
          ctx = context;
          return const SizedBox.shrink();
        }),
      ));

      showWebPhotoViewer(ctx, url: '');
      await tester.pump();
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });
}
