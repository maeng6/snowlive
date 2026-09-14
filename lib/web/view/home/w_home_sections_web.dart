import 'dart:async';

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_fleamarket.dart';
import 'package:com.snowlive/core/model/m_rankingListCrew.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

final _numberFormat = NumberFormat('###,###,###,###');

// ─────────────────────────────── 오늘의 랭킹 ───────────────────────────────

/// `오늘의 랭킹` 섹션 — 개인 일간 / 크루 일간 상위 8을 나란히 보여준다.
///
/// 모바일은 두 목록을 한 칸씩 좌우로 넘긴다(목업의 점 인디케이터).
class HomeTodayRankingWeb extends StatefulWidget {
  final DateTime today;
  final List<RankingUser> indiv;
  final List<CrewRanking> crew;
  final bool isLoading;

  const HomeTodayRankingWeb({
    super.key,
    required this.today,
    required this.indiv,
    required this.crew,
    required this.isLoading,
  });

  @override
  State<HomeTodayRankingWeb> createState() => _HomeTodayRankingWebState();
}

class _HomeTodayRankingWebState extends State<HomeTodayRankingWeb> {
  /// 데스크탑에서 제목·날짜·안내가 들어가는 좌측 열 폭(목업 실측).
  static const double _sideColumnWidth = 244;

  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;
    final isMobile = screenType == WebScreenType.mobile;
    final isDesktop = screenType == WebScreenType.desktop;

    return Container(
      decoration: BoxDecoration(
        // 모바일은 피그마 배경색 #F2F3F7, PC·태블릿은 gray50.
        color: isMobile ? const Color(0xFFF2F3F7) : SDSColor.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      // PC: 좌우 40 / 상하 30, 태블릿: 좌우 30 / 상하 30, 모바일: 좌우 16 / 상하 24.
      padding: switch (screenType) {
        WebScreenType.desktop =>
          const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        WebScreenType.tablet =>
          const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        WebScreenType.mobile =>
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      },
      // 목업: 데스크탑은 제목·날짜·안내가 **왼쪽 열**에 세로로 놓이고 카드가 그 오른쪽에
      // 붙는다. 태블릿·모바일은 제목이 위, 카드가 아래다.
      child: isDesktop ? _buildDesktop() : _buildNarrow(isMobile),
    );
  }

