import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart' show HomeFooterWeb;
import 'package:com.snowlive/web/view/shop/shop_sections_web.dart';
import 'package:com.snowlive/web/view/shop/w_shop_category_chips_web.dart';
import 'package:com.snowlive/web/view/shop/w_shop_grid_web.dart';
import 'package:com.snowlive/web/viewmodel/shop/vm_shop_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_sticky_footer_scroll_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 추천 상품(쿠팡 파트너스) 목록 — `#/shop`.
///
/// 타이틀 → 고지 문구 → 카테고리 칩 → 카드 그리드. 카드를 누르면 쿠팡이 새 탭으로
/// 열린다. 상세 화면은 없다. 사이드바도 없다(중고거래와 달리 내 활동이 없어서).
class ShopViewWeb extends StatelessWidget {
  const ShopViewWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<ShopViewModelWeb>();
    final isDesktop = context.isDesktop;

    return Container(
      color: SDSColor.snowliveWhite,
      // 여백은 스크롤 영역 **안쪽**(웹 공통 — 바깥이면 스크롤바가 안쪽에 뜬다).
      child: WebStickyFooterScroll(
        onRefresh: vm.load,
        padding: webHomePagePadding(context),
        content: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kWebDesktopListMaxWidth),
            child: Obx(() {
              // ⚠️ 분기 전에 관찰값을 모두 읽어야 Obx 구독이 걸린다.
              final isLoading = vm.isLoading;
              final hasError = vm.hasError;
              final categories = vm.categories;
              final selected = vm.selectedCategory;
              final visible = vm.visibleItems;
              final hasAny = vm.items.isNotEmpty;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kShopMenuLabel,
                    style: SDSTextStyle.extraBold.copyWith(
                      fontSize: webHomeTitleSize(context),
                      color: SDSColor.gray900,
                    ),
                  ),
                  const SizedBox(height: SDSSpacing.sm),
                  // 파트너스 고지 — 상품이 보이는 화면에 반드시. 폭과 무관하게 항상.
                  // 공정위 지침은 "쉽게 알아볼 수 있게"라 보조 설명(12·gray500)보다 한 단계
                  // 키우고 진하게(13·gray700) 둔다.
                  Text(
                    kShopDisclosure,
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 13,
                      height: 1.5,
                      color: SDSColor.gray700,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 30 : 22),
                  if (hasAny)
                    ShopCategoryChipsWeb(
                      categories: categories,
                      selected: selected,
                      onSelected: vm.selectCategory,
                    ),
                  // 칩 ↔ 그리드: 중고거래 탭줄 ↔ 그리드와 같은 PC 30 / 그 외 22.
                  if (hasAny) SizedBox(height: isDesktop ? 30 : 22),
                  if (isLoading && !hasAny)
                    const ShopGridSkeleton()
                  else if (hasError && !hasAny)
                    WebErrorState(onRetry: vm.load)
                  else if (visible.isEmpty)
                    const WebEmptyState(message: '아직 준비된 상품이 없어요')
                  else
                    ShopGridWeb(items: visible),
                ],
              );
            }),
          ),
        ),
        footer: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kWebDesktopListMaxWidth),
            child: Column(
              children: [SizedBox(height: webFooterTopGap(context)), const HomeFooterWeb()],
            ),
          ),
        ),
      ),
    );
  }
}
