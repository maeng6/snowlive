import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _numberFormat = NumberFormat('###,###,###,###');

/// 목업의 시간대 눈금. 서버 `time_info`는 이 순서의 9칸 배열이다(실측).
const List<String> kCrewTimeBuckets = [
  '00-08', '08-10', '10-12', '12-14', '14-16', '16-18', '18-20', '20-22', '22-00',
];

/// 카드에 보여줄 슬로프 개수. 목업이 7줄이고, 전체는 모달에서 본다.
const int kCrewTopSlopeCount = 7;

/// 슬로프 카운트 중 최댓값(막대 길이 기준). 비면 0.
int crewMaxSlopeCount(List<CountInfo> counts) {
  var max = 0;
  for (final c in counts) {
    final v = c.count ?? 0;
    if (v > max) max = v;
  }
  return max;
}

/// 시간대별 카운트를 [kCrewTimeBuckets] 순서의 9칸 리스트로 만든다.
/// 코어 모델이 `time_info` 배열을 이 라벨들을 키로 하는 Map으로 바꿔 준다
/// (`m_crewDetail.dart:118-128`). 키가 없으면 0으로 채워 눈금 개수를 유지한다.
List<int> crewTimeCounts(SeasonRankingInfo? season) {
  final raw = season?.timeCountInfo;
  return [
    for (final label in kCrewTimeBuckets) raw?[label] ?? 0,
  ];
}

/// `크루 라이딩 통계` — 좌: 슬로프별 가로 막대 / 우: 시간대별 세로 막대.
class CrewHomeRidingStatsWeb extends StatelessWidget {
  final SeasonRankingInfo? season;
  final String crewName;
  final String? crewLogoUrl;

  const CrewHomeRidingStatsWeb({
    super.key,
    required this.season,
    required this.crewName,
    this.crewLogoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final counts = season?.countInfo ?? const <CountInfo>[];
    final left = _SlopeCountCard(
      totalSlopeCount: season?.totalSlopeCount,
      counts: counts.take(kCrewTopSlopeCount).toList(),
      maxCount: crewMaxSlopeCount(counts),
    );
    final right = CrewTimeCountCard(timeCounts: crewTimeCounts(season));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '크루 라이딩 통계',
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => showCrewRidingStatsModal(
                context,
                season: season,
                crewName: crewName,
                crewLogoUrl: crewLogoUrl,
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: SDSColor.gray200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                '전체 슬로프 보기',
                style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
              ),
            ),
          ],
        ),
        const SizedBox(height: SDSSpacing.md),
        if (isDesktop)
          // ⚠️ `CrossAxisAlignment.stretch`를 그냥 쓰면 안 된다 — 부모가
          // SingleChildScrollView라 높이 제약이 무한이고, 그러면 stretch가 자식에게
          // 무한 높이를 물려서 레이아웃이 통째로 깨진다(실측: 화면이 밀려서 그려졌다).
          // IntrinsicHeight로 두 카드의 높이를 먼저 정해준 뒤 늘린다.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 4, child: left),
                const SizedBox(width: SDSSpacing.lg),
                Expanded(flex: 6, child: right),
              ],
            ),
          )
        else
          Column(children: [left, const SizedBox(height: SDSSpacing.md), right]),
      ],
    );
  }

}

/// 좌측 카드 — 총 라이딩 횟수 + 슬로프별 가로 막대.
class _SlopeCountCard extends StatelessWidget {
  final int? totalSlopeCount;
  final List<CountInfo> counts;
  final int maxCount;

  const _SlopeCountCard({
    required this.totalSlopeCount,
    required this.counts,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: SDSColor.blue50, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(SDSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('총 라이딩 횟수',
              style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500)),
          const SizedBox(height: 2),
          Text(
            '${_numberFormat.format(totalSlopeCount ?? 0)}회',
            style: SDSTextStyle.bold.copyWith(fontSize: 20, color: SDSColor.gray900),
          ),
          const SizedBox(height: SDSSpacing.md),
          if (counts.isEmpty)
            Text(
              '이번 시즌 라이딩 기록이 없어요.',
              style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
            )
          else
            for (var i = 0; i < counts.length; i++) ...[
              if (i > 0) const SizedBox(height: SDSSpacing.sm),
              CrewSlopeBarRow(
                label: counts[i].slope ?? '',
                count: counts[i].count ?? 0,
                maxCount: maxCount,
                // 1등 슬로프만 진한 파랑 + 검정 배지(목업).
                isTop: i == 0,
              ),
            ],
        ],
      ),
    );
  }
}

