import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_home_sections_web.dart';
import 'package:flutter/material.dart';

/// 칩 한 줄의 높이. 칩마다 이 높이를 **강제**해야 접힘 상태에서 둘째 줄이
/// 삐져나오지 않는다(글꼴 렌더링에 따라 버튼 높이가 미세하게 달라진다).
const double _kChipRowHeight = 40;

/// 2단(스키장) 칩 한 줄의 높이. 1단보다 작게 그려 계층이 보이게 한다.
const double _kSubChipRowHeight = 34;

/// `어떤 크루가 있을까요?` 칩 필터(2단).
///
/// 1단은 `스키장별` · `멤버 많은 순` · `이번 시즌 라이브온 많이 한 순` ·
/// `스키가 많은 크루` · `보드가 많은 크루` 다섯 개고 **단일 선택**이다.
/// `스키장별`을 고르면 **바로 아래에 스키장 칩 줄**이 나타난다(사용자 확정).
///
/// 1단은 5개라 한 줄에 들어가서 접기 토글이 필요 없다 — 접기 `^`는 스키장이 12개인
/// **2단에만** 둔다(접힘 상태는 한 줄).
///
/// 중고거래의 [FleamarketFilterPill]은 라벨 뒤에 드롭다운 화살표 배지가 붙는
/// **필터 트리거**라 여기 쓸 수 없다 → 색·radius·패딩만 같은 값으로 옮겨 왔다.
class LiveCrewFilterChipsWeb extends StatefulWidget {
  final List<CrewHomeChip> chips;
  final CrewHomeChip? selected;
  final ValueChanged<CrewHomeChip> onSelected;

  /// 2단 칩. 비어 있으면 그리지 않는다(`스키장별`이 아닌 칩을 고른 상태).
  final List<CrewHomeChip> resortChips;
  final CrewHomeChip? selectedResort;
  final ValueChanged<CrewHomeChip>? onResortSelected;

  const LiveCrewFilterChipsWeb({
    super.key,
    required this.chips,
    required this.selected,
    required this.onSelected,
    this.resortChips = const [],
    this.selectedResort,
    this.onResortSelected,
  });

  @override
  State<LiveCrewFilterChipsWeb> createState() => _LiveCrewFilterChipsWebState();
}

class _LiveCrewFilterChipsWebState extends State<LiveCrewFilterChipsWeb> {
  bool _isResortExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.chips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '어떤 크루가 있을까요?',
          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
        ),
        const SizedBox(height: SDSSpacing.md),
        Wrap(
          spacing: SDSSpacing.sm,
          runSpacing: SDSSpacing.sm,
          children: [
            for (final chip in widget.chips)
              SizedBox(
                height: _kChipRowHeight,
                child: _ToggleChip(
                  label: chip.label,
                  isActive: chip == widget.selected,
                  onTap: () => widget.onSelected(chip),
                ),
              ),
          ],
        ),
        if (widget.resortChips.isNotEmpty) ...[
          const SizedBox(height: SDSSpacing.md),
          _buildResortRow(),
        ],
      ],
    );
  }

  Widget _buildResortRow() {
    final wrap = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final chip in widget.resortChips)
          SizedBox(
            height: _kSubChipRowHeight,
            child: _ToggleChip(
              label: chip.label,
              isActive: chip == widget.selectedResort,
              isSub: true,
              onTap: () => widget.onResortSelected?.call(chip),
            ),
          ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          // 접힘 상태는 첫 줄만 보이게 잘라낸다(Wrap은 줄 수를 제한할 수 없다).
          child: _isResortExpanded
              ? wrap
              : ClipRect(child: SizedBox(height: _kSubChipRowHeight, child: wrap)),
        ),
        const SizedBox(width: SDSSpacing.sm),
        _ExpandToggle(
          isExpanded: _isResortExpanded,
          onTap: () => setState(() => _isResortExpanded = !_isResortExpanded),
        ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  /// 2단(스키장) 칩. 조금 작고 배경이 회색이라 1단과 구분된다.
  final bool isSub;

  const _ToggleChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isSub = false,
  });

  @override
  Widget build(BuildContext context) {
    final background = isActive
        ? SDSColor.gray900
        : (isSub ? SDSColor.gray50 : SDSColor.snowliveWhite);
    final border = isActive ? SDSColor.gray900 : (isSub ? SDSColor.gray50 : SDSColor.gray100);

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: isSub ? 12 : 14, vertical: isSub ? 7 : 9),
        side: BorderSide(width: 1, color: border),
        backgroundColor: background,
        foregroundColor: isActive ? SDSColor.snowliveWhite : SDSColor.gray900,
        elevation: 0,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      child: Text(
        label,
        style: (isSub ? SDSTextStyle.regular : SDSTextStyle.bold).copyWith(
          fontSize: isSub ? 12 : 13,
          color: isActive ? SDSColor.snowliveWhite : SDSColor.gray900,
        ),
      ),
    );
  }
}

class _ExpandToggle extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const _ExpandToggle({required this.isExpanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: _kSubChipRowHeight,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          size: 22,
          color: SDSColor.gray900,
        ),
      ),
    );
  }
}
