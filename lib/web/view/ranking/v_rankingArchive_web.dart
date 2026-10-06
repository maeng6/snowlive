import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_rankingListCrew_recordRoom.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv_recordRoom.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList.dart' show RankingFilter_resort, RankingFilter_fed;
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList_recordRoom.dart' show RankingFilter_season;
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_filter_sheet_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_crew_modal_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ranking_my_card_web.dart';
import 'package:com.snowlive/web/view/ranking/v_rankingHome_web.dart'
    show kRankingListMaxWidth, kRankingResortIds, kRankingSelectableResorts, kRankingSelectableFeds, rankColumnWidth;
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingArchiveCrew_web.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingArchiveIndiv_web.dart';
import 'package:com.snowlive/web/widget/w_numbered_pagination_web.dart';
import 'package:com.snowlive/web/widget/w_web_sticky_footer_scroll_web.dart';
import 'package:com.snowlive/web/widget/w_web_text_tabs_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_tap_web.dart';
import 'package:com.snowlive/web/widget/w_web_page_header_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 기록실 크루 → 크루 미리보기 팝업이 받는 [CrewCard].
/// 랭킹 홈의 `rankingCrewToCard`와 같은 역할인데, 모델 타입이 달라(공통 상위 타입이
/// 없다) 따로 둔다. 멤버 수·베이스 리조트 id는 응답에 없어 비운다.
CrewCard archiveCrewToCard(CrewRanking_recordRoom crew) => CrewCard(
      crewId: crew.crewId,
      crewName: crew.crewName,
      crewLogoUrl: crew.crewLogoUrl,
      color: crew.color,
      description: crew.description,
      baseResortNickname: crew.baseResortNickname,
    );

enum _ArchiveTab { individual, crew }

/// 웹 "랭킹 기록실" — 지난 시즌 개인/크루 랭킹 기록을 번호식 페이지네이션으로 본다.
/// 라이브 랭킹 화면(RankingHomeViewWeb)과 같은 골격이되, 시즌 선택 필터가 추가되고
/// 누적/일간 토글은 없다(기록실은 시즌 누적 기록만 다룬다).
class RankingArchiveViewWeb extends StatefulWidget {
  const RankingArchiveViewWeb({super.key});

  @override
  State<RankingArchiveViewWeb> createState() => _RankingArchiveViewWebState();
}

class _RankingArchiveViewWebState extends State<RankingArchiveViewWeb> {
  final RankingArchiveIndivViewModelWeb _vm = Get.find<RankingArchiveIndivViewModelWeb>();
  final RankingArchiveCrewViewModelWeb _crewVm = Get.find<RankingArchiveCrewViewModelWeb>();
  final _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  _ArchiveTab _tab = _ArchiveTab.individual;
  RankingFilter_season _selectedSeason = RankingFilter_season.season2526;
  RankingFilter_resort _selectedResort = RankingFilter_resort.total;
  RankingFilter_fed _selectedFed = RankingFilter_fed.initial;

  /// 타이틀 오른쪽 검색창 폭. 랭킹 홈과 같은 고정폭을 쓴다.
  static const double _searchBarWidth = 320;

