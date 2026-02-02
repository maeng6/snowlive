import 'dart:io';

import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/liveTalk/vm_liveTalk.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveTalkInputArea extends StatelessWidget {
  const LiveTalkInputArea({Key? key}) : super(key: key);

  void _showImagePickerOptions(BuildContext context, LiveTalkViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SDSColor.snowliveWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: SDSColor.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: SDSColor.gray600),
                title: Text(
                  '사진 촬영',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 16,
                    color: SDSColor.gray900,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: SDSColor.gray600),
                title: Text(
                  '앨범에서 선택',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 16,
                    color: SDSColor.gray900,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImageFromGallery();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final LiveTalkViewModel _liveTalkViewModel = Get.find<LiveTalkViewModel>();

    return Container(
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

            // 이미지 미리보기 (선택된 경우)
            Obx(() {
              // selectedRidingCardType 변경 감지를 위해 참조
              final _ = _liveTalkViewModel.selectedRidingCardType.value;

              if (_liveTalkViewModel.selectedImage.value != null) {
                return _buildImagePreview(_liveTalkViewModel);
              }
              // 라이딩 카드 선택된 경우
              if (_liveTalkViewModel.selectedRidingCard.value != null) {
                return _buildRidingCardPreview(_liveTalkViewModel);
              }
              // 수정 모드에서 기존 이미지가 있는 경우
              if (_liveTalkViewModel.isEditMode.value &&
                  _liveTalkViewModel.editingLiveTalk.value?.imageUrl != null &&
                  _liveTalkViewModel.editingLiveTalk.value!.imageUrl!.isNotEmpty) {
                return _buildExistingImagePreview(_liveTalkViewModel);
              }
              return const SizedBox.shrink();
            }),

            // 입력 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 이미지 선택 버튼
                  GestureDetector(
                    onTap: () => _showImagePickerOptions(context, _liveTalkViewModel),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: SDSColor.gray100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: SDSColor.gray600,
                        size: 22,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 텍스트 입력 필드
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 40,
                        maxHeight: 120,
                      ),
                      decoration: BoxDecoration(
                        color: SDSColor.gray50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: SDSColor.gray200),
                      ),
                      child: TextField(
                        controller: _liveTalkViewModel.textController,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 15,
                          color: SDSColor.gray900,
                        ),
                        decoration: InputDecoration(
                          hintText: '무슨 일이 있었나요?',
                          hintStyle: SDSTextStyle.regular.copyWith(
                            fontSize: 15,
                            color: SDSColor.gray400,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 전송/수정 버튼
                  Obx(() {
                    final isEnabled = _liveTalkViewModel.isButtonEnabled.value;
                    final isPosting = _liveTalkViewModel.isPosting.value;
                    final isEditMode = _liveTalkViewModel.isEditMode.value;

                    // 업로드 중이면 비활성화 (로딩 인디케이터 대신 버튼만 비활성화)
                    final canTap = isEnabled && !isPosting;

                    return GestureDetector(
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
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: canTap
                              ? SDSColor.snowliveBlue
                              : SDSColor.gray200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          isEditMode ? Icons.check : Icons.send_rounded,
                          color: canTap
                              ? SDSColor.snowliveWhite
                              : SDSColor.gray400,
                          size: 20,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingImagePreview(LiveTalkViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.only(left: 60, right: 12, top: 12),
      child: Stack(
        children: [
          // 기존 이미지 미리보기
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              viewModel.editingLiveTalk.value!.imageUrl!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),

          // 삭제 버튼
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => viewModel.removeExistingImage(),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(LiveTalkViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.only(left: 60, right: 12, top: 12),
      child: Stack(
        children: [
          // 이미지 미리보기
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(viewModel.selectedImage.value!.path),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),

          // 삭제 버튼 (업로드 중에는 숨김)
          Obx(() {
            if (viewModel.isUploadingImage.value) {
              return const SizedBox.shrink();
            }
            return Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => viewModel.removeImage(),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
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

    // 카드 크기: 너비 200, 높이는 원본 비율(960:1524)에 맞춤
    // pixelRatio 4.0과 함께 800px 너비의 고화질 이미지 생성
    const double cardWidth = 200;
    const double cardHeight = cardWidth * (1524 / 960);

    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
      child: Stack(
        children: [
          // 라이딩 카드 미리보기 (RepaintBoundary로 캡처 가능하게)
          RepaintBoundary(
            key: viewModel.ridingCardKey,
            child: SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // 배경 이미지 (카드 타입에 따라 다름)
                    Positioned.fill(
                      child: Image.asset(
                        cardType == 0
                            ? 'assets/imgs/imgs/img_summury_bg.png'
                            : 'assets/imgs/imgs/img_summury_bg_2.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // 상단: 프로필 이미지 + 닉네임 + 날짜
                    Positioned(
                      top: 17,
                      left: 12,
                      right: 12,
                      child: Column(
                        children: [
                          // 프로필 이미지
                          Container(
                            width: 43,
                            height: 43,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: (userViewModel.user.profile_image_url_user?.isNotEmpty ?? false)
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
                          // 닉네임
                          Text(
                            userViewModel.user.display_name ?? '',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 9,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // 날짜 + 요일
                          Text(
                            '${card.date ?? ''} ${card.weekday ?? ''}',
                            style: SDSTextStyle.regular.copyWith(
                              fontSize: 6,
                              color: Colors.white,
                            ),
                          ),
                          // 라이더 타이틀 (카드 타입에 따라 색상 다름)
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
                                  color: cardType == 0
                                      ? Colors.white
                                      : const Color(0xFF000000),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // 중앙: 라이딩 정보 (카드 타입에 따라 다른 내용)
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
                    // 하단: 스노우라이브 로고
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

          // 삭제 버튼 (업로드 중에는 숨김)
          Obx(() {
            if (viewModel.isUploadingImage.value) {
              return const SizedBox.shrink();
            }
            return Positioned(
              top: 4,
              left: cardWidth - 20,
              child: GestureDetector(
                onTap: () => viewModel.removeRidingCard(),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 미리보기용 타입 0 컨텐츠 (최다 슬로프 & 최고 속도)
  Widget _buildPreviewCardType0Content(dynamic card) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 오늘 총 라이딩 숫자
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
        // 최다 슬로프 & 최고 속도 (2열)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 최다 슬로프
            Expanded(
              child: Column(
                children: [
                  Text(
                    card.mostRiddenSlope?.isNotEmpty == true
                        ? card.mostRiddenSlope!
                        : '-',
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
            // 최고 속도
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

  // 미리보기용 타입 1 컨텐츠 (슬로프 리스트)
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
        // 첫 번째 슬로프 이름
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
        // 나머지 슬로프들
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
        // 라이딩 슬로프 라벨
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
