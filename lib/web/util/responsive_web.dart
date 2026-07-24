import 'package:flutter/material.dart';

/// 웹 반응형 브레이크포인트 기준값.
/// 데스크탑 >= [desktop], 태블릿 [tablet]~[desktop) 미만, 그 아래는 모바일.
/// [maxContentWidth] 이상에서는 콘텐츠가 더 커지지 않고 화면(배경)만 옆으로 늘어난다.
class WebBreakpoints {
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double maxContentWidth = 1440;
}

enum WebScreenType { mobile, tablet, desktop }

extension ResponsiveContext on BuildContext {
  WebScreenType get screenType {
    final width = MediaQuery.sizeOf(this).width;
    if (width >= WebBreakpoints.desktop) return WebScreenType.desktop;
    if (width >= WebBreakpoints.tablet) return WebScreenType.tablet;
    return WebScreenType.mobile;
  }

  bool get isDesktop => screenType == WebScreenType.desktop;

  bool get isTabletOrMobile => screenType != WebScreenType.desktop;
}

/// 1440px 초과 시 콘텐츠를 고정폭(1440)으로 얼리고 화면 중앙에 배치해서,
/// 초과분이 좌우 양쪽에 균등한 배경 여백으로 남도록 하는 래퍼.
class FrozenWidthCanvas extends StatelessWidget {
  final Widget child;

  const FrozenWidthCanvas({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: WebBreakpoints.maxContentWidth),
        child: child,
      ),
    );
  }
}
