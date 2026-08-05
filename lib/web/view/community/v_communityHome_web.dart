import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/community/w_community_header_web.dart';
import 'package:com.snowlive/web/view/community/w_community_list_web.dart';
import 'package:com.snowlive/web/view/community/w_community_sidebar_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityListPagination_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 1440px 기준 GNB(240)/좌우 여백(32*2)을 뺀, "목록 영역 + 우측 사이드바" 기준 폭.
/// 중고거래와 같은 계산식이라 두 화면의 콘텐츠 폭이 정확히 맞는다.
const double kCommunityContentMaxWidth =
    WebBreakpoints.maxContentWidth - kGnbSidebarWidth - (SDSSpacing.xl * 2);

/// 웹 커뮤니티 목록 화면.
class CommunityHomeViewWeb extends StatefulWidget {
  const CommunityHomeViewWeb({super.key});

  @override
  State<CommunityHomeViewWeb> createState() => _CommunityHomeViewWebState();
}

class _CommunityHomeViewWebState extends State<CommunityHomeViewWeb> {
  final CommunityListPaginationViewModelWeb _vm =
      Get.find<CommunityListPaginationViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final AuthCheckViewModelWeb _authVm = Get.find<AuthCheckViewModelWeb>();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

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
      style: SDSTextStyle.extraBold.copyWith(fontSize: 28, color: SDSColor.gray900),
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
              const SizedBox(width: SDSSpacing.lg),
              SizedBox(width: kCommunityDesktopSearchBarWidth, child: searchBar),
            ],
          )
        else ...[
          titleText,
          const SizedBox(height: SDSSpacing.md),
          searchBar,
        ],
        const SizedBox(height: SDSSpacing.lg),
        CommunityFilterRowWeb(
          tab: _tab,
          sort: _sort,
          onTabChanged: _onTabChanged,
          onSortSelected: _onSortSelected,
        ),
        const SizedBox(height: SDSSpacing.md),
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
        if (!isDesktop) ...[
          const SizedBox(height: SDSSpacing.lg),
          // content Column이 crossAxisAlignment.start라서 감싸지 않으면 버튼이
          // 내용 폭으로 줄어든다. 목업은 전체폭 버튼이다.
          SizedBox(width: double.infinity, child: CommunityWritePostButton(onTap: _onWritePost)),
        ],
      ],
    );

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
            constraints: const BoxConstraints(maxWidth: kCommunityContentMaxWidth),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: content),
                      CommunitySidebarWeb(onWritePost: _onWritePost),
                    ],
                  )
                : content,
          ),
        ),
      ),
    );
  }
}
