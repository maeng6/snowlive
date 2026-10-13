import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 가로 목록의 좌우 끝을 **흰색 그라데이션으로 덮어** 카드가 경계에서 서서히
/// 사라지게 한다 — 잘려서 끝나지 않고 더 있다는 것을 알린다.
///
/// ShaderMask(dstIn)로 투명하게 깎지 않고 **위에 흰 레이어를 덮는** 방식이다.
/// 덮는 색이 페이지 배경과 같은 흰색이라 이음매가 보이지 않는다.
class WebEdgeFade extends StatelessWidget {
  final Widget child;

  /// 덮이는 구간 폭. 라이브크루 캐러셀 기준 64(카드 한 장의 1/3 정도).
  final double fadeWidth;

  /// 각 끝을 덮을지. **그쪽에 더 볼 게 있을 때만** 켜면 목록의 처음·끝에서 카드가
  /// 괜히 희게 빠지지 않는다(끝이 없는 무한 캐러셀은 기본값 그대로 둘 것).
  final bool showStart;
  final bool showEnd;

  const WebEdgeFade({
    super.key,
    required this.child,
    this.fadeWidth = 64,
    this.showStart = true,
    this.showEnd = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      // 자식(레일)이 Stack 크기를 정하고, 그 위에 그라데이션을 덮는다.
      fit: StackFit.passthrough,
      children: [
        child,
        // 그라데이션이 카드의 탭·드래그를 가로채면 안 된다.
        Positioned.fill(
          child: IgnorePointer(
            // ⚠️ stretch가 꼭 필요하다 — 기본 center면 세로 제약이 느슨해지고,
            // 자식 없는 DecoratedBox는 그때 가장 작은 크기(높이 0)를 잡아서
            // 그라데이션이 아예 안 보인다.
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _gradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  visible: showStart,
                ),
                const Spacer(),
                _gradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  visible: showEnd,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _gradient({
    required Alignment begin,
    required Alignment end,
    required bool visible,
  }) =>
      SizedBox(
        width: fadeWidth,
        // 자리는 늘 차지하고 **불투명도만** 바꾼다 — 켜고 끌 때 폭이 변하면
        // 옆 Spacer가 밀려 목록이 흔들린다.
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: begin,
                end: end,
                colors: [
                  SDSColor.snowliveWhite,
                  SDSColor.snowliveWhite.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      );
}
