import 'dart:io';

import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/liveTalk/vm_liveTalk.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// ✅ InputArea는 "입력 UI만" 담당 (미리보기 제거)
class LiveTalkInputArea extends StatefulWidget {
  const LiveTalkInputArea({Key? key}) : super(key: key);

  @override
  State<LiveTalkInputArea> createState() => _LiveTalkInputAreaState();
}

class _LiveTalkInputAreaState extends State<LiveTalkInputArea> {
  final LiveTalkViewModel _liveTalkViewModel = Get.find<LiveTalkViewModel>();
  final GlobalKey _inputAreaKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // 텍스트 변경 시 높이 업데이트
    _liveTalkViewModel.textController.addListener(_updateHeight);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
  }

  @override
  void dispose() {
    _liveTalkViewModel.textController.removeListener(_updateHeight);
    super.dispose();
  }

  void _updateHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_inputAreaKey.currentContext != null) {
        final RenderBox renderBox = _inputAreaKey.currentContext!.findRenderObject() as RenderBox;
        _liveTalkViewModel.inputAreaHeight.value = renderBox.size.height;
      }
    });
  }

  void _showImagePickerOptions(BuildContext context, LiveTalkViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // UI 그대로
      builder: (context) => Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          color: SDSColor.snowliveWhite,
        ),
        child: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              color: SDSColor.snowliveWhite,
            ),
            padding: const EdgeInsets.only(bottom: 20, right: 20, left: 20, top: 12),
            height: 210,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        height: 4,
                        width: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: SDSColor.gray200,
                        ),
                      ),
                    ),
                    Text(
                      '업로드 방법을 선택해주세요.',
                      style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '업로드할 이미지를 선택해 주세요.\n이미지는 최대 1장까지 업로드할 수 있습니다.',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 14,
                        color: SDSColor.gray500,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const Expanded(child: SizedBox()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          viewModel.pickImageFromCamera();
                        },
                        style: TextButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                          splashFactory: InkRipple.splashFactory,
                          elevation: 0,
                          minimumSize: const Size(100, 48),
                          backgroundColor: SDSColor.sBlue500,
                        ),
                        child: Text(
                          '사진 촬영',
                          style: SDSTextStyle.bold.copyWith(
                            color: SDSColor.snowliveWhite,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          viewModel.pickImageFromGallery();
                        },
                        style: TextButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                          splashFactory: InkRipple.splashFactory,
                          elevation: 0,
                          minimumSize: const Size(100, 48),
                          backgroundColor: SDSColor.snowliveBlue,
                        ),
                        child: Text(
                          '앨범에서 선택',
                          style: SDSTextStyle.bold.copyWith(
                            color: SDSColor.snowliveWhite,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _inputAreaKey,
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 업로드 중 표시
            Obx(() {
              if (_liveTalkViewModel.isPosting.value) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: SDSColor.gray100,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SDSColor.gray600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _liveTalkViewModel.isEditMode.value ? '게시물 수정 중...' : '게시물 업로드 중...',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 13,
                          color: SDSColor.gray600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // 수정 모드 표시
            Obx(() {
              if (_liveTalkViewModel.isEditMode.value && !_liveTalkViewModel.isPosting.value) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: SDSColor.snowliveBlue.withOpacity(0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 16, color: SDSColor.snowliveBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '게시물 수정 중',
                          style: SDSTextStyle.regular.copyWith(
                            fontSize: 13,
                            color: SDSColor.snowliveBlue,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _liveTalkViewModel.cancelEditMode(),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: SDSColor.gray500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // ✅ 미리보기 영역 제거됨

            // 입력 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 이미지 선택 버튼
                  GestureDetector(
                    onTap: () => _showImagePickerOptions(context, _liveTalkViewModel),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/imgs/icons/icon_input_camera.svg',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 텍스트 입력 필드 (전송 버튼 포함)
                  Expanded(
                    child: Obx(() {
                      final isEnabled = _liveTalkViewModel.isButtonEnabled.value;
                      final isPosting = _liveTalkViewModel.isPosting.value;
                      final isEditMode = _liveTalkViewModel.isEditMode.value;
                      final canTap = isEnabled && !isPosting;

                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 36,
                          maxHeight: 120,
                        ),
                        child: TextFormField(
                          controller: _liveTalkViewModel.textController,
                          cursorColor: SDSColor.snowliveBlue,
                          cursorHeight: 16,
                          cursorWidth: 2,
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          style: SDSTextStyle.regular.copyWith(
                            fontSize: 14,
                            color: SDSColor.snowliveBlack,
                            height: 1.3
                          ),
                          decoration: InputDecoration(
                            hintText: '라이브톡을 남겨주세요.',
                            hintStyle: SDSTextStyle.regular.copyWith(
                              fontSize: 14,
                              color: SDSColor.gray400,
                            ),
                            contentPadding: EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                              left: 10,
                              right: 50,
                            ),
                            fillColor: SDSColor.gray50,
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: SDSColor.gray50),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: SDSColor.snowliveBlue,
                                strokeAlign: BorderSide.strokeAlignInside,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            isDense: true,
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 24,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: canTap
                                  ? () async {
                                FocusScope.of(context).unfocus();
                                if (isEditMode) {
                                  await _liveTalkViewModel.updateEditingPost();
                                } else {
                                  await _liveTalkViewModel.createPost();
                                }
                              }
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: isEditMode
                                    ? Icon(
                                  Icons.check,
                                  color: canTap ? SDSColor.snowliveBlue : SDSColor.gray300,
                                  size: 24,
                                )
                                    : Image.asset(
                                  canTap
                                      ? 'assets/imgs/icons/icon_livetalk_send.png'
                                      : 'assets/imgs/icons/icon_livetalk_send_g.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ (NEW) Preview Layer widget (same file) - 메인뷰 Stack에서 Positioned로 사용
class LiveTalkPreviewLayer extends StatelessWidget {
  const LiveTalkPreviewLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LiveTalkViewModel viewModel = Get.find<LiveTalkViewModel>();

    return Obx(() {
      // selectedRidingCardType 변경 감지를 위해 참조
      final _ = viewModel.selectedRidingCardType.value;

      if (viewModel.selectedImage.value != null) {
        return _buildImagePreview(viewModel);
      }
      if (viewModel.selectedRidingCard.value != null) {
        return _buildRidingCardPreview(viewModel);
      }
      if (viewModel.isEditMode.value &&
          viewModel.editingLiveTalk.value?.imageUrl != null &&
          viewModel.editingLiveTalk.value!.imageUrl!.isNotEmpty) {
        return _buildExistingImagePreview(viewModel);
      }

      return const SizedBox.shrink();
    });
  }

  Widget _buildExistingImagePreview(LiveTalkViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                viewModel.editingLiveTalk.value!.imageUrl!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => viewModel.removeExistingImage(),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(LiveTalkViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(viewModel.selectedImage.value!.path),
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Obx(() {
            if (viewModel.isUploadingImage.value) {
              return const SizedBox.shrink();
            }
            return Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => viewModel.removeImage(),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRidingCardPreview(LiveTalkViewModel viewModel) {
    final card = viewModel.selectedRidingCard.value!;
    final cardType = viewModel.selectedRidingCardType.value;
    final UserViewModel userViewModel = Get.find<UserViewModel>();

    const double cardWidth = 200;
    const double cardHeight = cardWidth * (1524 / 960);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: RepaintBoundary(
              key: viewModel.ridingCardKey,
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          cardType == 0
                              ? 'assets/imgs/imgs/img_summury_bg.png'
                              : 'assets/imgs/imgs/img_summury_bg_2.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 17,
                        left: 12,
                        right: 12,
                        child: Column(
                          children: [
                            Container(
                              width: 43,
                              height: 43,
                              decoration: const BoxDecoration(shape: BoxShape.circle),
                              child: ClipOval(
                                child: (userViewModel.user.profile_image_url_user?.isNotEmpty ??
                                    false)
                                    ? ExtendedImage.network(
                                  userViewModel.user.profile_image_url_user!,
                                  fit: BoxFit.cover,
                                  cache: true,
                                  loadStateChanged: (state) {
                                    if (state.extendedImageLoadState == LoadState.failed) {
                                      return Image.asset(
                                        'assets/imgs/profile/img_profile_default_circle.png',
                                        fit: BoxFit.cover,
                                      );
                                    }
                                    return null;
                                  },
                                )
                                    : Image.asset(
                                  'assets/imgs/profile/img_profile_default_circle.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userViewModel.user.display_name ?? '',
                              style: SDSTextStyle.bold.copyWith(
                                fontSize: 9,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${card.date ?? ''} ${card.weekday ?? ''}',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 6,
                                color: Colors.white,
                              ),
                            ),
                            if (card.riderTitle != null && card.riderTitle!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cardType == 0
                                      ? const Color(0xFF1B3A5C)
                                      : const Color(0xFFE2EDF8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  card.riderTitle!,
                                  style: SDSTextStyle.regular.copyWith(
                                    fontSize: 6,
                                    color: cardType == 0 ? Colors.white : const Color(0xFF000000),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Positioned(
                        top: 103,
                        bottom: 29,
                        left: 6,
                        right: 6,
                        child: Center(
                          child: cardType == 0
                              ? _buildPreviewCardType0Content(card)
                              : _buildPreviewCardType1Content(card),
                        ),
                      ),
                      Positioned(
                        bottom: 9,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Image.asset(
                            'assets/imgs/logos/snowliveLogo_main_white.png',
                            height: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Obx(() {
            if (viewModel.isUploadingImage.value) {
              return const SizedBox.shrink();
            }
            return Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => viewModel.removeRidingCard(),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPreviewCardType0Content(dynamic card) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${card.totalSlopeCount ?? 0}',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 20,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '오늘 총 라이딩',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 6,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 9),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    card.mostRiddenSlope?.isNotEmpty == true ? card.mostRiddenSlope! : '-',
                    style: SDSTextStyle.extraBold.copyWith(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if ((card.mostRiddenCount ?? 0) > 0)
                    Text(
                      '${card.mostRiddenCount}회',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 7,
                        color: Colors.white,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    '최다 슬로프',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 6,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        (card.topSpeed ?? 0).toStringAsFixed(1),
                        style: SDSTextStyle.extraBold.copyWith(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'km/h',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 7,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '최고 속도',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 6,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewCardType1Content(dynamic card) {
    final slopeEntries = card.slopeCountsByName?.entries.toList() ?? [];
    final firstSlope = slopeEntries.isNotEmpty ? slopeEntries.first : null;
    final restSlopes = slopeEntries.length > 1 ? slopeEntries.sublist(1) : [];
    final displaySlopes = restSlopes.take(2).toList();
    final remainingCount = restSlopes.length - displaySlopes.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${card.totalSlopeCount ?? 0}',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 20,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '오늘 총 라이딩',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 6,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          firstSlope?.key ?? '-',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 14,
            color: Colors.white,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (displaySlopes.isNotEmpty) ...[
          const SizedBox(height: 3),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 2,
            children: [
              ...displaySlopes.map((entry) {
                return Text(
                  entry.key,
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 7,
                    color: Colors.white,
                  ),
                );
              }),
              if (remainingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+$remainingCount',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 6,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 3),
        Text(
          '라이딩 슬로프',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 6,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
