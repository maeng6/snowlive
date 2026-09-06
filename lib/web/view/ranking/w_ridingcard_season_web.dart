import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_seasonRidingCard.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_riding_card_web.dart'
    show kRidingCardAspectRatio, kRidingCardBackgrounds;
import 'package:flutter/material.dart';

/// 앱이 시즌 카드를 그리는 기준 폭(`v_ridingCardList.dart:545`).
const double _kBaseWidth = 240;

/// 시즌 기록 카드.
///
/// **앱의 시즌 카드(`v_ridingCardList.dart:508-800`)를 그대로 옮긴 것.**
/// 배경은 데일리 카드 3번 스킨(`img_summury_bg_3.png`)을 쓰고, 값·라벨·단위·자릿수를
/// 앱 기준(width 240)으로 맞춘 뒤 실제 폭에 비례 환산한다.
///
/// 미리보기와 **캡처가 같은 위젯**이다 → 아바타는 캔버스 경로(`Image.network`)로 그린다
/// (데일리 카드와 같은 이유: `RepaintBoundary.toImage`는 캔버스에 그려진 것만 담는다).
class RidingCardSeasonWeb extends StatelessWidget {
  final SeasonRidingCard card;

  /// 카드에 찍는 시즌 라벨(`25/26 시즌`). 서버 값은 `2526`이라 화면이 만들어 넘긴다.
  final String seasonLabel;

  /// 시즌 카드 응답에도 닉네임·프로필이 있지만, 비면 로그인 사용자 값으로 채운다(앱과 동일).
  final String? displayName;
  final String? profileImageUrl;

  final double width;

  const RidingCardSeasonWeb({
    super.key,
    required this.card,
    required this.seasonLabel,
    this.displayName,
    this.profileImageUrl,
    this.width = _kBaseWidth,
  });

  double _s(double at240) => at240 * (width / _kBaseWidth);

  String get _name =>
      (card.displayName?.isNotEmpty ?? false) ? card.displayName! : (displayName ?? '');

  String? get _avatar =>
      (card.profileImageUrlUser?.isNotEmpty ?? false) ? card.profileImageUrlUser : profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width / kRidingCardAspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_s(20)),
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset(kRidingCardBackgrounds[2], fit: BoxFit.cover)),
            Positioned(
              top: _s(28),
              left: _s(20),
              right: _s(20),
              child: Column(
                children: [
                  _buildAvatar(),
                  SizedBox(height: _s(6)),
                  Text(
                    _name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.bold.copyWith(fontSize: _s(14), color: Colors.white),
                  ),
                  Text(
                    seasonLabel,
                    style: SDSTextStyle.regular.copyWith(fontSize: _s(10), color: Colors.white),
                  ),
                ],
              ),
            ),
            Positioned(
              top: _s(128),
              bottom: _s(50),
              left: _s(20),
              right: _s(20),
              child: Center(child: _buildStats()),
            ),
            Positioned(
              bottom: _s(24),
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset('assets/imgs/logos/snowliveLogo_main_white.png', height: _s(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final size = _s(68);
    final placeholder = Image.asset(
      'assets/imgs/profile/img_profile_default_circle.png',
      fit: BoxFit.cover,
    );
    final url = _avatar;

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: (url?.isNotEmpty ?? false)
            ? Image.network(
                url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder,
              )
            : placeholder,
      ),
    );
  }

  Widget _buildStats() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          (card.totalSlopeCount ?? 0) == 0 ? '-' : '${card.totalSlopeCount}',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: _s(28),
            color: Colors.white,
            height: 1.0,
          ),
        ),
        SizedBox(height: _s(2)),
        Text(
          '시즌 총 라이딩',
          style: SDSTextStyle.regular.copyWith(
            fontSize: _s(9),
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: _s(20)),
        Row(
          children: [
            Expanded(
              child: _SeasonStat(
                value: card.totalDistance,
                digits: 0,
                unit: 'km',
                label: '총 라이딩 거리',
                scale: _s,
              ),
            ),
            Expanded(
              child: _SeasonStat(
                value: card.avgSlope,
                digits: 1,
                unit: '°',
                label: '평균 경사도',
                scale: _s,
              ),
            ),
            Expanded(
              child: _SeasonStat(
                value: card.topSpeed,
                digits: 0,
                unit: 'km/h',
                label: '최고 속도',
                scale: _s,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SeasonStat extends StatelessWidget {
  final double? value;
  final int digits;
  final String unit;
  final String label;
  final double Function(double at240) scale;

  const _SeasonStat({
    required this.value,
    required this.digits,
    required this.unit,
    required this.label,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = (value ?? 0) != 0;

    return Column(
      children: [
        if (!hasValue)
          Text(
            '-',
            style: SDSTextStyle.extraBold.copyWith(fontSize: scale(17), color: Colors.white),
          )
        else
          // `54 km/h`처럼 단위가 긴 지표는 3분할 칸(240 기준 약 66px)을 넘긴다 →
          // 넘칠 때만 줄여서 그린다(앱은 카드 폭이 고정이라 드러나지 않던 문제).
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value!.toStringAsFixed(digits),
                  style: SDSTextStyle.extraBold.copyWith(fontSize: scale(17), color: Colors.white),
                ),
                SizedBox(width: scale(2)),
                Text(
                  unit,
                  style: SDSTextStyle.regular.copyWith(fontSize: scale(9), color: Colors.white),
                ),
              ],
            ),
          ),
        SizedBox(height: scale(2)),
        Text(
          label,
          maxLines: 1,
          style: SDSTextStyle.regular.copyWith(
            fontSize: scale(8),
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