  Widget _buildDesktop() {
    // 좌측 열의 안내 문구를 **카드 아래쪽에 맞춰** 내리려면(목업) 열 높이가 카드 높이를
    // 따라가야 한다. 스크롤 안에서는 높이가 무한이라 stretch만으로는 안 되고,
    // IntrinsicHeight로 카드 높이를 먼저 재야 한다
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _sideColumnWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: SDSSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(fontSize: 24),
                  // 제목-날짜 배지 간격 12 (피그마 기준).
                  const SizedBox(height: 12),
                  _buildDateBadge(),
                  const Spacer(),
                  // 목업은 안내 문구가 좌측 열 맨 아래에 두 줄로 놓인다
                  _buildNote(maxLines: 2),
                ],
              ),
            ),
          ),
          const SizedBox(width: SDSSpacing.md),
          Expanded(child: _buildIndivCard()),
          const SizedBox(width: 24),
          Expanded(child: _buildCrewCard()),
        ],
      ),
    );
  }

  Widget _buildNarrow(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _buildTitle(fontSize: isMobile ? 16 : 20, extraBold: !isMobile),
            // 모바일(피그마): 배지가 우측 끝 정렬.
            if (isMobile) ...[
              const Spacer(),
              _buildDateBadge(isMobile: true),
            ] else ...[
              const SizedBox(width: SDSSpacing.sm),
              _buildDateBadge(),
              const Spacer(),
              _buildNote(),
            ],
          ],
        ),
        const SizedBox(height: SDSSpacing.md),
        if (isMobile) _buildMobilePager() else _buildWideRow(),
        if (isMobile) ...[
          const SizedBox(height: 12),
          _buildDots(),
          const SizedBox(height: 16),
          Center(child: _buildNote(color: SDSColor.gray500)),
        ],
      ],
    );
  }

  // 제목: PC ExtraBold / 모바일 Bold(피그마), gray900
  Widget _buildTitle({required double fontSize, bool extraBold = true}) => Text(
        '오늘의 랭킹',
        style: (extraBold ? SDSTextStyle.extraBold : SDSTextStyle.bold)
            .copyWith(fontSize: fontSize, color: SDSColor.gray900),
      );

  // 날짜 배지: 검정 pill(40). PC 패딩 10/6·13 / 모바일 10/4·Bold 10 (피그마 기준)
  Widget _buildDateBadge({bool isMobile = false}) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: isMobile ? 4 : 6),
        decoration: BoxDecoration(
          color: SDSColor.snowliveBlack,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          homeTodayBadgeLabel(widget.today),
          style: (isMobile ? SDSTextStyle.bold : SDSTextStyle.regular).copyWith(
            fontSize: isMobile ? 10 : 13,
            color: SDSColor.snowliveWhite,
            height: isMobile ? 16 / 10 : 16 / 14,
          ),
        ),
      );

  /// 목업의 안내 문구. 좌측 열에서는 두 줄, 한 줄로 놓을 때는 줄바꿈을 공백으로 편다
  Widget _buildNote({int maxLines = 1, Color? color}) {
    const text = '오늘의 랭킹은\n10분마다 순위가 업데이트돼요';
    return Text(
      maxLines == 1 ? text.replaceAll('\n', ' ') : text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: SDSTextStyle.regular
          .copyWith(fontSize: 12, height: 1.4, color: color ?? SDSColor.gray400),
    );
  }

  Widget _buildWideRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildIndivCard()),
        const SizedBox(width: 20),
        Expanded(child: _buildCrewCard()),
      ],
    );
  }

  Widget _buildMobilePager() {
    // 고정 높이 대신 현재 페이지의 실제 콘텐츠 높이를 따라간다(리스트 개수 대응).
    return _ExpandablePageView(
      controller: _pageController,
      onPageChanged: (page) => setState(() => _page = page),
      // 회색 박스 좌우 패딩(16)의 2배로 넓혀 뷰포트가 박스 끝까지 닿는다 —
      // 넘길 때 카드가 박스 안에서 잘리지 않고 박스 끝에서 나온다.
      pageGap: SDSSpacing.md * 2,
      children: [_buildIndivCard(), _buildCrewCard()],
    );
  }

  // 크루/중고 캐러셀과 동일한 도트(_Dots: gray900/gray300)를 재사용한다.
  Widget _buildDots() => _Dots(count: 2, index: _page);

  Widget _buildIndivCard() {
    return _RankingCard(
      isLoading: widget.isLoading,
      isEmpty: widget.indiv.isEmpty,
      emptyMessage: '오늘 기록한 라이더가 아직 없어요',
      children: [
        for (var i = 0; i < widget.indiv.length; i++)
          _RankingRow(
            rank: i + 1,
            name: widget.indiv[i].displayName ?? '',
            subtitle: _affiliation(
              widget.indiv[i].resortNickname,
              widget.indiv[i].crewName,
            ),
            score: widget.indiv[i].overallTotalScore ?? 0,
            rankChange: widget.indiv[i].rankChange,
            // 시각 보정: 원형은 라운드 사각형(크루 32)보다 작아 보여 34로 키운다.
            leading: WebAvatar(
              url: widget.indiv[i].profileImageUrlUser,
              size: 34,
              userId: widget.indiv[i].userId,
            ),
          ),
      ],
    );
  }

  Widget _buildCrewCard() {
    return _RankingCard(
      isLoading: widget.isLoading,
      isEmpty: widget.crew.isEmpty,
      emptyMessage: '오늘 기록한 크루가 아직 없어요',
      children: [
        for (var i = 0; i < widget.crew.length; i++)
          _RankingRow(
            rank: i + 1,
            name: widget.crew[i].crewName ?? '',
            subtitle: _affiliation(
              widget.crew[i].baseResortNickname,
              widget.crew[i].description?.trim().replaceAll('\n', ' '),
            ),
            score: widget.crew[i].overallTotalScore ?? 0,
            rankChange: widget.crew[i].rankChange,
            onTap: widget.crew[i].crewId == null
                ? null
                : () => Get.toNamed('${WebRoutes.crewHome}?id=${widget.crew[i].crewId}'),
            // 로고가 없는 크루는 크루 색 기본 `LIVE CREW` 로고로 대체한다(요청).
            // 기본 로고 PNG는 자체 테두리/라운드 디자인이 있어 장식을 겹치지 않는다.
            leading: _CrewLogo(
              logoUrl: crewLogoUrlOf(
                logoUrl: widget.crew[i].crewLogoUrl,
                color: widget.crew[i].color,
              ),
              color: crewColorOf(widget.crew[i].color),
              isDefaultLogo: !(widget.crew[i].crewLogoUrl?.isNotEmpty ?? false),
            ),
          ),
      ],
    );
  }

  String _affiliation(String? resort, String? extra) {
    final parts = [
      if (resort?.isNotEmpty ?? false) resort!,
      if (extra?.isNotEmpty ?? false) extra!,
    ];
    return parts.join(' · ');
  }
}

/// 각 페이지의 실제 높이를 측정해 현재 페이지 높이에 맞춰 늘어나는 PageView.
/// 모바일 랭킹처럼 페이지마다 리스트 길이가 달라도 아래가 잘리거나 남지 않는다.
class _ExpandablePageView extends StatefulWidget {
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final List<Widget> children;

  /// 페이지 사이 간격. 뷰포트를 gap만큼 넓혀서 콘텐츠는 양끝에 딱 붙고,
  /// 넘길 때만 페이지 사이에 여백이 보인다.
  final double pageGap;

  const _ExpandablePageView({
    required this.controller,
    required this.onPageChanged,
    required this.children,
    this.pageGap = 0,
  });

