import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// `smoothDownscale` — 아이폰 Safari에서 티어 아이콘이 깨지던 문제(2026-10-12).
/// Safari는 `cacheWidth`(디코드 크기)를 주면 엔진이 캔버스로 줄이는 경로를 타고, 그 경로가
/// 반투명 픽셀의 알파를 잘못 다뤄 글로우가 각지고 밝게 나왔다 → 디코드 크기를 주지 않고
/// GPU 밉맵으로 줄인다.
void main() {
  Future<Image> pumpImage(WidgetTester tester, {required bool smooth}) async {
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: WebNetworkImage(
          url: 'https://example.com/tier.png',
          width: 28,
          height: 28,
          fit: BoxFit.contain,
          showPlaceholder: false,
          smoothDownscale: smooth,
        ),
      ),
    ));
    final image = tester.widget<Image>(find.byType(Image));
    // 테스트 HttpClient는 400을 준다 — 이미지 로드 실패만 비운다.
    await tester.pump();
    while (tester.takeException() != null) {}
    return image;
  }

  testWidgets('티어 아이콘: 디코드 크기 없음(ResizeImage 아님) + 밉맵 축소', (tester) async {
    final image = await pumpImage(tester, smooth: true);
    expect(image.image, isNot(isA<ResizeImage>()));
    expect(image.filterQuality, FilterQuality.medium);
  });

  testWidgets('그 외 이미지: 지금처럼 표시 크기로 디코드(메모리 절약)', (tester) async {
    final image = await pumpImage(tester, smooth: false);
    expect(image.image, isA<ResizeImage>());
    expect(image.filterQuality, FilterQuality.low);
  });
}
