import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/community/w_community_row_web.dart';
import 'package:com.snowlive/web/view/community/w_event_row_web.dart';
import 'package:com.snowlive/web/viewmodel/event/vm_eventListPagination_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_numbered_pagination_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 각종소식(이벤트) 목록 본문. 모바일은 카드형, 태블릿·데스크탑은 표형으로 그린다.
/// 커뮤니티에서 분리된 독립 화면([EventHomeViewWeb])에서 쓴다.
class EventListWeb extends StatelessWidget {
  const EventListWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<EventListPaginationViewModelWeb>();

    return Obx(() {
      final items = vm.items;
      final query = vm.appliedQuery;

      // 첫 로딩에만 스켈레톤을 쓴다. 페이지 이동 중에는 기존 목록을 유지해서
      // (전역 상단 진행바가 이미 돌고 있다) 목록이 통째로 사라지지 않게 한다.
      if (vm.isLoading && items.isEmpty) return const CommunityListSkeleton();

      if (vm.hasError) return WebErrorState(onRetry: vm.retry);

      if (items.isEmpty) {
        return WebEmptyState(
          message: query.isEmpty ? '아직 소식이 없어요.' : "'$query' 검색 결과가 없어요.",
        );
      }

      final isMobile = context.screenType == WebScreenType.mobile;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isMobile) const EventTableHeaderRow(),
          for (final event in items)
            isMobile
                ? EventCardRow(event: event, query: query)
                : EventTableRow(event: event, query: query),
          const SizedBox(height: SDSSpacing.lg),
          NumberedPaginationBar(
            currentPage: vm.currentPage,
            totalPages: vm.totalPages,
            hasPrevious: vm.hasPrevious,
            hasNext: vm.hasNext,
            pageWindow: vm.pageWindow(),
            onGotoPage: (page) => _gotoPage(context, vm, page),
          ),
        ],
      );
    });
  }

  /// 페이지를 옮기면 목록 상단으로 스크롤을 되돌린다(커뮤니티·중고거래와 동일).
  Future<void> _gotoPage(
    BuildContext context,
    EventListPaginationViewModelWeb vm,
    int page,
  ) async {
    await vm.gotoPage(page);
    if (!context.mounted) return;
    Scrollable.maybeOf(context)?.position.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
  }
}