/// 슬로프 한 줄. 전체 보기 모달에서도 같은 줄을 쓴다.
/// 막대/여백 비율을 flex 정수로 바꾼다. Expanded는 flex가 1 이상이어야 한다.
int _barFlex(double ratio) => (ratio * 1000).round().clamp(1, 1000);
int _restFlex(double ratio) => 1000 - _barFlex(ratio);

class CrewSlopeBarRow extends StatelessWidget {
  final String label;
  final int count;
  final int maxCount;
  final bool isTop;

  const CrewSlopeBarRow({
    super.key,
    required this.label,
    required this.count,
    required this.maxCount,
    this.isTop = false,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxCount <= 0 ? 0.0 : (count / maxCount).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SDSTextStyle.regular.copyWith(fontSize: 11, color: SDSColor.gray500),
          ),
        ),
        const SizedBox(width: SDSSpacing.sm),
        Expanded(
          // ⚠️ LayoutBuilder로 픽셀을 계산하면 안 된다 — 상위 IntrinsicHeight가
          // 고유 높이를 물어볼 때 LayoutBuilder는 답할 수 없어서 레이아웃이 통째로
          // 깨진다(실측: "LayoutBuilder does not support returning intrinsic
          // dimensions"). 그래서 flex 비율로 막대 길이를 만든다.
          child: Row(
            children: [
              Expanded(
                flex: _barFlex(ratio),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: isTop ? SDSColor.snowliveBlue : SDSColor.blue100,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (isTop)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: SDSColor.gray900,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    _numberFormat.format(count),
                    style: SDSTextStyle.bold.copyWith(fontSize: 11, color: SDSColor.snowliveWhite),
                  ),
                )
              else
                Text(
                  _numberFormat.format(count),
                  style: SDSTextStyle.bold.copyWith(fontSize: 11, color: SDSColor.gray900),
                ),
              // 남은 공간을 채워 막대가 비율만큼만 보이게 한다.
              if (_restFlex(ratio) > 0)
                Expanded(flex: _restFlex(ratio), child: const SizedBox.shrink()),
            ],
          ),
        ),
      ],
    );
  }
}

/// 시간대 한 칸의 최소 폭(숫자가 한 줄로 들어가는 최소값).
const double _minBarSlot = 40;

/// 시간대별 세로 막대 카드. 크루홈·전체보기 모달에서는 파란 카드로 쓰고, 일별 기록
/// 카드 안에서는 [filled]를 끄고 제목만 바꿔 같은 위젯을 쓴다.
class CrewTimeCountCard extends StatelessWidget {
  final List<int> timeCounts;
  final String title;
  final bool filled;
  final double chartHeight;

  const CrewTimeCountCard({
    super.key,
    required this.timeCounts,
    this.title = '시간대별 기록',
    this.filled = true,
    this.chartHeight = 180,
  });