  @override
  State<_ExpandablePageView> createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<_ExpandablePageView> {
  late List<double> _heights = List.filled(widget.children.length, 0);
  int _currentPage = 0;

  double get _currentHeight => _heights[_currentPage];

  @override
  void didUpdateWidget(covariant _ExpandablePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 데이터 로드 등으로 페이지 수가 바뀌면 측정값을 다시 만든다.
    if (oldWidget.children.length != widget.children.length) {
      _heights = List.filled(widget.children.length, 0);
      _currentPage = _currentPage.clamp(0, widget.children.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // 첫 프레임(측정 전)엔 높이 0이라 애니메이션 시작점만 잠깐 낮을 뿐,
      // 측정 즉시 목표 높이로 따라간다.
      tween: Tween<double>(end: _currentHeight),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      builder: (context, height, child) =>
          SizedBox(height: height, child: child),
      child: widget.pageGap > 0
          // 페이지 간 여백: 뷰포트를 gap만큼 넓히고 각 페이지에 gap/2씩
          // 패딩을 줘서, 정지 상태엔 콘텐츠가 양끝에 붙고 넘길 때만
          // 페이지 사이 간격이 보인다.
          ? LayoutBuilder(
              builder: (context, constraints) => OverflowBox(
                minWidth: constraints.maxWidth + widget.pageGap,
                maxWidth: constraints.maxWidth + widget.pageGap,
                child: _buildPageView(
                  EdgeInsets.symmetric(horizontal: widget.pageGap / 2),
                ),
              ),
            )
          : _buildPageView(EdgeInsets.zero),
    );
  }

  Widget _buildPageView(EdgeInsets pagePadding) {
    return PageView(
      controller: widget.controller,
      onPageChanged: (page) {
        setState(() => _currentPage = page);
        widget.onPageChanged(page);
      },
      children: [
        for (var i = 0; i < widget.children.length; i++)
          Padding(
            padding: pagePadding,
            child: OverflowBox(
              minHeight: 0,
              maxHeight: double.infinity,
              alignment: Alignment.topCenter,
              child: _SizeReportingWidget(
                onSizeChange: (size) {
                  if (_heights[i] != size.height) {
                    setState(() => _heights[i] = size.height);
                  }
                },
                child: widget.children[i],
              ),
            ),
          ),
      ],
    );
  }
}

/// 레이아웃 후 자신의 크기를 부모에게 알려 주는 래퍼
class _SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  const _SizeReportingWidget({
    required this.child,
    required this.onSizeChange,
  });

  @override
  State<_SizeReportingWidget> createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<_SizeReportingWidget> {
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return widget.child;
  }

  void _notifySize() {
    if (!mounted) return;
    final size = context.size;
    if (size != null && size != _oldSize) {
      _oldSize = size;
      widget.onSizeChange(size);
    }
  }
}

class _RankingCard extends StatelessWidget {
  final bool isLoading;
  final bool isEmpty;
  final String emptyMessage;
  final List<Widget> children;

  const _RankingCard({
    required this.isLoading,
    required this.isEmpty,
    required this.emptyMessage,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = context.screenType == WebScreenType.desktop;
    return Container(
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        // radius: PC 20 / 태블릿·모바일 16.
        borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
      ),
      // PC: 좌우 30 / 상하 24, 태블릿: 좌우 20 / 상하 20, 모바일: 좌우 16 / 상하 24 (피그마).
      padding: switch (context.screenType) {
        WebScreenType.desktop =>
          const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
        WebScreenType.tablet =>
          const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        WebScreenType.mobile =>
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      },
      child: isLoading
          ? Column(
              children: [
                for (var i = 0; i < kHomeRankingCount; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SkeletonShimmer(
                      child: Row(
                        children: [
                          const SkeletonBox(width: 32, height: 32, isCircle: true),
                          const SizedBox(width: 10),
                          const Expanded(child: SkeletonBox(width: double.infinity, height: 14)),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          : isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: SDSSpacing.xl),
                  child: WebEmptyState(message: emptyMessage, iconWidth: 48),
                )
              : Column(children: children),
    );
  }
}

class _RankingRow extends StatelessWidget {
  final int rank;
  final String name;
  final String subtitle;
  final int score;
  final Widget leading;

  /// 직전 집계 대비 순위 변동. 양수 ▲(빨강) / 음수 ▼(파랑) / null이면 화살표 없음.
  final int? rankChange;

  final VoidCallback? onTap;

  const _RankingRow({
    required this.rank,
    required this.name,
    required this.subtitle,
    required this.score,
    required this.leading,
    this.rankChange,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 피그마: 행 최소 높이 36, 행 간격 10(상하 5씩)
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 36),
        child: Row(
          children: [
            // 순위: Bold 14, 20폭 가운데 정렬 (피그마 기준).
            SizedBox(
              width: 20,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
              ),
            ),
            const SizedBox(width: 6),
            leading,
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 이름: Regular 14 (피그마 기준)
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.regular.copyWith(fontSize: 11, color: SDSColor.gray500),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 14),
            // 점수: Regular 16 (피그마 기준). 모바일은 '점' 접미사 없이 숫자만.
            Text(
              context.screenType == WebScreenType.mobile
                  ? _numberFormat.format(score)
                  : '${_numberFormat.format(score)}점',
              style: SDSTextStyle.regular.copyWith(fontSize: 16, color: SDSColor.gray900),
            ),
            const SizedBox(width: 4),
            // 화살표 자리는 값이 없어도 비워 둔다 — 점수 우측 끝이 행마다 흔들리지 않게.
            SizedBox(width: 10, child: Center(child: _RankChangeArrow(change: rankChange))),
          ],
        ),
      ),
    );

    if (onTap == null) return row;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: row),
    );
  }
}

/// 순위 변동 화살표(피그마) — 10x8 라운드 삼각형. 상승 빨간 ▲ / 하락 파란 ▼,
/// 변동 없거나 데이터가 없으면 없음.
class _RankChangeArrow extends StatelessWidget {
  final int? change;

  const _RankChangeArrow({required this.change});

  @override
  Widget build(BuildContext context) {
    final value = change;
    if (value == null || value == 0) return const SizedBox.shrink();
    final isUp = value > 0;
    return CustomPaint(
      size: const Size(10, 8),
      painter: _RoundedTrianglePainter(
        color: isUp ? SDSColor.red : SDSColor.snowliveBlue,
        pointUp: isUp,
      ),
    );
  }
}

/// 꼭짓점이 살짝 둥근 삼각형. fill 위에 round-join stroke를 겹쳐 그려 radius를 낸다.
class _RoundedTrianglePainter extends CustomPainter {
  final Color color;
  final bool pointUp;

