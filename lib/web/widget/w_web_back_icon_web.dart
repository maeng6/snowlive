import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 웹 공통 뒤로가기 아이콘 — Material 화살표 대신 앱과 동일한 에셋을 쓴다
/// (icon_snowLive_back.svg). 원색이 gray900이라 기본값이면
/// 그대로 그려지고, 밝은 배경 위 등에서는 [color]로 덮는다.
class WebBackIcon extends StatelessWidget {
  final double size;
  final Color color;

  const WebBackIcon({super.key, this.size = 24, this.color = SDSColor.gray900});

  @override
  Widget build(BuildContext context) {
    // 에셋(viewBox 26) 안쪽 좌측 여백 3을 렌더 크기에 비례해 음수 오프셋으로
    // 상쇄한다 — 화살표 획이 콘텐츠 좌측선에 딱 붙는다. 페인트만 이동하므로
    // 레이아웃·히트 영역은 그대로다. 모든 브레이크포인트 공통.
    return Transform.translate(
      offset: Offset(-size * 3 / 26, 0),
      child: SvgPicture.asset(
        'assets/imgs/icons/icon_snowLive_back.svg',
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
