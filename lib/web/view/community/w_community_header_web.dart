import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_filter_sheet_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityListPagination_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_text_tabs_web.dart';
import 'package:flutter/material.dart';

/// 데스크탑에서 타이틀 오른쪽에 붙는 검색바 폭(목업). 남은 폭을 다 먹지 않는다.
const double kCommunityDesktopSearchBarWidth = 360;

/// 검색범위 라벨이 바뀔 때 옆 입력창 폭이 흔들려 커서가 튀지 않도록 고정폭을 준다.
/// 가장 긴 라벨('제목+내용') 기준(regular 15).
const double _kScopeLabelWidth = 68;

/// 커뮤니티 목록 화면의 검색바. `[🔍] [제목+내용 ⌄]  [입력]` 구조(피그마 64:112895).
class CommunitySearchBarWeb extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final CommunitySearchScope scope;
  final ValueChanged<CommunitySearchScope> onScopeChanged;
  final ValueChanged<String> onSubmitted;

  /// 범위 드롭다운을 숨길지. 이벤트 API는 `search_query`(제목+내용)만 지원해서
  /// 선택할 게 없다 — 고를 수 없는 라벨을 보여주느니 아예 뺀다(사용자 결정).
  final bool scopeLocked;

  const CommunitySearchBarWeb({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scope,
    required this.onScopeChanged,
    required this.onSubmitted,
    this.scopeLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    // 피그마 64:112895 — 높이 40(패딩 14/10), 라운드 6, 아이콘 18(텍스트와 6),
    // 구분선 없이 범위 ↔ 입력 16, 텍스트 15(범위 gray900 / 힌트 gray500).
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: SDSColor.gray50,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: SDSColor.gray400),
          const SizedBox(width: 6),
          if (!scopeLocked) ...[
            WebDropdownTextButton<CommunitySearchScope>(
              label: scope.label,
              labelWidth: _kScopeLabelWidth,
              values: CommunitySearchScope.values,
              labelOf: (v) => v.label,
              // 목업의 검색범위 드롭다운에는 헤더가 없다.
              onSelected: (v) {
                onScopeChanged(v);
                // 범위만 바꾸고 바로 엔터를 칠 수 있게 포커스를 입력창으로 되돌린다.
                focusNode.requestFocus();
              },
              labelStyle: SDSTextStyle.regular.copyWith(
                fontSize: 15,
                color: SDSColor.gray900,
              ),
              // 태블릿은 PC식 앵커 드롭다운(공통 규칙), 모바일만 하단 시트.
              dropdownOnTablet: true,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: '게시글 검색',
                hintStyle: SDSTextStyle.regular.copyWith(
                  fontSize: 15,
                  color: SDSColor.gray500,
                ),
              ),
              style: SDSTextStyle.regular.copyWith(
                fontSize: 15,
                color: SDSColor.gray900,
              ),
              cursorHeight: 17,
            ),
          ),
        ],
      ),
    );
  }
}

/// 카테고리 탭 + 정렬 pill 한 줄.
/// 태블릿·데스크탑은 텍스트 탭, 모바일은 폭이 좁아 드롭다운으로 접는다(목업).
class CommunityFilterRowWeb extends StatelessWidget {
  final CommunityCategoryTab tab;
  final CommunitySortOption sort;
  final ValueChanged<CommunityCategoryTab> onTabChanged;
  final ValueChanged<CommunitySortOption> onSortSelected;

  /// 정렬 pill을 그릴지. 이벤트 API에는 정렬 파라미터가 없어서 그 탭에서는 숨긴다
  /// (눌러도 아무 일이 없는 UI를 두면 고장으로 읽힌다).
  final bool showSort;

  const CommunityFilterRowWeb({
    super.key,
    required this.tab,
    required this.sort,
    required this.onTabChanged,
    required this.onSortSelected,
    this.showSort = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;

    return Row(
      children: [
        if (isMobile)
          WebDropdownTextButton<CommunityCategoryTab>(
            label: tab.label,
            values: CommunityCategoryTab.values,
            labelOf: (v) => v.label,
            onSelected: onTabChanged,
            labelStyle: SDSTextStyle.bold.copyWith(
              fontSize: 15,
              color: SDSColor.gray900,
            ),
          )
        else
          // 새 탭 표준(피그마 64:112870) — bold 16, 비활성 gray200,
          // 1px 세로선 구분자, 간격 10 (키워드 알림과 동일).
          ...WebTextTabs<CommunityCategoryTab>(
            values: CommunityCategoryTab.values,
            selected: tab,
            labelOf: (v) => v.label,
            onSelected: onTabChanged,
            fontSize: 16,
            inactiveBold: true,
            inactiveColor: SDSColor.gray200,
            lineDivider: true,
            dividerGap: 10,
          ).buildChildren(),
        const Spacer(),
        if (showSort)
          FleamarketFilterPill<CommunitySortOption>(
            label: sort.label,
            // 목업(64:112888) — 커뮤니티 정렬 pill 라벨은 bold 14.
            labelFontSize: 14,
            // 기본값(최신순)이 아니면 다른 필터 pill과 같이 색이 반전된다.
            isActive: sort != CommunitySortOption.latest,
            // 헤더('필터') 없이 항목만 — 사용자 결정(2026-09-22).
            // 태블릿은 PC식 앵커 드롭다운(중고거래 필터 pill과 동일 규칙).
            dropdownOnTablet: true,
            values: CommunitySortOption.values,
            labelOf: (v) => v.label,
            onSelected: onSortSelected,
          ),
      ],
    );
  }
}

/// "OO 검색 결과입니다." 안내 박스. 결과가 0건이어도 검색 상태를 알 수 있게 유지한다.
class CommunitySearchNoticeWeb extends StatelessWidget {
  final String query;

  const CommunitySearchNoticeWeb({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SDSColor.gray100),
      ),
      child: Text(
        '$query 검색 결과입니다.',
        style: SDSTextStyle.bold.copyWith(
          fontSize: 14,
          color: SDSColor.gray900,
        ),
      ),
    );
  }
}
