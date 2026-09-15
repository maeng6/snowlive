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

/// 그리드와 스켈레톤(w_skeleton_web.dart)이 **같은 배치 값**을 쓰기 위한 단일 출처.
/// 여기서 어긋나면 로딩 → 데이터 전환 때 레이아웃이 튄다.
class FleamarketGridLayout {
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;
  final double topPadding;
  final double cellWidth;

  const FleamarketGridLayout._({
    required this.crossAxisCount,
    required this.spacing,
    required this.runSpacing,
    required this.topPadding,
    required this.cellWidth,
  });

  factory FleamarketGridLayout.of(WebScreenType screenType, double maxWidth) {
    final bool isDesktop = screenType == WebScreenType.desktop;
    // 태블릿(피그마 32:8799): PC처럼 다열 그리드 — 5열 고정, 간격 8/32.
    final bool isTablet = screenType == WebScreenType.tablet;
    // 열 간격 8 — PC·태블릿·모바일 공통 (모바일도 피그마 32:19273 실측 8).
    const double spacing = 8;
    // PC: 셀 최소 150px을 유지하도록 열 수를 4~5 사이에서 조절한다.
    // (3열까지 줄이지 않는다 — 좁은 폭에서는 4열인 채 셀이 작아진다.)
    final int crossAxisCount = isDesktop
        ? ((maxWidth + 8) / (150 + 8)).floor().clamp(4, 5)
        : (isTablet ? 5 : 2);
    return FleamarketGridLayout._(
      crossAxisCount: crossAxisCount,
      spacing: spacing,
      // 행 간격: PC 48 / 태블릿·모바일 32 (피그마).
      runSpacing: isDesktop ? 48 : 32,
      // 탭줄 ↔ 그리드: PC 30 / 태블릿·모바일 22 (피그마).
      topPadding: isDesktop ? 30 : 22,
      // 반올림 오차로 마지막 칸이 다음 줄로 밀리지 않게 살짝 내림.
      cellWidth: ((maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount)
          .floorToDouble(),
    );
  }
}

Future<void> _gotoPage(
  BuildContext context,
  FleamarketPaginationViewModelWeb vm,
  int page,
) async {
  // 클릭 즉시 스크롤 없이 최상단으로 점프한다(요청 — 스르륵 올라가지 않게).
  // 그 사이 그리드 자리에는 스켈레톤이 떠 있다(아래 build 참고).
  Scrollable.maybeOf(context)?.position.jumpTo(0);
  await vm.gotoPage(page);
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

      // 첫 로딩(페이지네이션 정보도 아직 없음): 스켈레톤만.
      if (isLoading && items.isEmpty) {
        return const FleamarketGridSkeleton();
      }

      if (!isLoading && items.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/imgs/icons/icon_nodata.png',
                  width: 64,
                  height: 64,
                ),
                const SizedBox(height: 12),
                Text(
                  '게시판에 글이 없습니다.',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 14,
                    color: SDSColor.gray500,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          // 페이지 번호 이동 중에는 첫 로딩과 같은 두 줄짜리 스켈레톤만 보여주고,
          // 아래를 빈 공간으로 채워 페이지네이션이 짧아진 콘텐츠를 따라
          // 화면 위로 올라오지 않게 한다(요청).
          if (isLoading) ...[
            const FleamarketGridSkeleton(),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.5),
          ]
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final layout = FleamarketGridLayout.of(
                  context.screenType,
                  constraints.maxWidth,
                );
                // 셀 높이를 고정하지 않고(Wrap) 각 줄이 그 줄에서 가장 긴 카드
                // 높이에 맞춰지게 한다 — 제목 1~2줄 차이로 생기던 오버플로우 방지.
                return Padding(
                  padding: EdgeInsets.only(top: layout.topPadding),
                  child: Wrap(
                    spacing: layout.spacing,
                    runSpacing: layout.runSpacing,
                    children: [
                      for (final data in items)
                        SizedBox(
                          width: layout.cellWidth,
                          child: FleamarketCardWeb(
                            data: data,
                            onTap: () async {
                              // 즉시 표시용으로 목록 데이터를 먼저 주입하고, URL에 id를 실어
                              // 이동한다(상세 화면이 그 id로 API 재조회 → 새로고침/직접진입도 됨).
                              detailVm.fetchFleamarketDetailFromList(
                                fleamarketResponse: data,
                              );
                              // 비로그인(게스트)도 조회수는 올라간다 → userId 없이도 호출.
                              if (data.fleaId != null) {
                                detailVm.addViewerFleamarket(
                                  fleamarketId: data.fleaId!,
                                  userId: userVm.user.user_id,
                                );
                              }
                              await Get.toNamed(
                                WebRoutes.fleamarketDetail,
                                parameters: {'id': '${data.fleaId}'},
                              );
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
