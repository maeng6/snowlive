import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketSearch.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/community/w_community_header_web.dart'
    show kCommunityDesktopSearchBarWidth;
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_filter_sheet_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketPagination_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const List<String> kFleamarketTabs = ['전체', '스키', '스노보드', '찜 목록', '내 게시글'];

/// 하위 탭 사이 구분선 색(디자인 지정 #ECECEC). 디자인 시스템의 gray100(#EFEFEF)과
/// 미묘하게 다른 값이라 토큰을 건드리지 않고 여기서만 쓴다.
const Color _kTabDividerColor = Color(0xFFECECEC);

/// 제목 + 인라인 검색(최근검색어 드롭다운 포함) + 탭 + 필터 pill + (데스크탑) 물품 올리기 버튼.
class FleamarketHeaderWeb extends StatefulWidget {
  const FleamarketHeaderWeb({super.key});

  @override
  State<FleamarketHeaderWeb> createState() => _FleamarketHeaderWebState();
}

class _FleamarketHeaderWebState extends State<FleamarketHeaderWeb> {
  final FleamarketListViewModel _vm = Get.find<FleamarketListViewModel>();
  final FleamarketSearchViewModel _searchVm = Get.find<FleamarketSearchViewModel>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final FleamarketPaginationViewModelWeb _paginationVm = Get.find<FleamarketPaginationViewModelWeb>();

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final _searchBarKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
    // FleamarketPaginationViewModelWeb.onInit()이 최초 진입 시점에 조회한 결과가
    // 화면에 반영되지 않는 경우가 있어(원인 미확정), 헤더가 마운트되는 시점에
    // 현재 활성 탭 기준으로 한 번 더 명시적으로 조회해서 항상 목록이 뜨도록 한다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadPaginationForTab(_vm.tapName);
    });
  }

  @override
  void dispose() {
    _hideOverlay();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// 최근검색어 드롭다운을 앱 최상위(root) Overlay에 직접 그린다. 이 화면의 위젯
  /// 트리 안에 Positioned로 두면 아무리 z-index를 조정해도 "이 컴포넌트 내부"를
  /// 벗어날 수 없어서, 페이지 내용(중고거래 리스트 등)에 가려지는 경우가 있었다.
  /// Overlay는 라우트/GNB보다도 위에 있는 별도 레이어라 항상 화면 제일 위에 뜬다.
  void _showOverlay() {
    _hideOverlay();
    final renderBox = _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // 드롭다운 바깥을 클릭하면 닫히도록, 화면 전체를 덮는 투명 배리어를 먼저 깔아둔다.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _searchFocus.unfocus,
              ),
            ),
            Positioned(
              top: offset.dy + size.height + 4,
              left: offset.dx,
              width: size.width,
              child: Obx(() {
                final recent = _searchVm.recentSearches;
                if (recent.isEmpty) return const SizedBox.shrink();
                return Material(
                  color: SDSColor.snowliveWhite,
                  elevation: 4,
                  shadowColor: SDSColor.gray900.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 260),
                    decoration: BoxDecoration(
                      color: SDSColor.snowliveWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SDSColor.gray100),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            // 목업: 타이틀은 볼드가 아니다(개발 중 붙어 있던 `v13` 표시도 제거).
                            child: Text('최근 검색어',
                                style: SDSTextStyle.regular
                                    .copyWith(fontSize: 12, color: SDSColor.gray500)),
                          ),
                          for (final term in recent)
                            _RecentSearchRow(
                              term: term,
                              onSelect: () => _selectRecentSearch(term),
                              onDelete: () => _searchVm.deleteRecentSearch(term),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// 탭 이름을 페이지네이션 조회 파라미터로 매핑해서 1페이지부터 다시 불러온다.
  void _loadPaginationForTab(
    String tapName, {
    String? categorySub,
    String? spot,
    String? searchQuery,
  }) {
    final userId = _userVm.user.user_id;
    switch (tapName) {
      case '스키':
        _paginationVm.loadFirstPage(
          userId: userId,
          categoryMain: '스키',
          categorySub: categorySub,
          spot: spot,
          searchQuery: searchQuery,
        );
        break;
      case '스노보드':
        _paginationVm.loadFirstPage(
          userId: userId,
          categoryMain: '스노보드',
          categorySub: categorySub,
          spot: spot,
          searchQuery: searchQuery,
        );
        break;
      case '찜 목록':
        _paginationVm.loadFirstPage(userId: userId, favoriteList: true, searchQuery: searchQuery);
        break;
      case '내 게시글':
        _paginationVm.loadFirstPage(userId: userId, myflea: true, searchQuery: searchQuery);
        break;
      case '전체':
      default:
        _paginationVm.loadFirstPage(
          userId: userId,
          categorySub: categorySub,
          spot: spot,
          searchQuery: searchQuery,
        );
    }
  }

  /// 최근검색어를 눌렀을 때 — 그 검색어로 검색창을 채우고 바로 검색한다.
  void _selectRecentSearch(String term) {
    _searchController.text = term;
    _runSearch(term);
  }

  void _runSearch(String query) {
    if (query.trim().isEmpty) return;
    _searchVm.saveRecentSearch(query.trim());
    _loadPaginationForTab(_vm.tapName, searchQuery: query.trim());
    _searchFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // 커뮤니티와 같은 기준(데스크탑)에서 검색창이 타이틀 오른쪽 같은 줄에 놓인다.
    final isWide = context.isDesktop;
    final titleText = Text('중고거래', style: SDSTextStyle.extraBold.copyWith(fontSize: 28, color: SDSColor.gray900));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleText,
              const SizedBox(width: SDSSpacing.lg),
              // 남은 폭을 다 먹지 않고 커뮤니티와 같은 고정폭으로 맞춘다.
              SizedBox(width: kCommunityDesktopSearchBarWidth, child: _buildSearchBar()),
            ],
          )
        else ...[
          titleText,
          const SizedBox(height: SDSSpacing.md),
          _buildSearchBar(),
        ],
        const SizedBox(height: SDSSpacing.md),
        _buildTabsAndFilters(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      key: _searchBarKey,
      height: 44,
      decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Image.asset('assets/imgs/icons/icon_search.png', width: 16, height: 16),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: '중고거래 물품 검색',
                hintStyle: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400),
              ),
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
              onSubmitted: _runSearch,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsAndFilters() {
    return Obx(() {
      final tapName = _vm.tapName;
      final showFilters = tapName == '전체' || tapName == '스키' || tapName == '스노보드';

      // 모바일은 탭 5개와 필터 2개가 한 줄에 들어가지 않아 탭이 필터에 잘려 붙었다
      // (실측) → 목업처럼 **탭을 드롭다운 하나로 접는다**.
      final isMobile = context.screenType == WebScreenType.mobile;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isMobile)
            _TabDropdown(
              selected: tapName,
              onSelected: (tab) {
                _vm.changeTap(tab);
                _loadPaginationForTab(tab);
              },
            )
          else
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < kFleamarketTabs.length; i++) ...[
                      // 목업은 탭 사이를 `|`로 나눈다(밑줄 대신).
                      if (i > 0) _buildTabDivider(),
                      _buildTabButton(kFleamarketTabs[i], tapName == kFleamarketTabs[i]),
                    ],
                  ],
                ),
              ),
            ),
          if (showFilters) ...[
            // 탭과 필터가 맞붙어 잘려 보이지 않게 최소 간격을 둔다.
            const SizedBox(width: SDSSpacing.md),
            // 좁은 폭에서 필터 두 개가 넘치면 옆으로 스크롤한다(잘리지 않게).
            if (isMobile)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: _buildFilterRow(tapName),
                ),
              )
            else
              _buildFilterRow(tapName),
          ] else if (isMobile)
            const Spacer(),
        ],
      );
    });
  }

  /// 탭 하나. 목업에 밑줄 표시가 없어 **선택 여부는 글자 굵기·색으로만** 나타낸다.
  Widget _buildTabButton(String label, bool isSelected) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _vm.changeTap(label);
          _loadPaginationForTab(label);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text(
            label,
            style: (isSelected ? SDSTextStyle.bold : SDSTextStyle.regular).copyWith(
              fontSize: 16,
              color: isSelected ? SDSColor.gray900 : SDSColor.gray300,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabDivider() {
    return Container(
      width: 1,
      height: 14,
      color: _kTabDividerColor,
    );
  }

  /// 선택된 카테고리/거래장소로 현재 활성 탭을 재조회한다.
  void _refetchCurrentTab(String tapName, {required String categorySub, required String categorySpot}) {
    final sub = categorySub == FleamarketCategory_sub.total.korean ? null : categorySub;
    final spot = categorySpot == FleamarketCategory_spot.total.korean ? null : categorySpot;
    _loadPaginationForTab(tapName, categorySub: sub, spot: spot);
  }

  Widget _buildFilterRow(String tapName) {
    late final String selectedSub;
    late final String selectedSpot;
    late final void Function(String) changeSub;
    late final void Function(String) changeSpot;

    switch (tapName) {
      case '스키':
        selectedSub = _vm.selectedCategory_sub_ski;
        selectedSpot = _vm.selectedCategory_spot_ski;
        changeSub = _vm.changeCategory_sub_ski;
        changeSpot = _vm.changeCategory_spot_ski;
        break;
      case '스노보드':
        selectedSub = _vm.selectedCategory_sub_board;
        selectedSpot = _vm.selectedCategory_spot_board;
        changeSub = _vm.changeCategory_sub_board;
        changeSpot = _vm.changeCategory_spot_board;
        break;
      case '전체':
      default:
        selectedSub = _vm.selectedCategory_sub_total;
        selectedSpot = _vm.selectedCategory_spot_total;
        changeSub = _vm.changeCategory_sub_total;
        changeSpot = _vm.changeCategory_spot_total;
    }

    return Row(
      children: [
        FleamarketFilterPill<FleamarketCategory_sub>(
          label: selectedSub,
          isActive: selectedSub != FleamarketCategory_sub.total.korean,
          title: '카테고리',
          values: FleamarketCategory_sub.values,
          labelOf: (v) => v.korean,
          onSelected: (v) {
            changeSub(v.korean);
            _refetchCurrentTab(tapName, categorySub: v.korean, categorySpot: selectedSpot);
          },
        ),
        const SizedBox(width: SDSSpacing.sm),
        FleamarketFilterPill<FleamarketCategory_spot>(
          label: selectedSpot,
          isActive: selectedSpot != FleamarketCategory_spot.total.korean,
          title: '거래장소',
          values: FleamarketCategory_spot.values,
          labelOf: (v) => v.korean,
          onSelected: (v) {
            changeSpot(v.korean);
            _refetchCurrentTab(tapName, categorySub: selectedSub, categorySpot: v.korean);
          },
        ),
      ],
    );
  }
}


/// 최근검색어 한 줄.
///
/// ⚠️ **tap이 아니라 pointer down에서 실행한다.** 이 목록은 root Overlay에 떠 있고
/// 검색창 포커스가 빠지면 곧바로 사라지는데, 항목을 누르면 **tap-up 전에 포커스가 빠져
/// 오버레이가 먼저 제거돼서** `onTap`이 아예 호출되지 않았다(실측: 눌러도 검색이 안 됨).
/// 삭제(`✕`)도 같은 이유로 pointer down에서 처리한다.
class _RecentSearchRow extends StatefulWidget {
  final String term;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  const _RecentSearchRow({
    required this.term,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  State<_RecentSearchRow> createState() => _RecentSearchRowState();
}

class _RecentSearchRowState extends State<_RecentSearchRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        color: _isHovered ? SDSColor.gray50 : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (_) => widget.onSelect(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    widget.term,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                  ),
                ),
              ),
            ),
            Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_) => widget.onDelete(),
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 12, top: 12, bottom: 12),
                child: Icon(Icons.close, size: 16, color: SDSColor.gray300),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// 모바일 하위 탭 드롭다운(`전체 ⌄`).
///
/// ⚠️ 트리거만 담은 위젯이어야 한다 — [showWebFilterMenu]가 넘겨받은 `context`의
/// RenderBox로 앵커를 재기 때문에 부모 Row의 context를 넘기면 패널 폭 계산이 어긋난다.
class _TabDropdown extends StatefulWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _TabDropdown({required this.selected, required this.onSelected});

  @override
  State<_TabDropdown> createState() => _TabDropdownState();
}

class _TabDropdownState extends State<_TabDropdown> {
  final LayerLink _link = LayerLink();

  Future<void> _open() async {
    final selected = await showWebFilterMenu<String>(
      context: context,
      link: _link,
      values: kFleamarketTabs,
      labelOf: (t) => t,
      centerSheetOnTablet: true,
    );
    if (selected == null) return;
    widget.onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _open,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.selected,
                  style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                ),
                const SizedBox(width: 2),
                Icon(Icons.expand_more, size: 18, color: SDSColor.gray900),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
