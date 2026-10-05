import 'dart:math' as math;

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/web_drag_scroll_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_home_sections_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';

/// 크루 로고 한 변.
const double _kCrewLogoSize = 40;

/// 행(= hover 배경) **최소** 높이. 로고 크기와 무관하게 48(목업)이고, 크루명이
/// 두 줄로 넘어가면 그만큼만 늘어난다.
const double _kCrewRowMinHeight = 48;

/// 행 안쪽 상하 여백. 크루명이 두 줄일 때 글자가 hover 배경에 붙지 않게 한다
/// (한 줄일 때는 최소 높이 48이 더 커서 영향이 없다).
const double _kCrewRowVerticalPadding = 4;

/// 행 사이 간격.
const double _kCrewRowGap = 10;

/// 좁은 폭의 구분선 좌우 여백.
///
/// 모바일 12 — 데스크탑(24)보다 좁혀야 다음 열의 로고가 걸쳐 보인다.
/// 태블릿 20 — 페이지 여백과 같은 값이라, 열이 왼쪽에 붙었을 때 **앞 열의 구분선이
/// 화면 밖으로 정확히 빠진다**(12로 두면 왼쪽 끝에 선이 붙어 보인다).
double _narrowDividerPad(BuildContext context) =>
    context.screenType == WebScreenType.tablet ? 20 : 12;
double _narrowColumnGutter(BuildContext context) => _narrowDividerPad(context) * 2 + 1;

/// 좁은 폭에서 한 열에 넣는 행 수(목업 10행). 화면 폭이 바뀌어도 이 구성은 그대로다.
const int _kRowsPerColumn = 10;

/// 좁은 폭에서 다음 열이 걸쳐 보이는 폭.
///
/// 이 구간에는 구분선 묶음 + 행 좌측 패딩(8)이 먼저 들어가고 남는 만큼 로고가 보인다.
/// 목록은 풀블리드라 **페이지 여백이 여기에 더해진다** → 모바일 27 / 태블릿 25 정도로
/// 로고가 조금 잘린 채 보인다(통째로 보이면 열이 끝난 것처럼 읽힌다).
double _columnPeek(BuildContext context) =>
    context.screenType == WebScreenType.tablet ? 54 : 44;

/// 좁은 폭 가로 목록의 높이. 행이 한 줄 고정이라 계산으로 확정된다.
const double _kPagerHeight =
    _kCrewRowMinHeight * _kRowsPerColumn + _kCrewRowGap * (_kRowsPerColumn - 1);

// ── 스켈레톤이 같은 자리를 잡으려면 알아야 하는 값들 ──────────────────────────
const double kCrewRowHeight = _kCrewRowMinHeight;
const double kCrewRowGap = _kCrewRowGap;
const int kCrewRowsPerColumn = _kRowsPerColumn;
const double kCrewPagerHeight = _kPagerHeight;

/// 데스크탑 열 사이(24 + 1px 선 + 24) / 좁은 폭은 화면별 값.
const double kCrewDesktopColumnGutter = 49;
double crewColumnGutter(BuildContext context) =>
    context.isDesktop ? kCrewDesktopColumnGutter : _narrowColumnGutter(context);

/// 좁은 폭에서 한 화면에 보이는 열 수.
int crewVisibleColumns(BuildContext context) =>
    context.screenType == WebScreenType.tablet ? 2 : 1;

/// 좁은 폭 열 폭. [hasMore]가 false면 peek을 빼지 않는다(넘길 열이 없을 때).
double crewNarrowColumnWidth(BuildContext context, double maxWidth, {bool hasMore = true}) {
  final visible = crewVisibleColumns(context);
  final peek = hasMore ? _columnPeek(context) : 0.0;
  return (maxWidth - _narrowColumnGutter(context) * (visible - 1) - peek) / visible;
}

