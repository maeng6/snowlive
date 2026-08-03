import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_ridingRecordCard.dart';
import 'package:flutter/material.dart';

/// 라이딩 기록 카드 배경(모바일 앱과 같은 에셋). 목업 썸네일 3종과 일치한다.
const List<String> kRidingCardBackgrounds = [
  'assets/imgs/imgs/img_summury_bg.png',
  'assets/imgs/imgs/img_summury_bg_2.png',
  'assets/imgs/imgs/img_summury_bg_3.png',
];

/// 카드 종횡비(목업: 세로로 긴 카드).
const double kRidingCardAspectRatio = 300 / 420;

/// 라이브톡에 올릴 라이딩 기록 카드.
///
/// 미리보기와 **캡처가 같은 위젯**이다. 캡처는 [RepaintBoundary.toImage()]로 하는데
/// 그건 캔버스에 그려진 것만 담기므로, 아바타는 `<img>` 폴백을 쓰는
/// [WebNetworkImage]가 아니라 캔버스 경로(`Image.network`)로 그린다.
/// Firebase Storage에 CORS가 없으면 디코드가 실패해 기본 아바타로 떨어진다.
class LiveTalkRidingCardWeb extends StatelessWidget {
  final RidingRecordCard card;

  /// 0/1/2 — [kRidingCardBackgrounds] 인덱스.
  final int cardType;

  /// 카드 폭. 안쪽 수치는 이 폭에 비례해 커진다.
  final double width;

  const LiveTalkRidingCardWeb({
    super.key,
    required this.card,
    required this.cardType,
    this.width = 300,
  });

  /// 폭 300 기준으로 잡은 값을 실제 폭에 맞춰 환산한다.
  double _s(double at300) => at300 * (width / 300);

  @override
  Widget build(BuildContext context) {
    final background = kRidingCardBackgrounds[cardType.clamp(0, kRidingCardBackgrounds.length - 1)];
    // 밝은 배경(3번)에서는 흰 글씨가 안 보인다.
    final isLight = cardType == 2 ? false : cardType == 0;

    return SizedBox(
      width: width,
      height: width / kRidingCardAspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_s(16)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(background, fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _s(20), vertical: _s(24)),
              child: Column(
                children: [
                  _buildAvatar(),
                  SizedBox(height: _s(8)),
                  Text(
                    card.displayName ?? '',
                    style: SDSTextStyle.bold.copyWith(fontSize: _s(15), color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: _s(2)),
                  Text(
                    // 목업은 "휘닉스파크 2026.01.14"지만 API에 리조트가 없다 → 날짜만.
                    '${card.date ?? ''} ${card.weekday ?? ''}'.trim(),
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: _s(10), color: Colors.white.withValues(alpha: 0.85)),
                  ),
                  if (card.riderTitle?.isNotEmpty ?? false) ...[
                    SizedBox(height: _s(8)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: _s(10), vertical: _s(4)),
                      decoration: BoxDecoration(
                        color: isLight ? const Color(0xFF1B3A5C) : const Color(0xFFE2EDF8),
                        borderRadius: BorderRadius.circular(_s(12)),
                      ),
                      child: Text(
                        card.riderTitle!,
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: _s(9),
                          color: isLight ? Colors.white : SDSColor.snowliveBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const Spacer(),
                  _buildTotal(),
                  SizedBox(height: _s(20)),
                  _buildStats(),
                  const Spacer(),
                  Image.asset('assets/imgs/logos/snowliveLogo_main_white.png', height: _s(10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final url = card.profileImageUrlUser;
    final size = _s(64);
    final placeholder = Container(
      width: size,
      height: size,
      color: Colors.white24,
      child: Icon(Icons.person, size: size * 0.6, color: Colors.white70),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: _s(2)),
      ),
      child: ClipOval(
        child: (url?.isNotEmpty ?? false)
            ? Image.network(
                url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                // 캡처에 담기려면 캔버스에 그려야 한다 → html 폴백을 쓰지 않는다.
                errorBuilder: (_, __, ___) => placeholder,
              )
            : placeholder,
      ),
    );
  }

  Widget _buildTotal() {
    final count = card.totalSlopeCount ?? 0;
    return Column(
      children: [
        Text(
          count == 0 ? '-' : '$count',
          style: SDSTextStyle.extraBold.copyWith(fontSize: _s(46), color: Colors.white, height: 1),
        ),
        SizedBox(height: _s(2)),
        Text('오늘 총 라이딩',
            style: SDSTextStyle.regular
                .copyWith(fontSize: _s(10), color: Colors.white.withValues(alpha: 0.85))),
      ],
    );
  }

  Widget _buildStats() {
    final slope = card.mostRiddenSlope;
    final slopeCount = card.mostRiddenCount ?? 0;
    final speed = card.topSpeed ?? 0;

    return Row(
      children: [
        Expanded(
          child: _StatColumn(
            valueSpans: [
              TextSpan(
                text: (slope?.isNotEmpty ?? false) ? slope! : '-',
                style: SDSTextStyle.extraBold.copyWith(fontSize: _s(17), color: Colors.white),
              ),
              if (slopeCount > 0)
                TextSpan(
                  text: '$slopeCount회',
                  style: SDSTextStyle.regular.copyWith(fontSize: _s(11), color: Colors.white),
                ),
            ],
            label: '최다 슬로프',
            labelSize: _s(9),
          ),
        ),
        Expanded(
          child: _StatColumn(
            valueSpans: [
              TextSpan(
                text: speed == 0 ? '-' : speed.toStringAsFixed(1),
                style: SDSTextStyle.extraBold.copyWith(fontSize: _s(17), color: Colors.white),
              ),
              if (speed != 0)
                TextSpan(
                  text: ' km/h',
                  style: SDSTextStyle.regular.copyWith(fontSize: _s(11), color: Colors.white),
                ),
            ],
            label: '최고 속도',
            labelSize: _s(9),
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final List<InlineSpan> valueSpans;
  final String label;
  final double labelSize;

  const _StatColumn({required this.valueSpans, required this.label, required this.labelSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text.rich(
          TextSpan(children: valueSpans),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: labelSize * 0.3),
        Text(label,
            style: SDSTextStyle.regular
                .copyWith(fontSize: labelSize, color: Colors.white.withValues(alpha: 0.85))),
      ],
    );
  }
}
