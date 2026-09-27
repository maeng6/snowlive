import 'package:flutter/material.dart';

/// 웹 공통 아이콘 버튼 — Material [IconButton]의 원형 hover 배경 대신
/// **아이콘 자체가 60% 투명도로 죽는** 방식(목록 텍스트 hover와
/// 같은 값). 리플/배경/그림자 없음, 150ms 페이드.
class WebIconButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final String? tooltip;

  /// 히트 영역 확보용 여백. IconButton(48박스)보다 타이트한 기본 4.
  /// 버튼 사이 간격은 호출자가 SizedBox로 준다(상세 아이콘 줄은 8).
  final EdgeInsets padding;

  const WebIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.padding = const EdgeInsets.all(4),
  });

  @override
  State<WebIconButton> createState() => _WebIconButtonState();
}

class _WebIconButtonState extends State<WebIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Widget child = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Padding(
          padding: widget.padding,
          child: AnimatedOpacity(
            opacity: _hovered ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: widget.icon,
          ),
        ),
      ),
    );
    if (widget.tooltip != null) {
      child = Tooltip(message: widget.tooltip!, child: child);
    }
    return child;
  }
}
