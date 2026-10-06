import 'dart:math' as math;

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_rankingListCrew.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList.dart' show RankingFilter_resort, RankingFilter_fed;
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_filter_sheet_web.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ranking_profile_modal_web.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_crew_modal_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ranking_my_card_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ranking_sidebar_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ranking_tier_guide_web.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingList_web.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingListCrew_web.dart';
import 'package:com.snowlive/web/widget/w_numbered_pagination_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_text_tabs_web.dart';
import 'package:com.snowlive/web/widget/w_web_sticky_footer_scroll_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 랭킹 목록 열 폭. 한 명씩 순서대로 읽히도록 목록은 1열로 두고, 한 줄이 너무 길어지지
/// 않게 폭을 묶는다.
const double kRankingListMaxWidth = 700;

/// 목록 + 간격 + 우측 사이드바를 합친 데스크탑 블록 폭.
const double kRankingContentMaxWidth =
    kRankingListMaxWidth + kWebSidebarGap + kWebSidebarWidth;

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

/// 순위 숫자 칸 폭. 고정폭으로 두면 한 자리 순위에선 여백이 뜨고 네 자리(1000위~)에선
/// 글줄이 넘어간다. 한 페이지의 순위는 연속 구간이라 **가장 큰 순위 하나만 실제로 재서**
/// 그 폭으로 칸을 통일한다 — 이름 줄의 세로 정렬은 유지되고 남는 여백만 사라진다.
double rankColumnWidth(BuildContext context, Iterable<int?> ranks) {
  var widest = 0;
  for (final rank in ranks) {
    if ((rank ?? 0) > widest) widest = rank!;
  }
  final painter = TextPainter(
    text: TextSpan(
      text: '$widest',
      style: SDSTextStyle.bold.copyWith(fontSize: 14),
    ),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  // 한 자리만 있는 페이지에서도 숫자가 답답해 보이지 않게 최소폭을 둔다.
  return math.max(painter.width, 16);
}

const List<RankingFilter_fed> kRankingSelectableFeds = [RankingFilter_fed.univ_ski, RankingFilter_fed.univ_board];

/// 랭킹 크루 → 크루 미리보기 팝업이 받는 [CrewCard].
///
/// 랭킹 응답에는 **멤버 수·베이스 리조트 id가 없어서** 팝업의 `N명` 줄은 비고 부제는
/// 리조트 별명으로 채워진다(추가 조회 없이 보여줄 수 있는 범위 — 슬로프크래프트의
/// `slopeCrewToCard`와 같은 판단).
CrewCard rankingCrewToCard(CrewRanking crew) => CrewCard(
      crewId: crew.crewId,
      crewName: crew.crewName,
      crewLogoUrl: crew.crewLogoUrl,
      color: crew.color,
      description: crew.description,
      baseResortNickname: crew.baseResortNickname,
    );

/// 누적/일간 바 높이 — 상단 9 + 텍스트 22 + 간격 8 + 밑줄 2.
const double _kDailyTabBarHeight = 41;

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

  /// 첫 화면에 보이는 프로필/크루 로고를 미리 받는 중. 이 동안에는 목록 대신
  /// 스켈레톤을 유지한다(라이브톡 첫 로딩과 같은 방식).
  bool _warmingImages = false;

  /// 미리 받아둘 이미지 수 — 첫 화면에 보이는 만큼만. 30개를 다 기다리면 너무 길다.
  static const int _kWarmUpImageCount = 10;

  /// 이미지가 느리면 기다리지 않고 목록을 보여준다(멈춘 것처럼 보이지 않게).
  static const Duration _kWarmUpTimeout = Duration(seconds: 1);

  void _reload() => _reloadAndWarm();

  Future<void> _reloadAndWarm() async {
    final q = _searchQuery.value.trim();
    final sq = q.isEmpty ? null : q;
    if (mounted) setState(() => _warmingImages = true);
    if (_tab == _RankingTab.individual) {
      await _vm.loadFirstPage(resortId: _resortId, federation: _federation, daily: _daily, searchQuery: sq);
    } else {
      await _crewVm.loadFirstPage(
          userId: _userVm.user.user_id, resortId: _resortId, federation: _federation, daily: _daily, searchQuery: sq);
    }
    await _warmUpImages();
  }

  /// 페이지 이동도 같은 흐름을 탄다 — 새 페이지의 이미지가 뒤늦게 들어차지 않게.
  Future<void> _gotoPageAndWarm(int page) async {
    if (mounted) setState(() => _warmingImages = true);
    if (_tab == _RankingTab.individual) {
      await _vm.gotoPage(page);
    } else {
      await _crewVm.gotoPage(page);
    }
    await _warmUpImages();
  }

  Future<void> _warmUpImages() async {
    if (!mounted) return;
    final urls = <String>{
      if (_tab == _RankingTab.individual)
        for (final u in _vm.items.take(_kWarmUpImageCount))
          ...[
            if (u.profileImageUrlUser?.isNotEmpty ?? false) u.profileImageUrlUser!,
            if (u.overallTierIconUrl?.isNotEmpty ?? false) u.overallTierIconUrl!,
          ]
      else
        for (final c in _crewVm.items.take(_kWarmUpImageCount))
          if (c.crewLogoUrl?.isNotEmpty ?? false) c.crewLogoUrl!,
    };
    if (urls.isNotEmpty) {
      await Future.wait(
        // 한 장이 404·CORS로 실패해도 나머지를 막지 않는다.
        urls.map((url) => precacheImage(NetworkImage(url), context).catchError((_) {})),
      ).timeout(_kWarmUpTimeout, onTimeout: () => const <void>[]);
    }
    if (mounted) setState(() => _warmingImages = false);
  }

  /// 데스크탑에서 타이틀 오른쪽에 붙는 검색창 폭(목업 기준). 남은 폭을 다 먹지 않고
  /// 고정폭으로 두는 게 목업 레이아웃이다.
  static const double _desktopSearchBarWidth = 320;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    // 홈 타이틀 공통: PC 32 / 태블릿·모바일 24 (중고거래 홈 기준).
    final titleText = Text('랭킹',
        style: SDSTextStyle.extraBold.copyWith(
            fontSize: webHomeTitleSize(context), color: SDSColor.gray900));

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop)
          // 데스크탑: 타이틀 + 고정폭 검색창. 기록실/등급표는 우측 사이드바 카드로 간다.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleText,
              // 타이틀 ↔ 검색바 36 (커뮤니티 홈과 동일).
              const SizedBox(width: 36),
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
        // 타이틀·검색 영역 ↔ 필터 줄: PC 30 / 태블릿 24 / 모바일 20 (홈 목록 공통).
        SizedBox(height: webTitleToFilterGap(context)),
        _buildTabRow(),
        // 탭·필터 줄 ↔ 누적/일간 16 (랭킹 목업 — 커뮤니티의 '필터↔목록 20'과는
        // 아래에 오는 요소가 달라서 별도 값으로 둔다).
        const SizedBox(height: 16),
        _buildDailyTabBarSlot(),
        // 누적/일간 ↔ 내 랭킹 카드 30.
        const SizedBox(height: 30),
        // 아래 여백은 카드 안(margin)에 있어서, 카드가 숨겨지면 여백도 같이 사라진다.
        _tab == _RankingTab.individual ? _buildMyRankingCard() : _buildMyCrewRankingCard(),
        _tab == _RankingTab.individual ? _buildIndivList() : _buildCrewList(),
      ],
    );

    // 콘텐츠가 짧으면 푸터가 뷰포트 하단에 붙는다(공통 골격). 여백은 스크롤
    // 영역 안쪽에 둔다(웹 공통 규칙 — 바깥에 두면 스크롤바가 브라우저 끝에 안 붙는다).
    return Container(
      color: SDSColor.snowliveWhite,
      child: WebStickyFooterScroll(
        // 홈 공통 여백(중고거래 홈 기준).
        padding: webHomePagePadding(context),
        content: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kRankingContentMaxWidth),
            // 데스크탑에서만 우측 열을 붙인다(중고거래 홈과 동일한 구조).
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: content),
                      // 목록 ↔ 사이드바 간격 40 (중고거래 홈과 동일).
                      const SizedBox(width: kWebSidebarGap),
                      const RankingSidebarWeb(),
                    ],
                  )
                : content,
          ),
        ),
        // 페이지네이션은 푸터 블록에 둔다 — 목록이 짧아도 화면 아래쪽에 머물고,
        // 길면 목록 바로 뒤에 자연스럽게 이어진다(스티키 푸터 골격이 그렇게 민다).
        footer: Column(
          children: [
            const SizedBox(height: SDSSpacing.lg),
            // 푸터 블록은 페이지 전체 폭이라 그냥 두면 페이지 한가운데에 온다 →
            // 목록은 [목록 + 간격 + 사이드바] 블록의 왼쪽에 있어서 오른쪽으로
            // 치우쳐 보인다. 같은 블록으로 묶고 사이드바 몫을 비워 목록 기준
            // 가운데에 오게 한다.
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kRankingContentMaxWidth),
                child: Row(
                  children: [
                    Expanded(child: _buildPagination()),
                    if (isDesktop)
                      const SizedBox(width: kWebSidebarGap + kWebSidebarWidth),
                  ],
                ),
              ),
            ),
            SizedBox(height: webFooterTopGap(context)),
            const HomeFooterWeb(),
          ],
        ),
      ),
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
            // onChanged로 검색어를 담아 결과 하이라이트에 쓰고, 제출(엔터) 시 서버 재조회한다.
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
        if (isMobile)
          // 모바일은 두 탭 + pill 두 개를 한 줄에 넣을 폭이 안 나온다 →
          // 현재 탭만 보여주는 드롭다운으로 접는다(커뮤니티 카테고리 탭과 동일).
          WebDropdownTextButton<_RankingTab>(
            label: _tabLabel(_tab),
            values: const [_RankingTab.individual, _RankingTab.crew],
            labelOf: _tabLabel,
            onSelected: _selectTab,
            labelStyle: SDSTextStyle.bold.copyWith(
              fontSize: 15,
              color: SDSColor.gray900,
            ),
          )
        else
          // 탭 표준(피그마 64:112870) — bold 16, 비활성 gray200,
          // 1px 세로선 구분자, 간격 10 (커뮤니티·각종소식과 동일).
          ...WebTextTabs<_RankingTab>(
            values: const [_RankingTab.individual, _RankingTab.crew],
            selected: _tab,
            labelOf: _tabLabel,
            onSelected: _selectTab,
            fontSize: 16,
            inactiveBold: true,
            inactiveColor: SDSColor.gray200,
            lineDivider: true,
            dividerGap: 10,
          ).buildChildren(),
        const Spacer(),
        FleamarketFilterPill<RankingFilter_resort>(
          label: _selectedResort.korean,
          isActive: _selectedResort != RankingFilter_resort.total,
          title: '스키장',
          // 태블릿도 PC식 앵커 드롭다운(중고거래·커뮤니티·각종소식과 동일 규칙).
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

  /// 누적/일간 — 목업대로 콘텐츠 폭을 반씩 나눠 갖는 밑줄 탭바.
  /// 태블릿·모바일에서 좌우 페이지 여백을 넘어 화면 끝까지 늘린다
  /// (목업 — 태블릿 106:23260 / 모바일 106:31618 모두 풀폭).
  /// 페이지 패딩 안에 있는 위젯이라 OverflowBox로 폭을 되돌려준다.
  /// ⚠️ 높이를 반드시 못 박아야 한다 — Column 안에서는 높이 제약이 무한이라
  /// null로 두면 OverflowBox가 그걸 그대로 받아 자식이 아예 안 그려진다.
  Widget _fullBleedOnTablet(Widget child, {required double height}) {
    if (context.isDesktop) return child;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return SizedBox(
      height: height,
      child: OverflowBox(
        minWidth: screenWidth,
        maxWidth: screenWidth,
        minHeight: height,
        maxHeight: height,
        child: child,
      ),
    );
  }

  Widget _buildDailyTabBarSlot() =>
      _fullBleedOnTablet(_buildDailyTabBar(), height: _kDailyTabBarHeight);

  Widget _buildDailyTabBar() {
    // comp_tab(피그마 106:14937) — 아래 전체 폭 1px 라인 위에 활성 탭의
    // 2px 밑줄이 겹쳐 그려진다. 탭 사이 1px.
    // 높이 41 = 상단 9 + 텍스트 22 + 간격 8 + 밑줄 2.
    return SizedBox(
      height: _kDailyTabBarHeight,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(height: 1, color: SDSColor.gray100),
          ),
          Row(
            children: [
              Expanded(
                child: _SegmentTab(label: '누적', isActive: !_daily, onTap: () => setState(() { _daily = false; _reload(); })),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _SegmentTab(label: '일간', isActive: _daily, onTap: () => setState(() { _daily = true; _reload(); })),
              ),
            ],
          ),
        ],
      ),
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
        if (!isGuest && (_vm.isLoading || !_vm.hasLoadedOnce)) return const MyRankingCardSkeleton();
        return const SizedBox.shrink();
      }
      final isResortScoped = _selectedResort != RankingFilter_resort.total;
      final isMobile = context.screenType == WebScreenType.mobile;

      return RankingMyCardShell(
        label: '내 랭킹',
        isMobile: isMobile,
        groups: [
          // 모바일은 카드 좌측의 '내 랭킹' 라벨이 없어서 통계 라벨이 그 역할을 한다(목업).
          RankingMyStat(
              label: isMobile ? '내 점수' : '개인 점수',
              value: '${isResortScoped ? my.resortTotalScore : my.overallTotalScore}',
              stacked: isMobile),
          RankingMyStat(
              label: isMobile ? '내 랭킹' : '개인 랭킹',
              value: '${isResortScoped ? my.resortRank : my.overallRank}',
              stacked: isMobile),
          // 리조트별/일간에는 티어가 오지 않으므로 그때만 그룹을 뺀다.
          if (!isResortScoped && !_daily)
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
      // 로그인 여부를 Obx 바깥에서 검사하면 로그인 확정 시점에 다시 그려지지 않아서
      // 카드가 계속 안 뜬다. 소속 크루가 없으면 뷰모델이 null로 정규화해주므로
      // 여기서는 데이터 유무만 보고 판단한다(크루 없으면 영역 자체가 숨겨짐).
      final my = _crewVm.myCrewRankingInfo;
      if (my == null) {
        // 개인랭킹 카드와 동일: 로딩 중이면 같은 높이로 자리를 잡아 리스트가 밀리지 않게 한다.
        final isGuest = _authVm.status == WebAuthStatus.unauthenticated;
        if (!isGuest && (_crewVm.isLoading || !_crewVm.hasLoadedOnce)) return const MyRankingCardSkeleton();
        return const SizedBox.shrink();
      }
      final isResortScoped = _selectedResort != RankingFilter_resort.total;
      final isMobile = context.screenType == WebScreenType.mobile;

      return RankingMyCardShell(
        label: '크루 랭킹',
        isMobile: isMobile,
        groups: [
          RankingMyStat(label: '크루 점수', value: '${isResortScoped ? my.resortTotalScore : my.overallTotalScore}', stacked: isMobile),
          RankingMyStat(label: '크루 랭킹', value: '${isResortScoped ? my.resortRank : my.overallRank}', stacked: isMobile),
          RankingCrewIdentity(
            name: my.crewName ?? '',
            // 로고가 없으면 목록·팝업과 같은 색별 기본 `LIVE CREW` 로고를 쓴다
            // (여기만 사람 아이콘으로 떨어지고 있었다).
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

  /// 현재 탭의 페이지네이션. 조회 중이거나 한 페이지뿐이면 그리지 않는다.
  Widget _buildPagination() {
    return Obx(() {
      final isIndiv = _tab == _RankingTab.individual;
      final loading = (isIndiv ? _vm.isLoading : _crewVm.isLoading) || _warmingImages;
      final totalPages = isIndiv ? _vm.totalPages : _crewVm.totalPages;
      if (loading || totalPages <= 1) return const SizedBox.shrink();
      return NumberedPaginationBar(
        currentPage: isIndiv ? _vm.currentPage : _crewVm.currentPage,
        totalPages: totalPages,
        hasPrevious: isIndiv ? _vm.hasPrevious : _crewVm.hasPrevious,
        hasNext: isIndiv ? _vm.hasNext : _crewVm.hasNext,
        pageWindow: isIndiv ? _vm.pageWindow() : _crewVm.pageWindow(),
        onGotoPage: _gotoPageAndWarm,
      );
    });
  }

  /// 결과 0건. 검색 중이면 **서버에 실제로 보낸** 검색어를 문구에 쓴다
  /// (입력 중인 값을 쓰면 아직 조회하지 않은 글자가 문구에 먼저 나온다).
  Widget _emptyState(String query) => WebEmptyState(
        message: query.isEmpty ? '랭킹 데이터가 없습니다.' : "'$query' 검색 결과가 없어요.",
        // 아이콘은 공용 기본값(icon_nodata.png)을 쓴다 — 랭킹 전용 에셋
        // (icon_ranking_nodata*.png)은 구 디자인 방패라 지금 티어 아이콘과 안 맞는다.
      );

  Widget _buildIndivList() {
    return Obx(() {
      final items = _vm.items;
      final isLoading = _vm.isLoading;

      // 탭·필터·검색·페이지 — 어느 걸 눌러도 서버를 다시 받는 구조라(캐시 없음)
      // 조회 중이면 항상 스켈레톤으로 바꿔 끼운다. 첫 조회 전(hasLoadedOnce=false)도
      // 마찬가지 — 시즌을 먼저 받아오는 구간에는 isLoading이 아직 false여서
      // "데이터 없음"이 먼저 스쳤다.
      if (isLoading || _warmingImages || !_vm.hasLoadedOnce) {
        // 티어는 전체 스키장 + 누적일 때만 나온다 — 스켈레톤도 같은 조건으로
        // 자리를 잡아야 점수 줄이 실제 텍스트와 같은 위치에 온다.
        return RankingListSkeleton(
          showTier: _selectedResort == RankingFilter_resort.total && !_daily,
        );
      }
      if (items.isEmpty) return _emptyState(_vm.appliedQuery);

      final isResortScoped = _selectedResort != RankingFilter_resort.total;
      final rankWidth = rankColumnWidth(
        context,
        items.map((u) => isResortScoped ? u.resortRank : u.overallRank),
      );

      return Column(children: [for (final u in items) _buildIndivRow(u, rankWidth)]);
    });
  }

  Widget _buildCrewList() {
    return Obx(() {
      final items = _crewVm.items;
      final isLoading = _crewVm.isLoading;

      if (isLoading || _warmingImages || !_crewVm.hasLoadedOnce) {
        // 크루 랭킹 행: 로고는 사각, 티어 없음(사양).
        return const RankingListSkeleton(circleAvatar: false, showTier: false, compactText: true);
      }
      if (items.isEmpty) return _emptyState(_crewVm.appliedQuery);

      final isResortScoped = _selectedResort != RankingFilter_resort.total;
      final rankWidth = rankColumnWidth(
        context,
        items.map((c) => isResortScoped ? c.resortRank : c.overallRank),
      );

      return Column(children: [for (final c in items) _buildCrewRow(c, rankWidth)]);
    });
  }

  Widget _buildIndivRow(RankingUser user, double rankWidth) {
    final isResortScoped = _selectedResort != RankingFilter_resort.total;
    final m = RankingRowMetrics.of(context);
    // hover 잉크는 조상 Material 캔버스에 그려진다 — 페이지 흰 배경 Container가
    // 그 위를 덮어 안 보이므로, 행 바로 위에 투명 Material을 끼운다.
    // 행 간격(8)은 잉크 밖으로 빼서 hover 박스가 행 크기에만 맞게 한다.
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => showRankingProfileModal(context, user),
          borderRadius: BorderRadius.circular(8),
          // hover 시 행 배경 검정 3% (커뮤니티·각종소식 표 행과 동일).
          hoverColor: SDSColor.gray900.withValues(alpha: 0.03),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: m.verticalPadding),
            // 높이를 공용 규격으로 못 박는다 — 안 그러면 이름+소속 두 줄의
            // line height가 행 높이를 결정해서 스켈레톤과 어긋난다.
            height: m.boxHeight,
            child: Row(
              children: [
                SizedBox(
                  width: rankWidth,
                  child: Text(
                    '${isResortScoped ? user.resortRank ?? '' : user.overallRank ?? ''}',
                    maxLines: 1,
                    softWrap: false,
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                  ),
                ),
                // 순위 ↔ 프로필 12.
                SizedBox(width: m.rankGap),
                ClipOval(
                  child: (user.profileImageUrlUser?.isNotEmpty ?? false)
                      ? WebNetworkImage(url: user.profileImageUrlUser, width: m.avatar, height: m.avatar)
                      : Container(
                          width: m.avatar,
                          height: m.avatar,
                          color: SDSColor.gray100,
                          child: Icon(Icons.person, size: 18, color: SDSColor.gray400)),
                ),
                SizedBox(width: m.nameGap),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // line height를 묶어야 행 높이가 계산 가능해진다(Pretendard 기본값은 더 크다).
                      Text(user.displayName ?? '',
                          style: SDSTextStyle.regular.copyWith(
                              fontSize: m.nameSize,
                              height: 20 / 15,
                              color: SDSColor.gray900)),
                      Text(
                        [
                          if (user.resortNickname?.isNotEmpty ?? false) user.resortNickname,
                          if (user.crewName?.isNotEmpty ?? false) user.crewName,
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SDSTextStyle.regular.copyWith(
                            fontSize: m.subSize, height: 17 / 13, color: SDSColor.gray500),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isResortScoped ? user.resortTotalScore ?? 0 : user.overallTotalScore ?? 0}점',
                  style: SDSTextStyle.regular
                      .copyWith(fontSize: m.scoreSize, color: SDSColor.gray900),
                ),
                if (!isResortScoped && !_daily && (user.overallTierIconUrl?.isNotEmpty ?? false)) ...[
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

  Widget _buildCrewRow(CrewRanking crew, double rankWidth) {
    final isResortScoped = _selectedResort != RankingFilter_resort.total;
    final m = RankingRowMetrics.of(context);
    // 로고가 없으면 색별 기본 `LIVE CREW` 로고, 색도 없으면 회색 기본으로 떨어진다.
    final logoUrl = crewLogoUrlOf(logoUrl: crew.crewLogoUrl, color: crew.color);
    // 크루랭킹에는 티어를 표시하지 않는다(개인랭킹만 티어 노출).
    // 크루명 아래 회색 보조줄: 베이스 스키장 별명 · 크루 소개글 (모바일과 동일).
    final baseNick = crew.baseResortNickname?.trim() ?? '';
    final crewDesc = crew.description?.trim() ?? '';
    final crewSubtitle = baseNick.isEmpty
        ? crewDesc
        : (crewDesc.isEmpty ? baseNick : '$baseNick · $crewDesc');
    final crewId = crew.crewId;
    // 개인 행과 같은 구조 — 투명 Material 위의 InkWell이라야 hover 잉크가 보이고,
    // 행 간격(8)은 잉크 밖으로 빼야 hover 박스가 행 크기에만 맞는다.
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: crewId == null
              ? null
              : () => showLiveCrewModal(context, rankingCrewToCard(crew)),
          borderRadius: BorderRadius.circular(8),
          hoverColor: SDSColor.gray900.withValues(alpha: 0.03),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: m.verticalPadding),
            // 개인 행과 같은 높이 — 탭을 바꿔도, 스켈레톤에서 넘어와도 목록이 안 튄다.
            height: m.boxHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: rankWidth,
                  child: Text(
                    '${isResortScoped ? crew.resortRank ?? '' : crew.overallRank ?? ''}',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        crew.crewName ?? '',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: SDSTextStyle.regular
                            .copyWith(fontSize: 14, height: 19 / 14, color: SDSColor.gray900),
                      ),
                      // ⚠️ 줄 사이에 따로 여백을 주지 않는다 — line height(19 + 16)만으로
                      // 모바일 행 내용 높이(36)에 딱 맞는다. 2라도 더하면 넘친다.
                      if (crewSubtitle.isNotEmpty)
                        Text(
                          crewSubtitle,
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
                    '${isResortScoped ? crew.resortTotalScore ?? 0 : crew.overallTotalScore ?? 0}점',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
                  ),
                ),
              ],
            ),
                ),
              ),
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

      /// 내 랭킹/내 크루 랭킹 카드의 공통 껍데기.
      ///

      /// 누적/일간 밑줄 탭. 비활성 쪽에도 같은 자리에 연한 선을 깔아 밑줄이 끊기지 않게 한다.
      class _SegmentTab extends StatefulWidget {
        final String label;
        final bool isActive;
        final VoidCallback onTap;

        const _SegmentTab({required this.label, required this.isActive, required this.onTap});

        @override
        State<_SegmentTab> createState() => _SegmentTabState();
      }

      class _SegmentTabState extends State<_SegmentTab> {
        bool _hovered = false;

        @override
        Widget build(BuildContext context) {
          // 활성은 검정 고정. 비활성만 hover 시 20% → 35%로 아주 살짝 진해진다
          // (공용 텍스트 탭과 같은 120ms 전환·클릭 커서).
          final color = widget.isActive
              ? SDSColor.gray900
              : SDSColor.gray900.withValues(alpha: _hovered ? 0.35 : 0.2);

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              onTap: widget.onTap,
              // 투명 영역도 눌리게 — 글자 밖 여백까지 탭 범위다.
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 9),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 120),
                      // line height 22는 글자 크기와 무관하게 묶는다 — 안 묶으면
                      // Pretendard가 알아서 잡아 바 높이가 흔들린다.
                      style: (widget.isActive ? SDSTextStyle.extraBold : SDSTextStyle.regular)
                          .copyWith(fontSize: 15, height: 22 / 15, color: color),
                      child: Text(widget.label, textAlign: TextAlign.center),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 2, color: widget.isActive ? SDSColor.gray900 : Colors.transparent),
                ],
              ),
      ),
    );
  }
}
