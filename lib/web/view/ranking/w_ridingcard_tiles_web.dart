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

  /// 썸네일 배경을 고른다(0·1). 카드 안 내용은 그리지 않는다.
  final int cardType;
  final VoidCallback onTap;

  /// 월 묶음의 첫 줄인지. 첫 줄만 위 여백이 없다 —
  /// 월 제목 아래 간격이 그 자리를 대신한다(목업 65:36714).
  final bool isFirst;

  /// 그 **달의** 마지막 줄인지. 달의 끝에는 구분선을 긋지 않는다
  /// (다음 달 제목과 사이가 간격으로 충분히 나뉜다).
  final bool isLast;

  const RidingCardListTileWeb({
    required this.card,
    required this.cardType,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: SDSColor.gray100)),
        ),
        // 목업: 카드 56 ↔ 아래 16 ↔ 구분선 ↔ 위 16.
        padding: EdgeInsets.only(top: isFirst ? 0 : 16, bottom: 16),
        child: Row(
          children: [
            Text(
              ridingCardDayLabel(card.date),
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
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
                      // 목업은 #111 50% — 가장 가까운 토큰을 쓴다.
                      style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                    ),
                  Text(
                    '총 ${card.totalSlopeCount ?? 0}회 라이딩',
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // 썸네일은 **카드 배경만** 그린다 — 앱 목록(`v_ridingCardList.dart`)과
            // 크기(40x64)·라운드(6)·맞춤(cover)까지 같다. 이 크기에 기록을 다 그리면
            // 글자가 읽히지 않는다(목업도 배경만이다).
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 40,
                height: 64,
                child: Image.asset(
                  cardType == 0
                      ? 'assets/imgs/imgs/img_summury_bg.png'
                      : 'assets/imgs/imgs/img_summury_bg_2.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

