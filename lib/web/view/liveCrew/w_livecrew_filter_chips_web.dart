import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_home_sections_web.dart';
import 'package:flutter/material.dart';

/// 칩 한 줄의 높이. 칩마다 이 높이를 **강제**해야 접힘 상태에서 둘째 줄이
/// 삐져나오지 않는다(글꼴 렌더링에 따라 버튼 높이가 미세하게 달라진다).
const double _kChipRowHeight = 40;

/// `어떤 크루가 있을까요?` 칩 필터.
///
/// 칩은 **단일 선택**이다(선택된 칩의 크루만 아래 그리드에 뜬다). 우측 `^`/`v`로
/// 여러 줄 전체를 펼치거나 첫 줄만 남긴다(목업).
///
/// 중고거래의 [FleamarketFilterPill]은 라벨 뒤에 드롭다운 화살표 배지가 붙는
/// **필터 트리거**라 여기 쓸 수 없다 → 색·radius·패딩만 같은 값으로 옮겨 왔다.
class LiveCrewFilterChipsWeb extends StatefulWidget {
  final List<CrewHomeChip> chips;
  final CrewHomeChip? selected;
  final ValueChanged<CrewHomeChip> onSelected;

  const LiveCrewFilterChipsWeb({
    super.key,
    required this.chips,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<LiveCrewFilterChipsWeb> createState() => _LiveCrewFilterChipsWebState();
}

class _LiveCrewFilterChipsWebState extends State<LiveCrewFilterChipsWeb> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.chips.isEmpty) return const SizedBox.shrink();

    final wrap = Wrap(
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
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '어떤 크루가 있을까요?',
          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
        ),
        const SizedBox(height: SDSSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              // 접힘 상태는 첫 줄만 보이게 잘라낸다(Wrap은 줄 수를 제한할 수 없다).
              child: _isExpanded
                  ? wrap
                  : ClipRect(child: SizedBox(height: _kChipRowHeight, child: wrap)),
            ),
            const SizedBox(width: SDSSpacing.sm),
            _ExpandToggle(
              isExpanded: _isExpanded,
              onTap: () => setState(() => _isExpanded = !_isExpanded),
            ),
          ],
        ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleChip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        side: BorderSide(width: 1, color: isActive ? SDSColor.gray900 : SDSColor.gray100),
        backgroundColor: isActive ? SDSColor.gray900 : SDSColor.snowliveWhite,
        foregroundColor: isActive ? SDSColor.snowliveWhite : SDSColor.gray900,
        elevation: 0,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold.copyWith(
          fontSize: 13,
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
      height: _kChipRowHeight,
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
