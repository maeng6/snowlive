import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_dailyRidingCard.dart';
import 'package:com.snowlive/core/model/m_seasonRidingCard.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_ridingCard.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList_recordRoom.dart'
    show RankingFilter_season;
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_riding_card_web.dart'
    show kRidingCardAspectRatio;
import 'package:com.snowlive/web/view/ranking/riding_card_sections_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ridingcard_actions_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ridingcard_detail_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ridingcard_season_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ridingcard_tiles_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_sticky_column_web.dart';
import 'package:com.snowlive/web/widget/w_web_text_tabs_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// 목업 실측 폭(월별 목록 480 + 간격 60 + 우측 시즌 카드 220). **PC에서만** 쓴다 —
/// 태블릿·모바일은 화면 폭을 그대로 채운다(목업 65:40630은 800폭 기준이라 760이 곧 전폭).
/// 이 화면은 목록이 좁은 기록 화면이라 공통 목록폭(1280)을 쓰지 않는다.
const double kRidingCardsContentMaxWidth = 760;

/// 우측 시즌 카드 열 폭. 카드 높이는 비율로 따라온다(220 → 349.25).
const double _kSeasonColumnWidth = 220;

/// 목록 ↔ 시즌 카드 열 간격.
const double _kSeasonColumnGap = 60;

/// 월 제목 줄 — 모바일만 줄 높이가 크고 글자가 작다(목업 65:43841, 앱도 18).
double _monthHeaderHeight(BuildContext context) =>
    context.screenType == WebScreenType.mobile ? 56 : 48;
double _monthTitleSize(BuildContext context) =>
    context.screenType == WebScreenType.mobile ? 18 : 24;

/// 월 제목 ↔ 그 달 첫 카드.
double _monthHeaderGap(BuildContext context) =>
    context.screenType == WebScreenType.mobile ? 10 : 20;

/// 월 묶음 사이 간격.
const double _kMonthGroupGap = 40;

/// 시즌 카드가 멈출 때 화면 위에 남기는 여백.
const double _kStickyTopGap = 24;

/// 페이지 맨 아래 여백.
const double _kPageBottomGap = 100;

/// 시즌 카드 묶음 ↔ 월별 목록 간격 — 태블릿 40 / 모바일 20
/// (목업 65:40630 · 65:43841).
double _seasonPanelBottomGap(BuildContext context) =>
    context.screenType == WebScreenType.mobile ? 20 : 40;

/// 그리드 간격 — 폭마다 목업이 다르다.
///  - PC: 목업은 열 9 · 줄 12지만 **열도 12로 둔다**(사용자 확정).
///  - 태블릿: 목업이 PC(목록 480)를 그대로 키운 것이라 **폭에 비례**한다
///    (760에서 열 14.3 · 줄 19.1 — 65:41916).
///  - 모바일: 3열이라 비율이 따로다(목록 343에서 열 5.9 · 줄 11.3 — 65:45787).
({double column, double row}) _gridGaps(BuildContext context, double gridWidth) {
  switch (context.screenType) {
    case WebScreenType.desktop:
      return (column: 12, row: 12);
    case WebScreenType.tablet:
      return (column: gridWidth * 9 / 480, row: gridWidth * 12 / 480);
    case WebScreenType.mobile:
      return (column: 6, row: 11);
  }
}

/// 라이딩 기록 카드. `#/riding-cards`
///
/// 데이터·카드 디자인은 **앱과 동일**하다 — 코어 [RidingCardViewModel]을 그대로 쓰고
/// (웹 금지 의존성이 없다) 카드 위젯도 앱에서 옮겨온 것을 쓴다. 레이아웃만 목업을 따른다:
/// 데스크탑은 좌측 월별 목록 + 우측 시즌 카드, 모바일은 위아래로 쌓는다.
class RidingCardsViewWeb extends StatefulWidget {
  const RidingCardsViewWeb({super.key});

  @override
  State<RidingCardsViewWeb> createState() => _RidingCardsViewWebState();
}

class _RidingCardsViewWebState extends State<RidingCardsViewWeb> {
  final RidingCardViewModel _vm = Get.find<RidingCardViewModel>();
  final AuthCheckViewModelWeb _authVm = Get.find<AuthCheckViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();

  /// 시즌 카드 캡처용.
  final GlobalKey _seasonCardKey = GlobalKey();

  /// 우측 시즌 카드를 상단에 고정하려면 페이지 스크롤 위치와 목록 높이가 필요하다.
  final ScrollController _scroll = ScrollController();
  final GlobalKey _listKey = GlobalKey();

  RankingFilter_season _season = ridingCardSeasons().first;

