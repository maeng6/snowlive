import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// `데크 ×` 처럼 라벨 + 삭제 버튼이 붙은 회색 칩 (피그마 64:105811).
/// 라운드 5 사각, 패딩 12/8, 라벨 regular 15, ×는 검정 40%.
///
/// 커뮤니티의 [CommunityCategoryChip]은 삭제가 없는 배지이고, 중고거래
/// [FleamarketFilterPill]은 필터 트리거(⌄)라 둘 다 이 용도로는 못 쓴다.
///
/// `×`는 라벨과 **별도 히트 영역**이다 — 칩 전체를 삭제 버튼으로 만들면 목록을
/// 훑다가 실수로 지우게 된다.
class WebDeleteChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  const WebDeleteChip({super.key, required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    // ×의 히트 확장 패딩(3)이 목업의 라벨↔× 간격 6과 우측 패딩 12에 흡수되도록
    // 좌 12 / 우 9, 사이 3으로 나눠 담는다(시각 결과는 12/6/12).
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 9, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: SDSColor.gray50,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
          ),
          const SizedBox(width: 3),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onDelete,
              // 아이콘만 히트 영역이면 너무 작아 누르기 어렵다. 투명 패딩으로 넓힌다.
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(3),
                // 목업 ×: 검정 40% (직선 획 대신 아이콘으로 근사 — 크기 동급).
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: SDSColor.gray900.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
