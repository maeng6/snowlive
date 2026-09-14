import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_card_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketMyActivity_web.dart';
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
              final bool isDesktop = context.isDesktop;
              // PC(피그마): 열 간격 8 / 행 간격 56. 그 외 기존 16/24.
              final double spacing = isDesktop ? 8 : SDSSpacing.md;
              // PC: 셀 최소 150px을 유지하도록 열 수를 3~5 사이에서 조절한다.
              final int crossAxisCount = isDesktop
                  ? ((constraints.maxWidth + 8) / (150 + 8)).floor().clamp(3, 5)
                  : 2;
              // 반올림 오차로 마지막 칸이 다음 줄로 밀리지 않게 살짝 내림.
              final double cellWidth =
                  ((constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount)
                      .floorToDouble();
              // 셀 높이를 고정하지 않고(Wrap) 각 줄이 그 줄에서 가장 긴 카드
              // 높이에 맞춰지게 한다 — 제목 1~2줄 차이로 생기던 오버플로우 방지.
              return Padding(
                // PC: 탭줄 ↔ 그리드 30 (피그마 — 배너 영역은 보류라 그리드가 바로 온다).
                padding: EdgeInsets.only(top: isDesktop ? 30 : 16),
                child: Wrap(
                  spacing: spacing,
                  runSpacing: isDesktop ? 48 : SDSSpacing.lg,
                  children: [
                    for (final data in items)
                      SizedBox(
                        width: cellWidth,
                        child: FleamarketCardWeb(
                          data: data,
                          onTap: () async {
                            // 즉시 표시용으로 목록 데이터를 먼저 주입하고, URL에 id를 실어
                            // 이동한다(상세 화면이 그 id로 API 재조회 → 새로고침/직접진입도 됨).
                            detailVm.fetchFleamarketDetailFromList(fleamarketResponse: data);
                            // 비로그인(게스트)도 조회수는 올라간다 → userId 없이도 호출.
                            if (data.fleaId != null) {
                              detailVm.addViewerFleamarket(
                                  fleamarketId: data.fleaId!, userId: userVm.user.user_id);
                            }
                            await Get.toNamed(WebRoutes.fleamarketDetail,
                                parameters: {'id': '${data.fleaId}'});
                            // 상세에서 돌아오면 사이드바의 최근 본 상품/찜 목록을 갱신한다
                            // (조회 기록이 서버에 반영된 뒤라 새로 본 상품이 바로 뜬다).
                            final userId = userVm.user.user_id;
                            if (userId != null) {
                              Get.find<FleamarketMyActivityViewModel>()
                                  .fetchMyActivity(userId: userId);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Padding(
            // 그리드 ↔ 페이지네이션 40, 아래 24.
            padding: const EdgeInsets.only(top: 40, bottom: 24),
            child: NumberedPaginationBar(
              currentPage: paginationVm.currentPage,
              totalPages: paginationVm.totalPages,
              hasPrevious: paginationVm.hasPrevious,
              hasNext: paginationVm.hasNext,
              // 가운데 페이지 번호는 최대 5개까지만 노출한다
              pageWindow: paginationVm.pageWindow(span: 5),
              onGotoPage: (page) => _gotoPage(context, paginationVm, page),
            ),
          ),
        ],
      );
    });
  }
}
