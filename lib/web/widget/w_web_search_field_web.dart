import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// `[🔍] 힌트` 만 있는 단순 검색 입력창.
///
/// 기존 검색바는 둘 다 못 쓴다 — 중고거래는 State의 private 메서드(`_buildSearchBar`)라
/// 파일 밖에서 호출할 수 없고, 커뮤니티([CommunitySearchBarWeb])는 검색범위 드롭다운과
/// 구분선이 구조에 박혀 있다. 치수·색은 중고거래 것을 그대로 옮겼다.
class WebSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  /// 엔터(또는 모바일 키보드의 검색)로 확정했을 때. 빈 문자열도 그대로 넘긴다.
  final ValueChanged<String> onSubmitted;

  final FocusNode? focusNode;

  /// 목업의 검색창은 알약이다. 사각(radius 8)이 필요한 자리도 있어 열어둔다
  final double borderRadius;

  const WebSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSubmitted,
    this.focusNode,
    this.borderRadius = 999,
  });

  @override
  Widget build(BuildContext context) {
    // 목업(218:67552) — 높이 40 = 상하 10 + 글줄 20, 좌우 14, 아이콘 16,
    // 아이콘 ↔ 글자 8, 글자 15. 친구 목록·크루 가입하기가 같은 컴포넌트다.
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: SDSColor.gray50,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          Image.asset('assets/imgs/icons/icon_search.png', width: 16, height: 16),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
              // 커서 높이 = 글자 크기 + 2(웹 공통 규칙).
              cursorHeight: 17,
              decoration: InputDecoration(
                hintText: hint,
                // 목업 힌트색 #949494 = gray500.
                hintStyle: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray500),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
