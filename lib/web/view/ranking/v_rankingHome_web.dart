import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_rankingListCrew.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList.dart' show RankingFilter_resort, RankingFilter_fed;
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_filter_sheet_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ranking_profile_modal_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ranking_sidebar_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ranking_tier_guide_web.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingList_web.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingListCrew_web.dart';
import 'package:com.snowlive/web/widget/w_numbered_pagination_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 데스크탑 콘텐츠 최대폭 (중고거래 화면과 동일 톤으로 맞춤).
const double kRankingContentMaxWidth = 1136;

/// 랭킹 리조트 픽커 표시 순서(총 스키장 랭킹 enum) → 실제 backend resort_id.
/// 4(에덴밸리/한솔)가 빠져서 4 다음이 6으로 건너뛴다(모바일과 동일한 매핑).
const Map<RankingFilter_resort, int> kRankingResortIds = {
  RankingFilter_resort.konjiam: 1,
  RankingFilter_resort.muju: 2,
  RankingFilter_resort.vivaldi: 3,
  RankingFilter_resort.alphen: 4,
  RankingFilter_resort.gangchon: 6,
  RankingFilter_resort.oak: 7,
  RankingFilter_resort.o2: 8,
  RankingFilter_resort.yongpyong: 9,
  RankingFilter_resort.welli: 10,
  RankingFilter_resort.jisan: 11,
  RankingFilter_resort.high1: 12,
  RankingFilter_resort.phoenix: 13,
};

const List<RankingFilter_resort> kRankingSelectableResorts = [
  RankingFilter_resort.konjiam,
  RankingFilter_resort.muju,
  RankingFilter_resort.vivaldi,
  RankingFilter_resort.alphen,
  RankingFilter_resort.gangchon,
  RankingFilter_resort.oak,
  RankingFilter_resort.o2,
  RankingFilter_resort.yongpyong,
  RankingFilter_resort.welli,
  RankingFilter_resort.jisan,
  RankingFilter_resort.high1,
  RankingFilter_resort.phoenix,
];

const List<RankingFilter_fed> kRankingSelectableFeds = [RankingFilter_fed.univ_ski, RankingFilter_fed.univ_board];

enum _RankingTab { individual, crew }

/// 웹 랭킹 화면 — 개인랭킹(번호식 페이지네이션) + 크루랭킹(next/previous 커서,
/// fetchRankingData_crew가 아직 번호식/게스트를 지원하지 않아 로그인 사용자만 조회 가능).
/// "랭킹 기록실"(시즌별 기록)은 이번 범위에서는 준비 중 안내만 띄운다.
class RankingHomeViewWeb extends StatefulWidget {
  const RankingHomeViewWeb({super.key});

  @override
  State<RankingHomeViewWeb> createState() => _RankingHomeViewWebState();
}

class _RankingHomeViewWebState extends State<RankingHomeViewWeb> {
  final RankingListViewModelWeb _vm = Get.find<RankingListViewModelWeb>();
  final RankingListCrewViewModelWeb _crewVm = Get.find<RankingListCrewViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final AuthCheckViewModelWeb _authVm = Get.find<AuthCheckViewModelWeb>();
  final _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  _RankingTab _tab = _RankingTab.individual;
  bool _daily = false;
  RankingFilter_resort _selectedResort = RankingFilter_resort.total;
  RankingFilter_fed _selectedFed = RankingFilter_fed.initial;

  Worker? _authWorker;

