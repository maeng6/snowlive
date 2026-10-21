import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 페이지와 함께 스크롤되다가 **상단에 닿으면 멈추는 열**.
///
/// 목록 옆에 붙는 카드·사이드바처럼, 목록은 계속 흘러가는데 옆 블록만 화면에
/// 남겨두고 싶을 때 쓴다. 페이지 전체가 하나의 스크롤(`SingleChildScrollView`)인
/// 웹 화면 구조를 그대로 두고, **칸은 제자리에 둔 채 안쪽만 그려서 내린다**
/// (`Transform`은 레이아웃을 바꾸지 않으므로 목록 폭·높이에 영향이 없다).
///
/// [boundsKey]는 같이 달리는 형제(보통 목록)다. 그 블록이 끝나면 더 내려가지
/// 않는다 — 안 그러면 페이지 끝에서 빈 공간 위에 혼자 떠 있게 된다.
class WebStickyColumn extends StatelessWidget {
  /// 이 열이 들어 있는 스크롤의 컨트롤러.
  final ScrollController controller;

  /// 같이 달리는 형제(목록). 이 높이를 넘겨 내려가지 않는다.
  final GlobalKey boundsKey;

  /// 멈출 때 화면 위쪽에 남길 여백.
  final double topGap;

  final Widget child;

  const WebStickyColumn({
    super.key,
    required this.controller,
    required this.boundsKey,
    required this.child,
    this.topGap = 24,
  });

  @override
  Widget build(BuildContext context) {
    // `_Slot`이 칸(원래 자리)이고 Transform은 그 **안쪽**이다 → 칸 자신의 위치는
    // 밀어낸 양에 영향받지 않아, 기준 오프셋을 매 프레임 안전하게 다시 잴 수 있다.
    return _Slot(controller: controller, boundsKey: boundsKey, topGap: topGap, child: child);
  }
}

class _Slot extends StatelessWidget {
  final ScrollController controller;
  final GlobalKey boundsKey;
  final double topGap;
  final Widget child;

  const _Slot({
    required this.controller,
    required this.boundsKey,
    required this.topGap,
    required this.child,
  });

  /// 얼마나 내려 그릴지. 스크롤이 기준점을 지나간 만큼이고, 형제 블록 끝에서 멈춘다.
  double _shift(BuildContext context) {
    if (!controller.hasClients) return 0;

    final slot = context.findRenderObject() as RenderBox?;
    final bounds = boundsKey.currentContext?.findRenderObject() as RenderBox?;
    if (slot == null || bounds == null || !slot.hasSize || !bounds.hasSize) return 0;

    final viewport = RenderAbstractViewport.maybeOf(slot);
    if (viewport == null) return 0;

    // 칸의 윗변이 화면 맨 위에 닿는 스크롤 위치. 레이아웃 기준이라 스크롤 중에도
    // 값이 흔들리지 않는다(`controller.offset`으로 재야 한 프레임 밀리지 않는다).
    final start = viewport.getOffsetToReveal(slot, 0).offset - topGap;
    final maxShift = bounds.size.height - slot.size.height;
    if (maxShift <= 0) return 0;

    return (controller.offset - start).clamp(0.0, maxShift);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) =>
          Transform.translate(offset: Offset(0, _shift(context)), child: child),
      child: child,
    );
  }
}