  @override
  Widget build(BuildContext context) {
    final max = timeCounts.fold<int>(0, (a, b) => b > a ? b : a);

    return Container(
      decoration: filled
          ? BoxDecoration(color: SDSColor.blue50, borderRadius: BorderRadius.circular(10))
          : null,
      padding: filled ? const EdgeInsets.all(SDSSpacing.lg) : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: filled
                  ? SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500)
                  : SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900)),
          const SizedBox(height: SDSSpacing.md),
          SizedBox(
            height: chartHeight,
            // 좁은 폭에서 9칸을 균등분할하면 칸이 30px도 안 돼 숫자가 두 줄로
            // 접히면서 세로로 넘친다(실측 12px) → 그때는 옆으로 스크롤한다.
            //
            // 여기 LayoutBuilder는 위 SizedBox(height: 180)가 감싸고 있어서 안전하다 —
            // 상위 IntrinsicHeight가 높이를 물어도 SizedBox가 180을 바로 답하므로
            // LayoutBuilder까지 질문이 내려가지 않는다(슬로프 막대에서 이걸 어겨서
            // 화면이 통째로 깨졌다: 위 CrewSlopeBarRow 주석 참고).
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bars = [
                  for (var i = 0; i < timeCounts.length; i++)
                    _TimeBar(
                      label: kCrewTimeBuckets[i],
                      count: timeCounts[i],
                      maxCount: max,
                      // 숫자·라벨 자리(60)를 뺀 만큼만 막대가 쓴다.
                      maxBarHeight: (chartHeight - 60).clamp(20.0, 400.0),
                    ),
                ];
                final slot = constraints.maxWidth / bars.length;
                if (slot >= _minBarSlot) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [for (final bar in bars) Expanded(child: bar)],
                  );
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final bar in bars) SizedBox(width: _minBarSlot, child: bar),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBar extends StatelessWidget {
  final String label;
  final int count;
  final int maxCount;

  /// 막대가 쓸 수 있는 최대 높이(숫자·라벨 자리를 뺀 값).
  final double maxBarHeight;

  const _TimeBar({
    required this.label,
    required this.count,
    required this.maxCount,
    required this.maxBarHeight,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxCount <= 0 ? 0.0 : (count / maxCount).clamp(0.0, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (count > 0)
          Text(
            _numberFormat.format(count),
            maxLines: 1,
            softWrap: false,
            style: SDSTextStyle.bold.copyWith(fontSize: 11, color: SDSColor.gray900),
          ),
        const SizedBox(height: 4),
        Container(
          width: 22,
          height: (maxBarHeight * ratio).clamp(count > 0 ? 4.0 : 0.0, maxBarHeight),
          decoration: BoxDecoration(
            color: SDSColor.blue100,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          softWrap: false,
          style: SDSTextStyle.regular.copyWith(fontSize: 10, color: SDSColor.gray500),
        ),
      ],
    );
  }
}

/// `전체 슬로프 보기` 모달 — 슬로프 전체 목록 + 시간대별 기록.
Future<void> showCrewRidingStatsModal(
  BuildContext context, {
  required SeasonRankingInfo? season,
  required String crewName,
  String? crewLogoUrl,
}) {
  return showWebOverlayModal<void>(
    context: context,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
    builder: (ctx, close) => _RidingStatsModal(
      season: season,
      crewName: crewName,
      crewLogoUrl: crewLogoUrl,
      onClose: close,
    ),
  );
}

class _RidingStatsModal extends StatelessWidget {
  final SeasonRankingInfo? season;
  final String crewName;
  final String? crewLogoUrl;
  final void Function([void result]) onClose;

  const _RidingStatsModal({
    required this.season,
    required this.crewName,
    required this.crewLogoUrl,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final counts = season?.countInfo ?? const <CountInfo>[];
    final max = crewMaxSlopeCount(counts);
    final timeCounts = crewTimeCounts(season);

    final slopeList = Container(
      decoration: BoxDecoration(color: SDSColor.blue50, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(SDSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('총 라이딩 횟수',
              style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500)),
          const SizedBox(height: 2),
          Text(
            '${_numberFormat.format(season?.totalSlopeCount ?? 0)}회',
            style: SDSTextStyle.bold.copyWith(fontSize: 20, color: SDSColor.gray900),
          ),
          const SizedBox(height: SDSSpacing.md),
          if (counts.isEmpty)
            Text('이번 시즌 라이딩 기록이 없어요.',
                style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400))
          else
            for (var i = 0; i < counts.length; i++) ...[
              if (i > 0) const SizedBox(height: SDSSpacing.sm),
              CrewSlopeBarRow(
                label: counts[i].slope ?? '',
                count: counts[i].count ?? 0,
                maxCount: max,
                isTop: i == 0,
              ),
            ],
        ],
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: SDSColor.snowliveWhite,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 932, maxHeight: 880),
            child: Padding(
              padding: const EdgeInsets.all(SDSSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text('크루 라이딩 통계',
                          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
                      const Spacer(),
                      if (crewLogoUrl?.isNotEmpty ?? false) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: WebNetworkImage(url: crewLogoUrl, width: 24, height: 24),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(crewName,
                          style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900)),
                    ],
                  ),
                  const SizedBox(height: SDSSpacing.md),
                  Flexible(
                    child: SingleChildScrollView(
                      child: isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 5, child: slopeList),
                                const SizedBox(width: SDSSpacing.md),
                                Expanded(flex: 5, child: CrewTimeCountCard(timeCounts: timeCounts)),
                              ],
                            )
                          : Column(children: [
                              slopeList,
                              const SizedBox(height: SDSSpacing.md),
                              CrewTimeCountCard(timeCounts: timeCounts),
                            ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: SDSColor.snowliveWhite,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onClose,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.close, size: 22, color: SDSColor.gray700),
            ),
          ),
        ),
      ],
    );
  }
}
