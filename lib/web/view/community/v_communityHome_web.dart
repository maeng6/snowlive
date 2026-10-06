import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/community/w_community_header_web.dart';
import 'package:com.snowlive/web/view/community/w_community_list_web.dart';
import 'package:com.snowlive/web/view/community/w_community_sidebar_web.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart' show HomeFooterWeb;
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityListPagination_web.dart';
import 'package:com.snowlive/web/widget/w_web_floating_bottombar_web.dart';
import 'package:com.snowlive/web/widget/w_web_sticky_footer_scroll_web.dart';
import 'package:com.snowlive/web/widget/w_web_sticky_sidebar_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// "목록 영역 + 우측 열" 블록 폭 = 목록 1280(웹 공통) + 간격 40 + 우측 열 220.
/// 중고거래 홈 블록과 동일한 1540이라, 넓은 화면에서 두 화면의 타이틀
/// 좌측 여백이 정확히 맞는다(피그마의 246 대신 웹 공통 사이드바 폭 — 사용자 결정).
const double kCommunityContentMaxWidth = kWebDesktopListMaxWidth + 40 + kWebSidebarWidth;

/// 사이드바(게시글 올리기 버튼)가 필터 줄과 같은 높이에서 시작하도록 내리는 값
/// (피그마 64:112373 — 타이틀 40 + 타이틀↔필터 줄 19).
const double _kCommunitySidebarTopOffset = 59;

/// 웹 커뮤니티 목록 화면.
class CommunityHomeViewWeb extends StatefulWidget {
  const CommunityHomeViewWeb({super.key});

  @override
  State<CommunityHomeViewWeb> createState() => _CommunityHomeViewWebState();
}

class _CommunityHomeViewWebState extends State<CommunityHomeViewWeb> {
  final CommunityListPaginationViewModelWeb _vm = Get.find<CommunityListPaginationViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final AuthCheckViewModelWeb _authVm = Get.find<AuthCheckViewModelWeb>();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  /// 사이드바를 스크롤에 맞춰 상단에 붙이려면 페이지 스크롤을 직접 잡아야 한다.
  final ScrollController _scrollController = ScrollController();

  CommunityCategoryTab _tab = CommunityCategoryTab.total;
  CommunitySearchScope _scope = CommunitySearchScope.titleContent;
  CommunitySortOption _sort = CommunitySortOption.latest;

  Worker? _authWorker;

  @override
  void initState() {
    super.initState();
    // 뷰모델 onInit에서 조회하지 않는다(중복 요청 방지) — 최초 조회는 여기서만 한다.
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
    // 목록이 user_id에 의존하므로(차단 유저 필터 등) 자동로그인이 확정되면 다시 조회한다.
    _authWorker = ever<WebAuthStatus>(_authVm.statusRx, (status) {
      if (status == WebAuthStatus.authenticated) _reload();
    });
  }