  @override
  void initState() {
    super.initState();
    // 각 뷰모델의 onInit()이 최초 진입 시점에 조회한 결과가 화면에 반영되지
    // 않는 경우가 있어(중고거래와 동일 증상), 화면이 마운트되는 시점에
    // 현재 탭 기준으로 한 번 더 명시적으로 조회해서 항상 목록이 뜨도록 한다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reload();
    });
    // 자동로그인(세션 복원) 확인이 최초 조회보다 늦게 끝나는 경우가 있는데,
    // 그때 첫 조회는 user_id 없이 나가서 서버가 my_ranking_info를 안 준다
    // (= "내 랭킹" 영역이 안 뜨고 탭을 다시 눌러야 뜨던 원인).
    // 로그인이 확정되는 시점에 한 번 더 조회해서 바로 반영되게 한다.
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
    if (_tab == _RankingTab.individual) {
      _vm.loadFirstPage(resortId: _resortId, federation: _federation, daily: _daily);
    } else {
      _crewVm.loadFirstPage(userId: _userVm.user.user_id, resortId: _resortId, federation: _federation, daily: _daily);
    }
  }

  /// 데스크탑에서 타이틀 오른쪽에 붙는 검색창 폭(목업 기준). 남은 폭을 다 먹지 않고
  /// 고정폭으로 두는 게 목업 레이아웃이다.
  static const double _desktopSearchBarWidth = 320;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final titleText = Text('랭킹', style: SDSTextStyle.extraBold.copyWith(fontSize: 28, color: SDSColor.gray900));

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop)
          // 데스크탑: 타이틀 + 고정폭 검색창. 기록실/등급표는 우측 사이드바 카드로 간다.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleText,
              const SizedBox(width: SDSSpacing.lg),
              SizedBox(width: _desktopSearchBarWidth, child: _buildSearchBar()),
            ],
          )
        else ...[
          // 태블릿/모바일은 우측 사이드바가 접히므로, 기록실/등급표 진입은
          // 타이틀 줄 오른쪽 끝에 텍스트 링크로 둔다.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleText,
              const SizedBox(width: SDSSpacing.md),
              // 320px급 좁은 화면에서 타이틀 + 링크 두 개가 한 줄에 안 들어갈 수
              // 있다. 오버플로로 깨지는 대신 FittedBox로 조금 줄어들게 둔다.
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: _buildEntryLinks(),
                ),
              ),
            ],
          ),
          const SizedBox(height: SDSSpacing.md),
          _buildSearchBar(),
        ],
        const SizedBox(height: SDSSpacing.lg),
        _buildTabRow(),
        const SizedBox(height: SDSSpacing.md),
        _buildDailyTabBar(),
        const SizedBox(height: SDSSpacing.lg),
        // 아래 여백은 카드 안(margin)에 있어서, 카드가 숨겨지면 여백도 같이 사라진다.
        _tab == _RankingTab.individual ? _buildMyRankingCard() : _buildMyCrewRankingCard(),
        _tab == _RankingTab.individual ? _buildIndivList() : _buildCrewList(),
      ],
    );

    return Container(
      color: SDSColor.snowliveWhite,
      padding: EdgeInsets.fromLTRB(isDesktop ? SDSSpacing.xl : SDSSpacing.md, 32, isDesktop ? SDSSpacing.xl : SDSSpacing.md, SDSSpacing.xl),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kRankingContentMaxWidth),
            // 데스크탑에서만 우측 열을 붙인다(중고거래 홈과 동일한 구조).
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: content),
                      const RankingSidebarWeb(),
                    ],
                  )
                : content,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: SDSColor.gray400),
          const SizedBox(width: 8),
          Expanded(
            // TODO: 백엔드가 랭킹 검색을 지원하면 활성화한다.
            // 현재 list-indiv/list-crew는 search/q/display_name 등 어떤 검색 파라미터도
            // 무시해서(검색어와 무관하게 동일한 전체 목록 반환) 서버 검색이 불가능하다.
            // 한 페이지(30명) 안에서만 거르면 전체 4천여 명 중 대부분이 안 잡혀
            // 사실상 동작하지 않는 것처럼 보이므로, 그때까지 입력을 막아둔다.
            // 파라미터가 생기면 enabled/onChanged만 되살리면 아래 하이라이트 로직이 그대로 동작한다.
            child: TextField(
              controller: _searchController,
              enabled: false,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: '닉네임 검색 준비 중',
                hintStyle: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400),
              ),
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
          ),
        ],
      ),
    );
  }

  /// "랭킹 기록실 | 랭킹 등급표 안내" 진입 링크. 태블릿/모바일에서 타이틀 줄
  /// 오른쪽 끝에 붙는다(데스크탑은 대신 우측 사이드바 카드로 노출).
  Widget _buildEntryLinks() {
    return Row(
      children: [
        _EntryLink(label: '랭킹 기록실', onTap: () => Get.toNamed(WebRoutes.rankingArchive)),
        const SizedBox(width: 12),
        Text('|', style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray200)),
        const SizedBox(width: 12),
        _EntryLink(label: '랭킹 등급표 안내', onTap: () => showRankingTierGuide(context)),
      ],
    );
  }

  String _tabLabel(_RankingTab tab) => tab == _RankingTab.crew ? '크루랭킹' : '개인랭킹';

  void _selectTab(_RankingTab tab) => setState(() {
        _tab = tab;
        _reload();
      });

  /// 크루/개인 탭 + 스키장/리그 필터 pill을 한 줄에 둔다(목업).
  Widget _buildTabRow() {
    final isMobile = context.screenType == WebScreenType.mobile;

    return Row(
      children: [
        // 모바일은 두 탭 + pill 두 개를 한 줄에 넣을 폭이 안 나온다 →
        // 목업대로 현재 탭만 보여주는 드롭다운으로 접는다(pill과 같은 시트 UI 재사용).
        if (isMobile)
          InkWell(
            onTap: () => showFleamarketFilterSheet<_RankingTab>(
              context,
              values: const [_RankingTab.crew, _RankingTab.individual],
              labelOf: _tabLabel,
              onSelected: _selectTab,
            ),
            child: Row(
              children: [
                Text(_tabLabel(_tab), style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900)),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 18, color: SDSColor.gray900),
              ],
            ),
          )
        else ...[
          _ToggleTab(
            label: _tabLabel(_RankingTab.crew),
            isActive: _tab == _RankingTab.crew,
            onTap: () => _selectTab(_RankingTab.crew),
          ),
          const SizedBox(width: 12),
          Text('|', style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray200)),
          const SizedBox(width: 12),
          _ToggleTab(
            label: _tabLabel(_RankingTab.individual),
            isActive: _tab == _RankingTab.individual,
            onTap: () => _selectTab(_RankingTab.individual),
          ),
        ],
        const Spacer(),
        FleamarketFilterPill(
          label: _selectedResort.korean,
          isActive: _selectedResort != RankingFilter_resort.total,
          onTap: () => showFleamarketFilterSheet<RankingFilter_resort>(
            context,
            values: [RankingFilter_resort.total, ...kRankingSelectableResorts],
            labelOf: (v) => v == RankingFilter_resort.total ? '전체 스키장' : v.korean,
            onSelected: (v) => setState(() {
              _selectedResort = v;
              _selectedFed = RankingFilter_fed.initial;
              _reload();
            }),
          ),
        ),
        const SizedBox(width: SDSSpacing.sm),
        FleamarketFilterPill(
          label: _selectedFed == RankingFilter_fed.initial ? '대학 리그' : _selectedFed.korean,
          isActive: _selectedFed != RankingFilter_fed.initial,
          onTap: () => showFleamarketFilterSheet<RankingFilter_fed>(
            context,
            values: kRankingSelectableFeds,
            labelOf: (v) => v.korean,
            onSelected: (v) => setState(() {
              _selectedFed = v;
              _selectedResort = RankingFilter_resort.total;
              _reload();
            }),
          ),
        ),
      ],
    );
  }

  /// 누적/일간 — 목업대로 콘텐츠 폭을 반씩 나눠 갖는 밑줄 탭바.
  Widget _buildDailyTabBar() {
    return Row(
      children: [
        Expanded(
          child: _SegmentTab(label: '누적', isActive: !_daily, onTap: () => setState(() { _daily = false; _reload(); })),
        ),
        Expanded(
          child: _SegmentTab(label: '일간', isActive: _daily, onTap: () => setState(() { _daily = true; _reload(); })),
        ),
      ],
    );
  }

  Widget _buildMyRankingCard() {
    return Obx(() {
      final my = _vm.myRankingInfo;
      if (my == null) {
        // 로그인 상태인데 아직 데이터가 안 왔을 뿐이면, 카드가 나중에 나타나며 아래
        // 리스트를 통째로 밀어낸다. 같은 높이의 자리표시로 공간을 먼저 잡아둔다.
        // 게스트는 카드가 아예 없는 게 확정이므로 바로 접는다(불필요한 자리 차지 방지).
        final isGuest = _authVm.status == WebAuthStatus.unauthenticated;
        if (!isGuest && _vm.isLoading) return const MyRankingCardSkeleton();
        return const SizedBox.shrink();
      }
      final isResortScoped = _selectedResort != RankingFilter_resort.total;
      final isMobile = context.screenType == WebScreenType.mobile;

      return _MyRankingCardShell(
        label: '내 랭킹',
        isMobile: isMobile,
        groups: [
          _MyRankingStat(label: '개인 점수', value: '${isResortScoped ? my.resortTotalScore : my.overallTotalScore}', stacked: isMobile),
          _MyRankingStat(label: '개인 랭킹', value: '${isResortScoped ? my.resortRank : my.overallRank}', stacked: isMobile),
          // 리조트별/일간에는 티어가 오지 않으므로 그때만 그룹을 뺀다.
          if (!isResortScoped && !_daily)
            _TierBadge(
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
      // 로그인 여부를 Obx 바깥에서 검사하면 로그인 확정 시점에 다시 그려지지 않아서
      // 카드가 계속 안 뜬다. 소속 크루가 없으면 뷰모델이 null로 정규화해주므로
      // 여기서는 데이터 유무만 보고 판단한다(크루 없으면 영역 자체가 숨겨짐).
      final my = _crewVm.myCrewRankingInfo;
      if (my == null) {
        // 개인랭킹 카드와 동일: 로딩 중이면 같은 높이로 자리를 잡아 리스트가 밀리지 않게 한다.
        final isGuest = _authVm.status == WebAuthStatus.unauthenticated;
        if (!isGuest && _crewVm.isLoading) return const MyRankingCardSkeleton();
        return const SizedBox.shrink();
      }
      final isResortScoped = _selectedResort != RankingFilter_resort.total;
      final isMobile = context.screenType == WebScreenType.mobile;

      return _MyRankingCardShell(
        label: '크루 랭킹',
        isMobile: isMobile,
        groups: [
          _MyRankingStat(label: '크루 점수', value: '${isResortScoped ? my.resortTotalScore : my.overallTotalScore}', stacked: isMobile),
          _MyRankingStat(label: '크루 랭킹', value: '${isResortScoped ? my.resortRank : my.overallRank}', stacked: isMobile),
          _CrewIdentity(
            name: my.crewName ?? '',
            logoUrl: my.crewLogoUrl,
            stacked: isMobile,
            // 웹에는 아직 크루 상세 화면이 없다(GNB의 '라이브크루'도 플레이스홀더).
            // 목업의 화살표 버튼은 그대로 두고, 화면이 생기면 여기만 라우팅으로 바꾼다.
            onTap: () => Get.snackbar('알림', '크루 화면은 준비 중이에요.'),
          ),
        ],
      );
    });
  }

  Widget _buildIndivList() {
    return Obx(() {
      final items = _vm.items;
      final isLoading = _vm.isLoading;

      if (isLoading && items.isEmpty) {
        return const RankingListSkeleton();
      }
      if (items.isEmpty) {
        return const WebEmptyState(message: '랭킹 데이터가 없습니다.');
      }

      final half = (items.length / 2).ceil();
      final left = items.sublist(0, half);
      final right = items.sublist(half);

      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: [for (final u in left) _buildIndivRow(u)])),
              const SizedBox(width: SDSSpacing.xl),
              Expanded(child: Column(children: [for (final u in right) _buildIndivRow(u)])),
            ],
          ),
          const SizedBox(height: SDSSpacing.lg),
          NumberedPaginationBar(
            currentPage: _vm.currentPage,
            totalPages: _vm.totalPages,
            hasPrevious: _vm.hasPrevious,
            hasNext: _vm.hasNext,
            pageWindow: _vm.pageWindow(),
            onGotoPage: (page) => _vm.gotoPage(page),
          ),
        ],
      );
    });
  }

  Widget _buildCrewList() {
    return Obx(() {
      final items = _crewVm.items;
      final isLoading = _crewVm.isLoading;

      if (isLoading && items.isEmpty) {
        return const RankingListSkeleton();
      }
      if (items.isEmpty) {
        return const WebEmptyState(message: '랭킹 데이터가 없습니다.');
      }

      final half = (items.length / 2).ceil();
      final left = items.sublist(0, half);
      final right = items.sublist(half);

      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: [for (final c in left) _buildCrewRow(c)])),
              const SizedBox(width: SDSSpacing.xl),
              Expanded(child: Column(children: [for (final c in right) _buildCrewRow(c)])),
            ],
          ),
          const SizedBox(height: SDSSpacing.lg),
          NumberedPaginationBar(
            currentPage: _crewVm.currentPage,
            totalPages: _crewVm.totalPages,
            hasPrevious: _crewVm.hasPrevious,
            hasNext: _crewVm.hasNext,
            pageWindow: _crewVm.pageWindow(),
            onGotoPage: (page) => _crewVm.gotoPage(page),
          ),
        ],
      );
    });
  }

  Widget _buildIndivRow(RankingUser user) {
    final isResortScoped = _selectedResort != RankingFilter_resort.total;
    return Obx(() {
      final query = _searchQuery.value;
      final isHighlighted = query.isNotEmpty && (user.displayName?.contains(query) ?? false);
      return InkWell(
        onTap: () => showRankingProfileModal(context, user),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isHighlighted ? SDSColor.blue50 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  '${isResortScoped ? user.resortRank ?? '' : user.overallRank ?? ''}',
                  style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                ),
              ),
              const SizedBox(width: 8),
              ClipOval(
                child: (user.profileImageUrlUser?.isNotEmpty ?? false)
                    ? WebNetworkImage(url: user.profileImageUrlUser, width: 32, height: 32)
                    : Container(width: 32, height: 32, color: SDSColor.gray100, child: Icon(Icons.person, size: 18, color: SDSColor.gray400)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName ?? '', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900)),
                    Text(
                      [
                        if (user.resortNickname?.isNotEmpty ?? false) user.resortNickname,
                        if (user.crewName?.isNotEmpty ?? false) user.crewName,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
                    ),
                  ],
                ),
              ),
              Text(
                '${isResortScoped ? user.resortTotalScore ?? 0 : user.overallTotalScore ?? 0}점',
                style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
              ),
              if (!isResortScoped && !_daily && (user.overallTierIconUrl?.isNotEmpty ?? false)) ...[
                const SizedBox(width: 6),
                WebNetworkImage(url: user.overallTierIconUrl, width: 24, height: 24, fit: BoxFit.contain),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCrewRow(CrewRanking crew) {
    final isResortScoped = _selectedResort != RankingFilter_resort.total;
    final logoUrl = (crew.crewLogoUrl?.isNotEmpty ?? false) ? crew.crewLogoUrl : crewDefaultLogoUrl[crew.color ?? ''];
    final hasTierIcon = !isResortScoped && !_daily && (crew.overallTierIconUrl?.isNotEmpty ?? false);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${isResortScoped ? crew.resortRank ?? '' : crew.overallRank ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (logoUrl?.isNotEmpty ?? false)
                ? WebNetworkImage(url: logoUrl, width: 32, height: 32)
                : Container(width: 32, height: 32, color: SDSColor.gray100),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              crew.crewName ?? '',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              '${isResortScoped ? crew.resortTotalScore ?? 0 : crew.overallTotalScore ?? 0}점',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
            ),
          ),
          if (hasTierIcon) ...[
            const SizedBox(width: 6),
            WebNetworkImage(url: crew.overallTierIconUrl, width: 24, height: 24, fit: BoxFit.contain),
          ],
        ],
      ),
    );
  }
}

