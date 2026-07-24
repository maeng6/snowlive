import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketSearch.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_filter_sheet_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const List<String> kFleamarketTabs = ['전체', '스키', '스노보드', '찜 목록', '내 게시글'];

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

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() => _showSuggestions = _searchFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _runSearch(String query) {
    if (query.trim().isEmpty) return;
    _searchVm.saveRecentSearch(query.trim());
    final userId = _userVm.user.user_id;
    switch (_vm.tapName) {
      case '스키':
        _vm.fetchFleamarketData_ski(userId: userId, categoryMain: '스키', search_query: query.trim());
        break;
      case '스노보드':
        _vm.fetchFleamarketData_board(userId: userId, categoryMain: '스노보드', search_query: query.trim());
        break;
      case '찜 목록':
        _vm.fetchFleamarketData_favorite(userId: userId, favorite_list: true, search_query: query.trim());
        break;
      case '내 게시글':
        _vm.fetchFleamarketData_my(userId: userId, myflea: true, search_query: query.trim());
        break;
      case '전체':
      default:
        _vm.fetchFleamarketData_total(userId: userId, search_query: query.trim());
    }
    _searchFocus.unfocus();
    setState(() => _showSuggestions = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('중고거래', style: SDSTextStyle.extraBold.copyWith(fontSize: 28, color: SDSColor.gray900)),
        const SizedBox(height: SDSSpacing.md),
        _buildSearchBar(),
        const SizedBox(height: SDSSpacing.md),
        _buildTabsAndFilters(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
        ),
        if (_showSuggestions)
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: Obx(() {
              final recent = _searchVm.recentSearches;
              if (recent.isEmpty) return const SizedBox.shrink();
              return Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 260),
                  decoration: BoxDecoration(
                    color: SDSColor.snowliveWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SDSColor.gray100),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text('최근 검색어', style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.gray500)),
                      ),
                      for (final term in recent)
                        ListTile(
                          dense: true,
                          leading: Icon(Icons.history, size: 18, color: SDSColor.gray400),
                          title: Text(term, style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900)),
                          trailing: IconButton(
                            icon: Icon(Icons.close, size: 16, color: SDSColor.gray300),
                            onPressed: () => _searchVm.deleteRecentSearch(term),
                          ),
                          onTap: () {
                            _searchController.text = term;
                            _runSearch(term);
                          },
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildTabsAndFilters() {
    return Obx(() {
      final tapName = _vm.tapName;
      final showFilters = tapName == '전체' || tapName == '스키' || tapName == '스노보드';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final tab in kFleamarketTabs) _buildTabButton(tab, tapName == tab),
                    ],
                  ),
                ),
              ),
              if (showFilters) _buildFilterRow(tapName),
            ],
          ),
          Container(height: 1, color: SDSColor.gray100),
        ],
      );
    });
  }

  Widget _buildTabButton(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: () => _vm.changeTap(label),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                label,
                style: (isSelected ? SDSTextStyle.bold : SDSTextStyle.regular).copyWith(
                  fontSize: 16,
                  color: isSelected ? SDSColor.gray900 : SDSColor.gray300,
                ),
              ),
            ),
            Container(height: 3, width: 40, color: isSelected ? SDSColor.gray900 : Colors.transparent),
          ],
        ),
      ),
    );
  }

  /// 선택된 카테고리/거래장소로 현재 활성 탭을 재조회한다.
  void _refetchCurrentTab(String tapName, {required String categorySub, required String categorySpot}) {
    final userId = _userVm.user.user_id;
    final sub = categorySub == FleamarketCategory_sub.total.korean ? null : categorySub;
    final spot = categorySpot == FleamarketCategory_spot.total.korean ? null : categorySpot;
    switch (tapName) {
      case '스키':
        _vm.fetchFleamarketData_ski(userId: userId, categoryMain: '스키', categorySub: sub, spot: spot);
        break;
      case '스노보드':
        _vm.fetchFleamarketData_board(userId: userId, categoryMain: '스노보드', categorySub: sub, spot: spot);
        break;
      case '전체':
      default:
        _vm.fetchFleamarketData_total(userId: userId, categorySub: sub, spot: spot);
    }
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
        FleamarketFilterPill(
          label: selectedSub,
          isActive: selectedSub != FleamarketCategory_sub.total.korean,
          onTap: () => showFleamarketFilterSheet<FleamarketCategory_sub>(
            context,
            values: FleamarketCategory_sub.values,
            labelOf: (v) => v.korean,
            onSelected: (v) {
              changeSub(v.korean);
              _refetchCurrentTab(tapName, categorySub: v.korean, categorySpot: selectedSpot);
            },
          ),
        ),
        const SizedBox(width: SDSSpacing.sm),
        FleamarketFilterPill(
          label: selectedSpot,
          isActive: selectedSpot != FleamarketCategory_spot.total.korean,
          onTap: () => showFleamarketFilterSheet<FleamarketCategory_spot>(
            context,
            values: FleamarketCategory_spot.values,
            labelOf: (v) => v.korean,
            onSelected: (v) {
              changeSpot(v.korean);
              _refetchCurrentTab(tapName, categorySub: selectedSub, categorySpot: v.korean);
            },
          ),
        ),
      ],
    );
  }
}
