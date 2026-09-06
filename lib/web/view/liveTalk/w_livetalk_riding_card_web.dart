import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_dailyRidingCard.dart';
import 'package:flutter/material.dart';

/// 라이딩 기록 카드 배경(모바일 앱과 같은 에셋).
/// 앱의 카드 공유는 0/1만 토글하지만 목업 썸네일이 3종이라 3번째까지 둔다.
const List<String> kRidingCardBackgrounds = [
  'assets/imgs/imgs/img_summury_bg.png',
  'assets/imgs/imgs/img_summury_bg_2.png',
  'assets/imgs/imgs/img_summury_bg_3.png',
];

/// 카드 종횡비. 배경 에셋 원본(960×1524)과 같아야 잘리지 않는다.
/// 앱의 카드 공유 다이얼로그도 같은 값을 쓴다.
const double kRidingCardAspectRatio = 960 / 1524;

/// 앱이 카드를 그리는 기준 폭. 안쪽 수치를 이 폭 기준으로 적어두고 실제 폭에 비례 환산한다.
const double _kBaseWidth = 320;

/// 라이브톡에 올릴 라이딩 기록 카드.
///
/// **모바일 앱의 카드 공유 다이얼로그([v_liveTalk_main.dart]의
/// `_buildLargeCardPreview` + `_buildDialogCardType0Content/1Content`)를 1:1로 옮긴 것.**
/// 값·단위·자릿수·라벨·글자 크기·여백을 모두 그쪽 기준(width 320)으로 맞췄다.
///
/// 스킨을 바꾸면 **배경만 바뀌는 게 아니라 내용 구성이 바뀐다**(앱과 동일) —
/// 0번은 기록 5종, 1번 이상은 `슬로프 리스트`(총 라이딩 + 최다 슬로프 + 그날 탄 슬로프들).
///
/// 미리보기와 **캡처가 같은 위젯**이다. 캡처는 [RepaintBoundary.toImage()]로 하는데
/// 그건 캔버스에 그려진 것만 담으므로, 아바타는 `<img>` 폴백을 쓰는
/// [WebNetworkImage]가 아니라 캔버스 경로(`Image.network`)로 그린다.
/// Firebase Storage에 CORS가 없으면 디코드가 실패해 기본 아바타로 떨어진다.
class LiveTalkRidingCardWeb extends StatelessWidget {
  final DailyRidingCard card;

  /// 데일리 카드에는 닉네임·프로필이 없다. 앱과 같이 **로그인 사용자**에서 받는다.
  final String? displayName;
  final String? profileImageUrl;

  /// 0/1/2 — [kRidingCardBackgrounds] 인덱스.
  final int cardType;

  final double width;

  const LiveTalkRidingCardWeb({
    super.key,
    required this.card,
    required this.cardType,
    this.displayName,
    this.profileImageUrl,
    this.width = _kBaseWidth,
  });

  /// 앱 기준(320) 값을 실제 폭에 맞춰 환산한다.
  double _s(double at320) => at320 * (width / _kBaseWidth);

  /// 밝은 배경(0번)에서만 타이틀 칩이 진한 남색이다(앱과 동일).
  bool get _isLight => cardType == 0;

