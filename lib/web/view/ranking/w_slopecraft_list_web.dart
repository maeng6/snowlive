import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/core/model/m_slope_rush.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/web_drag_scroll_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_crew_modal_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';

/// 점령 현황 제목 줄 높이. `전체 슬로프 보기` 버튼과 같다(목업 82:67418).
const double _kListHeaderHeight = 36;

/// 점령 현황 줄 — 내용 높이와 줄 사이 간격.
const double _kRowHeight = 48;
const double _kRowGap = 12;

/// hover 배경이 목록 폭 밖으로 넘치는 양(좌우 각각).
const double _kRowHoverBleed = 12;

/// TOP 5 카드 배경(목업 82:65443 실측 #F0F6FF).
/// 토큰 blue50(#ECF3FD)과 2~3/255 차이라 토큰을 쓰면 다른 색으로 보인다.
const Color kSlopeCraftTopCrewCardColor = Color(0xFFF0F6FF);

/// 점령 크루를 크루 미리보기 팝업에 넘기기 위한 변환.
///
/// 점령 응답(`SlopeCrew`)에는 멤버 수·리조트가 없어서 팝업의 `N명` 줄은 비고
/// 이름·로고·소개와 `크루 구경하기`만 나온다(추가 조회 없이 보여줄 수 있는 범위).
CrewCard slopeCrewToCard(SlopeCrew crew) => CrewCard(
  crewId: crew.crewId,
  crewName: crew.crewName,
  crewLogoUrl: crew.crewLogoUrl,
  description: crew.description,
);

/// `{리조트} 점령 현황` / `{슬로프} 점령 현황` 목록.
///
/// 슬로프를 고르지 않았으면 **슬로프별 1위 크루**를 한 줄씩(슬로프명 + 크루 + 점령률),
/// 골랐으면 **그 슬로프의 크루 전체**를 점령률 순으로 보여준다(목업).
class SlopeCraftListWeb extends StatelessWidget {
  final String title;
  final List<SlopeRushItem> items;

  /// 고른 슬로프. null이면 전체 모드.
  final SlopeRushItem? selectedSlope;
  final SlopeCrew? Function(SlopeRushItem item) leaderOf;
  final void Function(SlopeRushItem item) onSlopeTap;

  /// 전체 모드로 돌아가는 버튼(슬로프 모드에서만 그린다).
  final VoidCallback onShowAll;