  /// 어떤 로그인 상태로 조회를 마쳤는지(자동로그인이 끝난 뒤 내 카드로 다시 받아야 한다).
  WebAuthStatus? _loadedForAuth;
  Worker? _authWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadIfNeeded();
    });
    // 자동로그인 확인 전에는 user_id가 없어 조회가 의미 없다 → 상태가 정해지면 받는다.
    _authWorker = ever<WebAuthStatus>(_authVm.statusRx, (_) {
      if (!mounted) return;
      _loadIfNeeded();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _authWorker?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _loadIfNeeded() {
    final status = _authVm.status;
    if (status == WebAuthStatus.checking) return;
    if (_loadedForAuth == status) return;
    _loadedForAuth = status;
    if (_userVm.user.user_id == null) return;
    _vm.loadCardTypeMap();
    _fetch();
  }

  Future<void> _fetch() async {
    final userId = _userVm.user.user_id;
    if (userId == null) return;
    await Future.wait([
      _vm.fetchSeasonRidingCard(userId: userId, season: _season.dbSeason),
      // 데일리 목록은 시즌 파라미터가 없어 전체를 받고 화면에서 시즌으로 걸러 쓴다.
      _vm.fetchDailyRidingCardList(userId: userId),
    ]);
  }

  Future<void> _changeSeason(RankingFilter_season season) async {
    if (season == _season) return;
    setState(() => _season = season);
    final userId = _userVm.user.user_id;
    if (userId == null) return;
    await _vm.fetchSeasonRidingCard(userId: userId, season: season.dbSeason);
  }

  String get _seasonLabel => _season.korean.replaceAll('시즌', '').trim();

  void _toast(String message) {
    showWebToast(
      context,
      message,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: SDSColor.snowliveWhite,
      // 홈 공통 여백(중고거래 홈 기준).
      // ⚠️ 페이지 여백은 **스크롤 영역 안쪽**에 둔다(웹 공통) — 바깥에 주면
      // 스크롤바가 여백 안쪽에 생겨 브라우저 오른쪽 끝에 붙지 않는다.
      child: SingleChildScrollView(
        controller: _scroll,
        // 목록 끝과 화면 바닥 사이 여백(공통 기본 32보다 넉넉히).
        padding: webHomePagePadding(context, bottom: _kPageBottomGap),
        child: Center(
          child: ConstrainedBox(
            // 폭 제한은 PC에만 — 태블릿·모바일은 화면 폭을 그대로 쓴다
            // (목록이 좁게 갇히지 않게. 다른 서브 화면들과 같은 방식).
            constraints: BoxConstraints(
              maxWidth: context.isDesktop
                  ? kRidingCardsContentMaxWidth
                  : double.infinity,
            ),
            child: Obx(_buildBody),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // ⚠️ 분기 전에 관찰값을 모두 읽어야 Obx 구독이 확실히 걸린다.
    final seasonCard = _vm.seasonRidingCard.value;
    final allCards = _vm.dailyRidingCardList.toList();
    final isLoadingSeason = _vm.isLoadingSeasonCard.value;
    final isLoadingList = _vm.isLoadingDailyList.value;
    final isGrid = _vm.isGridView.value;
    _vm.cardTypeMap.length; // 스킨을 바꿨을 때 카드가 다시 그려지도록 구독한다.

    final cards = ridingCardsForSeason(allCards, _season.dbSeason);
    final months = groupRidingCardsByMonth(cards);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '라이딩 기록 카드',
          // 홈 타이틀 공통: PC 32 / 태블릿·모바일 24 (중고거래 홈 기준).
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: webHomeTitleSize(context),
            color: SDSColor.gray900,
          ),
        ),
        SizedBox(height: context.isDesktop ? 40 : 30),
        Align(
          alignment: Alignment.centerLeft,
          // 목업은 bold 16 · 비활성 gray200 · 1px 세로선 구분자(간격 10).
          child: WebTextTabs<RankingFilter_season>(
            values: ridingCardSeasons(),
            selected: _season,
            labelOf: (s) => s.korean,
            onSelected: _changeSeason,
            fontSize: 16,
            inactiveBold: true,
            inactiveColor: SDSColor.gray200,
            lineDivider: true,
            dividerGap: 10,
          ),
        ),
        // PC는 바로 월 제목이 오고, 태블릿·모바일은 시즌 카드가 먼저 온다.
        // 태블릿만 42고 PC·모바일은 32다(목업 65:36714 · 65:40630 · 65:43841).
        SizedBox(
          height: context.screenType == WebScreenType.tablet ? 42 : SDSSpacing.xl,
        ),
        if (_authVm.status == WebAuthStatus.unauthenticated)
          WebEmptyState(
            message: '로그인하면 내 라이딩 기록 카드를 볼 수 있어요.',
            actionLabel: '로그인하기',
            onAction: () => Get.toNamed(WebRoutes.login),
          )
        else if (isLoadingSeason && isLoadingList && seasonCard == null && cards.isEmpty)
          const _RidingCardsSkeleton()
        else
          _buildContent(seasonCard: seasonCard, months: months, isGrid: isGrid),
      ],
    );
  }

  Widget _buildContent({
    required SeasonRidingCard? seasonCard,
    required List<RidingCardMonth> months,
    required bool isGrid,
  }) {
    final seasonPanel = _buildSeasonPanel(seasonCard);
    final list = _buildMonths(months, isGrid);

    if (!context.isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (seasonPanel != null) ...[
            seasonPanel,
            SizedBox(height: _seasonPanelBottomGap(context)),
          ],
          list,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: KeyedSubtree(key: _listKey, child: list)),
        if (seasonPanel != null) ...[
          const SizedBox(width: _kSeasonColumnGap),
          SizedBox(
            width: _kSeasonColumnWidth,
            // 목록과 같이 올라가다 상단에 닿으면 멈춘다(목록만 계속 흐른다).
            child: WebStickyColumn(
              controller: _scroll,
              boundsKey: _listKey,
              topGap: _kStickyTopGap,
              child: seasonPanel,
            ),
          ),
        ],
      ],
    );
  }

  /// 시즌 카드 + `공유`·`이미지 저장`. 기록이 아예 없으면 그리지 않는다(앱과 동일).
  Widget? _buildSeasonPanel(SeasonRidingCard? card) {
    if (card == null) return null;
    final hasRecord = (card.totalSlopeCount ?? 0) != 0 ||
        (card.totalDistance ?? 0) != 0 ||
        (card.topSpeed ?? 0) != 0;
    if (!hasRecord) return null;

    return Column(
      children: [
        // 누르면 크게 본다(앱과 같은 경로). 옆 공유·저장 버튼은 그대로 둔다.
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => showSeasonRidingCardDetail(
              context,
              card: card,
              seasonLabel: '$_seasonLabel 시즌',
              dbSeason: _season.dbSeason,
              displayName: _userVm.user.display_name,
              profileImageUrl: _userVm.user.profile_image_url_user,
            ),
            child: RepaintBoundary(
              key: _seasonCardKey,
              child: RidingCardSeasonWeb(
                card: card,
                seasonLabel: '$_seasonLabel 시즌',
                displayName: _userVm.user.display_name,
                profileImageUrl: _userVm.user.profile_image_url_user,
                // 기본값(240)을 쓰면 열 폭(220) 안에서 내부 비례가 어긋난다.
                width: _kSeasonColumnWidth,
              ),
            ),
          ),
        ),
        const SizedBox(height: SDSSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CircleIconButton(
              asset: 'assets/imgs/icons/icon_summury_share.svg',
              onTap: () async {
                final ok = await shareRidingCardPng(
                  boundaryKey: _seasonCardKey,
                  filename: ridingCardSeasonFileName(_season.dbSeason),
                );
                if (!mounted) return;
                if (!ok) _toast('이 브라우저에서는 공유를 지원하지 않아요. 이미지 저장을 이용해 주세요.');
              },
            ),
            const SizedBox(width: 10),
            _SaveButton(
              label: '이미지 저장',
              isPrimary: false,
              onTap: () => saveRidingCardWithFeedback(
                context,
                boundaryKey: _seasonCardKey,
                filename: ridingCardSeasonFileName(_season.dbSeason),
                toast: _toast,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonths(List<RidingCardMonth> months, bool isGrid) {
    if (months.isEmpty) {
      return const WebEmptyState(message: '이 시즌 라이딩 기록이 없어요.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < months.length; i++) ...[
          if (i > 0) const SizedBox(height: _kMonthGroupGap),
          SizedBox(
            height: _monthHeaderHeight(context),
            child: Row(
              children: [
                Text(
                  months[i].title,
                  style: SDSTextStyle.bold
                      .copyWith(fontSize: _monthTitleSize(context), color: SDSColor.gray900),
                ),
                const Spacer(),
                // 보기 전환은 목업처럼 첫 달 제목 줄에만 둔다(전체에 적용된다).
                if (i == 0)
                  _ViewToggle(
                    isGrid: isGrid,
                    onChanged: (grid) {
                      if (grid != isGrid) _vm.toggleViewMode();
                    },
                  ),
              ],
            ),
          ),
          SizedBox(height: _monthHeaderGap(context)),
          if (isGrid) _buildGrid(months[i].cards) else _buildList(months[i].cards),
        ],
      ],
    );
  }

  Widget _buildGrid(List<DailyRidingCard> cards) {
    // 모바일만 3열이다(4열이면 카드가 80 남짓이라 내용이 안 읽힌다 — 앱도 3열).
    final columns = context.screenType == WebScreenType.mobile ? 3 : 4;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gaps = _gridGaps(context, constraints.maxWidth);
        final gridWidth = constraints.maxWidth;
        final columnGap = gaps.column;
        final rowGap = gaps.row;
        final width = (gridWidth - columnGap * (columns - 1)) / columns;
        return Wrap(
          spacing: columnGap,
          runSpacing: rowGap,
          children: [
            for (final card in cards)
              SizedBox(
                width: width,
                child: RidingCardGridTileWeb(
                  card: card,
                  cardType: _vm.getCardType(card.cardId ?? 0),
                  displayName: _userVm.user.display_name,
                  profileImageUrl: _userVm.user.profile_image_url_user,
                  onTap: () => _openDetail(card),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildList(List<DailyRidingCard> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < cards.length; i++)
          RidingCardListTileWeb(
            card: cards[i],
            cardType: _vm.getCardType(cards[i].cardId ?? 0),
            isFirst: i == 0,
            isLast: i == cards.length - 1,
            onTap: () => _openDetail(cards[i]),
          ),
      ],
    );
  }

  Future<void> _openDetail(DailyRidingCard card) async {
    await showRidingCardDetail(
      context,
      card: card,
      displayName: _userVm.user.display_name,
      profileImageUrl: _userVm.user.profile_image_url_user,
      cardTypeOf: () => _vm.getCardType(card.cardId ?? 0),
      onSwapCardType: () => _vm.toggleCardType(card.cardId ?? 0),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final bool isGrid;
  final ValueChanged<bool> onChanged;

  const _ViewToggle({required this.isGrid, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // 앱 라이딩 기록 카드와 같은 아이콘(`v_ridingCardList.dart`) — on/off 두 벌로 나뉜다.
    return Row(
      children: [
        _ToggleIcon(
          asset: isGrid
              ? 'assets/imgs/icons/icon_view_card_on.png'
              : 'assets/imgs/icons/icon_view_card_off.png',
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 6),
        _ToggleIcon(
          asset: !isGrid
              ? 'assets/imgs/icons/icon_view_list_on.png'
              : 'assets/imgs/icons/icon_view_list_off.png',
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  /// 켜짐/꺼짐이 **파일로 나뉘어 있다**(앱과 동일) — 색을 입히지 않는다.
  final String asset;
  final VoidCallback onTap;

  const _ToggleIcon({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      // 목업·앱 모두 아이콘 자리는 32x32.
      child: Image.asset(asset, width: 32, height: 32),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  /// 앱과 같은 아이콘 에셋(`icon_summury_share.svg`).
  final String asset;
  final VoidCallback onTap;

  const _CircleIconButton({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      shape: CircleBorder(side: BorderSide(color: SDSColor.gray200)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            // 원이 40(앱은 44)이라 아이콘도 같은 비율로 줄인다(앱 20 → 18).
            child: SvgPicture.asset(
              asset,
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(SDSColor.gray900, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _SaveButton({required this.label, required this.isPrimary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 목업 96x40 · 라운드 20. 웹 기본 visualDensity가 높이를 깎으므로 함께 고정한다.
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? SDSColor.snowliveBlue : SDSColor.snowliveBlack,
          elevation: 0,
          minimumSize: const Size(96, 40),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          visualDensity: VisualDensity.standard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          label,
          style: SDSTextStyle.extraBold.copyWith(fontSize: 13, color: SDSColor.snowliveWhite),
        ),
      ),
    );
  }
}

class _RidingCardsSkeleton extends StatelessWidget {
  const _RidingCardsSkeleton();

  @override
  Widget build(BuildContext context) {
    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SkeletonBox(width: 60, height: 26, radius: 6),
        const SizedBox(height: SDSSpacing.md),
        // 실제 행 높이와 맞춘다(썸네일 64 + 위아래 16).
        for (var i = 0; i < 6; i++) ...[
          if (i > 0) const SizedBox(height: 32),
          const SkeletonBox(height: 64, radius: 8),
        ],
      ],
    );
    final card = SizedBox(
      width: _kSeasonColumnWidth,
      child: Column(
        children: [
          const AspectRatio(
            aspectRatio: kRidingCardAspectRatio,
            child: SkeletonBox(radius: 20),
          ),
          const SizedBox(height: SDSSpacing.lg),
          const SkeletonBox(width: 146, height: 40, radius: 20),
        ],
      ),
    );

    return SkeletonShimmer(
      child: context.isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: list),
                const SizedBox(width: _kSeasonColumnGap),
                card,
              ],
            )
          : Column(
              children: [card, SizedBox(height: _seasonPanelBottomGap(context)), list]),
    );
  }
}