/// 선택한 칩의 크루 목록. 열은 **위에서 아래로** 채운다(목업).
///
/// - **데스크탑**: 목록 전체를 3열로 나눠 한 화면에 모두 보여준다(874에 딱 맞는다).
/// - **태블릿·모바일**: 한 열에 10행씩 끊어 가로로 깔고 **열 단위로 스와이프**한다.
///   다음 열이 살짝 걸쳐 보이고, 손을 떼면 항상 열 시작선에 멈춘다.
class LiveCrewListGridWeb extends StatelessWidget {
  final List<CrewCard> crews;
  final void Function(CrewCard crew) onCrewTap;

  const LiveCrewListGridWeb({super.key, required this.crews, required this.onCrewTap});

  @override
  Widget build(BuildContext context) {
    if (crews.isEmpty) {
      return const WebEmptyState(message: '아직 크루가 없어요.');
    }

    // 좁은 폭은 **열 하나가 넘김 단위**인 가로 스와이프 목록이다(목업 161:50263 /
    // 161:63231 — 열이 화면 밖까지 깔리고 다음 열이 살짝 보인다).
    if (!context.isDesktop) return _buildPager(context);

    final chunks = splitIntoColumns(crews, 3);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < chunks.length; i++) ...[
            if (i > 0) Container(width: 1, color: SDSColor.gray100),
            Expanded(
              child: Padding(
                // 구분선 양옆 24 → 열 사이 24+1+24 = 49 (목업 161:38007).
                padding: EdgeInsets.only(
                  left: i == 0 ? 0 : 24,
                  right: i == chunks.length - 1 ? 0 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 행 48 + 간격 10 = 피치 58
                    for (var r = 0; r < chunks[i].length; r++) ...[
                      if (r > 0) const SizedBox(height: _kCrewRowGap),
                      _CrewListRow(crew: chunks[i][r], onTap: () => onCrewTap(chunks[i][r])),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 좁은 폭 전용 — 열을 가로로 깔고 **열 단위로 스냅**되는 목록.
  Widget _buildPager(BuildContext context) {
    final chunks = chunkCrewsByRows(crews, _kRowsPerColumn);
    final visibleColumns = crewVisibleColumns(context);
    // 넘길 열이 없으면 peek을 주지 않는다 — 안 그러면 마지막 열이 이유 없이 좁아진다.
    final peek = chunks.length > visibleColumns ? _columnPeek(context) : 0.0;
    final dividerPad = _narrowDividerPad(context);
    final gutter = _narrowColumnGutter(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth =
            (constraints.maxWidth - gutter * (visibleColumns - 1) - peek) / visibleColumns;
        // 칸 폭 = 열 + 구분선 묶음. 이게 곧 스냅 단위다.
        final pitch = columnWidth + gutter;

        // 목록만 **화면 끝까지** 넓힌다 — 페이지 여백 안에 가두면 넘어가는 열이
        // 여백 선에서 잘려서 어색하다(캐러셀 레일과 같은 처리).
        // ⚠️ 높이를 못 박지 않으면 OverflowBox 자식이 아예 안 그려진다.
        final screenWidth = MediaQuery.sizeOf(context).width;
        // 스크롤 영역 안쪽에 페이지 여백을 다시 넣어, 열은 **여백 선에 맞춰** 서고
        // 넘길 때만 화면 끝까지 흐르게 한다. 여백이 선두에 들어가도 스냅 위치는
        // 그대로 열 피치의 배수다(여백만큼 밀린 자리에 열이 선다).
        final pagePadding = ((screenWidth - constraints.maxWidth) / 2).clamp(0.0, 40.0);
        // 끝 여백이 모자라면 **마지막 스냅 지점이 maxScrollExtent에서 잘려** 그 열만
        // 여백 선에 못 선다. 마지막 열이 제자리에 설 만큼은 뒤를 비워 둔다
        // (비는 폭은 peek 자리와 같아 눈에 띄지 않는다).
        final trailingPadding =
            math.max(pagePadding, screenWidth - pagePadding - visibleColumns * pitch);

        return SizedBox(
          // 가로 리스트는 높이를 못 박아야 한다(행이 한 줄 고정이라 계산이 맞는다).
          height: _kPagerHeight,
          child: OverflowBox(
            minWidth: screenWidth,
            maxWidth: screenWidth,
            minHeight: _kPagerHeight,
            maxHeight: _kPagerHeight,
            child: _CrewColumnPager(
              chunks: chunks,
              columnWidth: columnWidth,
              pitch: pitch,
              dividerPad: dividerPad,
              leadingPadding: pagePadding,
              trailingPadding: trailingPadding,
              onCrewTap: onCrewTap,
            ),
          ),
        );
      },
    );
  }
}

/// 열을 가로로 깔고 **열 단위로 멈추는** 목록 본체.
///
/// 스냅이 두 겹이다 — 손으로 끌었을 때는 [_ColumnSnapPhysics]가 관성 단계에서 붙이고,
/// **휠·트랙패드 가로 스크롤은 관성 단계를 안 거쳐서** 스크롤이 끝난 뒤
/// 가까운 열로 직접 붙인다(실측: 태블릿에서 첫 스와이프가 중간에 멈춤).
class _CrewColumnPager extends StatefulWidget {
  final List<List<CrewCard>> chunks;
  final double columnWidth;
  final double pitch;
  final double dividerPad;
  final double leadingPadding;
  final double trailingPadding;
  final void Function(CrewCard crew) onCrewTap;

  const _CrewColumnPager({
    required this.chunks,
    required this.columnWidth,
    required this.pitch,
    required this.dividerPad,
    required this.leadingPadding,
    required this.trailingPadding,
    required this.onCrewTap,
  });

  @override
  State<_CrewColumnPager> createState() => _CrewColumnPagerState();
}

class _CrewColumnPagerState extends State<_CrewColumnPager> {
  final ScrollController _controller = ScrollController();

  /// 붙이는 중에 들어오는 알림으로 또 붙이지 않게 막는다.
  bool _settling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _onScrollEnd(ScrollEndNotification notification) {
    if (_settling || !_controller.hasClients) return false;
    final position = _controller.position;
    final target = (position.pixels / widget.pitch).roundToDouble() * widget.pitch;
    final clamped = target.clamp(position.minScrollExtent, position.maxScrollExtent);
    if ((clamped - position.pixels).abs() < 0.5) return false;

    _settling = true;
    _controller
        .animateTo(clamped,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut)
        .whenComplete(() => _settling = false);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: _onScrollEnd,
      // 마우스로 끌어서도 넘길 수 있게 한다(웹 기본값은 휠만 허용).
      child: WebHorizontalDragScroll(
        child: ListView.builder(
          controller: _controller,
          padding: EdgeInsets.only(
            left: widget.leadingPadding,
            right: widget.trailingPadding,
          ),
          scrollDirection: Axis.horizontal,
          physics: _ColumnSnapPhysics(itemExtent: widget.pitch),
          // 칸 폭을 고정해야 스냅 계산이 맞고 먼 위치 점프도 빠르다.
          itemExtent: widget.pitch,
          itemCount: widget.chunks.length,
          itemBuilder: (_, i) {
            final column = widget.chunks[i];
            final isLast = i == widget.chunks.length - 1;
            return Row(
              children: [
                SizedBox(
                  width: widget.columnWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var r = 0; r < column.length; r++) ...[
                        if (r > 0) const SizedBox(height: _kCrewRowGap),
                        _CrewListRow(
                          crew: column[r],
                          onTap: () => widget.onCrewTap(column[r]),
                          // 열이 300 가까이 되므로 두 줄이 필요 없다 — 높이를 고정해야
                          // 가로 리스트 높이 계산이 맞는다.
                          allowTwoLines: false,
                        ),
                      ],
                    ],
                  ),
                ),
                // 마지막 열도 **폭은 그대로** 두고 선만 감춘다(칸 폭이 일정해야 한다).
                SizedBox(width: widget.dividerPad),
                Container(width: 1, color: isLast ? Colors.transparent : SDSColor.gray100),
                SizedBox(width: widget.dividerPad),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 손을 떼면 **열 시작선**에 붙는 physics.
///
/// `PageScrollPhysics`는 뷰포트 단위로만 스냅해서 쓸 수 없다 — 여기서는 스냅 단위가
/// 뷰포트가 아니라 열 피치([itemExtent])다.
class _ColumnSnapPhysics extends ScrollPhysics {
  final double itemExtent;

  const _ColumnSnapPhysics({required this.itemExtent, super.parent});

  @override
  _ColumnSnapPhysics applyTo(ScrollPhysics? ancestor) =>
      _ColumnSnapPhysics(itemExtent: itemExtent, parent: buildParent(ancestor));

  /// 놓은 지점에서 가장 가까운 열. 속도가 충분하면 그 방향으로 한 칸 더 간다.
  double _targetPixels(ScrollMetrics position, double velocity) {
    final tolerance = toleranceFor(position);
    var page = position.pixels / itemExtent;
    if (velocity < -tolerance.velocity) {
      page = page.floorToDouble();
    } else if (velocity > tolerance.velocity) {
      page = page.ceilToDouble();
    } else {
      page = page.roundToDouble();
    }
    return (page * itemExtent)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // 경계 밖(오버스크롤)에서는 기본 동작에 맡긴다.
    if ((velocity <= 0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = toleranceFor(position);
    final target = _targetPixels(position, velocity);
    if ((target - position.pixels).abs() < tolerance.distance) return null;
    return ScrollSpringSimulation(spring, position.pixels, target, velocity,
        tolerance: tolerance);
  }

  /// 스냅이 끝난 뒤에도 미세하게 흐르지 않도록.
  @override
  bool get allowImplicitScrolling => false;
}

class _CrewListRow extends StatefulWidget {
  final CrewCard crew;
  final VoidCallback onTap;

  /// 크루명을 두 줄까지 늘릴지. PC는 열이 좁아(≈259) 두 줄이 필요하지만,
  /// 좁은 폭의 가로 목록은 높이가 고정이라 한 줄로 묶는다.
  final bool allowTwoLines;

  const _CrewListRow({
    required this.crew,
    required this.onTap,
    this.allowTwoLines = true,
  });

  @override
  State<_CrewListRow> createState() => _CrewListRowState();
}

class _CrewListRowState extends State<_CrewListRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final crew = widget.crew;
    final logoUrl = crewLogoUrlOf(logoUrl: crew.crewLogoUrl, color: crew.color);
    final subtitle = crewRowSubtitle(crew);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered ? SDSColor.gray50 : SDSColor.snowliveWhite,
            borderRadius: BorderRadius.circular(8),
          ),
          // hover 배경 = 행 전체. 높이를 못 박지 않고 **최소 48**로 두어
          // 크루명이 두 줄이 되는 좁은 폭에서 행이 따라 늘어나게 한다.
          constraints: const BoxConstraints(minHeight: _kCrewRowMinHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: SDSSpacing.sm,
            vertical: _kCrewRowVerticalPadding,
          ),
          child: Row(
            children: [
              Container(
                width: _kCrewLogoSize,
                height: _kCrewLogoSize,
                decoration: BoxDecoration(
                  // 공용 비율(한 변의 0.2)로 모서리를 맞춘다.
                  borderRadius: BorderRadius.circular(crewLogoRadius(_kCrewLogoSize)),
                  border: Border.all(color: SDSColor.gray100),
                ),
                clipBehavior: Clip.antiAlias,
                child: (logoUrl?.isNotEmpty ?? false)
                    ? WebNetworkImage(
                        url: logoUrl, width: _kCrewLogoSize, height: _kCrewLogoSize)
                    : Container(color: SDSColor.gray100),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      crew.crewName ?? '',
                      // 열이 좁아지면(PC 안에서 창을 줄일 때) 한 줄로는 이름이 거의
                      // 다 잘려 버린다 → 두 줄까지 허용하고 그 뒤부터 말줄임.
                      maxLines: widget.allowTwoLines ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
