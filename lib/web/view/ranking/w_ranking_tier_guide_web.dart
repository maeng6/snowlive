import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';

class _TierInfo {
  final String name;
  final String percentile;
  final Color bg;
  final Color fg;

  const _TierInfo(this.name, this.percentile, this.bg, this.fg);
}

const List<_TierInfo> _kTiers = [
  _TierInfo('그랜드 마스터', '상위 0.2%', Color(0xFFEAF2FE), Color(0xFF3D83ED)),
  _TierInfo('마스터', '상위 3%', Color(0xFFEAF8EE), Color(0xFF3FAE5C)),
  _TierInfo('다이아몬드', '상위 10%', Color(0xFFF1EEFB), Color(0xFF8B7CD8)),
  _TierInfo('플래티넘', '상위 40%', Color(0xFFF1F1F1), Color(0xFF8C8C8C)),
  _TierInfo('골드', '상위 70%', Color(0xFFFFF4E2), Color(0xFFC98A2C)),
  _TierInfo('실버', '상위 90%', Color(0xFFF3F3F3), Color(0xFFA0A0A0)),
  _TierInfo('브론즈', '상위 100%', Color(0xFFFBEDE8), Color(0xFFC0704A)),
];

/// "스노우라이브 랭킹 등급표" 안내 모달. 모바일은 정적 이미지 1장으로 처리하지만,
/// 코드베이스에 등급 텍스트/퍼센트를 구조화한 소스가 없어 첨부 레퍼런스의 텍스트를
/// 그대로 옮겨 적었다(실제 배지 아이콘은 유저별 서버 응답이라 여기선 색상 원으로 대체).
Future<void> showRankingTierGuide(BuildContext context) {
  return showWebOverlayModal<void>(
    context: context,
    builder: (_, close) => Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(SDSSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text('스노우라이브 랭킹 등급표', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
                    Positioned(
                      right: 0,
                      child: InkWell(onTap: close, child: Icon(Icons.close, size: 20, color: SDSColor.gray400)),
                    ),
                  ],
                ),
                const SizedBox(height: SDSSpacing.lg),
                for (final tier in _kTiers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: SDSSpacing.sm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: tier.bg, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(Icons.ac_unit, color: tier.fg, size: 22),
                          const SizedBox(width: 12),
                          Text(tier.name, style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
                          const Spacer(),
                          Text(tier.percentile, style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
