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
        color: SDSColor.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(isMobile ? SDSSpacing.md : SDSSpacing.lg),
      // 목업: 데스크탑은 제목·날짜·안내가 **왼쪽 열**에 세로로 놓이고 카드가 그 오른쪽에
      // 붙는다. 태블릿·모바일은 제목이 위, 카드가 아래다.
      child: isDesktop ? _buildDesktop() : _buildNarrow(isMobile),
    );
  }

  Widget _buildDesktop() {
    // 좌측 열의 안내 문구를 **카드 아래쪽에 맞춰** 내리려면(목업) 열 높이가 카드 높이를
    // 따라가야 한다. 스크롤 안에서는 높이가 무한이라 stretch만으로는 안 되고,
    // IntrinsicHeight로 카드 높이를 먼저 재야 한다.
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
                  const SizedBox(height: SDSSpacing.md),
                  _buildDateBadge(),
                  const Spacer(),
                  // 목업은 안내 문구가 좌측 열 맨 아래에 두 줄로 놓인다.
                  _buildNote(maxLines: 2),
                ],
              ),
            ),
          ),
          const SizedBox(width: SDSSpacing.md),
          Expanded(child: _buildIndivCard()),
          const SizedBox(width: SDSSpacing.md),
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
            _buildTitle(fontSize: isMobile ? 16 : 20),
            const SizedBox(width: SDSSpacing.sm),
            _buildDateBadge(),
            // 모바일은 안내 문구가 목록 아래로 내려간다(목업).
            if (!isMobile) ...[const Spacer(), _buildNote()],
          ],
        ),
        const SizedBox(height: SDSSpacing.md),
        if (isMobile) _buildMobilePager() else _buildWideRow(),
        if (isMobile) ...[
          const SizedBox(height: SDSSpacing.sm),
          _buildDots(),
          const SizedBox(height: SDSSpacing.sm),
          Center(child: _buildNote()),
        ],
      ],
    );
  }

  Widget _buildTitle({required double fontSize}) => Text(
        '오늘의 랭킹',
        style: SDSTextStyle.extraBold.copyWith(fontSize: fontSize, color: SDSColor.gray900),
      );

  Widget _buildDateBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: SDSColor.gray900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          homeTodayBadgeLabel(widget.today),
          style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.snowliveWhite),
        ),
      );

  /// 목업의 안내 문구. 좌측 열에서는 두 줄, 한 줄로 놓을 때는 줄바꿈을 공백으로 편다.
  Widget _buildNote({int maxLines = 1}) {
    const text = '오늘의 랭킹은\n10분마다 순위가 업데이트돼요';
    return Text(
      maxLines == 1 ? text.replaceAll('\n', ' ') : text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: SDSTextStyle.regular.copyWith(fontSize: 12, height: 1.4, color: SDSColor.gray400),
    );
  }

  Widget _buildWideRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildIndivCard()),
        const SizedBox(width: SDSSpacing.md),
        Expanded(child: _buildCrewCard()),
      ],
    );
  }

  Widget _buildMobilePager() {
    return SizedBox(
      // 8행 + 카드 여백. 행 높이(46)를 고정해 두면 두 목록의 높이가 같아진다.
      height: kHomeRankingCount * 46 + SDSSpacing.md * 2,
      child: PageView(
        controller: _pageController,
        onPageChanged: (page) => setState(() => _page = page),
        children: [_buildIndivCard(), _buildCrewCard()],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 2; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _page ? SDSColor.gray600 : SDSColor.gray300,
              ),
            ),
          ),
      ],
    );
  }

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
            leading: WebAvatar(
              url: widget.indiv[i].profileImageUrlUser,
              size: 32,
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
            leading: _CrewLogo(
              logoUrl: crewLogoUrlOf(
                logoUrl: widget.crew[i].crewLogoUrl,
                color: widget.crew[i].color,
              ),
              color: crewColorOf(widget.crew[i].color),
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
    return Container(
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: SDSSpacing.md, vertical: SDSSpacing.md),
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
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$rank',
              style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
            ),
          ),
          const SizedBox(width: SDSSpacing.sm),
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.regular.copyWith(fontSize: 11, color: SDSColor.gray400),
                  ),
              ],
            ),
          ),
          const SizedBox(width: SDSSpacing.sm),
          Text(
            '${_numberFormat.format(score)}점',
            style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
          ),
          // 화살표 자리는 값이 없어도 비워 둔다 — 점수 우측 끝이 행마다 흔들리지 않게.
          SizedBox(width: 18, child: Center(child: _RankChangeArrow(change: rankChange))),
        ],
      ),
    );

    if (onTap == null) return row;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: row),
    );
  }
}

