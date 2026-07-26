import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketHome_web.dart' show kFleamarketContentMaxWidth;
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_filter_sheet_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_form_fields_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketPagination_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketUpdate_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 중고거래 글 수정 화면. 진입 전에 FleamarketUpdateViewModelWeb가
/// fetchFleamarketUpdateData(...)로 이미 채워져 있다고 가정한다
/// (진입점: FleamarketDetailOwnerActionsWeb의 "게시글 수정하기").
class FleamarketUpdateViewWeb extends StatelessWidget {
  const FleamarketUpdateViewWeb({super.key});

  bool _canSubmit(FleamarketUpdateViewModelWeb vm) =>
      vm.isTitleWritten &&
      vm.isProductNameWritten &&
      vm.selectedCategoryMain != kFleamarketCategoryMainPlaceholder &&
      vm.selectedCategorySub != kFleamarketCategorySubPlaceholder &&
      vm.isPriceWritten &&
      vm.selectedTradeMethod != kFleamarketTradeMethodPlaceholder &&
      vm.selectedTradeSpot != kFleamarketTradeSpotPlaceholder &&
      vm.isDescriptionWritten;

  Future<void> _submit(BuildContext context, FleamarketUpdateViewModelWeb vm) async {
    final userId = Get.find<UserViewModel>().user.user_id;
    final detailVm = Get.find<FleamarketDetailViewModel>();
    final fleaId = detailVm.fleamarketDetail.fleaId;
    if (userId == null || fleaId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    if (!_canSubmit(vm)) {
      Get.snackbar('알림', '필수 항목을 모두 입력해주세요.');
      return;
    }
    // 버튼 비활성화와 별개로, 연타/중복 호출이 실제로 들어와도 한 번만 전송되게 한다.
    if (vm.isSubmitting.value) return;
    vm.isSubmitting.value = true;
    try {
      await _submitInner(context, vm, userId, fleaId);
    } finally {
      // fenix 바인딩이라 화면을 떠나도 뷰모델이 살아남으므로 반드시 되돌린다.
      vm.isSubmitting.value = false;
    }
  }

  Future<void> _submitInner(
    BuildContext context,
    FleamarketUpdateViewModelWeb vm,
    int userId,
    int fleaId,
  ) async {
    final body = {
      'user_id': userId,
      'product_name': vm.textEditingController_productName.text,
      'category_main': vm.selectedCategoryMain,
      'category_sub': vm.selectedCategorySub,
      'price': vm.itemPriceTextEditingController.text,
      'negotiable': vm.negotiable,
      'method': vm.selectedTradeMethod,
      'spot': vm.selectedTradeSpot,
      'sns_url': vm.textEditingController_sns.text.trim(),
      'title': vm.textEditingController_title.text,
      'description': vm.textEditingController_desc.text,
    };

    // 남겨진 기존 사진 + 새로 추가된 사진을 순서대로 합쳐서 최종 photos 배열을 만든다.
    if (vm.newImageFiles.isNotEmpty) {
      await vm.getImageUrlList(newImages: vm.newImageFiles, pk: fleaId, userId: userId);
    }
    final merged = <Map<String, dynamic>>[
      for (final url in vm.existingImageUrls) {'url_flea_photo': url},
      ...vm.photos.cast<Map<String, dynamic>>(),
    ];
    for (var i = 0; i < merged.length; i++) {
      merged[i] = {...merged[i], 'display_order': i + 1};
    }

    await vm.updateFleamarket(fleaId, body, merged);
    await Get.find<FleamarketDetailViewModel>()
        .fetchFleamarketDetailFromAPI(fleamarketId: fleaId, userId: userId);
    if (Get.isRegistered<FleamarketPaginationViewModelWeb>()) {
      Get.find<FleamarketPaginationViewModelWeb>().loadFirstPage(userId: userId);
    }
    Get.back();
    Get.snackbar('완료', '게시글이 수정되었습니다.');
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<FleamarketUpdateViewModelWeb>();
    final isMobile = context.screenType == WebScreenType.mobile;

    return Container(
      color: SDSColor.snowliveWhite,
      padding: EdgeInsets.fromLTRB(
        context.isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        32,
        context.isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        SDSSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kFleamarketContentMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(onPressed: () => Get.back(), icon: Icon(Icons.arrow_back, color: SDSColor.gray900)),
                    const SizedBox(width: SDSSpacing.sm),
                    Text('글 수정', style: SDSTextStyle.extraBold.copyWith(fontSize: 22, color: SDSColor.gray900)),
                    const Spacer(),
                    if (!isMobile) _submitButton(context, vm),
                  ],
                ),
                const SizedBox(height: SDSSpacing.xl),
                _buildForm(context, vm),
                if (isMobile) ...[
                  const SizedBox(height: SDSSpacing.xl),
                  SizedBox(width: double.infinity, child: _submitButton(context, vm)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context, FleamarketUpdateViewModelWeb vm) {
    return Obx(() {
      final isSubmitting = vm.isSubmitting.value;
      return ElevatedButton(
        onPressed: (_canSubmit(vm) && !isSubmitting) ? () => _submit(context, vm) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: SDSColor.snowliveBlue,
          disabledBackgroundColor: SDSColor.gray200,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        // 라벨을 스피너로 교체하면 버튼 폭이 튀므로 라벨은 두고 앞에 끼워 넣는다.
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSubmitting) ...[
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(SDSColor.snowliveWhite),
                ),
              ),
              const SizedBox(width: SDSSpacing.sm),
            ],
            Text('수정하기', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite)),
          ],
        ),
      );
    });
  }

  Widget _buildForm(BuildContext context, FleamarketUpdateViewModelWeb vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FleamarketFormTextField(
          label: '제목',
          controller: vm.textEditingController_title,
          hint: '글 제목을 입력해 주세요. (최대 50자 이내)',
          maxLength: 50,
          onChanged: (v) => vm.changeTitleWritten(v.trim().isNotEmpty),
        ),
        const SizedBox(height: SDSSpacing.lg),
        FleamarketFormTextField(
          label: '제품명',
          controller: vm.textEditingController_productName,
          hint: '제품명을 입력해 주세요. (최대 20자 이내)',
          maxLength: 20,
          onChanged: (v) => vm.changeProductNameWritten(v.trim().isNotEmpty),
        ),
        const SizedBox(height: SDSSpacing.lg),
        Obx(() => FleamarketFormTwoColumnRow(
              left: FleamarketFormDropdownField(
                label: '전체 카테고리',
                value: vm.selectedCategoryMain,
                placeholder: kFleamarketCategoryMainPlaceholder,
                onTap: () => showFleamarketFilterSheet<String>(
                  context,
                  values: kFleamarketCategoryMainList,
                  labelOf: (v) => v,
                  onSelected: (v) {
                    vm.selectCategoryMain(v);
                    vm.resetCategorySub();
                  },
                ),
              ),
              right: FleamarketFormDropdownField(
                label: '상세 카테고리',
                value: vm.selectedCategorySub,
                placeholder: kFleamarketCategorySubPlaceholder,
                onTap: () {
                  if (vm.selectedCategoryMain == kFleamarketCategoryMainPlaceholder) {
                    Get.snackbar('알림', '전체 카테고리를 먼저 선택해주세요.');
                    return;
                  }
                  final list = vm.selectedCategoryMain == '스키' ? kFleamarketCategorySubSkiList : kFleamarketCategorySubBoardList;
                  showFleamarketFilterSheet<String>(
                    context,
                    values: list,
                    labelOf: (v) => v,
                    onSelected: (v) => vm.selectCategorySub(v),
                  );
                },
              ),
            )),
        const SizedBox(height: SDSSpacing.lg),
        FleamarketFormTextField(
          label: '가격',
          controller: vm.itemPriceTextEditingController,
          hint: '금액을 입력해 주세요.',
          suffixText: '원',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
          onChanged: (v) => vm.changePriceWritten(v.trim().isNotEmpty),
        ),
        const SizedBox(height: SDSSpacing.sm),
        Obx(() => _NegotiableToggle(value: vm.negotiable, onTap: vm.toggleNegotiable)),
        const SizedBox(height: SDSSpacing.lg),
        _PhotoUploadSection(vm: vm),
        const SizedBox(height: SDSSpacing.lg),
        Obx(() => FleamarketFormTwoColumnRow(
              left: FleamarketFormDropdownField(
                label: '희망 거래 방법',
                value: vm.selectedTradeMethod,
                placeholder: kFleamarketTradeMethodPlaceholder,
                onTap: () => showFleamarketFilterSheet<String>(
                  context,
                  values: kFleamarketTradeMethodList,
                  labelOf: (v) => v,
                  onSelected: (v) => vm.selectTradeMethod(v),
                ),
              ),
              right: FleamarketFormDropdownField(
                label: '거래 희망 장소',
                value: vm.selectedTradeSpot,
                placeholder: kFleamarketTradeSpotPlaceholder,
                onTap: () => showFleamarketFilterSheet<String>(
                  context,
                  values: kFleamarketTradeSpotList,
                  labelOf: (v) => v,
                  onSelected: (v) => vm.selectTradeSpot(v),
                ),
              ),
            )),
        const SizedBox(height: SDSSpacing.lg),
        FleamarketFormTextField(
          label: '카카오 오픈채팅 URL',
          controller: vm.textEditingController_sns,
          hint: 'URL',
          helperText: '카카오톡에서 오픈채팅 URL을 복사할 경우, 다른 텍스트가 함께 복사되기 때문에 URL 부분만 입력되도록 확인 후 입력 부탁드립니다.',
        ),
        const SizedBox(height: SDSSpacing.lg),
        FleamarketFormTextField(
          label: '상세 설명',
          controller: vm.textEditingController_desc,
          hint: '상품에 대한 상세 설명을 작성해 주세요. (최대 1,000자 이내)\n\n부적절한 단어나 문장이 포함되는 경우 사전 고지없이 게시글 삭제가 될 수 있습니다.',
          maxLength: 1000,
          expands: true,
          height: 180,
          onChanged: (v) => vm.changeDescriptionWritten(v.trim().isNotEmpty),
        ),
      ],
    );
  }
}

