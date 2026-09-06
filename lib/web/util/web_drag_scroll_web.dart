import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 마우스로도 **드래그해서** 스크롤할 수 있게 하는 스크롤 동작.
///
/// Flutter 웹 기본 [MaterialScrollBehavior]는 `dragDevices`에 마우스를 넣지 않아서
/// 가로 스크롤 영역을 마우스로 끌어도 움직이지 않는다(휠/트랙패드만 동작). 일자 줄이나
/// 카드 캐러셀처럼 **가로로만 움직이는 영역**은 끌어서 넘기는 게 자연스러워서 여기서만
/// 마우스 드래그를 켠다.
class WebDragScrollBehavior extends MaterialScrollBehavior {
  const WebDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.mouse,
      };
}

/// 가로 스크롤 영역을 [WebDragScrollBehavior]로 감싼다.
///
/// 세로 페이지 스크롤에는 영향이 없다 — 가로 스크롤러가 가로 드래그만 가져간다.
class WebHorizontalDragScroll extends StatelessWidget {
  final Widget child;

  const WebHorizontalDragScroll({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const WebDragScrollBehavior(),
      child: child,
    );
  }
}
