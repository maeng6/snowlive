import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 칩 줄 높이(라이브크루 필터 칩과 같은 36 = 상하 10 + 줄높이 16).
const double kShopChipRowHeight = 36;

/// 카테고리 칩 한 줄 — 단일 선택. 좁은 폭에서는 가로로 스크롤된다(줄바꿈 없음).
/// 모양은 라이브크루 필터 칩·슬로프크래프트 시즌 칩과 같은 알약(선택 = 검정 바탕).
class ShopCategoryChipsWeb extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const ShopCategoryChipsWeb({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kShopChipRowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // 마우스 휠로도 가로 스크롤이 되게 기본 physics 유지. 스크롤바는 숨긴다.
        padding: EdgeInsets.zero,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: SDSSpacing.sm),
        itemBuilder: (context, i) {
          final label = categories[i];
          return _Chip(
            label: label,
            isActive: label == selected,
            onTap: () => onSelected(label),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final background = isActive ? SDSColor.gray900 : SDSColor.snowliveWhite;
    final border = isActive ? SDSColor.gray900 : SDSColor.gray100;

    return ElevatedButton(
      onPressed: onTap,
      // hover — 면만 어두워진다(선택은 검정 10% 더, 미선택은 gray50). 테두리 고정.
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
          // 줄높이를 묶어야 칩 높이가 36으로 계산된다.
          height: 16 / 13,
        ),
      ),
    );
  }
}