/// 순위 변동 화살표(목업) — 상승은 빨간 ▲, 하락은 파란 ▼, 변동 없거나 데이터가 없으면 없음.
class _RankChangeArrow extends StatelessWidget {
  final int? change;

  const _RankChangeArrow({required this.change});

  @override
  Widget build(BuildContext context) {
    final value = change;
    if (value == null || value == 0) return const SizedBox.shrink();
    final isUp = value > 0;
    return Icon(
      isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
      size: 18,
      color: isUp ? SDSColor.red : SDSColor.snowliveBlue,
    );
  }
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
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? SDSColor.gray100,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: (logoUrl?.isNotEmpty ?? false)
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

class _HomeCrewCardsWebState extends State<HomeCrewCardsWeb> {
  int _page = 0;

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
          onPrev: pages.length > 1 ? () => setState(() => _page = (_page - 1) % pages.length) : null,
          onNext: pages.length > 1 ? () => setState(() => _page = (_page + 1) % pages.length) : null,
        ),
        const SizedBox(height: SDSSpacing.md),
        if (widget.isLoading)
          _buildSkeleton(perPage)
        else if (widget.cards.isEmpty)
          const WebEmptyState(message: '아직 공개된 크루 소식이 없어요')
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < perPage; i++) ...[
                if (i > 0) const SizedBox(width: SDSSpacing.md),
                Expanded(
                  child: i < page.length
                      ? _CrewTalkCard(card: page[i])
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        if (pages.length > 1) ...[
          const SizedBox(height: SDSSpacing.md),
          _Dots(count: pages.length, index: _page.clamp(0, pages.length - 1)),
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

class _CrewTalkCard extends StatelessWidget {
  final HomeCrewCard card;

  const _CrewTalkCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final crewColor = crewColorOf(card.crewColor);
    final logoUrl = crewLogoUrlOf(logoUrl: card.crewLogoUrl, color: card.crewColor);

    return MouseRegion(
      cursor: card.crewId == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: card.crewId == null
            ? null
            : () => Get.toNamed('${WebRoutes.crewHome}?id=${card.crewId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 360 / 260,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (card.imageUrl != null)
                      WebNetworkImage(url: card.imageUrl, fit: BoxFit.cover)
                    else
                      // 사진이 없으면 크루 색 배경 + 기본 로고(요청·목업의 초록 카드).
                      Container(
                        color: crewColor ?? SDSColor.gray100,
                        alignment: Alignment.center,
                        child: FractionallySizedBox(
                          widthFactor: 0.36,
                          child: (logoUrl?.isNotEmpty ?? false)
                              ? WebNetworkImage(url: logoUrl, fit: BoxFit.contain)
                              : const SizedBox.shrink(),
                        ),
                      ),
                    if (card.isNew)
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: SDSColor.gray900,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NEW',
                            style: SDSTextStyle.extraBold
                                .copyWith(fontSize: 11, color: SDSColor.snowliveWhite),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: SDSSpacing.sm),
            Row(
              children: [
                _CrewLogo(logoUrl: logoUrl, color: crewColor, size: 24, radius: 6),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    card.crewName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              card.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
            ),
            if (card.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                card.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: SDSTextStyle.regular
                    .copyWith(fontSize: 13, height: 1.4, color: SDSColor.gray600),
              ),
            ],
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

class _HomeFleamarketWebState extends State<HomeFleamarketWeb> {
  int _page = 0;

  int _perPage(WebScreenType type) => switch (type) {
        WebScreenType.desktop => 6,
        WebScreenType.tablet => 4,
        WebScreenType.mobile => 2,
      };

  @override
  Widget build(BuildContext context) {
    final perPage = _perPage(context.screenType);
    final pages = homeCarouselPages(widget.items, perPage);
    final page = pages.isEmpty ? const <Fleamarket>[] : pages[_page.clamp(0, pages.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HomeSectionHeader(
          title: '중고거래',
          onPrev: pages.length > 1 ? () => setState(() => _page = (_page - 1) % pages.length) : null,
          onNext: pages.length > 1 ? () => setState(() => _page = (_page + 1) % pages.length) : null,
          trailing: _MoreButton(onTap: () => Get.toNamed(WebRoutes.fleamarketList)),
        ),
        const SizedBox(height: SDSSpacing.md),
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
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < perPage; i++) ...[
                if (i > 0) const SizedBox(width: SDSSpacing.md),
                Expanded(
                  child: i < page.length ? _FleamarketMiniCard(item: page[i]) : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        if (pages.length > 1) ...[
          const SizedBox(height: SDSSpacing.md),
          _Dots(count: pages.length, index: _page.clamp(0, pages.length - 1)),
        ],
      ],
    );
  }
}

class _FleamarketMiniCard extends StatelessWidget {
  final Fleamarket item;

  const _FleamarketMiniCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final photo = (item.photos?.isNotEmpty ?? false) ? item.photos!.first.urlFleaPhoto : null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Get.toNamed('${WebRoutes.fleamarketDetail}?id=${item.fleaId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: SDSColor.gray50,
                  child: (photo?.isNotEmpty ?? false)
                      ? WebNetworkImage(url: photo, fit: BoxFit.cover)
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(height: SDSSpacing.sm),
            Text(
              item.productName ?? item.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray700),
            ),
            const SizedBox(height: 2),
            Text(
              '${_numberFormat.format(item.price ?? 0)}원',
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────── 공용 조각 ───────────────────────────────

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
        if (onPrev != null || onNext != null) ...[
          _ArrowButton(icon: Icons.chevron_left, onTap: onPrev),
          const SizedBox(width: SDSSpacing.sm),
          _ArrowButton(icon: Icons.chevron_right, onTap: onNext),
        ],
        if (trailing != null) ...[const SizedBox(width: SDSSpacing.sm), trailing!],
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      shape: CircleBorder(side: BorderSide(color: SDSColor.gray200)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 20,
            color: onTap == null ? SDSColor.gray300 : SDSColor.gray900,
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
    return Material(
      color: SDSColor.gray900,
      borderRadius: BorderRadius.circular(6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                color: i == index ? SDSColor.gray600 : SDSColor.gray300,
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

  /// 목업 실측 열 폭(Contact 한 열).
  static const double _contactColumnWidth = 208;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, color: SDSColor.gray100),
        SizedBox(height: isMobile ? SDSSpacing.lg : 36),
        if (isMobile) ..._buildMobile() else ..._buildWide(screenType),
        SizedBox(height: isMobile ? SDSSpacing.lg : 36),
        Divider(height: 1, color: SDSColor.gray100),
        const SizedBox(height: SDSSpacing.md),
        _buildBottomRow(isMobile),
        const SizedBox(height: SDSSpacing.xl),
      ],
    );
  }

  List<Widget> _buildWide(WebScreenType screenType) {
    // 태블릿은 폭이 좁아 열이 겹치므로 Contact 줄과 배지 줄을 분리한다.
    final isTablet = screenType == WebScreenType.tablet;
    if (isTablet) {
      return [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _logo(),
            const Spacer(),
            _storeBadges(),
          ],
        ),
        const SizedBox(height: SDSSpacing.lg),
        _contactColumns(expand: true),
      ];
    }

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _logo(),
          const Spacer(),
          _contactColumns(expand: false),
          const SizedBox(width: SDSSpacing.lg),
          _storeBadges(),
        ],
      ),
    ];
  }

  List<Widget> _buildMobile() => [
        // 모바일도 목업처럼 좌측 정렬(stretch 안에서는 이미지가 가운데로 붙는다).
        Align(alignment: Alignment.centerLeft, child: _logo()),
        const SizedBox(height: SDSSpacing.lg),
        _contactColumns(expand: true),
        const SizedBox(height: SDSSpacing.lg),
        _storeBadges(isCompact: true),
      ];

  /// GNB 좌상단과 **같은 로고 에셋**(벡터)을 쓴다.
  Widget _logo() => SvgPicture.asset(
        'assets/imgs/logos/snowlive_logo_black_web.svg',
        height: 22,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
      );

  Widget _contactColumns({required bool expand}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        for (final column in _columns)
          expand
              ? Expanded(child: _contactColumn(column))
              : SizedBox(width: _contactColumnWidth, child: _contactColumn(column)),
      ],
    );
  }

  Widget _contactColumn(List<String> labels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Contact',
          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
        ),
        const SizedBox(height: 14),
        for (final label in labels)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ContactLink(label: label),
          ),
      ],
    );
  }

  Widget _storeBadges({bool isCompact = false}) {
    // 좁은 폭에서도 두 배지를 한 줄에 둔다(목업) → 살짝 줄이고, 그래도 넘치면 축소한다.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StoreBadge(kind: _StoreKind.appStore, url: _appStore, isCompact: isCompact),
          const SizedBox(width: SDSSpacing.sm),
          _StoreBadge(kind: _StoreKind.googlePlay, url: _playStore, isCompact: isCompact),
        ],
      ),
    );
  }

  Widget _buildBottomRow(bool isMobile) {
    final copyright = Text(
      '© ${DateTime.now().year} 134CreativeLab. All rights reserved.',
      style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
    );
    final links = Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _FooterLink(label: 'Privacy Policy', url: _privacy),
        SizedBox(width: SDSSpacing.lg),
        _FooterLink(label: 'Terms of Use', url: _terms),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [copyright, const SizedBox(height: SDSSpacing.sm), links],
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
          fontSize: 15,
          color: SDSColor.gray900,
          decoration: _isHovered ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}