  @override
  void dispose() {
    // 해제하지 않으면 라우트를 왕복할 때마다 리스너가 쌓여 재조회가 여러 번 나간다.
    _authWorker?.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _reload() {
    _vm.loadFirstPage(
      userId: _userVm.user.user_id,
      tab: _tab,
      scope: _scope,
      sort: _sort,
      query: _searchController.text,
    );
  }

  void _onTabChanged(CommunityCategoryTab tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
    _reload();
  }

  void _onScopeChanged(CommunitySearchScope scope) {
    if (scope == _scope) return;
    setState(() => _scope = scope);
    // 검색어가 이미 적용된 상태면 새 범위로 즉시 다시 조회한다(엔터를 또 치지 않게).
    if (_vm.appliedQuery.isNotEmpty || _searchController.text.trim().isNotEmpty) _reload();
  }

  void _onSortSelected(CommunitySortOption sort) {
    if (sort == _sort) return;
    setState(() => _sort = sort);
    _reload();
  }

  void _onWritePost() => Get.toNamed(WebRoutes.communityUpload);

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final titleText = Text(
      '커뮤니티',
      // 홈 타이틀 공통: PC 32 / 태블릿·모바일 24, extraBold —
      // 목업(64:112894)은 bold지만 중고거래 홈과 통일(사용자 결정).
      style: SDSTextStyle.extraBold.copyWith(
        fontSize: webHomeTitleSize(context),
        color: SDSColor.gray900,
      ),
    );
    final searchBar = CommunitySearchBarWeb(
      controller: _searchController,
      focusNode: _searchFocus,
      scope: _scope,
      onScopeChanged: _onScopeChanged,
      onSubmitted: (_) => _reload(),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop)
          // 데스크탑만 타이틀 + 고정폭 검색바가 한 줄에 온다(목업).
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleText,
              // 타이틀 ↔ 검색바 36 (피그마 64:112893).
              const SizedBox(width: 36),
              SizedBox(width: kCommunityDesktopSearchBarWidth, child: searchBar),
            ],
          )
        else ...[
          titleText,
          const SizedBox(height: SDSSpacing.md),
          searchBar,
        ],
        // 타이틀·검색 영역 ↔ 필터 줄: PC 30 / 태블릿 24 / 모바일 20
        // (중고거래 홈 타이틀줄↔탭줄과 동일 규칙).
        SizedBox(height: webTitleToFilterGap(context)),
        CommunityFilterRowWeb(
          tab: _tab,
          sort: _sort,
          onTabChanged: _onTabChanged,
          onSortSelected: _onSortSelected,
        ),
        // 필터 줄 ↔ 목록 20 (확정값 — 10에서 +10).
        const SizedBox(height: 20),
        // 검색 중이면 안내 박스를 목록 위에 둔다. 서버에 실제로 보낸 검색어를 쓴다.
        Obx(() {
          final query = _vm.appliedQuery;
          if (query.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: SDSSpacing.md),
            child: CommunitySearchNoticeWeb(query: query),
          );
        }),
        const CommunityListWeb(),
      ],
    );

    // 콘텐츠가 짧으면 푸터가 뷰포트 하단에 붙는다(공통 골격). 여백은 스크롤
    // 영역 안쪽(웹 공통 규칙) — 태블릿·모바일은 콘텐츠가 하단 플로팅 바 뒤로
    // 지나가도록 바 높이만큼 하단 여백을 확보한다.
    final Widget scroll = WebStickyFooterScroll(
      controller: _scrollController,
      padding: webHomePagePadding(
        context,
        bottom: isDesktop ? SDSSpacing.xl : kWebFloatingBottomBarHeight + SDSSpacing.md,
      ),
      content: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kCommunityContentMaxWidth),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: content),
                    // 목록 ↔ 사이드바 간격 40 (중고거래 홈과 동일).
                    const SizedBox(width: 40),
                    // 스크롤을 내리면 사이드바가 화면 상단 30에 멈춰 따라붙고
                    // 목록만 올라간다(라이브톡과 동일).
                    // 상단 오프셋은 **바깥**에 둔다 — 안에 두면 sticky가 그
                    // 여백까지 밀어 올려 높이 계산이 어긋난다.
                    Padding(
                      padding: const EdgeInsets.only(top: _kCommunitySidebarTopOffset),
                      child: WebStickySidebar(
                        controller: _scrollController,
                        naturalTop: webHomePagePadding(context).top + _kCommunitySidebarTopOffset,
                        child: CommunitySidebarWeb(onWritePost: _onWritePost),
                      ),
                    ),
                  ],
                )
              : content,
        ),
      ),
      // 홈과 동일한 푸터 — 1560 블록 밖, 콘텐츠 영역 폭(푸터 정책).
      footer: Column(
        children: [
          SizedBox(height: webFooterTopGap(context)),
          const HomeFooterWeb(),
        ],
      ),
    );

    if (isDesktop) {
      return Container(color: SDSColor.snowliveWhite, child: scroll);
    }
    // 태블릿·모바일: 게시글 올리기 하단 플로팅 바(목업 숨은 프레임 64:112973/112975,
    // 중고거래 목록·올리기와 동일한 공통 구성).
    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          scroll,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: WebFloatingBottomBar(
              child: WebBottomBarButton(
                label: '게시글 올리기',
                background: SDSColor.snowliveBlue,
                foreground: SDSColor.snowliveWhite,
                onTap: _onWritePost,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
