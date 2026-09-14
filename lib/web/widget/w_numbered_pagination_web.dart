import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 번호식 페이지네이션 바(‹ 1 … n-1 n n+1 … N ›). 중고거래/랭킹 등
/// gotoPage/pageWindow 인터페이스를 갖는 웹 전용 페이지네이션 뷰모델과 함께 쓴다.
class NumberedPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;
  final List<int> pageWindow;
  final ValueChanged<int> onGotoPage;

  const NumberedPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
    required this.pageWindow,
    required this.onGotoPage,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        // 양 끝(비활성)에서는 화살표를 숨긴다. 자리는 유지해서 숫자가 흔들리지 않게.
        // 화살표 ↔ 숫자 간격은 spacing(2)보다 넓게 띄운다.
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _EdgeArrow(
            icon: Icons.chevron_left,
            enabled: hasPrevious,
            onTap: () => onGotoPage(currentPage - 1),
          ),
        ),
        if (pageWindow.first > 1) ...[
          _PageNumberButton(label: '1', isActive: false, onTap: () => onGotoPage(1)),
          if (pageWindow.first > 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('…', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400)),
            ),
        ],
        for (final page in pageWindow)
          _PageNumberButton(label: '$page', isActive: page == currentPage, onTap: () => onGotoPage(page)),
        if (pageWindow.last < totalPages) ...[
          if (pageWindow.last < totalPages - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('…', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400)),
            ),
          _PageNumberButton(label: '$totalPages', isActive: false, onTap: () => onGotoPage(totalPages)),
        ],
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: _EdgeArrow(
            icon: Icons.chevron_right,
            enabled: hasNext,
            onTap: () => onGotoPage(currentPage + 1),
          ),
        ),
      ],
    );
  }
}

/// 이전/다음 화살표 — 비활성이면 **미노출**(투명)하되 자리는 그대로 차지한다.
class _EdgeArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _EdgeArrow({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: enabled,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: IconButton(
        onPressed: enabled ? onTap : null,
        icon: Icon(icon),
      ),
    );
  }
}

class _PageNumberButton extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PageNumberButton({required this.label, required this.isActive, required this.onTap});

  @override
  State<_PageNumberButton> createState() => _PageNumberButtonState();
}

class _PageNumberButtonState extends State<_PageNumberButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.isActive;
    // 미선택 숫자: hover 시 폰트 60% 불투명도.
    final Color numberColor = _hovered
        ? SDSColor.gray700.withValues(alpha: 0.6)
        : SDSColor.gray700;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: isActive ? null : widget.onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? SDSColor.gray900 : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            widget.label,
            // 미선택도 Bold (색으로만 구분).
            style: SDSTextStyle.bold.copyWith(
              fontSize: 14,
              color: isActive ? SDSColor.snowliveWhite : numberColor,
            ),
          ),
        ),
      ),
    );
  }
}