  const _RoundedTrianglePainter({required this.color, required this.pointUp});

  @override
  void paint(Canvas canvas, Size size) {
    // stroke 두께의 절반만큼 안쪽으로 그려야 전체 크기가 10x8을 넘지 않는다.
    const strokeWidth = 2.0;
    const inset = strokeWidth / 2;

    final path = pointUp
        ? (Path()
          ..moveTo(size.width / 2, inset)
          ..lineTo(size.width - inset, size.height - inset)
          ..lineTo(inset, size.height - inset)
          ..close())
        : (Path()
          ..moveTo(inset, inset)
          ..lineTo(size.width - inset, inset)
          ..lineTo(size.width / 2, size.height - inset)
          ..close());

    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_RoundedTrianglePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointUp != pointUp;
}

/// 크루 로고. 없으면 크루 색 배경 + 기본 로고(요청·목업).
class _CrewLogo extends StatelessWidget {
  final String? logoUrl;
  final Color? color;
  final double size;
  final double radius;

  const _CrewLogo({
    required this.logoUrl,
    required this.color,
    this.size = 32,
    this.radius = 6,
    this.isDefaultLogo = false,
  });

  /// 기본 `LIVE CREW` 로고 PNG는 자체 테두리·라운드가 그려져 있어
  /// 배경색/보더를 겹치면 이중 테두리처럼 보인다 → 이미지만 그대로 그린다.
  final bool isDefaultLogo;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = logoUrl?.isNotEmpty ?? false;

    if (isDefaultLogo && hasImage) {
      // 원본 PNG는 흰 배경 + 자체 라운드(32px 기준 약 5.2). radius 6에 gray50
      // 라인만 얹으면 원본 모서리와 어긋나지 않는다.
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: SDSColor.gray100),
        ),
        clipBehavior: Clip.antiAlias,
        child: WebNetworkImage(url: logoUrl, width: size, height: size),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hasImage ? null : (color ?? SDSColor.gray100),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: SDSColor.gray100),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? WebNetworkImage(url: logoUrl, width: size, height: size)
          : const SizedBox.shrink(),
    );
  }
}

// ─────────────────────────────── 우리 크루는요 ───────────────────────────────

/// `우리 크루는요` — 공개 크루톡을 카드로 넘겨 본다.
class HomeCrewCardsWeb extends StatefulWidget {
  final List<HomeCrewCard> cards;
  final bool isLoading;

  const HomeCrewCardsWeb({super.key, required this.cards, required this.isLoading});

  @override
  State<HomeCrewCardsWeb> createState() => _HomeCrewCardsWebState();
}