  const SlopeCraftListWeb({
    super.key,
    required this.title,
    required this.items,
    required this.selectedSlope,
    required this.leaderOf,
    required this.onSlopeTap,
    required this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    final slope = selectedSlope;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 제목 줄은 `전체 슬로프 보기` 버튼(36)에 맞춰 **높이 36 고정**이다 —
        // 버튼이 없는 전체 모드에서도 제목이 같은 자리에 선다(목업 82:64717 · 82:67418).
        SizedBox(
          height: _kListHeaderHeight,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 15,
                    color: SDSColor.gray900,
                  ),
                ),
              ),
              if (slope != null)
                OutlinedButton(
                  onPressed: onShowAll,
                  // 목업 실측: 109x36 · 테두리 #ECECEC(가이드상 gray100) ·
                  // 라운드 6 · 패딩 12/10 · Bold 13.
                  // 웹 기본 visualDensity가 높이를 깎으므로 함께 고정한다.
                  // hover는 **라인 버튼 공통 규칙**(`WebProfilePillButton`과 같다) —
                  // 테두리·글자는 그대로 두고 면이 흰색 → gray50으로 어두워진다.
                  // 리플·그림자·전환 애니메이션은 쓰지 않는다.
                  style: ButtonStyle(
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    shadowColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    elevation: const WidgetStatePropertyAll(0),
                    animationDuration: Duration.zero,
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.hovered)
                          ? SDSColor.gray50
                          : SDSColor.snowliveWhite,
                    ),
                    side: const WidgetStatePropertyAll(
                      BorderSide(color: SDSColor.gray100),
                    ),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    minimumSize: const WidgetStatePropertyAll(
                      Size(0, _kListHeaderHeight),
                    ),
                    visualDensity: VisualDensity.standard,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  child: Text(
                    '전체 슬로프 보기',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 13,
                      color: SDSColor.gray900,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // 제목 줄 ↔ 첫 줄. 줄 위에 6이 붙으므로 그만큼 빼서 글자 기준 30을 맞춘다.
        const SizedBox(height: 16),
        if (slope != null)
          ..._buildSlopeCrews(context, slope)
        else
          ..._buildSlopeRows(context),
      ],
    );
  }

  /// 전체 모드 — 슬로프별 1위 크루.
  List<Widget> _buildSlopeRows(BuildContext context) {
    // 슬로프 목록은 와도(미점령 포함) 아무도 점령하지 않았으면 "점령 기록 없음"으로 안내한다.
    // (예전엔 미점령 행만 쭉 떠서 '점령 기록이 없다'는 안내가 전혀 보이지 않았다.)
    final hasAnyOccupied = items.any((item) => leaderOf(item) != null);
    if (items.isEmpty || !hasAnyOccupied) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              '점령 기록이 없어요.',
              style: SDSTextStyle.regular.copyWith(
                fontSize: 13,
                color: SDSColor.gray400,
              ),
            ),
          ),
        ),
      ];
    }

    return [
      for (final item in items)
        _CrewRow(
          slopeName: item.slopeNickname.isNotEmpty
              ? item.slopeNickname
              : item.slopeFullname,
          crew: leaderOf(item),
          onTap: () => onSlopeTap(item),
        ),
    ];
  }

  /// 슬로프 모드 — 그 슬로프의 크루 전체(점령률 내림차순).
  List<Widget> _buildSlopeCrews(BuildContext context, SlopeRushItem slope) {
    final crews = [...slope.crews]..sort((a, b) => b.ratio.compareTo(a.ratio));
    if (crews.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              '아직 아무도 점령하지 않은 슬로프예요.',
              style: SDSTextStyle.regular.copyWith(
                fontSize: 13,
                color: SDSColor.gray400,
              ),
            ),
          ),
        ),
      ];
    }

    return [
      for (final crew in crews)
        _CrewRow(
          slopeName: null,
          crew: crew,
          onTap: () => showLiveCrewModal(context, slopeCrewToCard(crew)),
        ),
    ];
  }
}

class _CrewRow extends StatelessWidget {
  /// null이면 슬로프명 칸을 그리지 않는다(슬로프 모드).
  final String? slopeName;
  final SlopeCrew? crew;
  final VoidCallback onTap;