  Worker? _authWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reload();
    });
    // 자동로그인 확인이 최초 조회보다 늦게 끝나면 첫 조회가 user_id 없이 나가서
    // 서버가 내 랭킹 정보를 안 준다. 로그인 확정 시 한 번 더 조회한다(랭킹 화면과 동일).
    _authWorker = ever<WebAuthStatus>(
      Get.find<AuthCheckViewModelWeb>().statusRx,
      (status) {
        if (status == WebAuthStatus.authenticated && mounted) _reload();
      },
    );
  }

  @override
  void dispose() {
    _authWorker?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  int? get _resortId => _selectedResort == RankingFilter_resort.total ? null : kRankingResortIds[_selectedResort];
  String? get _federation => _selectedFed == RankingFilter_fed.initial ? null : _selectedFed.english;

  void _reload() {
    final season = _selectedSeason.dbSeason;
    final q = _searchQuery.value.trim();
    final sq = q.isEmpty ? null : q;
    if (_tab == _ArchiveTab.individual) {
      _vm.loadFirstPage(season: season, resortId: _resortId, federation: _federation, searchQuery: sq);
    } else {
      _crewVm.loadFirstPage(season: season, resortId: _resortId, federation: _federation, searchQuery: sq);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 타이틀 줄에 검색바를 붙이는 기준을 랭킹 홈과 통일한다(데스크탑 = 1024 이상).
    final isWide = context.isDesktop;

    // 콘텐츠가 짧으면 푸터가 뷰포트 하단에 붙는다(공통 골격). 여백은 스크롤
    // 영역 안쪽에 둔다(웹 공통 규칙).
    return Container(
      color: SDSColor.snowliveWhite,
      child: WebStickyFooterScroll(
        // 서브 페이지 공통 여백(중고거래 상세·폼 기준).
        padding: webSubPagePadding(context),
        content: Center(
          child: ConstrainedBox(
            // 이 화면은 우측 사이드바가 없어서 목록 폭만 쓴다.
            // PC에서만 묶는다 — 태블릿에서도 걸면 좌우가 크게 비어 버린다.
            constraints: BoxConstraints(
              maxWidth: context.isDesktop ? kRankingListMaxWidth : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildTitleRow(),
                      // 타이틀 ↔ 검색바 36 (커뮤니티·랭킹 홈과 동일).
                      const SizedBox(width: 36),
                      SizedBox(width: _searchBarWidth, child: _buildSearchBar()),
                    ],
                  )
                else ...[
                  _buildTitleRow(),
                  const SizedBox(height: SDSSpacing.md),
                  _buildSearchBar(),
                ],
                // 타이틀·검색 영역 ↔ 필터 줄: PC 30 / 태블릿 24 / 모바일 20 (목록 공통).
                SizedBox(
                    height: isWide
                        ? 30
                        : (context.screenType == WebScreenType.tablet ? 24 : 20)),
                _buildTabAndFilterRow(),
                // 필터 줄 ↔ 아래 20 (커뮤니티·각종소식 확정값).
                const SizedBox(height: 20),
                // 아래 여백은 카드 안(margin)에 있어서, 카드가 숨겨지면 여백도 같이 사라진다.
                _tab == _ArchiveTab.individual ? _buildMyRankingCard() : _buildMyCrewRankingCard(),
                _tab == _ArchiveTab.individual ? _buildIndivList() : _buildCrewList(),
              ],
            ),
          ),
        ),
        // 페이지네이션은 푸터 블록에 둔다 — 목록이 짧아도 화면 아래쪽에 머문다(랭킹 홈과 동일).
        footer: Column(
          children: [
            const SizedBox(height: SDSSpacing.lg),
            _buildPagination(),
            SizedBox(height: context.isDesktop ? 120 : 80),
            const HomeFooterWeb(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    // 서브 페이지 공통 헤더 — 데스크탑은 같은 줄 우측에 검색바가 이어져
    // 타이틀을 확장하지 않는다. 모바일은 타이틀이 남은 폭을 차지하고 그 끝에
    // 시즌 pill이 붙는다(목업).
    final isMobile = context.screenType == WebScreenType.mobile;
    return WebPageHeader(
      title: '랭킹 기록실',
      onBack: () => Get.back(),
      expandTitle: isMobile,
      actions: isMobile ? [_titleRowSeasonSelector()] : const [],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      // 웹 검색바 공통(피그마 64:112895 — 커뮤니티·각종소식과 동일):
      // 높이 40 / 좌우 14 / 라운드 6 / 아이콘 18(텍스트와 6) / 텍스트 15(힌트 gray500).
      height: 40,
      decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(6)),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: SDSColor.gray400),
          const SizedBox(width: 6),
          Expanded(
            // 서버 통합검색: 닉네임/상태메세지/자주가는스키장 + 소속 크루의 크루명/소개글/베이스스키장.
            child: TextField(
              controller: _searchController,
              onChanged: (v) => _searchQuery.value = v,
              onSubmitted: (_) => _reload(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: '닉네임·크루·스키장 검색',
                hintStyle: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray500),
              ),
              style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
              cursorHeight: 17,
            ),
          ),
          Obx(() => _searchQuery.value.isEmpty
              ? const SizedBox.shrink()
              : InkWell(
                  onTap: () {
                    _searchController.clear();
                    _searchQuery.value = '';
                    _reload();
                  },
                  child: Icon(Icons.close, size: 18, color: SDSColor.gray400),
                )),
        ],
      ),
    );
  }

  /// 크루/개인 탭 + 시즌·리조트·리그 필터를 한 줄에 배치. 좁은 화면에서는 Wrap으로 접힌다.
  /// 타이틀 줄의 시즌 선택(모바일).
  ///
  /// 목업(106:32607)은 pill이 아니라 **배경·테두리 없는 텍스트 + 화살표**다 —
  /// `25/26` bold 14 검정 lh16 + 화살표 16. 탭 드롭다운과 같은 위젯을 쓴다.
  Widget _titleRowSeasonSelector() {
    return WebDropdownTextButton<RankingFilter_season>(
      label: _seasonLabel(_selectedSeason),
      values: RankingFilter_season.values,
      labelOf: _seasonLabel,
      onSelected: (v) => setState(() {
        _selectedSeason = v;
        _reload();
      }),
      labelStyle: SDSTextStyle.bold.copyWith(
        fontSize: 14,
        height: 16 / 14,
        color: SDSColor.gray900,
      ),
      iconSize: 16,
    );
  }

  /// `25/26시즌` → `25/26 시즌` (연도와 '시즌' 사이를 띄운다).
  String _seasonLabel(RankingFilter_season v) =>
      '${v.korean.replaceAll('시즌', '').trim()} 시즌';

  /// 시즌 선택 pill. 폭에 따라 타이틀 줄(모바일) 또는 필터 줄(PC·태블릿)에 붙는다.
  Widget _buildSeasonPill() {
    return FleamarketFilterPill<RankingFilter_season>(
      label: _seasonLabel(_selectedSeason),
      isActive: true,
      title: '시즌',
      // 태블릿도 PC식 앵커 드롭다운(중고거래·커뮤니티·각종소식과 동일 규칙).
      dropdownOnTablet: true,
      values: RankingFilter_season.values,
      labelOf: (v) => v.korean,
      onSelected: (v) => setState(() {
        _selectedSeason = v;
        _reload();
      }),
    );
  }

  Widget _buildTabAndFilterRow() {
    final isMobile = context.screenType == WebScreenType.mobile;
    return Row(
      children: [
        // 모바일은 탭을 드롭다운으로 접는다(랭킹 홈과 동일) — pill과 한 줄에 들어가야 한다.
        if (isMobile)
          WebDropdownTextButton<_ArchiveTab>(
            label: _tab == _ArchiveTab.crew ? '크루랭킹' : '개인랭킹',
            values: const [_ArchiveTab.individual, _ArchiveTab.crew],
            labelOf: (v) => v == _ArchiveTab.crew ? '크루랭킹' : '개인랭킹',
            onSelected: (v) => setState(() { _tab = v; _reload(); }),
            labelStyle: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
          )
        else
        // 탭 표준(피그마 64:112870) — bold 16, 비활성 gray200,
        // 1px 세로선 구분자, 간격 10 (랭킹 홈·커뮤니티와 동일).
        ...WebTextTabs<_ArchiveTab>(
          values: const [_ArchiveTab.individual, _ArchiveTab.crew],
          selected: _tab,
          labelOf: (v) => v == _ArchiveTab.crew ? '크루랭킹' : '개인랭킹',
          onSelected: (v) => setState(() { _tab = v; _reload(); }),
          fontSize: 16,
          inactiveBold: true,
          inactiveColor: SDSColor.gray200,
          lineDivider: true,
          dividerGap: 10,
        ).buildChildren(),
        const Spacer(),
        // 모바일은 시즌 pill이 타이틀 줄 우측으로 올라간다(목업 106:31632) —
        // 탭 드롭다운 + pill 세 개를 한 줄에 넣을 폭이 안 나온다.
        if (!isMobile) ...[
          _buildSeasonPill(),
          const SizedBox(width: SDSSpacing.sm),
        ],
        const SizedBox(width: SDSSpacing.sm),
        FleamarketFilterPill<RankingFilter_resort>(
          label: _selectedResort == RankingFilter_resort.total ? '전체 스키장' : _selectedResort.korean,
          isActive: _selectedResort != RankingFilter_resort.total,
          title: '스키장',
          dropdownOnTablet: true,
          values: [RankingFilter_resort.total, ...kRankingSelectableResorts],
          labelOf: (v) => v == RankingFilter_resort.total ? '전체 스키장' : v.korean,
          onSelected: (v) => setState(() {
            _selectedResort = v;
            // 서버가 스키장·리그를 동시에 못 받아서 한쪽을 고르면 다른 쪽을 푼다.
            // 단 '전체 스키장'(해제)은 리그 선택을 건드리지 않는다.
            if (v != RankingFilter_resort.total) _selectedFed = RankingFilter_fed.initial;
            _reload();
          }),
        ),
        const SizedBox(width: SDSSpacing.sm),
        FleamarketFilterPill<RankingFilter_fed>(
          label: _selectedFed == RankingFilter_fed.initial ? '대학 리그' : _selectedFed.korean,
          isActive: _selectedFed != RankingFilter_fed.initial,
          title: '대학 리그',
          dropdownOnTablet: true,
          // 해제 값(initial)을 맨 앞에 넣어야 다시 전체로 돌아올 수 있다.
          values: const [RankingFilter_fed.initial, ...kRankingSelectableFeds],
          labelOf: (v) => v == RankingFilter_fed.initial ? '전체 리그' : v.korean,
          onSelected: (v) => setState(() {
            _selectedFed = v;
            // '전체 리그'(해제)는 스키장 선택을 건드리지 않는다.
            if (v != RankingFilter_fed.initial) _selectedResort = RankingFilter_resort.total;
            _reload();
          }),
        ),
      ],
    );
  }

  bool get _isResortScoped => _selectedResort != RankingFilter_resort.total;

  Widget _buildMyRankingCard() {
    return Obx(() {
      final my = _vm.myRankingInfo;
      if (my == null) return const SizedBox.shrink();
      final isMobile = context.screenType == WebScreenType.mobile;

      return RankingMyCardShell(
        label: '내 랭킹',
        isMobile: isMobile,
        groups: [
          RankingMyStat(
              label: '개인 점수',
              value: '${_isResortScoped ? my.resortTotalScore : my.overallTotalScore}',
              stacked: isMobile),
          RankingMyStat(
              label: '개인 랭킹',
              value: '${_isResortScoped ? my.resortRank : my.overallRank}',
              stacked: isMobile),
          // 리조트별로는 티어가 오지 않으므로 그때만 그룹을 뺀다(랭킹 홈과 동일).
          if (!_isResortScoped)
            RankingTierBadge(
              iconUrl: my.overallTierIconUrl,
              name: my.tierNameKor ?? '',
              stacked: isMobile,
            ),
        ],
      );
    });
  }

  Widget _buildMyCrewRankingCard() {
    return Obx(() {
      // 로그인 여부를 Obx 바깥에서 검사하면 로그인 확정 시점에 다시 그려지지 않는다.
      // 소속 크루가 없으면 뷰모델이 null로 정규화해주므로 데이터 유무만 보고 판단한다.
      final my = _crewVm.myCrewRankingInfo;
      if (my == null) return const SizedBox.shrink();
      final isMobile = context.screenType == WebScreenType.mobile;

      return RankingMyCardShell(
        label: '내 크루 랭킹',
        isMobile: isMobile,
        groups: [
          RankingMyStat(
              label: '크루 점수',
              value: '${_isResortScoped ? my.resortTotalScore : my.overallTotalScore}',
              stacked: isMobile),
          RankingMyStat(
              label: '크루 랭킹',
              value: '${_isResortScoped ? my.resortRank : my.overallRank}',
              stacked: isMobile),
          // 앱 기록실에도 크루명 + 로고가 있다(v_rankingList_crew_recordRoom.dart) —
          // 랭킹 홈과 같은 묶음을 붙여 두 화면을 맞춘다.
          RankingCrewIdentity(
            name: my.crewName ?? '',
            logoUrl: crewLogoUrlOf(logoUrl: my.crewLogoUrl, color: my.color),
            stacked: isMobile,
            onTap: my.crewId == null
                ? null
                : () => Get.toNamed('${WebRoutes.crewHome}?id=${my.crewId}'),
          ),
        ],
      );
    });
  }

  Widget _buildIndivList() {
    return Obx(() {
      final items = _vm.items;
      // 조회 중이면 항상 스켈레톤(랭킹 홈과 동일).
      if (_vm.isLoading) {
        // 기록실 행은 홈보다 글자가 한 단계 작다. 티어는 전체 스키장일 때만 나온다.
        return RankingListSkeleton(compactText: true, showTier: !_isResortScoped);
      }
      if (items.isEmpty) return _emptyState(_vm.appliedQuery);

      return _rowList(
        count: items.length,
        rowAt: (i) => _buildIndivRow(
          items[i],
          rankColumnWidth(
            context,
            items.map((u) => _isResortScoped ? u.resortRank : u.overallRank),
          ),
        ),
);
    });
  }

  Widget _buildCrewList() {
    return Obx(() {
      final items = _crewVm.items;
      if (_crewVm.isLoading) {
        // 기록실 크루 행은 로고가 사각이고, 티어는 전체 스키장일 때만 나온다.
        return RankingListSkeleton(
            circleAvatar: false, compactText: true, showTier: !_isResortScoped);
      }
      if (items.isEmpty) return _emptyState(_crewVm.appliedQuery);

      return _rowList(
        count: items.length,
        rowAt: (i) => _buildCrewRow(
          items[i],
          rankColumnWidth(
            context,
            items.map((c) => _isResortScoped ? c.resortRank : c.overallRank),
          ),
        ),
);
    });
  }

  /// 결과 0건. 검색 중이면 **서버에 실제로 보낸** 검색어를 문구에 쓴다.
  Widget _emptyState([String query = '']) => WebEmptyState(
        message: query.isEmpty ? '해당 시즌의 랭킹 기록이 없습니다.' : "'$query' 검색 결과가 없어요.",
        // 아이콘은 공용 기본값(랭킹 홈과 동일).
      );

  /// 목록(행만). 페이지네이션은 푸터 블록에 있다 — 목록이 짧아도 화면 아래쪽에
  /// 머물게 하려고 분리했다(랭킹 홈과 동일).
  /// 현재 탭의 페이지네이션. 조회 중이거나 한 페이지뿐이면 그리지 않는다.
  Widget _buildPagination() {
    return Obx(() {
      final isIndiv = _tab == _ArchiveTab.individual;
      final loading = isIndiv ? _vm.isLoading : _crewVm.isLoading;
      final totalPages = isIndiv ? _vm.totalPages : _crewVm.totalPages;
      if (loading || totalPages <= 1) return const SizedBox.shrink();
      return NumberedPaginationBar(
        currentPage: isIndiv ? _vm.currentPage : _crewVm.currentPage,
        totalPages: totalPages,
        hasPrevious: isIndiv ? _vm.hasPrevious : _crewVm.hasPrevious,
        hasNext: isIndiv ? _vm.hasNext : _crewVm.hasNext,
        pageWindow: isIndiv ? _vm.pageWindow() : _crewVm.pageWindow(),
        onGotoPage: (page) => isIndiv ? _vm.gotoPage(page) : _crewVm.gotoPage(page),
      );
    });
  }

  Widget _rowList({required int count, required Widget Function(int index) rowAt}) {
    return Column(children: [for (int i = 0; i < count; i++) rowAt(i)]);
  }

  Widget _buildIndivRow(RankingUser_recordRoom user, double rankWidth) {
    final m = RankingRowMetrics.of(context);
    final userId = user.userId;
    // hover 잉크는 조상 Material 캔버스에 그려진다 — 페이지 흰 배경이 그 위를
    // 덮으므로 행 바로 위에 투명 Material을 끼운다. 행 간격(8)은 잉크 밖으로
    // 빼서 hover 박스가 행 크기에만 맞게 한다(랭킹 홈과 동일한 구조).
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          // 랭킹 홈처럼 **행 전체**를 눌러 프로필 팝업을 연다(아바타만 눌리던 것).
          onTap: userId == null
              ? null
              : () => openWebProfilePopup(
                    context,
                    userId: userId,
                    name: user.displayName,
                    avatarUrl: user.profileImageUrlUser,
                  ),
          borderRadius: BorderRadius.circular(8),
          // hover 시 행 배경 검정 3% (커뮤니티·각종소식 표 행과 동일).
          hoverColor: SDSColor.gray900.withValues(alpha: 0.03),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: m.verticalPadding),
            // 내용 높이를 공용 상수로 못 박는다 — 안 그러면 이름+소속 두 줄의 line height가
            // 행 높이를 결정해서 스켈레톤과 어긋난다(랭킹 홈과 동일).
            height: m.boxHeight,
            child: Row(
            children: [
              SizedBox(
                width: rankWidth,
                child: Text(
                  '${_isResortScoped ? user.resortRank ?? '' : user.overallRank ?? ''}',
                  maxLines: 1,
                  softWrap: false,
                  style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                ),
              ),
              SizedBox(width: m.rankGap),
              // 행 전체가 팝업을 열므로 아바타에 따로 탭을 걸지 않는다.
              ClipOval(
                child: (user.profileImageUrlUser?.isNotEmpty ?? false)
                    ? WebNetworkImage(
                        url: user.profileImageUrlUser,
                        width: 36,
                        height: 36,
                        fallback: _avatarFallback(),
                      )
                    : _avatarFallback(),
              ),
              SizedBox(width: m.nameGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? '',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      // line height를 묶어야 행 높이가 계산 가능해진다(Pretendard 기본값은 더 크다).
                      style: SDSTextStyle.regular
                          .copyWith(fontSize: 14, height: 19 / 14, color: SDSColor.gray900),
                    ),
                    Text(
                      [
                        if (user.resortNickname?.isNotEmpty ?? false) user.resortNickname,
                        if (user.crewName?.isNotEmpty ?? false) user.crewName,
                      ].join(' · '),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.regular
                          .copyWith(fontSize: 12, height: 16 / 12, color: SDSColor.gray500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  '${_isResortScoped ? user.resortTotalScore ?? 0 : user.overallTotalScore ?? 0}점',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
                ),
              ),
              if (!_isResortScoped && (user.overallTierIconUrl?.isNotEmpty ?? false)) ...[
                const SizedBox(width: 8),
                WebNetworkImage(url: user.overallTierIconUrl, width: 36, height: 36, fit: BoxFit.contain, showPlaceholder: false),
              ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCrewRow(CrewRanking_recordRoom crew, double rankWidth) {
    final m = RankingRowMetrics.of(context);
    // 로고가 없으면 색별 기본 `LIVE CREW` 로고, 색도 없으면 회색 기본으로 떨어진다.
    final logoUrl = crewLogoUrlOf(logoUrl: crew.crewLogoUrl, color: crew.color);
    final hasTierIcon = !_isResortScoped && (crew.overallTierIconUrl?.isNotEmpty ?? false);
    final crewId = crew.crewId;
    // 개인 행과 같은 구조(투명 Material + InkWell) — 랭킹 홈 크루 행과 동일.
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: crewId == null
              ? null
              : () => showLiveCrewModal(context, archiveCrewToCard(crew)),
          borderRadius: BorderRadius.circular(8),
          hoverColor: SDSColor.gray900.withValues(alpha: 0.03),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: m.verticalPadding),
            // 개인 행과 같은 높이.
            height: m.boxHeight,
            child: Row(
              children: [
                SizedBox(
                  width: rankWidth,
                  child: Text(
                    '${_isResortScoped ? crew.resortRank ?? '' : crew.overallRank ?? ''}',
                    maxLines: 1,
                    softWrap: false,
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                  ),
                ),
                SizedBox(width: m.rankGap),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: (logoUrl?.isNotEmpty ?? false)
                      ? WebNetworkImage(url: logoUrl, width: m.avatar, height: m.avatar)
                      : Container(width: m.avatar, height: m.avatar, color: SDSColor.gray100),
                ),
                SizedBox(width: m.nameGap),
                Expanded(
                  child: Text(
                    crew.crewName ?? '',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: 14, height: 19 / 14, color: SDSColor.gray900),
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: Text(
                    '${_isResortScoped ? crew.resortTotalScore ?? 0 : crew.overallTotalScore ?? 0}점',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
                  ),
                ),
                if (hasTierIcon) ...[
                  const SizedBox(width: 8),
                  WebNetworkImage(url: crew.overallTierIconUrl, width: 36, height: 36, fit: BoxFit.contain, showPlaceholder: false),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      width: 36,
      height: 36,
      color: SDSColor.gray100,
      child: Icon(Icons.person, size: 18, color: SDSColor.gray400),
    );
  }
}


