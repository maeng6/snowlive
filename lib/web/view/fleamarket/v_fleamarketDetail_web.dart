import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
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
        // 상세 데이터는 목록 카드를 탭할 때 동기로 주입된다. 따라서 여기가 비어 있다는 건
        // 직접 URL 진입/새로고침처럼 조회 자체가 일어나지 않은 경우로, 스피너를 계속
        // 돌리면 영원히 돈다(실제로 그런 버그가 있었다). 빠져나갈 길을 준다.
        return WebEmptyState(
          message: '상품 정보를 불러올 수 없어요.\n목록에서 다시 선택해주세요.',
          actionLabel: '중고거래 목록으로',
          onAction: () => Get.offAllNamed(WebRoutes.fleamarketList),
        );
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