/// 타이틀 줄 오른쪽 끝에 붙는 진입 링크(태블릿/모바일). 아이콘 없이 텍스트만 두고,
/// 두 링크 사이는 탭 줄과 같은 '|' 구분자로 나눈다.
class _EntryLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _EntryLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(label, style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleTab({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: (isActive ? SDSTextStyle.bold : SDSTextStyle.regular).copyWith(
          fontSize: 15,
          color: isActive ? SDSColor.gray900 : SDSColor.gray300,
        ),
      ),
    );
  }
}

/// 내 랭킹/내 크루 랭킹 카드의 공통 껍데기.
///
/// 데스크탑·태블릿은 왼쪽에 카드 라벨을 두고 정보 그룹을 오른쪽 끝에 몰아 붙이고,
/// 모바일은 라벨을 빼고 그룹들이 카드 폭을 균등하게 나눠 갖는다(목업).
class _MyRankingCardShell extends StatelessWidget {
  final String label;
  final bool isMobile;
  final List<Widget> groups;

  const _MyRankingCardShell({required this.label, required this.isMobile, required this.groups});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 카드가 숨겨질 때 아래 여백까지 같이 사라지도록 간격을 카드 안에 둔다.
      margin: const EdgeInsets.only(bottom: SDSSpacing.xl),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 16),
      decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          if (!isMobile) ...[
            Text(label, style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
            const Spacer(),
          ],
          for (var i = 0; i < groups.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 32,
                color: SDSColor.gray200,
                margin: EdgeInsets.symmetric(horizontal: isMobile ? SDSSpacing.sm : SDSSpacing.lg),
              ),
            isMobile ? Expanded(child: groups[i]) : groups[i],
          ],
        ],
      ),
    );
  }
}