  const _CrewRow({
    required this.slopeName,
    required this.crew,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 로고가 없는 크루는 앱과 같이 **색별 기본 `LIVE CREW` 마크**로 대체한다
    // (점령 응답에는 크루 색이 없어 회색 기본 마크로 떨어진다).
    final logoUrl = crew == null
        ? ''
        : (crewLogoUrlOf(logoUrl: crew!.crewLogoUrl) ?? '');
    final description = crew?.description.trim().replaceAll('\n', ' ') ?? '';

    // 줄 높이 48 · 줄 사이 12(목업 16에서 4 줄인 값, 사용자 확정).
    return SizedBox(
      height: _kRowHeight + _kRowGap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // hover 배경만 좌우로 조금 **넘치게** 그린다 — 목록 폭(=글자 위치)은
          // 그대로 두고 배경에만 좌우 여백이 생긴다. 넘치는 쪽은 지도와의
          // 간격(40)·페이지 여백(40) 안이라 다른 요소를 건드리지 않는다.
          final inkWidth = constraints.maxWidth + _kRowHoverBleed * 2;
          return OverflowBox(
            minWidth: inkWidth,
            maxWidth: inkWidth,
            minHeight: 0,
            maxHeight: _kRowHeight + _kRowGap,
            // hover 잉크는 조상 Material 캔버스에 그려진다 — 페이지 흰 배경이
            // 그 위를 덮으므로 행 바로 위에 투명 Material을 끼운다
            // (커뮤니티·각종소식 행과 같다).
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                // 표·목록 행 공통 hover — 검정 3%.
                hoverColor: SDSColor.gray900.withValues(alpha: 0.03),
                child: Padding(
                  // 위아래는 똑같이 6씩(한쪽에만 주면 배경이 한쪽으로만 번진다),
                  // 좌우는 넘친 만큼 되돌려 글자를 제자리에 둔다.
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kRowHoverBleed,
                    vertical: _kRowGap / 2,
                  ),
                  child: Row(
                    children: [
                      if (slopeName != null) ...[
                        SizedBox(
                          width: 48,
                          child: Text(
                            slopeName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 12,
                              color: SDSColor.gray900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: SDSColor.snowliveWhite,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: SDSColor.gray100),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: logoUrl.isEmpty
                            ? null
                            : WebNetworkImage(
                                url: logoUrl,
                                width: 48,
                                height: 48,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: crew == null
                            ? Text(
                                '미점령',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 14,
                                  color: SDSColor.gray400,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    crew!.crewName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    // 목업은 크루명이 **Regular 16**이다(볼드 아님).
                                    style: SDSTextStyle.regular.copyWith(
                                      fontSize: 16,
                                      color: SDSColor.gray900,
                                    ),
                                  ),
                                  if (description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: SDSTextStyle.regular.copyWith(
                                        fontSize: 13,
                                        color: SDSColor.gray500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 64,
                        child: Text(
                          crew == null
                              ? '-'
                              : slopeCraftRatioLabel(crew!.ratio),
                          textAlign: TextAlign.right,
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: 16,
                            color: SDSColor.gray900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 점령률 표기. 서버는 0~1 비율로 준다(실측 0.425 → `42.5%`).
String slopeCraftRatioLabel(double ratio) {
  final percent = ratio * 100;
  // 소수점이 의미 없는 값(40.0)은 정수로 적는다(목업의 `23%`).
  final text = percent % 1 == 0
      ? percent.toStringAsFixed(0)
      : percent.toStringAsFixed(1);
  return '$text%';
}

/// `전체 스키장 점령 TOP 5 크루` 가로 줄.
///
/// 전용 API가 없어 **크루홈 집계의 `이번 시즌 슬로프 점령` 상위 5개**를 쓴다.
/// 그래서 지난 시즌 탭에서는 화면이 이 줄을 그리지 않는다.
class SlopeCraftTopCrewsWeb extends StatelessWidget {
  final List<CrewCard> crews;

  const SlopeCraftTopCrewsWeb({super.key, required this.crews});

  @override
  Widget build(BuildContext context) {
    if (crews.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '전체 스키장 점령 TOP 5 크루',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 14,
            color: SDSColor.gray900,
          ),
        ),
        // 목업 실측: 소제목 ↔ 카드 16, 카드 224x58, 카드 사이 10.
        const SizedBox(height: 16),
        SizedBox(
          height: 58,
          child: WebHorizontalDragScroll(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: crews.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) =>
                  _TopCrewCard(rank: index + 1, crew: crews[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopCrewCard extends StatelessWidget {
  final int rank;
  final CrewCard crew;

  const _TopCrewCard({required this.rank, required this.crew});

  @override
  Widget build(BuildContext context) {
    return Material(
      // 목업 실측 #F0F6FF — blue50(#ECF3FD)보다 살짝 밝고 푸르다.
      color: kSlopeCraftTopCrewCardColor,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showLiveCrewModal(context, crew),
        child: Container(
          width: 224,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              Text(
                '$rank위',
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 15,
                  color: SDSColor.gray900,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  crew.crewName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // 목업: 크루명은 로고 왼쪽에 **오른쪽 정렬**로 붙는다.
                  textAlign: TextAlign.right,
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 16,
                    color: SDSColor.gray900,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: SDSColor.snowliveWhite,
                  borderRadius: BorderRadius.circular(5),
                ),
                clipBehavior: Clip.antiAlias,
                // 로고가 없으면 앱과 같은 색별 기본 마크(크루홈 집계에는 색이 있다).
                child: WebNetworkImage(
                  url: crewLogoUrlOf(
                    logoUrl: crew.crewLogoUrl,
                    color: crew.color,
                  ),
                  width: 30,
                  height: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
