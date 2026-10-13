import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';

/// 지표 바 한 칸.
class WebStatItem {
  final String label;
  final String value;

  /// 주면 칸 전체가 탭 대상이 되고, hover에서 밑줄이 생긴다.
  final VoidCallback? onTap;

  const WebStatItem({required this.label, required this.value, this.onTap});
}

/// `라벨 값 | 라벨 값` 형태의 **회색 지표 바**. 랭킹 `내 랭킹 카드`에서 확정한
/// 규격을 크루홈·기록실이 함께 쓴다(같은 성격의 지표 바가 화면마다 다르면 눈에 띈다).
///
/// 규격: gray50 · 라운드 16 · 좌우 30 / 상하 7(모바일 16) · 최소 높이 54 ·
/// 라벨 Regular 14(검정 50%) · 값 Bold 17 · 구분선 1×16 gray700 10%, 좌우 24.
///
/// 모바일은 한 줄에 세 칸을 넣으면 넘치므로 각 칸이 **값(위)·라벨(아래)**로 쌓이고
/// 칸 사이 구분선 여백을 0으로 줄여 폭을 나눠 갖는다.
class WebStatsBar extends StatelessWidget {
  final List<WebStatItem> items;

  /// 바 오른쪽 끝에 붙는 위젯(가입 신청·랭킹 진입 링크 등). 모바일에서는 칸 아래로 내려간다.
  final Widget? trailing;

  const WebStatsBar({super.key, required this.items, this.trailing});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final cells = [
      for (final item in items) _StatCell(item: item, stacked: isMobile),
    ];

    // 높이는 54로 못 박는다 — 랭킹 카드는 티어 아이콘(40)이 높이를 만들어
    // 7+40+7 = 54가 되는데, 여기는 아이콘이 없어 그냥 두면 40으로 얇아진다.
    return Container(
      constraints: BoxConstraints(minHeight: isMobile ? 0 : 54),
      alignment: isMobile ? null : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: SDSColor.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: isMobile ? 16 : 7),
      child: isMobile ? _buildStacked(cells) : _buildInline(cells),
    );
  }

  /// 모바일 — 세 지표가 한 줄에 나란히 서되 각 칸이 값(위)·라벨(아래)로 쌓인다.
  /// 남는 폭은 칸 사이에 고르게 퍼진다.
  Widget _buildStacked(List<Widget> cells) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < cells.length; i++) ...[
              if (i > 0) _divider(margin: 0),
              cells[i],
            ],
          ],
        ),
        if (trailing != null) ...[
          const SizedBox(height: 12),
          Center(child: trailing!),
        ],
      ],
    );
  }

  Widget _buildInline(List<Widget> cells) {
    // 지표는 **왼쪽에 모여** 있다(남는 폭을 나눠 갖지 않는다).
    final group = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < cells.length; i++) ...[
          if (i > 0) _divider(),
          Flexible(fit: FlexFit.loose, child: cells[i]),
        ],
      ],
    );
    if (trailing == null) return group;

    // ⚠️ `Spacer`로 밀면 안 된다 — Spacer(flex 1)와 지표 칸들(Flexible, 각 flex 1)이
    // 남는 폭을 **나눠 갖기** 때문에 Spacer가 1/4만 받아 링크가 우측 끝까지 가지 않는다.
    // 두 덩어리를 `spaceBetween`으로 양 끝에 붙이는 게 확실하다.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: group),
        Padding(
          padding: const EdgeInsets.only(left: SDSSpacing.md),
          child: trailing!,
        ),
      ],
    );
  }

  /// 항목 사이 구분선 — 1×16, gray700 10%, 좌우 24.
  Widget _divider({double margin = 24}) => Container(
        width: 1,
        height: 16,
        margin: EdgeInsets.symmetric(horizontal: margin),
        color: SDSColor.gray700.withValues(alpha: 0.1),
      );
}

class _StatCell extends StatefulWidget {
  final WebStatItem item;

  /// 모바일은 값(위) · 라벨(아래)로 쌓고 가운데 정렬한다.
  final bool stacked;

  const _StatCell({required this.item, required this.stacked});

  @override
  State<_StatCell> createState() => _StatCellState();
}

class _StatCellState extends State<_StatCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final onTap = widget.item.onTap;
    // 누를 수 있는 칸만 hover에서 **밑줄**로 알린다 — 바 안이라 배경 틴트를 쓰면
    // gray50 위에 또 회색이 깔려 잘 안 보인다.
    final underline = onTap != null && _hovered ? TextDecoration.underline : null;

    final label = Text(
      widget.item.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: SDSTextStyle.regular.copyWith(
        fontSize: 14,
        color: SDSColor.gray900.withValues(alpha: 0.5),
        decoration: underline,
        decorationColor: SDSColor.gray900.withValues(alpha: 0.5),
      ),
    );
    final value = Text(
      widget.item.value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: SDSTextStyle.bold.copyWith(
        fontSize: 17,
        color: SDSColor.gray900,
        decoration: underline,
      ),
    );

    final cell = widget.stacked
        // 값 ↔ 라벨 4 (목업 — 값 21 / 라벨 16, 칸 높이 41).
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [value, const SizedBox(height: 4), label],
          )
        // 가로 배치는 라벨 ↔ 값 11.
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [label, const SizedBox(width: 11), Flexible(child: value)],
          );
    if (onTap == null) return cell;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: cell,
      ),
    );
  }
}

/// 지표 바 오른쪽 끝의 진입 링크 — `가입 신청하기` · `크루원 시즌 랭킹`이 모두 이것이다.
///
/// 목업(174:60474 · 161:96325) — **Bold 16 + 간격 10 + 16px 원형 화살표**.
/// 아이콘은 검정 원 안에 흰 꺾쇠다(목업 `Group 646` SVG와 같은 모양을 그린다 —
/// 에셋 `icon_arrow_round_black.png`은 꺾쇠가 아니라 꼬리 달린 화살표라 쓰지 않는다).
/// hover에서는 글자에 밑줄만 생긴다(바 안이라 배경 틴트를 쓰지 않는다).
class WebStatsBarLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const WebStatsBarLink({super.key, required this.label, required this.onTap});

  @override
  State<WebStatsBarLink> createState() => _WebStatsBarLinkState();
}

class _WebStatsBarLinkState extends State<WebStatsBarLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 16,
                  color: SDSColor.gray900,
                  decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
              const SizedBox(width: 10),
              const _CircleArrow(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 검정 원(16) 안의 흰 꺾쇠 — 목업 `Group 646`. 지표 바 진입 링크에 쓴다.
class _CircleArrow extends StatelessWidget {
  const _CircleArrow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: SDSColor.snowliveBlack,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      // 원 안에 꽉 차지 않게 12로 그린다(목업 꺾쇠가 원 지름의 약 7/16을 차지한다).
      child: const Icon(Icons.chevron_right, size: 12, color: SDSColor.snowliveWhite),
    );
  }
}
