import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 웹 공용 토글 스위치(라이브톡 `전체공개`, 프로필 편집 `프로필 비공개`).
///
/// Material 기본 스위치(52×32 + 탭 영역)는 14 글줄 옆에서 과하게 크다 →
/// 0.8배로 줄이고 탭 영역 여백을 걷어 오른쪽 선에 맞춘다.
///
/// ⚠️ 색은 **스라블루 / 흰색 / gray200** 세 가지만 쓴다. Material 기본값은
/// 테마 보라(primary)·테두리선·눌림 오버레이·꺼진 상태 손잡이 회색을
/// 제멋대로 넣으므로 전부 명시해서 덮는다(상태별로 다 지정해야 한다 —
/// 하나라도 비우면 그 상태에서 기본 테마 색이 되살아난다).
class WebSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const WebSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.8,
      alignment: Alignment.centerRight,
      child: Switch(
        value: value,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        splashRadius: 0,
        thumbColor: const WidgetStatePropertyAll(SDSColor.snowliveWhite),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? SDSColor.snowliveBlue
              : SDSColor.gray200,
        ),
        // 트랙 테두리선·호버/눌림 오버레이 제거.
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        trackOutlineWidth: const WidgetStatePropertyAll(0),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }
}
