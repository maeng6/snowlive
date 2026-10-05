import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/widget/w_web_section_link_button_web.dart';
import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 차트 막대 두께 — 가로(슬로프별)·세로(시간대별) 모두 14로 통일(사용자 확정).
const double _kBarThickness = 14;

/// 막대 끝 라운드 — 목업(161:86797/86817)은 **자라나는 쪽 끝만 4**다
/// (가로 막대는 오른쪽, 세로 막대는 위쪽. 시작 쪽은 각지다).
const double _kBarRadius = 4;

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
///
/// 전체 슬로프 보기: PC·태블릿은 **팝업**, 모바일은 팝업 대신 **그 자리에서
/// 아래로 펼친다**(좁은 화면에서 팝업이 거의 전체를 덮어 맥락이 끊긴다).
class CrewHomeRidingStatsWeb extends StatefulWidget {
  final SeasonRankingInfo? season;
  final String crewName;
  final String? crewLogoUrl;

  /// 서버 색 문자열. 로고가 비어 있으면 이 색의 기본 `LIVE CREW` 마크를 쓴다.
  final String? crewColor;

  const CrewHomeRidingStatsWeb({
    super.key,
    required this.season,
    required this.crewName,
    this.crewLogoUrl,
    this.crewColor,
  });

  @override
  State<CrewHomeRidingStatsWeb> createState() => _CrewHomeRidingStatsWebState();
}