class _HomeCrewCardsWebState extends State<HomeCrewCardsWeb>
    with SingleTickerProviderStateMixin {
  int _page = 0;

  /// 페이지 전환 시 카드가 왼쪽부터 순서대로 페이드인하는 스태거 애니메이션.
  /// 카드당 200ms, 80ms 간격 → 3장 기준 총 360ms.
  static const int _kCardFadeMs = 200;
  static const int _kCardStaggerMs = 80;
  late final AnimationController _cardsEnter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _kCardFadeMs + _kCardStaggerMs * 2),
  )..forward();

  @override
  void dispose() {
    _cardsEnter.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  /// 모바일 PageView(스와이프) 컨트롤러.
  final PageController _mobileController = PageController();

  void _goTo(int page, int pageCount) {
    setState(() => _page = page % pageCount);
    _cardsEnter.forward(from: 0);
  }

  /// i번째 카드의 페이드인 구간(왼쪽부터 순서대로).
  Animation<double> _cardFade(int i) {
    final int totalMs = _cardsEnter.duration!.inMilliseconds;
    final double start = (i * _kCardStaggerMs) / totalMs;
    final double end =
        ((i * _kCardStaggerMs + _kCardFadeMs) / totalMs).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _cardsEnter,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  int _perPage(WebScreenType type) => switch (type) {
        WebScreenType.desktop => 3,
        WebScreenType.tablet => 2,
        WebScreenType.mobile => 1,
      };

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;
    final perPage = _perPage(screenType);
    final pages = homeCarouselPages(widget.cards, perPage);
    final page = pages.isEmpty ? const <HomeCrewCard>[] : pages[_page.clamp(0, pages.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HomeSectionHeader(
          title: '우리 크루는요',
          onPrev: pages.length > 1 ? () => _goTo(_page - 1, pages.length) : null,
          onNext: pages.length > 1 ? () => _goTo(_page + 1, pages.length) : null,
        ),
        // 헤더 ↔ 캐러셀 간격 16.
        const SizedBox(height: 16),
        if (widget.isLoading)
          _buildSkeleton(perPage)
        else if (widget.cards.isEmpty)
          const WebEmptyState(message: '아직 공개된 크루 소식이 없어요')
        else if (screenType == WebScreenType.mobile)
          // 모바일: 랭킹처럼 손가락을 따라오는 PageView 스와이프.
          _ExpandablePageView(
            controller: _mobileController,
            onPageChanged: (p) => setState(() => _page = p),
            // 화면 좌우 마진(16)의 2배로 넓혀 뷰포트가 화면 끝까지 닿는다 —
            // 넘길 때 다음 페이지가 섹션 안에서 잘리지 않고 화면 끝에서 나온다.
            pageGap: SDSSpacing.md * 2,
            children: [
              for (final pageItems in pages)
                _buildCards(screenType, perPage, pageItems),
            ],
          )
        else
          _SwipeDetector(
            // 태블릿은 스와이프로도 페이지를 넘긴다.
            enabled: screenType == WebScreenType.tablet && pages.length > 1,
            onSwipeLeft: () => _goTo(_page + 1, pages.length),
            onSwipeRight: () => _goTo(_page - 1, pages.length),
            child: _buildCards(screenType, perPage, page),
          ),
        if (pages.length > 1) ...[
          const SizedBox(height: 24),
          _Dots(count: pages.length, index: _page.clamp(0, pages.length - 1)),
        ],
      ],
    );
  }

  Widget _buildCards(
      WebScreenType screenType, int perPage, List<HomeCrewCard> page) {
    final bool isMobile = screenType == WebScreenType.mobile;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < perPage; i++) ...[
          // 카드 간 간격 40 (피그마 기준).
          if (i > 0) const SizedBox(width: 24),
          Expanded(
            child: i < page.length
                ? (isMobile
                    // 모바일: PageView가 전환을 담당하므로 스태거 없이 그대로.
                    ? _CrewTalkCard(card: page[i])
                    : AnimatedBuilder(
                        animation: _cardFade(i),
                        builder: (context, child) {
                          final anim = _cardFade(i);
                          return Opacity(
                            opacity: anim.value,
                            // 아래에서 위로 12px 살짝 올라오며 등장.
                            child: Transform.translate(
                              offset: Offset(0, (1 - anim.value) * 12),
                              child: child,
                            ),
                          );
                        },
                        child: _CrewTalkCard(card: page[i]),
                      ))
                : const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }

  Widget _buildSkeleton(int perPage) {
    return Row(
      children: [
        for (var i = 0; i < perPage; i++) ...[
          if (i > 0) const SizedBox(width: SDSSpacing.md),
          const Expanded(
            child: SkeletonShimmer(
              child: SkeletonBox(width: double.infinity, height: 260, radius: 12),
            ),
          ),
        ],
      ],
    );
  }
}

class _CrewTalkCard extends StatefulWidget {
  final HomeCrewCard card;

  const _CrewTalkCard({required this.card});

  @override
  State<_CrewTalkCard> createState() => _CrewTalkCardState();
}

class _CrewTalkCardState extends State<_CrewTalkCard> with _TapFeedback {
  bool _hovered = false;

  bool get _highlighted => _hovered || pressed;

  HomeCrewCard get card => widget.card;

  @override
  Widget build(BuildContext context) {
    final crewColor = crewColorOf(card.crewColor);
    final logoUrl = crewLogoUrlOf(logoUrl: card.crewLogoUrl, color: card.crewColor);

    return MouseRegion(
      cursor: card.crewId == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => pressDown(),
        onTapUp: (_) => pressUpDelayed(),
        onTapCancel: pressCancel,
        onTap: card.crewId == null
            ? null
            : () => Get.toNamed('${WebRoutes.crewHome}?id=${card.crewId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지: 360x240, radius 16 (피그마 기준).
            // hover(PC)/press(터치) 시 라운드 영역째 2% 축소.
            AspectRatio(
              aspectRatio: 360 / 240,
              child: AnimatedScale(
                scale: _highlighted ? 0.98 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (card.imageUrl != null)
                        WebNetworkImage(url: card.imageUrl, fit: BoxFit.cover)
                      else
                        // 사진이 없으면 크루 색 배경 + 기본 로고(목업의 초록 카드).
                        Container(
                          color: crewColor ?? SDSColor.gray100,
                          alignment: Alignment.center,
                          child: FractionallySizedBox(
                            widthFactor: 0.20,
                            child: (logoUrl?.isNotEmpty ?? false)
                                ? WebNetworkImage(url: logoUrl, fit: BoxFit.contain)
                                : const SizedBox.shrink(),
                          ),
                        ),
                    if (card.isNew)
                      // NEW 배지: 검정 pill(40), 패딩 9/4, Bold 10 (피그마 기준).
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: SDSColor.snowliveBlack,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Text(
                            'NEW',
                            style: SDSTextStyle.bold
                                .copyWith(fontSize: 10, color: SDSColor.snowliveWhite),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: SDSSpacing.md),
            // 텍스트 블록은 카드보다 좌우 10 안쪽 (피그마 기준).
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 크루 로고 30, radius 5 (피그마 기준)
                      _CrewLogo(logoUrl: logoUrl, color: crewColor, size: 26, radius: 5),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          card.crewName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SDSTextStyle.regular.copyWith(
                            fontSize: 13,
                            color: SDSColor.gray900,
                            height: 16 / 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 제목: Bold 18 (피그마 기준)
                  Text(
                    card.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                  ),
                  const SizedBox(height: 2),
                  // 설명: 최대 2줄. 문구가 없거나 한 줄이어도 두 줄 높이(14*1.4*2)를
                  // 항상 확보해 카드 높이가 흔들리지 않게 한다
                  SizedBox(
                    height: 14 * 1.4 * 2,
                    child: Text(
                      card.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.regular
                          .copyWith(fontSize: 14, height: 1.4, color: SDSColor.gray900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────── 중고거래 ───────────────────────────────

/// 홈의 `중고거래` 캐러셀. 카드는 목업대로 사진 + 물품명 + 가격만 보여준다.
class HomeFleamarketWeb extends StatefulWidget {
  final List<Fleamarket> items;
  final bool isLoading;

  const HomeFleamarketWeb({super.key, required this.items, required this.isLoading});

  @override
  State<HomeFleamarketWeb> createState() => _HomeFleamarketWebState();
}

class _HomeFleamarketWebState extends State<HomeFleamarketWeb>
    with SingleTickerProviderStateMixin {
  int _page = 0;

  /// 페이지 전환 시 카드가 왼쪽부터 순서대로 페이드+살짝 상승(크루 캐러셀과 동일).
  /// 6장이라 스태거 간격은 짧게(50ms) 가져간다.
  static const int _kCardFadeMs = 200;
  static const int _kCardStaggerMs = 50;
  late final AnimationController _cardsEnter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _kCardFadeMs + _kCardStaggerMs * 5),
  )..forward();

  /// 모바일 PageView(스와이프) 컨트롤러.
  final PageController _mobileController = PageController();

  @override
  void dispose() {
    _cardsEnter.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _goTo(int page, int pageCount) {
    setState(() => _page = page % pageCount);
    _cardsEnter.forward(from: 0);
  }

  Animation<double> _cardFade(int i) {
    final int totalMs = _cardsEnter.duration!.inMilliseconds;
    final double start = (i * _kCardStaggerMs) / totalMs;
    final double end =
        ((i * _kCardStaggerMs + _kCardFadeMs) / totalMs).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _cardsEnter,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  int _perPage(WebScreenType type) => switch (type) {
        WebScreenType.desktop => 6,
        WebScreenType.tablet => 4,
        WebScreenType.mobile => 2,
      };

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;
    final perPage = _perPage(screenType);
    final pages = homeCarouselPages(widget.items, perPage);
    final page = pages.isEmpty ? const <Fleamarket>[] : pages[_page.clamp(0, pages.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HomeSectionHeader(
          title: '중고거래',
          onPrev: pages.length > 1 ? () => _goTo(_page - 1, pages.length) : null,
          onNext: pages.length > 1 ? () => _goTo(_page + 1, pages.length) : null,
          trailing: _MoreButton(onTap: () => Get.toNamed(WebRoutes.fleamarketList)),
        ),
        // 헤더 ↔ 그리드 간격 — 크루 캐러셀과 동일(16)
        const SizedBox(height: 16),
        if (widget.isLoading)
          Row(
            children: [
              for (var i = 0; i < perPage; i++) ...[
                if (i > 0) const SizedBox(width: SDSSpacing.md),
                const Expanded(
                  child: SkeletonShimmer(
                    child: SkeletonBox(width: double.infinity, height: 160, radius: 8),
                  ),
                ),
              ],
            ],
          )
        else if (widget.items.isEmpty)
          const WebEmptyState(message: '아직 등록된 물품이 없어요')
        else if (screenType == WebScreenType.mobile)
          // 모바일: 랭킹처럼 손가락을 따라오는 PageView 스와이프.
          _ExpandablePageView(
            controller: _mobileController,
            onPageChanged: (p) => setState(() => _page = p),
            // 화면 좌우 마진(16)의 2배로 넓혀 뷰포트가 화면 끝까지 닿는다 —
            // 넘길 때 다음 페이지가 섹션 안에서 잘리지 않고 화면 끝에서 나온다.
            pageGap: SDSSpacing.md * 2,
            children: [
              for (final pageItems in pages)
                _buildCards(screenType, perPage, pageItems),
            ],
          )
        else
          _SwipeDetector(
            // 태블릿은 스와이프로도 페이지를 넘긴다.
            enabled: screenType == WebScreenType.tablet && pages.length > 1,
            onSwipeLeft: () => _goTo(_page + 1, pages.length),
            onSwipeRight: () => _goTo(_page - 1, pages.length),
            child: _buildCards(screenType, perPage, page),
          ),
        if (pages.length > 1) ...[
          const SizedBox(height: 24),
          _Dots(count: pages.length, index: _page.clamp(0, pages.length - 1)),
        ],
      ],
    );
  }

  Widget _buildCards(
      WebScreenType screenType, int perPage, List<Fleamarket> page) {
    final bool isMobile = screenType == WebScreenType.mobile;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < perPage; i++) ...[
          if (i > 0) const SizedBox(width: SDSSpacing.md),
          Expanded(
            child: i < page.length
                ? (isMobile
                    // 모바일: PageView가 전환을 담당하므로 스태거 없이 그대로.
                    ? _FleamarketMiniCard(item: page[i])
                    : AnimatedBuilder(
                        animation: _cardFade(i),
                        builder: (context, child) {
                          final anim = _cardFade(i);
                          return Opacity(
                            opacity: anim.value,
                            // 아래에서 위로 12px 살짝 올라오며 등장.
                            child: Transform.translate(
                              offset: Offset(0, (1 - anim.value) * 12),
                              child: child,
                            ),
                          );
                        },
                        child: _FleamarketMiniCard(item: page[i]),
                      ))
                : const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }
}

class _FleamarketMiniCard extends StatefulWidget {
  final Fleamarket item;

  const _FleamarketMiniCard({required this.item});

  @override
  State<_FleamarketMiniCard> createState() => _FleamarketMiniCardState();
}

class _FleamarketMiniCardState extends State<_FleamarketMiniCard> with _TapFeedback {
  bool _hovered = false;

  bool get _highlighted => _hovered || pressed;

  Fleamarket get item => widget.item;

  @override
  Widget build(BuildContext context) {
    final photo = (item.photos?.isNotEmpty ?? false) ? item.photos!.first.urlFleaPhoto : null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => pressDown(),
        onTapUp: (_) => pressUpDelayed(),
        onTapCancel: pressCancel,
        onTap: () => Get.toNamed('${WebRoutes.fleamarketDetail}?id=${item.fleaId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지: 1:1, radius 10, 빈 배경 #F2F3F7 (피그마 기준).
            // hover(PC)/press(터치) 시 라운드 영역째 2% 축소.
            AspectRatio(
              aspectRatio: 1,
              child: AnimatedScale(
                scale: _highlighted ? 0.98 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: const Color(0xFFF2F3F7),
                    child: (photo?.isNotEmpty ?? false)
                        ? WebNetworkImage(url: photo, fit: BoxFit.cover)
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 물품명: Regular 14 / 가격: Bold 16, 간격 6 (피그마 기준).
            Text(
              item.productName ?? item.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
            const SizedBox(height: 2),
            Text(
              '${_numberFormat.format(item.price ?? 0)}원',
              style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────── 공용 조각 ───────────────────────────────

/// 탭 피드백 공통 로직 — 터치(태블릿)에서 hover 대신 쓰며, 빠르게 탭해도
/// 효과가 잠깐(150ms)은 보이게 릴리즈를 지연한다.
mixin _TapFeedback<T extends StatefulWidget> on State<T> {
  bool pressed = false;
  Timer? _pressTimer;

  void pressDown() {
    _pressTimer?.cancel();
    setState(() => pressed = true);
  }

  void pressUpDelayed() {
    _pressTimer?.cancel();
    _pressTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => pressed = false);
    });
  }

  void pressCancel() {
    _pressTimer?.cancel();
    setState(() => pressed = false);
  }

  @override
  void dispose() {
    _pressTimer?.cancel();
    super.dispose();
  }
}

/// 태블릿·모바일에서 캐러셀을 좌우 스와이프로 넘길 수 있게 하는 래퍼.
/// 수평 드래그만 가로채므로 카드 탭은 그대로 동작한다.
class _SwipeDetector extends StatelessWidget {
  final bool enabled;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final Widget child;

  const _SwipeDetector({
    required this.enabled,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -200) {
          onSwipeLeft();
        } else if (velocity > 200) {
          onSwipeRight();
        }
      },
      child: child,
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final Widget? trailing;

  const _HomeSectionHeader({
    required this.title,
    this.onPrev,
    this.onNext,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    return Row(
      children: [
        Text(
          title,
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: isMobile ? 18 : 22,
            color: SDSColor.gray900,
          ),
        ),
        const Spacer(),
        // 모바일은 스와이프로 넘기므로 < > 버튼을 노출하지 않는다.
        if (!isMobile && (onPrev != null || onNext != null)) ...[
          _ArrowButton(icon: Icons.chevron_left, onTap: onPrev),
          const SizedBox(width: SDSSpacing.sm),
          _ArrowButton(icon: Icons.chevron_right, onTap: onNext),
          // 화살표 ↔ 더보기 간격 30 (피그마 기준).
          if (trailing != null) const SizedBox(width: 30),
        ],
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _ArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> with _TapFeedback {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onTap != null;
    // hover(PC)/press(터치) 시: 원 배경 black / 화살표 white / 라인 black.
    final bool highlighted = enabled && (_hovered || pressed);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: highlighted ? SDSColor.snowliveBlack : SDSColor.snowliveWhite,
        shape: CircleBorder(
          side: BorderSide(
            color: highlighted ? SDSColor.snowliveBlack : SDSColor.gray200,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (value) => value ? pressDown() : pressUpDelayed(),
          // 클릭 시 스플래시/하이라이트 효과 제거.
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              widget.icon,
              size: 20,
              color: !enabled
                  ? SDSColor.gray300
                  : (highlighted ? SDSColor.snowliveWhite : SDSColor.gray900),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 더보기: 검정 배경, radius 4, 패딩 13/8, Bold 13 (피그마 기준).
    return Material(
      color: SDSColor.snowliveBlack,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: Text(
            '더보기',
            style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.snowliveWhite),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;

  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == index ? SDSColor.gray900 : SDSColor.gray300,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────── 푸터 ───────────────────────────────

/// 홈 하단 푸터 — 로고 / Contact 3열 / 스토어 배지 / 저작권·약관.
///
/// 목업: 로고는 좌측, Contact 3열과 스토어 배지는 **우측에 모여** 있다.
class HomeFooterWeb extends StatelessWidget {
  const HomeFooterWeb({super.key});

  static const _appStore = 'https://apps.apple.com/kr/app/id1602642173';
  static const _playStore =
      'https://play.google.com/store/apps/details?id=com.snowlive.snowlive';
  static const _privacy =
      'https://sites.google.com/view/134creativelabprivacypolicy/%ED%99%88';
  static const _terms = 'https://sites.google.com/view/snowlive-termsofservice/%ED%99%88';

  /// 목업의 Contact 3열. 채널 링크가 아직 없어서 문구만 두고 링크는 붙이지 않는다.
  static const _columns = [
    ['Instagram', 'Kakao', 'X', 'TikTok'],
    ['Instagram', 'Kakao'],
    ['Instagram', 'Kakao'],
  ];

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;
    final isMobile = screenType == WebScreenType.mobile;

    // 피그마: 상단 구분선 없음, 콘텐츠 ↔ 구분선(#ECECEC) ↔ 하단행 간격 각 30
    // 좌우 여백은 페이지 콘텐츠 패딩(40)이 담당하므로 상하 40만 갖는다.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isMobile) ..._buildMobile() else ..._buildWide(screenType),
          const SizedBox(height: 30),
          const Divider(height: 1, color: Color(0xFFECECEC)),
          const SizedBox(height: 30),
          _buildBottomRow(isMobile),
        ],
      ),
    );
  }

  List<Widget> _buildWide(WebScreenType screenType) {
    final isTablet = screenType == WebScreenType.tablet;
    if (isTablet) {
      // 태블릿(피그마): 로고 좌 / Contact 3열(간격 40) + 배지 세로 스택(높이 36) 우.
      return [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _logo(),
            const Spacer(),
            _contactColumns(gap: 40),
            // Contact ↔ 배지 간격 50 (피그마 기준).
            const SizedBox(width: 50),
            _storeBadgesColumn(),
          ],
        ),
      ];
    }

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _logo(),
          const Spacer(),
          _contactColumns(),
          // Contact ↔ 배지 간격 70 (피그마 기준).
          const SizedBox(width: 70),
          _storeBadges(),
        ],
      ),
    ];
  }

  // 모바일(피그마 1:13252): 로고(19) ↔ Contact 30, 3열 좌측 정렬(간격 60),
  // Contact ↔ 배지 30, 배지 높이 40 한 줄(간격 10).
  List<Widget> _buildMobile() => [
        // 모바일도 목업처럼 좌측 정렬(stretch 안에서는 이미지가 가운데로 붙는다).
        Align(alignment: Alignment.centerLeft, child: _logo(height: 19)),
        const SizedBox(height: 30),
        _contactColumns(gap: 60),
        const SizedBox(height: 30),
        _storeBadges(),
      ];

  /// GNB 좌상단과 **같은 로고 에셋**(벡터)을 쓴다. PC·태블릿 22 / 모바일 19.
  /// 탭하면 홈으로 이동한다(상단바 로고와 동일).
  Widget _logo({double height = 22}) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => Get.toNamed(WebRoutes.home),
          child: SvgPicture.asset(
            'assets/imgs/logos/snowlive_logo_black_web.svg',
            height: height,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
          ),
        ),
      );

  Widget _contactColumns({double gap = 70}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _columns.length; i++) ...[
          // 열 사이 간격: PC 70 / 태블릿 40 / 모바일 60 (피그마 기준).
          if (i > 0) SizedBox(width: gap),
          _contactColumn(_columns[i]),
        ],
      ],
    );
  }

  Widget _contactColumn(List<String> labels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 헤더 Bold 14, 항목 간격 8 (피그마 기준). 마지막 항목 뒤에는 여백을
        // 두지 않는다 — 아래 요소와의 간격(40)이 정확히 유지되도록
        Text(
          'Contact',
          style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
        ),
        for (final label in labels) ...[
          const SizedBox(height: 8),
          _ContactLink(label: label),
        ],
      ],
    );
  }

  Widget _storeBadges() {
    // 좁은 폭에서도 두 배지를 한 줄에 둔다(목업) → 넘치면 축소한다.
    return const FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StoreBadge(kind: _StoreKind.appStore, url: _appStore),
          // 배지 간격 10 (피그마 기준).
          SizedBox(width: 10),
          _StoreBadge(kind: _StoreKind.googlePlay, url: _playStore),
        ],
      ),
    );
  }

  /// 태블릿: 배지를 세로로 쌓고(간격 10) 우측 정렬, 높이 40.
  Widget _storeBadgesColumn() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StoreBadge(kind: _StoreKind.appStore, url: _appStore),
        SizedBox(height: 10),
        _StoreBadge(kind: _StoreKind.googlePlay, url: _playStore),
      ],
    );
  }

  Widget _buildBottomRow(bool isMobile) {
    // 하단행: Regular 13, black 50% / 링크 간격 30 (피그마 기준).
    final copyright = Text(
      '© ${DateTime.now().year} 134CreativeLab. All rights reserved.',
      style: SDSTextStyle.regular.copyWith(
        fontSize: 13,
        color: SDSColor.snowliveBlack.withOpacity(0.5),
      ),
    );
    final links = Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _FooterLink(label: 'Privacy Policy', url: _privacy),
        SizedBox(width: 30),
        _FooterLink(label: 'Terms of Use', url: _terms),
      ],
    );

    if (isMobile) {
      // 카피라이트 ↔ 링크 간격 16 (피그마 기준).
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [copyright, const SizedBox(height: SDSSpacing.md), links],
      );
    }
    return Row(children: [copyright, const Spacer(), links]);
  }
}

