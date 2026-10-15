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

  /// 글줄(27) 위아래 여백. 화면마다 행 간격이 달라 열어 둔다
  /// (크루 설정 12 → 피치 51, 친구 설정 8 → 피치 43).
  final double verticalPadding;

  const WebSettingsRow({
    super.key,
    required this.label,
    this.badgeCount,
    this.badgeLabel,
    required this.onTap,
    this.verticalPadding = 12,
  });

  @override
  Widget build(BuildContext context) {
    final count = badgeCount ?? 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        // 목업(174:85477) — 글줄 27 + 상하 여백이 행 피치를 만든다.
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: Row(
          children: [
            Text(
              label,
              style: SDSTextStyle.bold
                  .copyWith(fontSize: 16, height: 27 / 16, color: SDSColor.gray900),
            ),
            if (badgeLabel?.isNotEmpty ?? false) ...[
              const SizedBox(width: SDSSpacing.sm),
              _TextBadge(label: badgeLabel!),
            ] else if (count > 0) ...[
              const SizedBox(width: SDSSpacing.sm),
              _CountBadge(count: count),
            ],
            const Spacer(),
            // 목업(218:68132) — 꺾쇠 24, #B7B7B7(gray400).
            Icon(Icons.chevron_right, size: 24, color: SDSColor.gray400),
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
    // 목업(218:68130) — 패딩 8/2, 라운드 10, ExtraBold 12.
    // 자릿수에 따라 폭이 늘어나므로 고정 폭 대신 패딩으로만 잡는다.
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: SDSColor.snowliveBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: SDSTextStyle.extraBold.copyWith(fontSize: 12, color: SDSColor.snowliveWhite),
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
    // 목업(174:85491) — 35×19, 패딩 6/4, Bold 10(글줄 11), 라운드 23.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: SDSColor.snowliveBlue,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold
            .copyWith(fontSize: 10, height: 11 / 10, color: SDSColor.snowliveWhite),
      ),
    );
  }
}