class _CrewHomeRidingStatsWebState extends State<CrewHomeRidingStatsWeb> {
  /// 모바일에서 슬로프 목록을 전부 펼쳤는지.
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isMobile = context.screenType == WebScreenType.mobile;
    final season = widget.season;
    final counts = season?.countInfo ?? const <CountInfo>[];
    // 모바일에서 펼친 상태면 상위 N개가 아니라 전부 그린다.
    final visibleCounts =
        (isMobile && _expanded) ? counts : counts.take(kCrewTopSlopeCount).toList();
    final hasMore = counts.length > kCrewTopSlopeCount;
    final left = _SlopeCountCard(
      totalSlopeCount: season?.totalSlopeCount,
      counts: visibleCounts,
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
              style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
            ),
            const Spacer(),
            // 모바일은 펼침 토글(문구도 함께 바뀐다), 그 외는 팝업.
            if (!isMobile || hasMore)
              WebSectionLinkButton(
                label: isMobile
                    ? (_expanded ? '슬로프 접기' : '전체 슬로프 보기')
                    : '전체 슬로프 보기',
                onTap: () {
                  if (isMobile) {
                    setState(() => _expanded = !_expanded);
                    return;
                  }
                  showCrewRidingStatsModal(
                    context,
                    season: season,
                    crewName: widget.crewName,
                    // 로고가 없으면 색별 기본 마크로 대체한다(목록·팝업과 같은 처리).
                    crewLogoUrl: crewLogoUrlOf(
                        logoUrl: widget.crewLogoUrl, color: widget.crewColor),
                  );
                },
              ),
          ],
        ),
        // 제목줄 ↔ 카드 12 (목업 — 제목줄 36, 카드 48).
        const SizedBox(height: 12),
        if (context.screenType != WebScreenType.mobile)
          // 두 카드는 **각자 제 높이**를 쓴다. 예전에는 IntrinsicHeight + stretch로
          // 높이를 맞췄는데, 슬로프가 많은 크루에서는 왼쪽이 길어진 만큼 오른쪽
          // 시간대별 카드까지 늘어나 차트 아래가 텅 비었다.
          // (stretch를 쓰려면 IntrinsicHeight가 꼭 필요했다 — 부모가 스크롤뷰라
          //  높이 제약이 무한이라서. 이제 둘 다 필요 없다.)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PC 목업(161:86785/86813) — 좌 423 : 우 430, 사이 21.
              // 태블릿 목업(161:93667)은 370 : 370, 사이 20 — 1:1로 나눈다.
              Expanded(flex: isDesktop ? 423 : 1, child: left),
              SizedBox(width: isDesktop ? 21 : 20),
              Expanded(flex: isDesktop ? 430 : 1, child: right),
            ],
          )
        else
          // 카드 사이 20 (목업 161:101702 — 카드 310, 다음 카드 330).
          Column(children: [left, const SizedBox(height: 20), right]),
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
      // 목업 — 카드 라운드 16, 패딩 24, 제목 13 / 값 Bold 24(제목↔값 2).
      decoration: BoxDecoration(color: SDSColor.blue50, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('총 라이딩 횟수',
              style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500)),
          const SizedBox(height: 2),
          Text(
            '${_numberFormat.format(totalSlopeCount ?? 0)}회',
            style: SDSTextStyle.bold.copyWith(fontSize: 24, color: SDSColor.gray900),
          ),
          // 값 ↔ 막대 목록 24 (목업 — 값 끝 70, 목록 94).
          const SizedBox(height: SDSSpacing.lg),
          if (counts.isEmpty)
            Text(
              '이번 시즌 라이딩 기록이 없어요.',
              style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
            )
          else
            for (var i = 0; i < counts.length; i++) ...[
              // 행 피치 28 = 막대 14 + 간격 14 (목업 161:86789).
              if (i > 0) const SizedBox(height: 14),
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
            // 목업 — 슬로프 라벨 Regular 12, 검정 50%.
            style: SDSTextStyle.regular
                .copyWith(fontSize: 12, color: SDSColor.gray900.withValues(alpha: 0.5)),
          ),
        ),
        // 라벨 ↔ 막대 10 (목업 — 라벨 폭 36, 막대 시작 46).
        const SizedBox(width: 10),
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
                  // 막대 두께는 가로·세로 차트 모두 14로 통일(사용자 확정).
                  height: _kBarThickness,
                  decoration: const BoxDecoration(
                    color: SDSColor.blue100,
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(_kBarRadius)),
                  ).copyWith(color: isTop ? SDSColor.snowliveBlue : SDSColor.blue100),
                ),
              ),
              const SizedBox(width: 6),
              if (isTop)
                Container(
                  // 목업(161:86805) — 34×20, 라운드 20, Bold 12 흰색
                  height: 20,
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(minWidth: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: SDSColor.gray900,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _numberFormat.format(count),
                    style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.snowliveWhite),
                  ),
                )
              else
                Text(
                  _numberFormat.format(count),
                  style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.gray900),
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
    // 목업(161:86816) 차트 영역 228 → 카드 높이가 310으로 고정된다.
    this.chartHeight = 228,
  });

  @override
  Widget build(BuildContext context) {
    final max = timeCounts.fold<int>(0, (a, b) => b > a ? b : a);

    return Container(
      // 카드 라운드는 좌측 카드와 같은 16(목업).
      decoration: filled
          ? BoxDecoration(color: SDSColor.blue50, borderRadius: BorderRadius.circular(16))
          : null,
      padding: filled ? const EdgeInsets.all(20) : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: filled
                  // 카드 제목은 좌측 카드와 같은 Regular 13.
                  ? SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500)
                  : SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900)),
          // 제목 ↔ 차트 20 (목업 — 제목 끝 38, 차트 58).
          const SizedBox(height: 20),
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
            style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.gray900),
          ),
        // 숫자 ↔ 막대 5 (목업).
        const SizedBox(height: 5),
        Container(
          width: _kBarThickness,
          height: (maxBarHeight * ratio).clamp(count > 0 ? 4.0 : 0.0, maxBarHeight),
          decoration: const BoxDecoration(
            color: SDSColor.blue100,
            borderRadius: BorderRadius.vertical(top: Radius.circular(_kBarRadius)),
          ),
        ),
        // 막대 ↔ 라벨 8, 라벨 Regular 11 (목업).
        const SizedBox(height: 8),
        Text(
          label,
          maxLines: 1,
          softWrap: false,
          style: SDSTextStyle.regular.copyWith(fontSize: 11, color: SDSColor.gray500),
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
    // 상하 여백의 **최소값**. 보통은 카드 높이 상한(화면 80%)이 10% 여백을
    // 만들지만, 창이 아주 낮을 때 카드가 가장자리에 닿지 않게 바닥을 깔아둔다.
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
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
    final isTablet = context.screenType == WebScreenType.tablet;
    // 태블릿만 목업(161:99209) 값 — 카드 패딩 30 · 제목 20 · 닫기 48/간격 20.
    // PC·모바일은 앞서 확정한 24 / 16 / 40·12를 그대로 쓴다.
    final double cardPadding = isTablet ? 30 : SDSSpacing.lg;
    final double titleSize = isTablet ? 20 : 16;
    final double titleGap = isTablet ? 20 : SDSSpacing.md;
    final double closeSize = isTablet ? 48 : 40;
    final double closeGap = isTablet ? 20 : 12;
    // 카드 폭 상한 — PC 932 / 태블릿 483(목업). 더 좁으면 부모 제약에 맞춰 줄어든다.
    final double cardMaxWidth = isTablet ? 483 : 932;
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
        // 목업에서 **카드가 화면 정중앙**이고 닫기 버튼만 그 바깥 오른쪽에 걸린다.
        // Row 전체가 가운데 정렬되므로, 오른쪽 (간격 + 버튼)과 같은 폭을 왼쪽에
        // 비워 둬야 카드 중심이 화면 중심과 맞는다.
        if (isTablet) SizedBox(width: closeGap + closeSize),
        // ⚠️ `Flexible`이 꼭 필요하다 — 닫기 버튼(40)과 간격(12)은 고정 폭이라
        // 카드가 남는 폭까지만 줄어들어야 한다. 이게 없으면 카드가 가용 폭을 통째로
        // 가져가서 그 둘이 밖으로 밀려나 오른쪽이 잘린다(태블릿 실측).
        Flexible(
          child: Material(
            color: SDSColor.snowliveWhite,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              // 둘 다 **상한만** 둔다 — 내용이 모자라면 카드가 그만큼 줄고(여백이
              // 늘어나고), 넘치면 상한에서 멈춰 안쪽 스크롤이 생긴다.
              // 높이 상한 80% = 상하 10%씩 여백(최소 여백은 오버레이 패딩 24).
              constraints: BoxConstraints(
                maxWidth: cardMaxWidth,
                maxHeight: MediaQuery.sizeOf(context).height * 0.8,
              ),
            child: Padding(
              // ⚠️ 오른쪽·아래 여백은 여기서 주지 않는다 — 스크롤바가 카드
              // 오른쪽 선에 붙어야 하므로 스크롤 영역 **안쪽**으로 내린다(웹 공통).
              padding: EdgeInsets.fromLTRB(cardPadding, cardPadding, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    // 제목 줄은 스크롤 밖이라 오른쪽 여백을 직접 든다.
                    padding: EdgeInsets.only(right: cardPadding),
                    child: Row(
                    children: [
                      Text('크루 라이딩 통계',
                          style: SDSTextStyle.bold
                              .copyWith(fontSize: titleSize, color: SDSColor.gray900)),
                      const Spacer(),
                      if (crewLogoUrl?.isNotEmpty ?? false) ...[
                        // 크루명 왼쪽 로고 — 라운드는 공용 비율, 흰 마크가 흰 배경에
                        // 묻히지 않게 gray100 선을 두른다(목록·팝업과 같은 처리).
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(crewLogoRadius(24)),
                            border: Border.all(color: SDSColor.gray100),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: WebNetworkImage(url: crewLogoUrl, width: 24, height: 24),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(crewName,
                          style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900)),
                    ],
                  ),
                  ),
                  SizedBox(height: titleGap),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(right: cardPadding, bottom: cardPadding),
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
        ),
        SizedBox(width: closeGap),
        Material(
          color: SDSColor.snowliveWhite,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onClose,
            child: SizedBox(
              width: closeSize,
              height: closeSize,
              // 원이 커지면 글리프도 같은 비율로(40→22 기준).
              child: Icon(Icons.close,
                  size: closeSize * 22 / 40, color: SDSColor.gray700),
            ),
          ),
        ),
      ],
    );
  }
}