class _NegotiableToggle extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;
  const _NegotiableToggle({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Icons.check_circle : Icons.check_circle_outline,
              size: 20,
              color: value ? SDSColor.snowliveBlue : SDSColor.gray300,
            ),
            const SizedBox(width: 8),
            Text('가격 제안 가능 안내하기', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray700)),
          ],
        ),
      ),
    );
  }
}

class _PhotoUploadSection extends StatelessWidget {
  final FleamarketUpdateViewModelWeb vm;
  const _PhotoUploadSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FleamarketFormLabel('사진 업로드'),
        Obx(() {
          final existing = vm.existingImageUrls;
          final newFiles = vm.newImageFiles;
          return Wrap(
            spacing: SDSSpacing.sm,
            runSpacing: SDSSpacing.sm,
            children: [
              InkWell(
                onTap: vm.isGettingImageFromGallery ? null : vm.getImageFromGallery,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(8)),
                  child: vm.isGettingImageFromGallery
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.camera_alt_outlined, color: SDSColor.gray400),
                ),
              ),
              for (var i = 0; i < existing.length; i++)
                _photoThumb(
                  isFirst: i == 0,
                  onRemove: () => vm.removeExistingImage(i),
                  child: Image.network(existing[i], width: 72, height: 72, fit: BoxFit.cover),
                ),
              for (var i = 0; i < newFiles.length; i++)
                _photoThumb(
                  isFirst: existing.isEmpty && i == 0,
                  onRemove: () => vm.removeNewImage(i),
                  child: Image.network(newFiles[i]!.path, width: 72, height: 72, fit: BoxFit.cover),
                ),
            ],
          );
        }),
        const SizedBox(height: 6),
        Obx(() => Text('${vm.totalImageCount} / 10장', style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500))),
        const SizedBox(height: 2),
        Text('1장당 3MB 이내로 업로드해주세요. (최대 10장 이내)',
            style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400)),
        Text('대표 사진은 처음 선택한 사진으로 자동 등록됩니다.',
            style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400)),
      ],
    );
  }

  Widget _photoThumb({required Widget child, required bool isFirst, required VoidCallback onRemove}) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
        if (isFirst)
          Positioned(
            left: 2,
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4)),
              child: const Text('대표사진', style: TextStyle(color: Colors.white, fontSize: 9)),
            ),
          ),
        Positioned(
          right: -4,
          top: -4,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
