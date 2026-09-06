import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// `데크 ×` 처럼 라벨 + 삭제 버튼이 붙은 회색 알약 칩.
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
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 7, bottom: 7),
      decoration: BoxDecoration(
        color: SDSColor.gray50,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray900),
          ),
          const SizedBox(width: 4),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onDelete,
              // 아이콘만 히트 영역이면 너무 작아 누르기 어렵다. 투명 패딩으로 넓힌다.
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(Icons.close, size: 14, color: SDSColor.gray500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
