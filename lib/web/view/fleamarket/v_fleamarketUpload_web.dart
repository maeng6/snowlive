import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_form_fields_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketPagination_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketUpdate_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketUpload_web.dart';
import 'package:com.snowlive/web/widget/w_web_back_icon_web.dart';
import 'package:com.snowlive/web/widget/w_web_floating_bottombar_web.dart';
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

  Future<void> _submit(
    BuildContext context,
    FleamarketUploadViewModelWeb vm,
  ) async {
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

  Future<void> _submitInner(
    BuildContext context,
    FleamarketUploadViewModelWeb vm,
    int userId,
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

    await vm.uploadFleamarket(body);
    if (vm.pk == 0) {
      Get.snackbar('오류', '등록에 실패했습니다. 잠시 후 다시 시도해주세요.');
      return;
    }

    if (vm.imageFiles.isNotEmpty) {
      await vm.getImageUrlList(
        newImages: vm.imageFiles,
        pk: vm.pk,
        userId: userId,
      );
      await Get.find<FleamarketUpdateViewModelWeb>().updateFleamarket(
        vm.pk,
        body,
        vm.photos.cast<Map<String, dynamic>>(),
      );
    }

    if (Get.isRegistered<FleamarketPaginationViewModelWeb>()) {
      Get.find<FleamarketPaginationViewModelWeb>().loadFirstPage(
        userId: userId,
      );
    }
    Get.back();
    Get.snackbar('완료', '게시글이 등록되었습니다.');
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<FleamarketUploadViewModelWeb>();
    final isMobile = context.screenType == WebScreenType.mobile;
    final isDesktop = context.isDesktop;

    final Widget scroll = SingleChildScrollView(
      // 여백은 스크롤 영역 안쪽(서브 페이지 공통) — 모바일은 콘텐츠가 하단
      // 플로팅 바 뒤로 지나가도록 바 높이만큼 하단 여백을 확보한다.
      padding: webSubPagePadding(
        context,
        bottom: isMobile
            ? kWebFloatingBottomBarHeight + SDSSpacing.md
            : SDSSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          // PC만 상세와 같은 800 고정 중앙(피그마 62:98906) — 태블릿·모바일은
          // 제한 없이 화면(패딩 제외)을 가득 채운다(상세와 동일 규칙).
          constraints: BoxConstraints(
            maxWidth: isDesktop
                ? kWebSubPageMaxWidth
                : double.infinity,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  WebIconButton(
                    onTap: () => Get.back(),
                    // 좌측 히트 여백만 0 — 아이콘이 콘텐츠 좌측선에 붙는다
                    padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
                    // 뒤로가기: PC·태블릿 30 / 모바일 24 (상세와 동일).
                    icon: WebBackIcon(size: isMobile ? 24 : 30),
                  ),
                  // 뒤로가기 ↔ 제목 3(에셋 좌측 상쇄 오프셋 반영해 눈으로 맞춘 값),
                  // 제목 bold PC 30(피그마 62:98906) / 태블릿·모바일 24(피그마 62:98390).
                  const SizedBox(width: 3),
                  Text(
                    '내 물건 팔기',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: isDesktop ? 30 : 24,
                      color: SDSColor.gray900,
                    ),
                  ),
                  const Spacer(),
                  if (!isMobile) ..._buildActionButtons(context, vm),
                ],
              ),
              // 헤더 줄 ↔ 폼 PC 40(피그마 62:98906) / 태블릿·모바일 26
              // (피그마 62:98390 — 버튼 줄 하단 110 → 첫 라벨 136).
              SizedBox(height: webFormHeaderGap(context)),
              _buildForm(context, vm),
            ],
          ),
        ),
      ),
    );

    if (!isMobile) {
      return Container(color: SDSColor.snowliveWhite, child: scroll);
    }
    // 모바일: 하단 플로팅 바 — 목록 하단바와 동일 규격(페이드 + 버튼 48).
    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          scroll,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: WebFloatingBottomBar(
              child: _buildMobileBottomButtons(context, vm),
            ),
          ),
        ],
      ),
    );
  }

  /// 모바일 하단 플로팅 바 버튼 줄 — 임시저장 100 고정 + 판매하기 나머지,
  /// 간격 10 (피그마 62:98468). 버튼 규격(높이 48)은 목록 하단바와 동일.
  Widget _buildMobileBottomButtons(
    BuildContext context,
    FleamarketUploadViewModelWeb vm,
  ) {
    return Obx(() {
      final isSubmitting = vm.isSubmitting.value;
      return Row(
        children: [
          SizedBox(
            width: 100,
            child: WebBottomBarButton(
              label: '임시저장',
              background: SDSColor.snowliveWhite,
              foreground: SDSColor.gray900,
              onTap: isSubmitting
                  ? null
                  : () => Get.snackbar('알림', '임시저장 기능은 준비 중이에요.'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: WebBottomBarButton(
              label: '판매하기',
              background: SDSColor.snowliveBlue,
              foreground: SDSColor.snowliveWhite,
              onTap: (_canSubmit(vm) && !isSubmitting)
                  ? () => _submit(context, vm)
                  : null,
              leading: isSubmitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          SDSColor.snowliveWhite,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      );
    });
  }

  List<Widget> _buildActionButtons(
    BuildContext context,
    FleamarketUploadViewModelWeb vm, {
    bool expand = false,
  }) {
    Widget wrap(Widget child) => expand ? Expanded(child: child) : child;
    // 제출 중에는 임시저장 버튼도 같이 잠가야 하는데, Obx로 판매하기 버튼만 감싸면
    // 임시저장 버튼은 리빌드되지 않아 계속 눌린다. 두 버튼을 하나의 Obx 안에서 만든다.
    return [
      // 목업: 임시저장은 테두리 없는 텍스트 버튼이다(bold 16, 패딩 16/10).
      // visualDensity가 버튼 최소 높이를 깎으므로 SizedBox로 40을 강제한다.
      wrap(
        Obx(
          () => SizedBox(
            height: 40,
            child: TextButton(
              onPressed: vm.isSubmitting.value
                  ? null
                  : () => Get.snackbar('알림', '임시저장 기능은 준비 중이에요.'),
              style: TextButton.styleFrom(
                // 높이 40 고정(피그마 comp_button) — visualDensity에 눌리지 않게 한다.
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                '임시저장',
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 16,
                  color: SDSColor.gray900,
                ),
              ),
            ),
          ),
        ),
      ),
      // 버튼 사이 10 (피그마 62:98906).
      const SizedBox(width: 10),
      wrap(
        Obx(() {
          final isSubmitting = vm.isSubmitting.value;
          return SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: (_canSubmit(vm) && !isSubmitting)
                  ? () => _submit(context, vm)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: SDSColor.snowliveBlue,
                disabledBackgroundColor: SDSColor.gray200,
                elevation: 0,
                // 높이 40 고정(피그마 comp_button) — visualDensity에 눌리지 않게 한다.
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                // 목업 지정 라운드 5.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          SDSColor.snowliveWhite,
                        ),
                      ),
                    ),
                    const SizedBox(width: SDSSpacing.sm),
                  ],
                  Text(
                    '판매하기',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 16,
                      color: SDSColor.snowliveWhite,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    ];
  }

  Widget _buildForm(BuildContext context, FleamarketUploadViewModelWeb vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WebFormTextField(
          label: '제목',
          controller: vm.textEditingController_title,
          hint: '글 제목을 입력해 주세요. (최대 50자 이내)',
          maxLength: 50,
          onChanged: (v) => vm.changeTitleWritten(v.trim().isNotEmpty),
        ),
        // 필드 사이 30 (피그마 62:98906).
        const SizedBox(height: 30),
        WebFormTextField(
          label: '제품명',
          controller: vm.textEditingController_productName,
          hint: '제품명을 입력해 주세요. (최대 20자 이내)',
          maxLength: 20,
          onChanged: (v) => vm.changeProductNameWritten(v.trim().isNotEmpty),
        ),
        // 필드 사이 30 (피그마 62:98906).
        const SizedBox(height: 30),
        Obx(
          () => WebFormTwoColumnRow(
            left: WebFormDropdownField<String>(
              anchoredOnTablet: true,
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
            right: WebFormDropdownField<String>(
              anchoredOnTablet: true,
              label: '상세 카테고리',
              value: vm.selectedCategorySub,
              placeholder: kFleamarketCategorySubPlaceholder,
              // Obx 안이라 전체 카테고리가 바뀌면 이 목록도 다시 계산된다.
              values: vm.selectedCategoryMain == '스키'
                  ? kFleamarketCategorySubSkiList
                  : kFleamarketCategorySubBoardList,
              labelOf: (v) => v,
              onSelected: (v) => vm.selectCategorySub(v),
              canOpen: () {
                if (vm.selectedCategoryMain ==
                    kFleamarketCategoryMainPlaceholder) {
                  Get.snackbar('알림', '전체 카테고리를 먼저 선택해주세요.');
                  return false;
                }
                return true;
              },
            ),
          ),
        ),
        // 필드 사이 30 (피그마 62:98906).
        const SizedBox(height: 30),
        WebFormTextField(
          label: '가격',
          controller: vm.itemPriceTextEditingController,
          hint: '금액을 입력해 주세요.',
          suffixText: '원',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          onChanged: (v) => vm.changePriceWritten(v.trim().isNotEmpty),
        ),
        // 가격 인풋 ↔ 체크 줄 12 (피그마 62:98906).
        const SizedBox(height: 12),
        Obx(
          () => _NegotiableToggle(
            value: vm.negotiable,
            onTap: vm.toggleNegotiable,
          ),
        ),
        // 필드 사이 30 (피그마 62:98906).
        const SizedBox(height: 30),
        _PhotoUploadSection(vm: vm),
        // 필드 사이 30 (피그마 62:98906).
        const SizedBox(height: 30),
        Obx(
          () => WebFormTwoColumnRow(
            left: WebFormDropdownField<String>(
              anchoredOnTablet: true,
              label: '희망 거래 방법',
              value: vm.selectedTradeMethod,
              placeholder: kFleamarketTradeMethodPlaceholder,
              values: kFleamarketTradeMethodList,
              labelOf: (v) => v,
              onSelected: (v) => vm.selectTradeMethod(v),
            ),
            right: WebFormDropdownField<String>(
              anchoredOnTablet: true,
              label: '거래 희망 장소',
              value: vm.selectedTradeSpot,
              placeholder: kFleamarketTradeSpotPlaceholder,
              values: kFleamarketTradeSpotList,
              labelOf: (v) => v,
              onSelected: (v) => vm.selectTradeSpot(v),
            ),
          ),
        ),
        // 필드 사이 30 (피그마 62:98906).
        const SizedBox(height: 30),
        WebFormTextField(
          label: '카카오 오픈채팅 URL',
          controller: vm.textEditingController_sns,
          hint: 'URL',
          helperText:
              '카카오톡에서 오픈채팅 URL을 복사할 경우, 다른 텍스트가 함께 복사되기 때문에 URL 부분만 입력되도록 확인 후 입력 부탁드립니다.',
        ),
        // 필드 사이 30 (피그마 62:98906).
        const SizedBox(height: 30),
        WebFormTextField(
          label: '상세 설명',
          controller: vm.textEditingController_desc,
          hint:
              '상품에 대한 상세 설명을 작성해 주세요. (최대 1,000자 이내)\n\n부적절한 단어나 문장이 포함되는 경우 사전 고지없이 게시글 삭제가 될 수 있습니다.',
          maxLength: 1000,
          expands: true,
          // 피그마 62:98906 — 상세 설명 208.
          height: 208,
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
        // 피그마 62:98906 — 아이콘 24 + 간격 6 + regular 13 검정.
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 앱과 동일한 체크 에셋(icon_check_filled/unfilled).
            Image.asset(
              value
                  ? 'assets/imgs/icons/icon_check_filled.png'
                  : 'assets/imgs/icons/icon_check_unfilled.png',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 6),
            Text(
              '가격 제안 가능 안내하기',
              style: SDSTextStyle.regular.copyWith(
                fontSize: 13,
                color: SDSColor.gray900,
              ),
            ),
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
        const WebFormLabel('사진 업로드'),
        Obx(() {
          final files = vm.imageFiles;
          return Wrap(
            spacing: SDSSpacing.sm,
            runSpacing: SDSSpacing.sm,
            children: [
              InkWell(
                onTap: vm.isGettingImageFromGallery
                    ? null
                    : vm.getImageFromGallery,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: SDSColor.gray50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: vm.isGettingImageFromGallery
                      ? const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                SDSColor.gray400,
                              ),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.camera_alt_rounded,
                          size: 24,
                          color: SDSColor.gray400,
                        ),
                ),
              ),
              for (var i = 0; i < files.length; i++) _photoThumb(files[i], i),
            ],
          );
        }),
        // 피그마 62:98906 — 박스↔카운트 8(13px), 카운트↔안내 8(12px 2줄).
        const SizedBox(height: 8),
        Obx(
          () => Text(
            '${vm.imageFiles.length} / 5장',
            style: SDSTextStyle.regular.copyWith(
              fontSize: 13,
              color: SDSColor.gray500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '1장당 3MB 이내로 업로드해주세요. (최대 5장 이내)',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 12,
            color: SDSColor.gray400,
          ),
        ),
        Text(
          '대표 사진은 처음 선택한 사진으로 자동 등록됩니다.',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 12,
            color: SDSColor.gray400,
          ),
        ),
      ],
    );
  }

  Widget _photoThumb(dynamic xfile, int index) {
    return Stack(
      children: [
        // 연한 보더 + 라운드. 보더는 이미지 위에 겹쳐 그려 크기 변화가 없다.
        Container(
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SDSColor.gray100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              xfile.path,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (index == 0)
          Positioned(
            left: 2,
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '대표사진',
                style: TextStyle(color: Colors.white, fontSize: 9),
              ),
            ),
          ),
        // 닫기 버튼이 스택 밖(-4)에 있으면 기본 클립에 잘린다 → 안쪽 모서리에 둔다.
        Positioned(
          right: 4,
          top: 4,
          child: InkWell(
            onTap: () => vm.removeSelectedImage(index),
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
