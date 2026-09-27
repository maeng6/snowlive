import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';

/// 번호식 페이지네이션 바(‹ 1 … n-1 n n+1 … N ›). 중고거래/랭킹 등
/// gotoPage/pageWindow 인터페이스를 갖는 웹 전용 페이지네이션 뷰모델과 함께 쓴다.
///
/// [textOnly]가 true면 커뮤니티 목업(64:112758) 스타일 — 배경 없이 글자색만
/// (활성 gray900 / 비활성 gray200, bold 16, 30×30, 간격 10). 기본값(false)은
/// 기존 원형 스타일(중고거래·랭킹 확정값)이라 바꾸면 회귀가 된다.
class NumberedPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;
  final List<int> pageWindow;
  final ValueChanged<int> onGotoPage;
  final bool textOnly;

  const NumberedPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
    required this.pageWindow,
    required this.onGotoPage,
    this.textOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final ellipsis = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '…',
        style: textOnly
            ? SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray200)
            : SDSTextStyle.regular.copyWith(
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
          textOnly: textOnly,
          onTap: () => onGotoPage(1),
        ),
        if (window.first > 2) ellipsis,
      ],
      for (final page in window)
        _PageNumberButton(
          label: '$page',
          isActive: page == currentPage,
          textOnly: textOnly,
          onTap: () => onGotoPage(page),
        ),
      if (window.last < totalPages) ...[
        if (window.last < totalPages - 1) ellipsis,
        _PageNumberButton(
          label: '$totalPages',
          isActive: false,
          textOnly: textOnly,
          onTap: () => onGotoPage(totalPages),
        ),
      ],
    ];

    final prevArrow = _EdgeArrow(
      icon: Icons.chevron_left,
      enabled: hasPrevious,
      compact: textOnly,
      onTap: () => onGotoPage(currentPage - 1),
    );
    final nextArrow = _EdgeArrow(
      icon: Icons.chevron_right,
      enabled: hasNext,
      compact: textOnly,
      onTap: () => onGotoPage(currentPage + 1),
    );

    if (textOnly) {
      // 화살표는 바의 **양 끝에 고정**, 숫자는 그 사이 중앙 정렬 — 좁은 폭에서
      // 화살표가 아랫줄로 꺾이지 않는다(사용자 확정). 숫자만 넘치면 숫자끼리 줄바꿈.
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          prevArrow,
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              children: numbers,
            ),
          ),
          nextArrow,
        ],
      );
    }

    // 원형 스타일(중고거래·랭킹 확정값) — 기존 Wrap 구조 유지.
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
/// [compact]는 텍스트형 페이지네이션용 30×30 검정 화살표(목업 64:112759).
class _EdgeArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final bool compact;
  final VoidCallback onTap;

  const _EdgeArrow({
    required this.icon,
    required this.enabled,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (compact) {
      child = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(icon, size: 20, color: SDSColor.gray900),
          ),
        ),
      );
    } else {
      child = IconButton(onPressed: enabled ? onTap : null, icon: Icon(icon));
    }
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
  final bool textOnly;
  final VoidCallback onTap;

  const _PageNumberButton({
    required this.label,
    required this.isActive,
    required this.textOnly,
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

    if (widget.textOnly) {
      // 커뮤니티 목업 — 배경 없이 색만: 활성 gray900 / 비활성 gray200,
      // 비활성 hover는 탭과 같은 gray600.
      final Color color = isActive
          ? SDSColor.gray900
          : (_hovered ? SDSColor.gray600 : SDSColor.gray200);
      return MouseRegion(
        cursor: isActive ? MouseCursor.defer : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isActive ? null : widget.onTap,
          child: SizedBox(
            width: 30,
            height: 30,
            child: Center(
              child: Text(
                widget.label,
                style: SDSTextStyle.bold.copyWith(fontSize: 16, color: color),
              ),
            ),
          ),
        ),
      );
    }

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