class _MyRankingStat extends StatelessWidget {
  final String label;
  final String value;

  /// 모바일: 값 위 / 라벨 아래로 쌓는다. 그 외: 라벨 왼쪽 / 값 오른쪽 한 줄.
  final bool stacked;

  const _MyRankingStat({required this.label, required this.value, this.stacked = false});

  @override
  Widget build(BuildContext context) {
    final labelText = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: SDSTextStyle.regular.copyWith(fontSize: stacked ? 12 : 13, color: SDSColor.gray500),
    );
    final valueText = Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: SDSTextStyle.bold.copyWith(fontSize: stacked ? 17 : 15, color: SDSColor.gray900),
    );

    if (stacked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [valueText, const SizedBox(height: 2), labelText],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [labelText, const SizedBox(width: 8), valueText],
    );
  }
}

/// 티어 아이콘 + 티어명 그룹(개인랭킹 카드).
class _TierBadge extends StatelessWidget {
  final String? iconUrl;
  final String name;
  final bool stacked;

  const _TierBadge({required this.iconUrl, required this.name, required this.stacked});

  @override
  Widget build(BuildContext context) {
    final hasIcon = iconUrl?.isNotEmpty ?? false;
    final nameText = Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: SDSTextStyle.bold.copyWith(fontSize: stacked ? 13 : 14, color: SDSColor.gray900),
    );

