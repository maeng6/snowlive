import 'package:com.snowlive/core/model/m_affiliate_product.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_card_web.dart'
    show kFleamarketPhotoRadius;
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_grid_web.dart'
    show FleamarketGridLayout;
import 'package:com.snowlive/web/view/shop/w_shop_card_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:flutter/material.dart';

/// GridView가 실제로 주는 셀 폭. [FleamarketGridLayout.cellWidth]는 내림한 값이라
/// 정사각 이미지(AspectRatio 1)의 실제 높이보다 최대 1px 작다 → 그 값으로 셀 높이를
/// 잡으면 0.5px씩 넘쳐 줄무늬가 뜬다(실측). 높이 계산은 이 정확한 폭으로 한다.
double shopExactCellWidth(FleamarketGridLayout layout, double maxWidth) =>
    (maxWidth - layout.spacing * (layout.crossAxisCount - 1)) / layout.crossAxisCount;

/// 추천 상품 그리드 — 열 수·간격은 중고거래 그리드([FleamarketGridLayout])와 같다
/// (PC 4~5열 · 태블릿 5열 · 모바일 2열, 열 간격 8, 행 간격 PC 48 / 그 외 32).
class ShopGridWeb extends StatelessWidget {
  final List<AffiliateProduct> items;

  const ShopGridWeb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = FleamarketGridLayout.of(context.screenType, constraints.maxWidth);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: layout.crossAxisCount,
            crossAxisSpacing: layout.spacing,
            mainAxisSpacing: layout.runSpacing,
            mainAxisExtent: shopExactCellWidth(layout, constraints.maxWidth) + shopCardTextBlockHeight(),
          ),
          itemBuilder: (context, i) => ShopCardWeb(product: items[i]),
        );
      },
    );
  }
}

/// 로딩 자리표시 — 실제 그리드와 같은 배치 값을 써서 데이터가 와도 안 튄다.
class ShopGridSkeleton extends StatelessWidget {
  final int itemCount;

  const ShopGridSkeleton({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = FleamarketGridLayout.of(context.screenType, constraints.maxWidth);
          final cellWidth = shopExactCellWidth(layout, constraints.maxWidth);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: itemCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layout.crossAxisCount,
              crossAxisSpacing: layout.spacing,
              mainAxisSpacing: layout.runSpacing,
              mainAxisExtent: cellWidth + shopCardTextBlockHeight(),
            ),
            itemBuilder: (context, index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: cellWidth, height: cellWidth, radius: kFleamarketPhotoRadius),
                const SizedBox(height: 10),
                const SkeletonLine(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                SkeletonLine(width: cellWidth * 0.6, height: 12),
                const SizedBox(height: 10),
                SkeletonLine(width: cellWidth * 0.4, height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}
