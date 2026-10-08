import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_form_fields_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketUpdate_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart' show showWebConfirmDialog;
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
        const SizedBox(height: SDSSpacing.sm),
        OutlinedButton(
          onPressed: () => _confirmDelete(context, detailVm, userVm),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: SDSColor.gray200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('삭제하기', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.red)),
        ),
      ],
    );
  }

  /// 내 게시글 삭제 — 확인 후 삭제하고, 목록을 새로 받도록 플리마켓 홈으로 보낸다.
  Future<void> _confirmDelete(
    BuildContext context,
    FleamarketDetailViewModel detailVm,
    UserViewModel userVm,
  ) async {
    final fleaId = detail.fleaId;
    final userId = userVm.user.user_id;
    if (fleaId == null || userId == null) return;
    final ok = await showWebConfirmDialog(
      context: context,
      title: '게시글을 삭제하시겠어요?',
      message: '삭제한 게시글은 복구할 수 없어요.',
      confirmLabel: '삭제',
      isDestructive: true,
    );
    if (!ok) return;
    await detailVm.deleteFleamarket(fleamarketId: fleaId, userId: userId);
    // 삭제 후 목록을 새로 받도록 홈을 다시 띄운다(core가 성공 시 pop도 하지만,
    // 목록 갱신을 보장하기 위해 홈을 새로 연다).
    Get.offAllNamed(WebRoutes.fleamarketList);
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
      sns: detail.snsUrl ?? '',
      photos: detail.photos,
    );
    updateVm.setIsSelectedCategoryTrue();
    updateVm.setNegotiable(detail.negotiable ?? false);
    Get.toNamed(WebRoutes.fleamarketUpdate);
  }

  void _showStatusSheet(BuildContext context, FleamarketDetailViewModel detailVm) {
    final userVm = Get.find<UserViewModel>();
    showWebOverlayModal<FleamarketStatus>(
      context: context,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.all(16),
      builder: (_, close) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        // ListTile은 Material 조상을 요구한다(Overlay에 직접 꽂아서 Dialog가 없다).
        child: Material(
          color: SDSColor.snowliveWhite,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final status in FleamarketStatus.values)
                  ListTile(
                    title: Center(
                      child: Text(status.korean, style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900)),
                    ),
                    onTap: () => close(status),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).then((status) {
      // 배경 탭으로 닫으면 null.
      if (status == null) return;
      detailVm.updateStatus(
        fleamarketId: detail.fleaId!,
        body: {'user_id': userVm.user.user_id, 'status': status.korean},
      );
    });
  }
}
