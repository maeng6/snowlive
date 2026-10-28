import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';

/// 번호식 페이지네이션 바(‹ 1 … n-1 n n+1 … N ›). 중고거래/랭킹 등
/// gotoPage/pageWindow 인터페이스를 갖는 웹 전용 페이지네이션 뷰모델과 함께 쓴다.
///
/// 디자인은 **중고거래 확정값 하나로 통일**한다(사용자 확정) — 선택된 번호는 검정
/// 원 + 흰 글자, 나머지는 gray700 Bold(그 위 hover 60%), 양 끝 화살표는 비활성일 때
/// 자리만 남기고 숨는다. 예전에는 커뮤니티·각종소식만 배경 없는 텍스트형(`textOnly`)을
/// 따로 썼는데, 같은 성격의 바가 화면마다 다르면 바로 눈에 띄어서 걷어냈다.
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
    final ellipsis = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '…',
        style: SDSTextStyle.regular.copyWith(
          fontSize: 14,
          color: SDSColor.gray400,
        ),
      ),
    );

    // 모바일은 숫자(1·N 포함)를 최대 5개까지만 — 좁은 폭에서 줄바꿈 방지(사용자 확정).
    final window = context.screenType == WebScreenType.mobile
        ? _clampedWindow(maxNumbers: 5)
        : pageWindow;

    final numbers = <Widget>[
      if (window.first > 1) ...[
        _PageNumberButton(
          label: '1',
          isActive: false,
          onTap: () => onGotoPage(1),
        ),
        if (window.first > 2) ellipsis,
      ],
      for (final page in window)
        _PageNumberButton(
          label: '$page',
          isActive: page == currentPage,
          onTap: () => onGotoPage(page),
        ),
      if (window.last < totalPages) ...[
        if (window.last < totalPages - 1) ellipsis,
        _PageNumberButton(
          label: '$totalPages',
          isActive: false,
          onTap: () => onGotoPage(totalPages),
        ),
      ],
    ];

    final prevArrow = _EdgeArrow(
      icon: Icons.chevron_left,
      enabled: hasPrevious,
      onTap: () => onGotoPage(currentPage - 1),
    );
    final nextArrow = _EdgeArrow(
      icon: Icons.chevron_right,
      enabled: hasNext,
      onTap: () => onGotoPage(currentPage + 1),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        // 양 끝(비활성)에서는 화살표를 숨긴다. 자리는 유지해서 숫자가 흔들리지 않게.
        // 화살표 ↔ 숫자 간격은 spacing보다 넓게 띄운다.
        Padding(padding: const EdgeInsets.only(right: 10), child: prevArrow),
        ...numbers,
        Padding(padding: const EdgeInsets.only(left: 10), child: nextArrow),
      ],
    );
  }

  /// 숫자 버튼 총량(윈도우 + 앞의 1 + 뒤의 N)이 [maxNumbers]를 넘지 않게
  /// 윈도우를 현재 페이지에서 먼 쪽부터 잘라낸다.
  List<int> _clampedWindow({required int maxNumbers}) {
    final win = List<int>.from(pageWindow);
    bool fits() {
      final extras =
          (win.first > 1 ? 1 : 0) + (win.last < totalPages ? 1 : 0);
      return win.length + extras <= maxNumbers;
    }

    while (win.length > 1 && !fits()) {
      final distFirst = currentPage - win.first;
      final distLast = win.last - currentPage;
      if (distFirst >= distLast) {
        win.removeAt(0);
      } else {
        win.removeLast();
      }
    }
    return win;
  }
}

/// 이전/다음 화살표 — 비활성이면 **미노출**(투명)하되 자리는 그대로 차지한다.
class _EdgeArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _EdgeArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child =
        IconButton(onPressed: enabled ? onTap : null, icon: Icon(icon));
    return Visibility(
      visible: enabled,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: child,
    );
  }
}

class _PageNumberButton extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PageNumberButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

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
