import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_fleamarket.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_card_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class _TabBundle {
  final List<Fleamarket> list;
  final bool isLoading;
  final String nextPageUrl;
  final String previousPageUrl;
  final Future<void> Function() fetchNext;
  final Future<void> Function() fetchPrevious;

  _TabBundle({
    required this.list,
    required this.isLoading,
    required this.nextPageUrl,
    required this.previousPageUrl,
    required this.fetchNext,
    required this.fetchPrevious,
  });
}

_TabBundle _bundleFor(FleamarketListViewModel vm, String tapName) {
  switch (tapName) {
    case '스키':
      return _TabBundle(
        list: vm.fleamarketListSki,
        isLoading: vm.isLoadingList_ski,
        nextPageUrl: vm.nextPageUrlSki,
        previousPageUrl: vm.previousPageUrlSki,
        fetchNext: vm.fetchNextPage_ski,
        fetchPrevious: vm.fetchPreviousPage_ski,
      );
    case '스노보드':
      return _TabBundle(
        list: vm.fleamarketListBoard,
        isLoading: vm.isLoadingList_board,
        nextPageUrl: vm.nextPageUrlBoard,
        previousPageUrl: vm.previousPageUrlBoard,
        fetchNext: vm.fetchNextPage_board,
        fetchPrevious: vm.fetchPreviousPage_board,
      );
    case '찜 목록':
      return _TabBundle(
        list: vm.fleamarketListFavorite,
        isLoading: vm.isLoadingList_favorite,
        nextPageUrl: vm.nextPageUrlFavorite,
        previousPageUrl: vm.previousPageUrlFavorite,
        fetchNext: vm.fetchNextPage_favorite,
        fetchPrevious: vm.fetchPreviousPage_favorite,
      );
    case '내 게시글':
      return _TabBundle(
        list: vm.fleamarketListMy,
        isLoading: vm.isLoadingList_my,
        nextPageUrl: vm.nextPageUrlMy,
        previousPageUrl: vm.previousPageUrlMy,
        fetchNext: vm.fetchNextPage_my,
        fetchPrevious: vm.fetchPreviousPage_my,
      );
    case '전체':
    default:
      return _TabBundle(
        list: vm.fleamarketListTotal,
        isLoading: vm.isLoadingList_total,
        nextPageUrl: vm.nextPageUrlTotal,
        previousPageUrl: vm.previousPageUrlTotal,
        fetchNext: vm.fetchNextPage_total,
        fetchPrevious: vm.fetchPreviousPage_total,
      );
  }
}

/// 반응형 상품 그리드 + `‹ ›` 페이지네이션(숫자는 표시 전용).
class FleamarketGridWeb extends StatefulWidget {
  const FleamarketGridWeb({super.key});

  @override
  State<FleamarketGridWeb> createState() => _FleamarketGridWebState();
}

class _FleamarketGridWebState extends State<FleamarketGridWeb> {
  final FleamarketListViewModel _vm = Get.find<FleamarketListViewModel>();
  final Map<String, int> _pageByTab = {};

  int _pageOf(String tapName) => _pageByTab[tapName] ??= 1;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = context.isDesktop ? 5 : 2;

    return Obx(() {
      final tapName = _vm.tapName;
      final bundle = _bundleFor(_vm, tapName);
      final currentPage = _pageOf(tapName);

      if (bundle.isLoading && bundle.list.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(top: 80),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (bundle.list.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Center(
            child: Column(
              children: [
                Image.asset('assets/imgs/icons/icon_nodata.png', width: 64, height: 64),
                const SizedBox(height: 12),
                Text('게시판에 글이 없습니다.', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500)),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 16),
            itemCount: bundle.list.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: SDSSpacing.md,
              mainAxisSpacing: SDSSpacing.lg,
              childAspectRatio: 0.66,
            ),
            itemBuilder: (context, index) {
              final data = bundle.list[index];
              return FleamarketCardWeb(
                data: data,
                onTap: () {
                  // 상세 화면은 이번 작업 범위 밖 — 추후 연결 예정.
                  // 주의: detailFleamarket API는 user_id=0(비회원)을 실제 계정으로 취급하지 않고
                  // 404("No User matches the given query")를 반환함(직접 확인) — 목록 조회와 달리
                  // 비로그인 상세보기는 백엔드에서 별도로 허용해줘야 함. 로그인 사용자는 그대로 동작.
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: currentPage > 1
                      ? () async {
                          await bundle.fetchPrevious();
                          setState(() => _pageByTab[tapName] = currentPage - 1);
                        }
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                for (var page = 1; page <= 5; page++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '$page',
                      style: (page == currentPage ? SDSTextStyle.bold : SDSTextStyle.regular).copyWith(
                        fontSize: 14,
                        color: page == currentPage ? SDSColor.gray900 : SDSColor.gray300,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: bundle.nextPageUrl.isNotEmpty
                      ? () async {
                          await bundle.fetchNext();
                          setState(() => _pageByTab[tapName] = currentPage + 1);
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
