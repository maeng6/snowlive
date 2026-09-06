import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_dailyRidingCard.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_riding_card_web.dart';
import 'package:com.snowlive/web/view/ranking/riding_card_sections_web.dart';
import 'package:flutter/material.dart';

/// 그리드 한 칸 — 카드 + 왼쪽 위 날짜 배지.
class RidingCardGridTileWeb extends StatelessWidget {
  final DailyRidingCard card;
  final int cardType;
  final String? displayName;
  final String? profileImageUrl;
  final VoidCallback onTap;

  const RidingCardGridTileWeb({
    required this.card,
    required this.cardType,
    required this.displayName,
    required this.profileImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              LiveTalkRidingCardWeb(
                card: card,
                cardType: cardType,
                displayName: displayName,
                profileImageUrl: profileImageUrl,
                width: constraints.maxWidth,
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: SDSColor.snowliveWhite,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: Text(
                    ridingCardDayBadge(card.date),
                    style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.gray900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 목록 한 줄 — 날짜 + 칭호 + 총 라이딩 횟수 + 카드 썸네일.
class RidingCardListTileWeb extends StatelessWidget {
  final DailyRidingCard card;
  final int cardType;
  final String? displayName;
  final String? profileImageUrl;
  final VoidCallback onTap;

  const RidingCardListTileWeb({
    required this.card,
    required this.cardType,
    required this.displayName,
    required this.profileImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: SDSColor.gray100)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Text(
              ridingCardDayLabel(card.date),
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
            ),
            const SizedBox(width: SDSSpacing.md),
            // ⚠️ `Spacer` + `Flexible`을 쓰면 둘 다 flex 1이라 **남는 폭을 반씩 나눠 갖는다**
            // → 칭호 길이에 따라 오른쪽 블록과 썸네일 위치가 행마다 달라졌다(실측).
            // 오른쪽 블록이 남는 폭을 전부 갖고 그 안에서 오른쪽 정렬해야 썸네일이 고정된다.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (card.riderTitle?.isNotEmpty ?? false)
                    Text(
                      card.riderTitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
                    ),
                  Text(
                    '총 ${card.totalSlopeCount ?? 0}회 라이딩',
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 썸네일도 같은 카드 위젯이다(작게 그린다).
            LiveTalkRidingCardWeb(
              card: card,
              cardType: cardType,
              displayName: displayName,
              profileImageUrl: profileImageUrl,
              width: 34,
            ),
          ],
        ),
      ),
    );
  }
}