    if (stacked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasIcon) WebNetworkImage(url: iconUrl, width: 24, height: 24, fit: BoxFit.contain),
          if (hasIcon) const SizedBox(height: 2),
          nameText,
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasIcon) ...[
          WebNetworkImage(url: iconUrl, width: 28, height: 28, fit: BoxFit.contain),
          const SizedBox(width: 8),
        ],
        nameText,
      ],
    );
  }
}

/// 크루명 + 크루 로고 + 크루 화면 진입 버튼 그룹(크루랭킹 카드).
class _CrewIdentity extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final bool stacked;
  final VoidCallback onTap;

  const _CrewIdentity({required this.name, required this.logoUrl, required this.stacked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final logo = (logoUrl?.isNotEmpty ?? false)
        ? WebNetworkImage(url: logoUrl, width: stacked ? 24 : 28, height: stacked ? 24 : 28, fit: BoxFit.contain)
        : Icon(Icons.groups_outlined, size: stacked ? 22 : 26, color: SDSColor.gray400);
    final nameText = Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: SDSTextStyle.bold.copyWith(fontSize: stacked ? 13 : 14, color: SDSColor.gray900),
    );

    if (stacked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo,
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: nameText),
              const SizedBox(width: 4),
              _CircleArrowButton(onTap: onTap),
            ],
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        nameText,
        const SizedBox(width: 8),
        logo,
        const SizedBox(width: 8),
        _CircleArrowButton(onTap: onTap),
      ],
    );
  }
}

class _CircleArrowButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CircleArrowButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.gray900,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(3),
          child: Icon(Icons.chevron_right, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

/// 누적/일간 밑줄 탭. 비활성 쪽에도 같은 자리에 연한 선을 깔아 밑줄이 끊기지 않게 한다.
class _SegmentTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentTab({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: (isActive ? SDSTextStyle.bold : SDSTextStyle.regular)
                  .copyWith(fontSize: 15, color: isActive ? SDSColor.gray900 : SDSColor.gray300),
            ),
          ),
          // 두 탭의 선 두께가 달라도 아래쪽 끝이 맞도록 같은 높이의 띠 안에서 정렬한다.
          SizedBox(
            height: 3,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: isActive ? 3 : 1,
                color: isActive ? SDSColor.gray900 : SDSColor.gray200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
