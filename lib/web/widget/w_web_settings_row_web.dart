import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// `제목 [배지] >` 형태의 설정 목록 행.
///
/// 치수는 랭킹 사이드바의 링크 카드(`w_ranking_sidebar_web.dart`)를 따르되 목업처럼
/// 테두리 없는 평평한 행으로 둔다. 파란 카운트 배지는 웹에 아직 없어서 여기서 만든다.
class WebSettingsRow extends StatelessWidget {
  final String label;

  /// 라벨 뒤 파란 원형 배지에 표시할 개수. null이거나 0이면 배지를 그리지 않는다.
  final int? badgeCount;

  /// 개수 대신 글자를 넣는 배지(크루 설정의 `NEW`). [badgeCount]보다 우선한다.
  final String? badgeLabel;

  final VoidCallback onTap;

  const WebSettingsRow({
    super.key,
    required this.label,
    this.badgeCount,
    this.badgeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final count = badgeCount ?? 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Text(label, style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900)),
            if (badgeLabel?.isNotEmpty ?? false) ...[
              const SizedBox(width: SDSSpacing.sm),
              _TextBadge(label: badgeLabel!),
            ] else if (count > 0) ...[
              const SizedBox(width: SDSSpacing.sm),
              _CountBadge(count: count),
            ],
            const Spacer(),
            Icon(Icons.chevron_right, size: 20, color: SDSColor.gray300),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 한 자리는 원, 두 자리 이상은 알약이 되도록 최소 폭만 잡고 좌우 패딩을 준다.
      constraints: const BoxConstraints(minWidth: 20),
      height: 20,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: SDSColor.snowliveBlue,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.snowliveWhite),
      ),
    );
  }
}

/// 글자 배지(`NEW`). 개수 배지와 달리 알약 모양이다.
class _TextBadge extends StatelessWidget {
  final String label;

  const _TextBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: SDSColor.snowliveBlue,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold.copyWith(fontSize: 11, color: SDSColor.snowliveWhite),
      ),
    );
  }
}
