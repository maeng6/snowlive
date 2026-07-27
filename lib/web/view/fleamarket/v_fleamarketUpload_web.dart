import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketHome_web.dart' show kFleamarketContentMaxWidth;
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_form_fields_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketPagination_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketUpdate_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketUpload_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 중고거래 새 글 올리기 화면.
class FleamarketUploadViewWeb extends StatelessWidget {
  const FleamarketUploadViewWeb({super.key});

  bool _canSubmit(FleamarketUploadViewModelWeb vm) =>
      vm.isTitleWritten &&
      vm.isProductNameWritten &&
      vm.selectedCategoryMain != kFleamarketCategoryMainPlaceholder &&
      vm.selectedCategorySub != kFleamarketCategorySubPlaceholder &&
      vm.isPriceWritten &&
      vm.selectedTradeMethod != kFleamarketTradeMethodPlaceholder &&
      vm.selectedTradeSpot != kFleamarketTradeSpotPlaceholder &&
      vm.isDescriptionWritten;

  Future<void> _submit(BuildContext context, FleamarketUploadViewModelWeb vm) async {
    final userId = Get.find<UserViewModel>().user.user_id;
    if (userId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    if (!_canSubmit(vm)) {
      Get.snackbar('알림', '필수 항목을 모두 입력해주세요.');
      return;
    }
    // 이미 제출 중이면 무시한다. 버튼 비활성화와 별개로, 연타/중복 호출이 실제로
    // 들어와도 글이 두 번 등록되지 않도록 하는 마지막 방어선.
    if (vm.isSubmitting.value) return;
    vm.isSubmitting.value = true;
    try {
      await _submitInner(context, vm, userId);
    } finally {
      // 성공 시 Get.back()으로 화면을 떠나지만, fenix 바인딩이라 뷰모델은 살아남는다.
      // 반드시 되돌려야 다음 진입에서 버튼이 비활성인 채로 남지 않는다.
      vm.isSubmitting.value = false;
    }
  }

  Future<void> _submitInner(BuildContext context, FleamarketUploadViewModelWeb vm, int userId) async {
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

    await vm.uploadFleamarket(body);
    if (vm.pk == 0) {
      Get.snackbar('오류', '등록에 실패했습니다. 잠시 후 다시 시도해주세요.');
      return;
    }

    if (vm.imageFiles.isNotEmpty) {
      await vm.getImageUrlList(newImages: vm.imageFiles, pk: vm.pk, userId: userId);
      await Get.find<FleamarketUpdateViewModelWeb>().updateFleamarket(
        vm.pk,
        body,
        vm.photos.cast<Map<String, dynamic>>(),
      );
    }

    if (Get.isRegistered<FleamarketPaginationViewModelWeb>()) {
      Get.find<FleamarketPaginationViewModelWeb>().loadFirstPage(userId: userId);
    }
    Get.back();
    Get.snackbar('완료', '게시글이 등록되었습니다.');
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<FleamarketUploadViewModelWeb>();
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
                    Text('내 물건 팔기', style: SDSTextStyle.extraBold.copyWith(fontSize: 22, color: SDSColor.gray900)),
                    const Spacer(),
                    if (!isMobile) ..._buildActionButtons(context, vm),
                  ],
                ),
                const SizedBox(height: SDSSpacing.xl),
                _buildForm(context, vm),
                if (isMobile) ...[
                  const SizedBox(height: SDSSpacing.xl),
                  Row(children: _buildActionButtons(context, vm, expand: true)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context, FleamarketUploadViewModelWeb vm, {bool expand = false}) {
    Widget wrap(Widget child) => expand ? Expanded(child: child) : child;
    // 제출 중에는 임시저장 버튼도 같이 잠가야 하는데, Obx로 판매하기 버튼만 감싸면
    // 임시저장 버튼은 리빌드되지 않아 계속 눌린다. 두 버튼을 하나의 Obx 안에서 만든다.
    return [
      wrap(Obx(() => OutlinedButton(
            onPressed: vm.isSubmitting.value ? null : () => Get.snackbar('알림', '임시저장 기능은 준비 중이에요.'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: SDSColor.gray200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('임시저장', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
          ))),
      const SizedBox(width: SDSSpacing.sm),
      wrap(Obx(() {
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
          // 라벨을 스피너로 "교체"하면 버튼 폭이 튀므로, 라벨은 두고 앞에 끼워 넣는다.
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
              Text('판매하기', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite)),
            ],
          ),
        );
      })),
    ];
  }

  Widget _buildForm(BuildContext context, FleamarketUploadViewModelWeb vm) {
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
              left: FleamarketFormDropdownField<String>(
                label: '전체 카테고리',
                value: vm.selectedCategoryMain,
                placeholder: kFleamarketCategoryMainPlaceholder,
                values: kFleamarketCategoryMainList,
                labelOf: (v) => v,
                onSelected: (v) {
                  vm.selectCategoryMain(v);
                  vm.resetCategorySub();
                },
              ),
              right: FleamarketFormDropdownField<String>(
                label: '상세 카테고리',
                value: vm.selectedCategorySub,
                placeholder: kFleamarketCategorySubPlaceholder,
                // Obx 안이라 전체 카테고리가 바뀌면 이 목록도 다시 계산된다.
                values: vm.selectedCategoryMain == '스키' ? kFleamarketCategorySubSkiList : kFleamarketCategorySubBoardList,
                labelOf: (v) => v,
                onSelected: (v) => vm.selectCategorySub(v),
                canOpen: () {
                  if (vm.selectedCategoryMain == kFleamarketCategoryMainPlaceholder) {
                    Get.snackbar('알림', '전체 카테고리를 먼저 선택해주세요.');
                    return false;
                  }
                  return true;
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
              left: FleamarketFormDropdownField<String>(
                label: '희망 거래 방법',
                value: vm.selectedTradeMethod,
                placeholder: kFleamarketTradeMethodPlaceholder,
                values: kFleamarketTradeMethodList,
                labelOf: (v) => v,
                onSelected: (v) => vm.selectTradeMethod(v),
              ),
              right: FleamarketFormDropdownField<String>(
                label: '거래 희망 장소',
                value: vm.selectedTradeSpot,
                placeholder: kFleamarketTradeSpotPlaceholder,
                values: kFleamarketTradeSpotList,
                labelOf: (v) => v,
                onSelected: (v) => vm.selectTradeSpot(v),
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
  final FleamarketUploadViewModelWeb vm;
  const _PhotoUploadSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FleamarketFormLabel('사진 업로드'),
        Obx(() {
          final files = vm.imageFiles;
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
              for (var i = 0; i < files.length; i++) _photoThumb(files[i], i),
            ],
          );
        }),
        const SizedBox(height: 6),
        Obx(() => Text('${vm.imageFiles.length} / 10장', style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500))),
        const SizedBox(height: 2),
        Text('1장당 3MB 이내로 업로드해주세요. (최대 10장 이내)',
            style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400)),
        Text('대표 사진은 처음 선택한 사진으로 자동 등록됩니다.',
            style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400)),
      ],
    );
  }

  Widget _photoThumb(dynamic xfile, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(xfile.path, width: 72, height: 72, fit: BoxFit.cover),
        ),
        if (index == 0)
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
            onTap: () => vm.removeSelectedImage(index),
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