/// Contact 항목. 목업처럼 올리면 밑줄이 생긴다(채널 URL은 아직 없어 이동은 하지 않는다).
class _ContactLink extends StatefulWidget {
  final String label;

  const _ContactLink({required this.label});

  @override
  State<_ContactLink> createState() => _ContactLinkState();
}

class _ContactLinkState extends State<_ContactLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Text(
        widget.label,
        style: SDSTextStyle.regular.copyWith(
          fontSize: 14,
          color: SDSColor.gray900,
          decoration: _isHovered ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}

enum _StoreKind { appStore, googlePlay }

/// 스토어 배지 — 공식 SVG 에셋(높이 40, 피그마 기준).
class _StoreBadge extends StatelessWidget {
  final _StoreKind kind;
  final String url;

  /// 배지 높이 40 (피그마 기준).
  final double height;

  const _StoreBadge({
    required this.kind,
    required this.url,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isApple = kind == _StoreKind.appStore;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: SvgPicture.asset(
          isApple
              ? 'assets/imgs/logos/badge_app_store.svg'
              : 'assets/imgs/logos/badge_google_play.svg',
          height: height,
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final String url;

  const _FooterLink({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: Text(
          label,
          style: SDSTextStyle.regular.copyWith(
            fontSize: 13,
            color: SDSColor.snowliveBlack.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
