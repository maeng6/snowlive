import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_filter_sheet_web.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_home_sections_web.dart';
import 'package:flutter/material.dart';

/// 칩 한 줄의 높이. 칩마다 이 높이를 **강제**해야 글꼴 렌더링에 따라 버튼 높이가
/// 미세하게 달라지는 걸 막는다. 목업(161:38968) 36 = 상하 10 + 글자 줄높이 16
/// (= 스키장 드롭다운 pill의 높이와 같다).
const double _kChipRowHeight = 36;

/// `어떤 크루가 있을까요?` 칩 필터.
///
/// 칩은 `스키장별 크루` · `대형 크루` · `시즌 최다 라이브온` ·
/// `스키어 중심 크루` · `보더 중심 크루` 다섯 개고 **단일 선택**이다.
///
/// `스키장별 크루`만 모양이 다르다 — **앱 랭킹 필터와 같은 드롭다운 pill**
/// ([FleamarketFilterPill], 라벨 뒤 원형 화살표)이라 누르면 스키장 목록이
/// 드롭다운(모바일·태블릿은 딤 시트)으로 뜨고 거기서 고른다.
/// 예전에는 아래에 스키장 칩을 한 줄 더 깔았는데, **같은 알약 모양이 두 줄로 쌓여
/// 어느 쪽이 상위 필터인지 헷갈린다**는 피드백으로 드롭다운으로 접었다.
class LiveCrewFilterChipsWeb extends StatelessWidget {
  final List<CrewHomeChip> chips;
  final CrewHomeChip? selected;
  final ValueChanged<CrewHomeChip> onSelected;

  /// 드롭다운에 담을 스키장 목록. 비어 있으면 `스키장별` 칩 자체가 없다.
  final List<CrewHomeChip> resortChips;

  /// 지금 고른 스키장(= pill에 찍히는 이름). 아직 안 골랐으면 null.
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
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '어떤 크루가 있을까요?',
          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
        ),
        // 제목 ↔ 칩: PC 16 / 좁은 폭 20 (태블릿 목업 — 제목 끝 449, 칩 469).
        SizedBox(height: context.isDesktop ? 12 : 12),
        Wrap(
          spacing: SDSSpacing.sm,
          runSpacing: SDSSpacing.sm,
          children: [
            for (final chip in chips)
              SizedBox(
                height: _kChipRowHeight,
                child: chip.kind == CrewHomeChipKind.byResort
                    ? _buildResortPill(chip)
                    : _ToggleChip(
                        label: chip.label,
                        isActive: chip == selected,
                        onTap: () => onSelected(chip),
                      ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildResortPill(CrewHomeChip byResort) {
    final isActive = selected?.kind == CrewHomeChipKind.byResort;
    return FleamarketFilterPill<CrewHomeChip>(
      // 고른 스키장이 곧 필터값이라 pill에 그 이름을 찍는다(앱 랭킹 필터와 같다).
      label: isActive ? (selectedResort?.label ?? byResort.label) : byResort.label,
      isActive: isActive,
      title: '스키장',
      values: resortChips,
      labelOf: (chip) => chip.label,
      onSelected: (chip) {
        // 스키장을 고르는 것으로 `스키장별` 선택까지 끝난다 — 칩을 먼저 누를 필요가 없다.
        onSelected(byResort);
        onResortSelected?.call(chip);
      },
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = isActive ? SDSColor.gray900 : SDSColor.snowliveWhite;
    final border = isActive ? SDSColor.gray900 : SDSColor.gray100;

    return ElevatedButton(
      onPressed: onTap,
      // hover — 칩도 버튼과 같이 **면이 어두워진다**(테두리는 고정).
      // 선택됨은 배경에 검정 10%, 미선택은 흰 배경 → gray50.
      style: ButtonStyle(
        splashFactory: NoSplash.splashFactory,
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        animationDuration: Duration.zero,
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        side: WidgetStatePropertyAll(BorderSide(width: 1, color: border)),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (!states.contains(WidgetState.hovered)) return background;
          return isActive
              ? Color.alphaBlend(Colors.black.withValues(alpha: 0.1), background)
              : SDSColor.gray50;
        }),
        foregroundColor: WidgetStatePropertyAll(
          isActive ? SDSColor.snowliveWhite : SDSColor.gray900,
        ),
        minimumSize: const WidgetStatePropertyAll(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold.copyWith(
          fontSize: 13,
          // 줄높이를 묶어야 칩 높이가 36으로 계산된다(안 묶으면 Pretendard가 더 크게 잡는다).
          height: 16 / 13,
          color: isActive ? SDSColor.snowliveWhite : SDSColor.gray900,
        ),
      ),
    );
  }
}
