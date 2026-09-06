import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// `전체 | 잡담 | 시즌방` 처럼 `|`로 구분되는 텍스트 탭 한 줄.
///
/// 커뮤니티 카테고리 탭에만 있던 구현을 그대로 올려 공용화했다 — 키워드 알림
/// 설정처럼 같은 모양의 탭이 필요한 화면이 생겨서다. 렌더 결과는 이전과 동일하다.
///
/// 폭에 따른 처리는 **호출자가 정한다**. 커뮤니티는 탭이 5개라 모바일에서 드롭다운으로
/// 접지만, 탭이 2~3개면 모바일에서도 한 줄에 들어간다.
class WebTextTabs<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelected;

  const WebTextTabs({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: buildChildren());
  }

  /// 이미 `Row`를 갖고 있는 호출자(커뮤니티 필터 줄은 정렬 pill과 한 Row다)가
  /// 스프레드로 끼워 넣을 수 있게 분리해 둔다.
  List<Widget> buildChildren() {
    final widgets = <Widget>[];
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (i > 0) {
        widgets.addAll([
          const SizedBox(width: 12),
          Text('|', style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray200)),
          const SizedBox(width: 12),
        ]);
      }
      widgets.add(
        _HoverTabText(
          label: labelOf(value),
          isActive: value == selected,
          onTap: () => onSelected(value),
        ),
      );
    }
    return widgets;
  }
}

/// 탭 하나. 마우스를 올리면 비활성 탭 글자색이 살짝 진해지고 클릭 커서가 뜬다.
class _HoverTabText extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _HoverTabText({required this.label, required this.isActive, required this.onTap});

  @override
  State<_HoverTabText> createState() => _HoverTabTextState();
}

class _HoverTabTextState extends State<_HoverTabText> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // 활성 탭은 진한색 고정. 비활성 탭만 hover 시 gray300 → gray600으로 살짝 진해진다.
    final color = widget.isActive
        ? SDSColor.gray900
        : (_hovered ? SDSColor.gray600 : SDSColor.gray300);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 120),
          style: (widget.isActive ? SDSTextStyle.bold : SDSTextStyle.regular)
              .copyWith(fontSize: 15, color: color),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
