import 'dart:io';

import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/liveTalk/vm_liveTalk.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';

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
            // ✅ 수정 모드 표시 - main.dart Stack으로 이동됨

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
                                child: Image.asset(
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
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF000000).withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                viewModel.editingLiveTalk.value!.imageUrl!,
                height: 120,
                fit: BoxFit.contain,
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
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF000000).withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(viewModel.selectedImage.value!.path),
                height: 120,
                fit: BoxFit.contain,
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
    // 높이 126 고정, 비율에 맞게 너비 계산
    const double cardHeight = 126;
    const double cardWidth = cardHeight * (960 / 1524);

    // 캡처된 이미지가 있으면 그 이미지를 표시
    final capturedImage = viewModel.capturedRidingCardImage.value;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF000000).withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: capturedImage != null
                    ? Image.file(
                        capturedImage,
                        fit: BoxFit.cover,
                      )
                    : _buildRidingCardWidget(viewModel),
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

  /// 캡처된 이미지가 없을 때 사용하는 fallback 위젯
  Widget _buildRidingCardWidget(LiveTalkViewModel viewModel) {
    final card = viewModel.selectedRidingCard.value!;
    final cardType = viewModel.selectedRidingCardType.value;
    final UserViewModel userViewModel = Get.find<UserViewModel>();

    return RepaintBoundary(
      key: viewModel.ridingCardKey,
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
          // 상단: 프로필 + 닉네임 + 날짜
          Positioned(
            top: 10,
            left: 8,
            right: 8,
            child: Column(
              children: [
                Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: (userViewModel.user.profile_image_url_user?.isNotEmpty ?? false)
                        ? ExtendedImage.network(
                            userViewModel.user.profile_image_url_user!,
                            fit: BoxFit.cover,
                            cache: true,
                            loadStateChanged: (state) {
                              switch (state.extendedImageLoadState) {
                                case LoadState.loading:
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 25,
                                      height: 25,
                                      color: Colors.white,
                                    ),
                                  );
                                case LoadState.failed:
                                  return Image.asset(
                                    'assets/imgs/profile/img_profile_default_circle.png',
                                    fit: BoxFit.cover,
                                  );
                                case LoadState.completed:
                                  return null;
                              }
                            },
                          )
                        : Image.asset(
                            'assets/imgs/profile/img_profile_default_circle.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userViewModel.user.display_name ?? '',
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 5,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${card.date ?? ''} ${card.weekday ?? ''}',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 3,
                    color: Colors.white,
                  ),
                ),
                if (card.riderTitle != null && card.riderTitle!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: cardType == 0
                          ? const Color(0xFF1B3A5C)
                          : const Color(0xFFE2EDF8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      card.riderTitle!,
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 3,
                        color: cardType == 0 ? Colors.white : const Color(0xFF000000),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          // 중앙: 라이딩 정보
          Positioned(
            top: 58,
            bottom: 20,
            left: 6,
            right: 6,
            child: Center(
              child: cardType == 0
                  ? _buildPreviewCardType0Content(card)
                  : _buildPreviewCardType1Content(card),
            ),
          ),
          // 하단: 로고
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/imgs/logos/snowliveLogo_main_white.png',
                height: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCardType0Content(dynamic card) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 오늘 총 라이딩 & 최다 슬로프 (2열)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 오늘 총 라이딩
            Expanded(
              child: Column(
                children: [
                  Text(
                    (card.totalSlopeCount ?? 0) == 0 ? '-' : '${card.totalSlopeCount}',
                    style: SDSTextStyle.extraBold.copyWith(
                      fontSize: 7,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    '오늘 총 라이딩',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 3,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // 최다 슬로프
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          card.mostRiddenSlope?.isNotEmpty == true ? card.mostRiddenSlope! : '-',
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 6,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if ((card.mostRiddenCount ?? 0) > 0) ...[
                        Text(
                          '${card.mostRiddenCount}회',
                          style: SDSTextStyle.regular.copyWith(
                            fontSize: 4,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '최다 슬로프',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 3,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // 라이딩 거리 & 평균 경사도 & 최고 속도 (3열)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 라이딩 거리
            Expanded(
              child: Column(
                children: [
                  (card.totalDistance ?? 0) == 0
                      ? Text('-', style: SDSTextStyle.extraBold.copyWith(fontSize: 5, color: Colors.white))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              (card.totalDistance ?? 0).toStringAsFixed(0),
                              style: SDSTextStyle.extraBold.copyWith(fontSize: 5, color: Colors.white),
                            ),
                            Text('km', style: SDSTextStyle.regular.copyWith(fontSize: 3, color: Colors.white)),
                          ],
                        ),
                  Text('라이딩 거리', style: SDSTextStyle.regular.copyWith(fontSize: 3, color: Colors.white.withOpacity(0.7))),
                ],
              ),
            ),
            // 평균 경사도
            Expanded(
              child: Column(
                children: [
                  (card.avgSlope ?? 0) == 0
                      ? Text('-', style: SDSTextStyle.extraBold.copyWith(fontSize: 5, color: Colors.white))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              (card.avgSlope ?? 0).toStringAsFixed(1),
                              style: SDSTextStyle.extraBold.copyWith(fontSize: 5, color: Colors.white),
                            ),
                            Text('°', style: SDSTextStyle.regular.copyWith(fontSize: 5, color: Colors.white)),
                          ],
                        ),
                  Text('평균 경사도', style: SDSTextStyle.regular.copyWith(fontSize: 3, color: Colors.white.withOpacity(0.7))),
                ],
              ),
            ),
            // 최고 속도
            Expanded(
              child: Column(
                children: [
                  (card.topSpeed ?? 0) == 0
                      ? Text('-', style: SDSTextStyle.extraBold.copyWith(fontSize: 5, color: Colors.white))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              (card.topSpeed ?? 0).toStringAsFixed(0),
                              style: SDSTextStyle.extraBold.copyWith(fontSize: 5, color: Colors.white),
                            ),
                            Text('km/h', style: SDSTextStyle.regular.copyWith(fontSize: 3, color: Colors.white)),
                          ],
                        ),
                  Text('최고 속도', style: SDSTextStyle.regular.copyWith(fontSize: 3, color: Colors.white.withOpacity(0.7))),
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
        // 오늘 총 라이딩 숫자
        Text(
          '${card.totalSlopeCount ?? 0}',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 10,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        // 오늘 총 라이딩 라벨
        Text(
          '오늘 총 라이딩',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 3,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 6),
        // 첫 번째 슬로프 이름 (큰 글씨)
        Text(
          firstSlope?.key ?? '-',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 6,
            color: Colors.white,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        // 나머지 슬로프들
        if (displaySlopes.isNotEmpty) ...[
          const SizedBox(height: 2),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 2,
            runSpacing: 1,
            children: [
              ...displaySlopes.map((entry) {
                return Text(
                  entry.key,
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 4,
                    color: Colors.white,
                  ),
                );
              }),
              if (remainingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '+$remainingCount',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 3,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ],
        // 라이딩 슬로프 라벨
        Text(
          '라이딩 슬로프',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 3,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