  @override
  Widget build(BuildContext context) {
    final background =
        kRidingCardBackgrounds[cardType.clamp(0, kRidingCardBackgrounds.length - 1)];

    return SizedBox(
      width: width,
      height: width / kRidingCardAspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_s(24)),
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset(background, fit: BoxFit.cover)),
            // 상단: 프로필 + 닉네임 + 날짜 + 라이더 타이틀
            Positioned(
              top: _s(40),
              left: _s(32),
              right: _s(32),
              child: Column(
                children: [
                  _buildAvatar(),
                  SizedBox(height: _s(10)),
                  Text(
                    displayName ?? '',
                    style: SDSTextStyle.bold.copyWith(fontSize: _s(20), color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: _s(6)),
                    child: Text(
                      '${card.date ?? ''} ${card.weekday ?? ''}'.trim(),
                      style: SDSTextStyle.regular.copyWith(fontSize: _s(13), color: Colors.white),
                    ),
                  ),
                  if (card.riderTitle?.isNotEmpty ?? false)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: _s(12), vertical: _s(3)),
                      decoration: BoxDecoration(
                        color: _isLight ? const Color(0xFF1B3A5C) : const Color(0xFFE2EDF8),
                        borderRadius: BorderRadius.circular(_s(20)),
                      ),
                      child: Text(
                        card.riderTitle!,
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: _s(13),
                          color: _isLight ? Colors.white : const Color(0xFF000000),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            // 중앙: 0번은 기록 5종, 1번 이상은 슬로프 리스트(앱의 카드 타입 구성).
            Positioned(
              top: _s(236),
              bottom: _s(80),
              left: _s(24),
              right: _s(24),
              child: Center(child: _isLight ? _buildStats() : _buildSlopeList()),
            ),
            Positioned(
              bottom: _s(40),
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/imgs/logos/snowliveLogo_main_white.png',
                  height: _s(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final size = _s(100);
    final placeholder = Image.asset(
      'assets/imgs/profile/img_profile_default_circle.png',
      fit: BoxFit.cover,
    );

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: (profileImageUrl?.isNotEmpty ?? false)
            ? Image.network(
                profileImageUrl!,
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

  /// 앱과 같은 2행 구성 — 위 2열(총 라이딩·최다 슬로프), 아래 3열(거리·경사도·속도).
  Widget _buildStats() {
    final slope = card.mostRiddenSlope;
    final slopeCount = card.mostRiddenCount ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _s(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _StatColumn(
                  label: '오늘 총 라이딩',
                  labelSize: _s(12),
                  gap: _s(4),
                  value: [
                    _span(
                      (card.totalSlopeCount ?? 0) == 0 ? '-' : '${card.totalSlopeCount}',
                      _s(30),
                      isBold: true,
                      height: 1.0,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _StatColumn(
                  label: '최다 슬로프',
                  labelSize: _s(12),
                  gap: _s(4),
                  value: [
                    _span((slope?.isNotEmpty ?? false) ? slope! : '-', _s(24), isBold: true),
                    if (slopeCount > 0) ...[
                      _gapSpan(_s(4)),
                      _span('$slopeCount회', _s(16)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: _s(16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _StatColumn(
                label: '라이딩 거리',
                labelSize: _s(12),
                gap: _s(2),
                value: _valueWithUnit(card.totalDistance, digits: 0, unit: 'km', unitSize: _s(14)),
              ),
            ),
            Expanded(
              child: _StatColumn(
                // 앱은 이 라벨만 10pt다(다른 라벨은 12pt).
                label: '평균 경사도',
                labelSize: _s(10),
                gap: _s(2),
                value: _valueWithUnit(card.avgSlope, digits: 1, unit: '°', unitSize: _s(20)),
              ),
            ),
            Expanded(
              child: _StatColumn(
                label: '최고 속도',
                labelSize: _s(12),
                gap: _s(2),
                value: _valueWithUnit(card.topSpeed, digits: 0, unit: 'km/h', unitSize: _s(14)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 슬로프 리스트 카드(앱 `_buildDialogCardType1Content`).
  ///
  /// 총 라이딩 → 가장 많이 탄 슬로프(큰 글씨) → 나머지 슬로프 이름들(최대 2줄, 넘치면 `+N`).
  Widget _buildSlopeList() {
    final entries = card.slopeCountsByName?.entries.toList() ?? [];
    final first = entries.isNotEmpty ? entries.first : null;
    final rest = entries.length > 1 ? entries.sublist(1) : const <MapEntry<String, int>>[];

    // 카드 폭에서 좌우 패딩(24*2)을 뺀 값이 슬로프 이름이 쓸 수 있는 폭이다(앱과 동일).
    final available = width - _s(48);
    final spacing = _s(8);
    final nameStyle = SDSTextStyle.bold.copyWith(fontSize: _s(14), color: Colors.white);

    final displayCount = ridingCardSlopeCountForTwoLines(
      slopes: rest.map((e) => e.key).toList(),
      maxWidth: available,
      style: nameStyle,
      spacing: spacing,
    );
    final display = rest.take(displayCount).toList();
    final remaining = rest.length - displayCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${card.totalSlopeCount ?? 0}',
          style: SDSTextStyle.extraBold
              .copyWith(fontSize: _s(40), color: Colors.white, height: 1.0),
        ),
        SizedBox(height: _s(4)),
        Text(
          '오늘 총 라이딩',
          style: SDSTextStyle.regular
              .copyWith(fontSize: _s(12), color: Colors.white.withValues(alpha: 0.7)),
        ),
        SizedBox(height: _s(24)),
        Text(
          first?.key ?? '-',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: SDSTextStyle.extraBold
              .copyWith(fontSize: _s(24), color: Colors.white, height: 1.0),
        ),
        if (display.isNotEmpty) ...[
          SizedBox(height: _s(6)),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: spacing,
            runSpacing: _s(2),
            children: [
              for (final entry in display) Text(entry.key, style: nameStyle),
              if (remaining > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: _s(6)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(_s(10)),
                  ),
                  child: Text(
                    '+$remaining',
                    style: SDSTextStyle.bold.copyWith(fontSize: _s(11), color: Colors.black),
                  ),
                ),
            ],
          ),
        ],
        SizedBox(height: _s(4)),
        Text(
          '라이딩 슬로프',
          style: SDSTextStyle.regular
              .copyWith(fontSize: _s(12), color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  /// 0이면 단위 없이 `-`만 그린다(앱과 동일).
  List<InlineSpan> _valueWithUnit(
    double? raw, {
    required int digits,
    required String unit,
    required double unitSize,
  }) {
    final value = raw ?? 0;
    if (value == 0) return [_span('-', _s(22), isBold: true)];
    return [
      _span(value.toStringAsFixed(digits), _s(22), isBold: true),
      _gapSpan(_s(2)),
      _span(unit, unitSize),
    ];
  }

  InlineSpan _span(String text, double size, {bool isBold = false, double? height}) {
    return TextSpan(
      text: text,
      style: (isBold ? SDSTextStyle.extraBold : SDSTextStyle.regular)
          .copyWith(fontSize: size, color: Colors.white, height: height),
    );
  }

  /// 값과 단위 사이 간격. 한 Text.rich 안에서 띄우려면 스팬으로 넣어야 한다.
  InlineSpan _gapSpan(double width) => WidgetSpan(child: SizedBox(width: width));
}

/// 값 한 줄 + 라벨 한 줄. 값은 숫자와 단위가 섞이므로 [Text.rich]로 그린다.
class _StatColumn extends StatelessWidget {
  final List<InlineSpan> value;
  final String label;
  final double labelSize;
  final double gap;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.labelSize,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text.rich(
          TextSpan(children: value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: gap),
        Text(
          label,
          style: SDSTextStyle.regular
              .copyWith(fontSize: labelSize, color: Colors.white.withValues(alpha: 0.7)),
          maxLines: 1,
        ),
      ],
    );
  }
}


/// 슬로프 이름 하나의 렌더 폭.
double ridingCardTextWidth(String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width;
}

/// **2줄에 들어가는 슬로프 개수**(앱 `_getSlopeCountForTwoLines` 이식).
///
/// 넘치는 만큼은 `+N` 배지로 접는데, 그 배지가 들어갈 자리까지 고려해 개수를 줄인다.
/// 앱 로직을 그대로 옮겼다 — 카드가 두 줄을 넘겨 잘리는 것을 막는 게 목적이다.
int ridingCardSlopeCountForTwoLines({
  required List<String> slopes,
  required double maxWidth,
  required TextStyle style,
  required double spacing,
}) {
  double currentLineWidth = 0;
  var lineCount = 1;
  var count = 0;

  for (var i = 0; i < slopes.length; i++) {
    final textWidth = ridingCardTextWidth(slopes[i], style);

    if (currentLineWidth + textWidth > maxWidth) {
      lineCount++;
      if (lineCount > 2) {
        final plusWidth = ridingCardTextWidth('+${slopes.length - count}', style);
        while (count > 0) {
          var lastLineWidth = 0.0;
          var tempLineCount = 1;
          for (var j = 0; j < count; j++) {
            final w = ridingCardTextWidth(slopes[j], style);
            if (lastLineWidth + w > maxWidth) {
              tempLineCount++;
              lastLineWidth = w + spacing;
            } else {
              lastLineWidth += w + spacing;
            }
          }
          if (tempLineCount <= 2 && lastLineWidth + plusWidth <= maxWidth) break;
          if (tempLineCount < 2) break;
          count--;
        }
        return count;
      }
      currentLineWidth = textWidth + spacing;
    } else {
      currentLineWidth += textWidth + spacing;
    }
    count++;
  }
  return count;
}