enum _StoreKind { appStore, googlePlay }

/// 스토어 배지.
///
/// ⚠️ 공식 배지 이미지 에셋이 아직 없어서 **목업과 같은 모양으로 그려** 둔다
/// (흰 배경 + 검정 테두리 + 로고 + 2줄 문구). 공식 PNG/SVG를 받으면 이 위젯 안의
/// 그리기만 `Image.asset`으로 바꾸면 된다.
class _StoreBadge extends StatelessWidget {
  final _StoreKind kind;
  final String url;

  /// 모바일에서 두 배지가 한 줄에 들어가도록 조금 작게 그린다.
  final bool isCompact;

  const _StoreBadge({required this.kind, required this.url, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final isApple = kind == _StoreKind.appStore;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: Container(
          height: isCompact ? 44 : 52,
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14),
          decoration: BoxDecoration(
            color: SDSColor.snowliveWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SDSColor.gray900, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isApple)
                Icon(Icons.apple, size: isCompact ? 26 : 30, color: SDSColor.gray900)
              else
                _GooglePlayGlyph(size: isCompact ? 20 : 24),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isApple ? 'Download on the' : 'GET IT ON',
                    style: SDSTextStyle.regular.copyWith(fontSize: 10, color: SDSColor.gray900),
                  ),
                  Text(
                    isApple ? 'App Store' : 'Google Play',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: isCompact ? 16 : 19,
                      height: 1.1,
                      color: SDSColor.gray900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Google Play 삼각형(4색). 공식 에셋이 들어오면 이 위젯은 지운다.
class _GooglePlayGlyph extends StatelessWidget {
  final double size;

  const _GooglePlayGlyph({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GooglePlayPainter()),
    );
  }
}

class _GooglePlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    // 좌측 꼭짓점에서 우측 중앙으로 벌어지는 네 조각.
    void tri(List<Offset> points, Color color) {
      paint.color = color;
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path..close(), paint);
    }

    final left = Offset(w * 0.1, 0);
    final bottomLeft = Offset(w * 0.1, h);
    final mid = Offset(w * 0.62, h / 2);
    final top = Offset(w * 0.86, h * 0.28);
    final bottom = Offset(w * 0.86, h * 0.72);

    tri([left, mid, Offset(w * 0.1, h / 2)], const Color(0xFF00D3FF)); // 파랑(위)
    tri([Offset(w * 0.1, h / 2), mid, bottomLeft], const Color(0xFF00E676)); // 초록(아래)
    tri([left, top, mid], const Color(0xFFFFCE00)); // 노랑
    tri([bottomLeft, bottom, mid], const Color(0xFFFF3A44)); // 빨강
  }

  @override
  bool shouldRepaint(_GooglePlayPainter oldDelegate) => false;
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
          style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
        ),
      ),
    );
  }
}
