import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_form_fields_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketUpdate_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 작성자 전용: 거래 상태 설정하기 + 끌어올리기. 작성자가 아니면 아무것도 렌더링하지 않는다.
class FleamarketDetailOwnerActionsWeb extends StatelessWidget {
  final FleamarketDetailModel detail;

  const FleamarketDetailOwnerActionsWeb({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final userVm = Get.find<UserViewModel>();
    final detailVm = Get.find<FleamarketDetailViewModel>();
    final isOwner = detail.userId != null && detail.userId == userVm.user.user_id;
    if (!isOwner) return const SizedBox.shrink();

    final isSoldOut = detail.status == FleamarketStatus.soldOut.korean;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: SDSSpacing.md),
        OutlinedButton(
          onPressed: () => _editPost(detail),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: SDSColor.gray200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('게시글 수정하기', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
        ),
        const SizedBox(height: SDSSpacing.sm),
        OutlinedButton(
          onPressed: () => _showStatusSheet(context, detailVm),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: SDSColor.gray200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('거래 상태 설정하기', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
        ),
        if (!isSoldOut) ...[
          const SizedBox(height: SDSSpacing.sm),
          OutlinedButton(
            onPressed: () => detailVm.bumpFleamarket(fleaId: detail.fleaId!),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: SDSColor.gray200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('끌어올리기', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
          ),
        ],
      ],
    );
  }

  Future<void> _editPost(FleamarketDetailModel detail) async {
    final updateVm = Get.find<FleamarketUpdateViewModelWeb>();
    await updateVm.fetchFleamarketUpdateData(
      title: detail.title ?? '',
      categorySub: detail.categorySub ?? kFleamarketCategorySubPlaceholder,
      categoryMain: detail.categoryMain ?? kFleamarketCategoryMainPlaceholder,
      productName: detail.productName ?? '',
      price: detail.price ?? 0,
      tradeMethod: detail.method ?? kFleamarketTradeMethodPlaceholder,
      tradeSpot: detail.spot ?? kFleamarketTradeSpotPlaceholder,
      desc: detail.description ?? '',
      photos: detail.photos,
    );
    updateVm.setIsSelectedCategoryTrue();
    updateVm.setNegotiable(detail.negotiable ?? false);
    Get.toNamed(WebRoutes.fleamarketUpdate);
  }

  void _showStatusSheet(BuildContext context, FleamarketDetailViewModel detailVm) {
    final userVm = Get.find<UserViewModel>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: SDSColor.snowliveWhite, borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final status in FleamarketStatus.values)
                  ListTile(
                    title: Center(
                      child: Text(status.korean, style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900)),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      detailVm.updateStatus(
                        fleamarketId: detail.fleaId!,
                        body: {'user_id': userVm.user.user_id, 'status': status.korean},
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
