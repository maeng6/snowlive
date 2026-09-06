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
import 'package:com.snowlive/web/widget/w_web_text_tabs_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 목업 실측 폭(월별 목록 + 우측 시즌 카드 열).
const double kRidingCardsContentMaxWidth = 1160;

/// 우측 시즌 카드 열 폭(카드 240 + 여유).
const double _kSeasonColumnWidth = 260;

/// 그리드 카드 사이 간격.
const double _kGridGap = 12;

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
      alignment: context.screenType == WebScreenType.mobile
          ? Alignment.bottomCenter
          : Alignment.topCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Container(
      color: SDSColor.snowliveWhite,
      padding: EdgeInsets.fromLTRB(
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        32,
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        SDSSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kRidingCardsContentMaxWidth),
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
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: context.screenType == WebScreenType.mobile ? 22 : 28,
            color: SDSColor.gray900,
          ),
        ),
        const SizedBox(height: SDSSpacing.lg),
        Align(
          alignment: Alignment.centerLeft,
          child: WebTextTabs<RankingFilter_season>(
            values: ridingCardSeasons(),
            selected: _season,
            labelOf: (s) => s.korean,
            onSelected: _changeSeason,
          ),
        ),
        const SizedBox(height: SDSSpacing.xl),
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
            const SizedBox(height: SDSSpacing.xxl),
          ],
          list,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: list),
        if (seasonPanel != null) ...[
          const SizedBox(width: SDSSpacing.xl),
          SizedBox(width: _kSeasonColumnWidth, child: seasonPanel),
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
        RepaintBoundary(
          key: _seasonCardKey,
          child: RidingCardSeasonWeb(
            card: card,
            seasonLabel: '$_seasonLabel 시즌',
            displayName: _userVm.user.display_name,
            profileImageUrl: _userVm.user.profile_image_url_user,
          ),
        ),
        const SizedBox(height: SDSSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CircleIconButton(
              icon: Icons.ios_share,
              onTap: () async {
                final ok = await shareRidingCardPng(
                  boundaryKey: _seasonCardKey,
                  filename: ridingCardSeasonFileName(_season.dbSeason),
                );
                if (!mounted) return;
                if (!ok) _toast('이 브라우저에서는 공유를 지원하지 않아요. 이미지 저장을 이용해 주세요.');
              },
            ),
            const SizedBox(width: 12),
            _SaveButton(
              label: '이미지 저장',
              isPrimary: false,
              onTap: () async {
                final ok = await saveRidingCardPng(
                  boundaryKey: _seasonCardKey,
                  filename: ridingCardSeasonFileName(_season.dbSeason),
                );
                if (!mounted) return;
                _toast(ok ? '이미지를 저장했어요.' : '이미지 저장에 실패했어요.');
              },
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
          if (i > 0) const SizedBox(height: SDSSpacing.xxl),
          Row(
            children: [
              Text(
                months[i].title,
                style: SDSTextStyle.extraBold.copyWith(fontSize: 20, color: SDSColor.gray900),
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
          const SizedBox(height: SDSSpacing.md),
          if (isGrid) _buildGrid(months[i].cards) else _buildList(months[i].cards),
        ],
      ],
    );
  }

  Widget _buildGrid(List<DailyRidingCard> cards) {
    final columns = switch (context.screenType) {
      WebScreenType.desktop => 4,
      WebScreenType.tablet => 3,
      WebScreenType.mobile => 3,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - _kGridGap * (columns - 1)) / columns;
        return Wrap(
          spacing: _kGridGap,
          runSpacing: _kGridGap,
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
        for (final card in cards)
          RidingCardListTileWeb(
            card: card,
            cardType: _vm.getCardType(card.cardId ?? 0),
            displayName: _userVm.user.display_name,
            profileImageUrl: _userVm.user.profile_image_url_user,
            onTap: () => _openDetail(card),
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
    return Row(
      children: [
        _ToggleIcon(
          icon: Icons.grid_view_rounded,
          isActive: isGrid,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 8),
        _ToggleIcon(
          icon: Icons.format_list_bulleted,
          isActive: !isGrid,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleIcon({required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 22, color: isActive ? SDSColor.gray900 : SDSColor.gray300),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

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
          child: Icon(icon, size: 18, color: SDSColor.gray900),
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
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? SDSColor.snowliveBlue : SDSColor.snowliveBlack,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite),
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
        for (var i = 0; i < 6; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          const SkeletonBox(height: 56, radius: 8),
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
          const SizedBox(height: SDSSpacing.md),
          const SkeletonBox(width: 160, height: 44, radius: 50),
        ],
      ),
    );

    return SkeletonShimmer(
      child: context.isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: list),
                const SizedBox(width: SDSSpacing.xl),
                card,
              ],
            )
          : Column(children: [card, const SizedBox(height: SDSSpacing.xxl), list]),
    );
  }
}
