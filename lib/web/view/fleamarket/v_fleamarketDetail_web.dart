import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketHome_web.dart' show kFleamarketContentMaxWidth;
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_body_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_comments_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_gallery_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_owner_actions_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_recommend_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_seller_row_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 중고거래 웹 상세화면. 목록 카드 탭에서 fetchFleamarketDetailFromList로 이미
/// 채워진 FleamarketDetailViewModel의 상태를 그대로 읽어서 렌더링한다.
class FleamarketDetailView extends StatelessWidget {
  const FleamarketDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final detailVm = Get.find<FleamarketDetailViewModel>();
    final isDesktop = context.isDesktop;

    return Obx(() {
      final detail = detailVm.fleamarketDetail;
      if (detail.fleaId == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final gallery = FleamarketDetailGalleryWeb(photos: detail.photos ?? []);
      final infoColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FleamarketDetailSellerRowWeb(detail: detail),
          const SizedBox(height: SDSSpacing.md),
          FleamarketDetailBodyWeb(detail: detail),
          FleamarketDetailOwnerActionsWeb(detail: detail),
        ],
      );

      return Container(
        color: SDSColor.snowliveWhite,
        padding: EdgeInsets.fromLTRB(
          isDesktop ? SDSSpacing.xl : SDSSpacing.md,
          32,
          isDesktop ? SDSSpacing.xl : SDSSpacing.md,
          SDSSpacing.xl,
        ),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kFleamarketContentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back, color: SDSColor.gray900),
                  ),
                  const SizedBox(height: SDSSpacing.sm),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: gallery),
                        const SizedBox(width: SDSSpacing.xl),
                        Expanded(flex: 6, child: infoColumn),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        gallery,
                        const SizedBox(height: SDSSpacing.md),
                        infoColumn,
                      ],
                    ),
                  const SizedBox(height: SDSSpacing.xl),
                  Container(height: 8, color: SDSColor.gray50),
                  const SizedBox(height: SDSSpacing.xl),
                  FleamarketDetailCommentsWeb(detail: detail),
                  const SizedBox(height: SDSSpacing.xl),
                  FleamarketDetailRecommendWeb(categoryMain: detail.categoryMain, excludeFleaId: detail.fleaId),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
