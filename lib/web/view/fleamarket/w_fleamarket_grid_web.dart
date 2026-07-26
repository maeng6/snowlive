import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_card_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketPagination_web.dart';
import 'package:com.snowlive/web/widget/w_numbered_pagination_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 카드 이미지(정사각형) 아래 텍스트 블록(제목 2줄+부제+가격+통계행)이 필요로 하는
/// 대략적인 고정 높이. 열 개수(5열/2열)에 따라 셀 폭이 달라져도 이 값은 그대로 유지해야
/// childAspectRatio 방식에서 생기던 오버플로우가 재발하지 않는다.
const double kFleamarketCardTextBlockHeight = 128;

Future<void> _gotoPage(BuildContext context, FleamarketPaginationViewModelWeb vm, int page) async {
  await vm.gotoPage(page);
  if (!context.mounted) return;
  final scrollable = Scrollable.maybeOf(context);
  scrollable?.position.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
}

/// 반응형 상품 그리드 + 번호식 페이지네이션(‹ 1 … n n+1 n+2 … N ›).
class FleamarketGridWeb extends StatelessWidget {
  const FleamarketGridWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final paginationVm = Get.find<FleamarketPaginationViewModelWeb>();
    final detailVm = Get.find<FleamarketDetailViewModel>();
    final userVm = Get.find<UserViewModel>();
    final crossAxisCount = context.isDesktop ? 5 : 2;

    return Obx(() {
      final items = paginationVm.items;
      final isLoading = paginationVm.isLoading;

      // 첫 로딩(보여줄 게 아무것도 없을 때)만 스켈레톤. 페이지 번호 이동은
      // items가 남아 있어 기존 그리드가 유지되고 상단 진행바만 도는데,
      // 그게 웹에서 기대되는 동작이라 일부러 그대로 둔다.
      if (isLoading && items.isEmpty) {
        return const FleamarketGridSkeleton();
      }

      if (items.isEmpty) {
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
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = SDSSpacing.md;
              final cellWidth = (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 16),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: SDSSpacing.lg,
                  mainAxisExtent: cellWidth + kFleamarketCardTextBlockHeight,
                ),
                itemBuilder: (context, index) {
                  final data = items[index];
                  return FleamarketCardWeb(
                    data: data,
                    onTap: () {
                      detailVm.fetchFleamarketDetailFromList(fleamarketResponse: data);
                      Get.toNamed(WebRoutes.fleamarketDetail);
                      final userId = userVm.user.user_id;
                      if (userId != null && data.fleaId != null) {
                        detailVm.addViewerFleamarket(fleamarketId: data.fleaId!, userId: userId);
                      }
                    },
                  );
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: NumberedPaginationBar(
              currentPage: paginationVm.currentPage,
              totalPages: paginationVm.totalPages,
              hasPrevious: paginationVm.hasPrevious,
              hasNext: paginationVm.hasNext,
              pageWindow: paginationVm.pageWindow(),
              onGotoPage: (page) => _gotoPage(context, paginationVm, page),
            ),
          ),
        ],
      );
    });
  }
}
