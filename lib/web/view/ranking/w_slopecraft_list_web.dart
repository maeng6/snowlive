import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/core/model/m_slope_rush.dart';
import 'package:com.snowlive/web/util/web_drag_scroll_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_crew_modal_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';

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
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
              ),
            ),
            if (slope != null)
              OutlinedButton(
                onPressed: onShowAll,
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
        if (slope != null)
          ..._buildSlopeCrews(context, slope)
        else
          ..._buildSlopeRows(context),
      ],
    );
  }

  /// 전체 모드 — 슬로프별 1위 크루.
  List<Widget> _buildSlopeRows(BuildContext context) {
    if (items.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              '점령 기록이 없어요.',
              style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray400),
            ),
          ),
        ),
      ];
    }

    return [
      for (final item in items)
        _CrewRow(
          slopeName: item.slopeNickname.isNotEmpty ? item.slopeNickname : item.slopeFullname,
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
              style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray400),
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

  const _CrewRow({required this.slopeName, required this.crew, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final logoUrl = crew?.crewLogoUrl ?? '';
    final description = crew?.description.trim().replaceAll('\n', ' ') ?? '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            if (slopeName != null) ...[
              SizedBox(
                width: 52,
                child: Text(
                  slopeName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
                ),
              ),
              const SizedBox(width: SDSSpacing.sm),
            ],
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SDSColor.snowliveWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SDSColor.gray100),
              ),
              clipBehavior: Clip.antiAlias,
              child: logoUrl.isEmpty
                  ? null
                  : WebNetworkImage(url: logoUrl, width: 40, height: 40),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: crew == null
                  ? Text(
                      '미점령',
                      style:
                          SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          crew!.crewName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SDSTextStyle.bold
                              .copyWith(fontSize: 14, color: SDSColor.gray900),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SDSTextStyle.regular
                                .copyWith(fontSize: 11, color: SDSColor.gray500),
                          ),
                        ],
                      ],
                    ),
            ),
            const SizedBox(width: SDSSpacing.sm),
            Text(
              crew == null ? '-' : slopeCraftRatioLabel(crew!.ratio),
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
            ),
          ],
        ),
      ),
    );
  }
}

/// 점령률 표기. 서버는 0~1 비율로 준다(실측 0.425 → `42.5%`).
String slopeCraftRatioLabel(double ratio) {
  final percent = ratio * 100;
  // 소수점이 의미 없는 값(40.0)은 정수로 적는다(목업의 `23%`).
  final text = percent % 1 == 0 ? percent.toStringAsFixed(0) : percent.toStringAsFixed(1);
  return '$text%';
}

/// `전체 스키장 점령 TOP 5 크루` 가로 줄.
///
/// 전용 API가 없어 **크루홈 집계의 `이번 시즌 슬로프 점령` 상위 5개**를 쓴다(사용자 확정).
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
          style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: WebHorizontalDragScroll(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: crews.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) => _TopCrewCard(rank: index + 1, crew: crews[index]),
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
      color: SDSColor.blue50,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showLiveCrewModal(context, crew),
        child: Container(
          width: 226,
          padding: const EdgeInsets.symmetric(horizontal: SDSSpacing.md),
          child: Row(
            children: [
              Text(
                '$rank위',
                style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray600),
              ),
              const SizedBox(width: SDSSpacing.md),
              Expanded(
                child: Text(
                  crew.crewName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                ),
              ),
              const SizedBox(width: SDSSpacing.sm),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: SDSColor.snowliveWhite,
                  borderRadius: BorderRadius.circular(6),
                ),
                clipBehavior: Clip.antiAlias,
                child: (crew.crewLogoUrl?.isNotEmpty ?? false)
                    ? WebNetworkImage(url: crew.crewLogoUrl, width: 32, height: 32)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
