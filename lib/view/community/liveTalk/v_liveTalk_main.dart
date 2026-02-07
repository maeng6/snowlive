import 'dart:io';
import 'dart:ui' as ui;
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_dailyRidingCard.dart';
import 'package:com.snowlive/model/m_liveTalk.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/community/liveTalk/v_liveTalk_feedItem.dart';
import 'package:com.snowlive/view/community/liveTalk/v_liveTalk_inputArea.dart';
import 'package:com.snowlive/viewmodel/liveTalk/vm_liveTalk.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_ridingCard.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';

class LiveTalkMainView extends StatefulWidget {
  const LiveTalkMainView({Key? key}) : super(key: key);

  @override
  State<LiveTalkMainView> createState() => _LiveTalkMainViewState();
}

class _LiveTalkMainViewState extends State<LiveTalkMainView> {
  final LiveTalkViewModel _liveTalkViewModel = Get.find<LiveTalkViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final RidingCardViewModel _ridingCardViewModel = Get.find<RidingCardViewModel>();

  // pull-to-refresh 중인지 여부
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // 초기 데이터가 아직 로드되지 않은 경우에만 로드
    if (!_liveTalkViewModel.isInitialLoaded.value) {
      _liveTalkViewModel.fetchLiveTalkList(refresh: true);
    }
  }

  @override
  void dispose() {
    // 화면을 나갈 때 이미지 크기 캐시 삭제
    _liveTalkViewModel.clearImageSizeCache();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _isRefreshing = true;
    await _liveTalkViewModel.onRefresh();
    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: SDSColor.snowliveWhite,
        body: Stack(
        children: [
          // 피드 목록
          Obx(() {
            // 초기 로딩 시에만 전체 화면 로딩 표시
            // (이미 데이터가 있거나, 당겨서 새로고침, 게시물 업로드 후에는 표시 안함)
            if (_liveTalkViewModel.isLoading.value &&
                _liveTalkViewModel.liveTalkList.isEmpty &&
                !_isRefreshing &&
                !_liveTalkViewModel.isPosting.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: SDSColor.snowliveBlue,
                ),
              );
            }

            // 빈 상태
            if (_liveTalkViewModel.liveTalkList.isEmpty) {
              return _buildEmptyState();
            }

            // 리스트 표시 (당겨서 새로고침 시 화면 유지, 핀만 회전)
            return RefreshIndicator(
              onRefresh: _onRefresh,
              strokeWidth: 2,
              displacement: 40,
              backgroundColor: SDSColor.snowliveBlue,
              color: SDSColor.snowliveWhite,
              child: ListView.builder(
                controller: _liveTalkViewModel.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                cacheExtent: 1000,
                padding: EdgeInsets.only(
                  top: 0,
                  bottom: 100, // 하단 입력 영역 높이만큼 여유
                ),
                itemCount: _liveTalkViewModel.liveTalkList.length + 1,
                itemBuilder: (context, index) {
                  // 마지막 아이템: 로딩 인디케이터
                  if (index == _liveTalkViewModel.liveTalkList.length) {
                    return Obx(() {
                      if (_liveTalkViewModel.isLoadingNextPage.value) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                backgroundColor: SDSColor.gray100,
                                color: SDSColor.gray300.withOpacity(0.6),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    });
                  }

                  final liveTalk = _liveTalkViewModel.liveTalkList[index];
                  final isLast = index == _liveTalkViewModel.liveTalkList.length - 1;
                  return LiveTalkFeedItem(
                    key: ValueKey(liveTalk.livetalkId),
                    liveTalk: liveTalk,
                    onLike: () => _liveTalkViewModel.toggleLikeByIndex(index),
                    onComment: () => _goToCommentScreen(liveTalk),
                    onMore: () => _showMoreBottomSheet(liveTalk, index),
                    isLast: isLast,
                  );
                },
              ),
            );
          }),

          // 하단 입력 영역
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LiveTalkInputArea(),
          ),

          // 업로드/수정 중 표시 (inputArea 위에 떠있는 형태)
          Obx(() {
            // 미리보기가 있는지 확인하여 bottom 위치 계산
            final hasPreview = _liveTalkViewModel.selectedImage.value != null ||
                _liveTalkViewModel.selectedRidingCard.value != null ||
                (_liveTalkViewModel.isEditMode.value &&
                    _liveTalkViewModel.editingLiveTalk.value?.imageUrl != null &&
                    _liveTalkViewModel.editingLiveTalk.value!.imageUrl!.isNotEmpty);
            // 미리보기 높이: 이미지 120 + 패딩 16 + 여유 = 약 152
            final previewHeight = hasPreview ? 152.0 : 0.0;

            // 업로드 중 표시
            if (_liveTalkViewModel.isPosting.value) {
              return Positioned(
                left: 0,
                right: 0,
                bottom: _liveTalkViewModel.inputAreaHeight.value + 16 + previewHeight,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: SDSColor.snowliveWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: SDSColor.gray200, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LoadingAnimationWidget.waveDots(
                          color: SDSColor.gray500,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '게시물 업로드 중',
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: 13,
                            color: SDSColor.snowliveBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            // 수정 모드 표시 (업로드 중이 아닐 때)
            if (_liveTalkViewModel.isEditMode.value) {
              return Positioned(
                left: 0,
                right: 0,
                bottom: _liveTalkViewModel.inputAreaHeight.value + 16 + previewHeight,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: SDSColor.snowliveWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: SDSColor.gray200, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '게시물 수정 중',
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: 13,
                            color: SDSColor.snowliveBlack,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _liveTalkViewModel.cancelEditMode(),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: SDSColor.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // 라이딩 카드 공유 FAB
          Obx(() => Positioned(
            right: 16,
            bottom: _liveTalkViewModel.inputAreaHeight.value + 16,
            child: GestureDetector(
              onTap: () => _showRidingCardSelection(),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: SDSColor.snowliveBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/imgs/icons/icon_livetalk_card.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          )),

          // 맨 위로 버튼 (FAB 위에 위치, 간격 10px)
          Obx(() {
            if (_liveTalkViewModel.showScrollToTopButton.value) {
              return Positioned(
                right: 16,
                bottom: _liveTalkViewModel.inputAreaHeight.value + 16 + 56 + 10,
                child: GestureDetector(
                  onTap: _liveTalkViewModel.scrollToTop,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: SDSColor.snowliveWhite,
                      shape: BoxShape.circle,
                      border: Border.all(color: SDSColor.gray200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/imgs/icons/icon_top_page.svg',
                        width: 16,
                        height: 16,
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // 이미지 미리보기 레이어 (항상 맨 위에 노출)
          Obx(() => Positioned(
            left: 0,
            right: 0,
            bottom: _liveTalkViewModel.inputAreaHeight.value + 12,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: LiveTalkPreviewLayer(),
            ),
          )),
        ],
      ),
      ),
    );
  }

  void _showRidingCardSelection() async {
    HapticFeedback.lightImpact();

    // 오늘 날짜 (yyyy-MM-dd 형식)
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // 로딩 표시
    CustomFullScreenDialog.showDialog();

    // 라이딩 카드 목록 로드
    final dailyCards = await _ridingCardViewModel.fetchDailyRidingCardListByUserId(
      _userViewModel.user.user_id,
    );

    CustomFullScreenDialog.cancelDialog();

    // 오늘 날짜의 카드 찾기
    final todayCard = dailyCards.firstWhereOrNull((card) => card.date == today);

    if (todayCard == null) {
      // 오늘의 기록 카드가 없는 경우
      Get.snackbar(
        '알림',
        '오늘의 라이딩 기록 카드가 없습니다.\n라이브온 후 기록 카드가 생성됩니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: SDSColor.gray900.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // 오늘의 카드가 있으면 바로 선택 다이얼로그 표시
    _showTodayCardSelectionDialog(todayCard);
  }

  /// 오늘의 카드 선택 다이얼로그 (바텀시트 없이 바로 표시)
  void _showTodayCardSelectionDialog(DailyRidingCard card) {
    final repaintBoundaryKey = GlobalKey();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Obx(() {
            final currentCardType = _ridingCardViewModel.getCardType(card.cardId ?? 0);

            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Spacer(),

                // 타이틀
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    '오늘의 라이딩 기록 카드',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),

                // 카드 미리보기 (크게) - RepaintBoundary로 감싸서 캡처 가능하게
                RepaintBoundary(
                  key: repaintBoundaryKey,
                  child: SizedBox(
                    width: 320,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 960 / 1524,
                        child: _buildLargeCardPreview(card, currentCardType),
                      ),
                    ),
                  ),
                ),

                // 닫기 버튼 + 카드 변경 버튼
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // X 버튼 (닫기)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.pop(dialogContext),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.close,
                              size: 26,
                              color: SDSColor.gray900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 카드 변경 버튼
                      GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          final newType = currentCardType == 0 ? 1 : 0;
                          await _ridingCardViewModel.setCardType(card.cardId ?? 0, newType);
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/imgs/icons/icon_summury_change.svg',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 선택 버튼 (하단 고정)
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: GestureDetector(
                    onTap: () async {
                      // 카드 이미지 캡처
                      final capturedFile = await _captureCardAsImage(repaintBoundaryKey);

                      Navigator.pop(dialogContext); // 다이얼로그 닫기
                      _liveTalkViewModel.selectRidingCard(
                        card,
                        cardType: currentCardType,
                        capturedImage: capturedFile,
                      );
                    },
                    child: Container(
                      width: 200,
                      height: 56,
                      decoration: BoxDecoration(
                        color: SDSColor.snowliveBlue,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: Text(
                          '라이브톡에 공유하기',
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: 16,
                            color: SDSColor.snowliveWhite,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  /// 날짜에서 일(day) 추출 (예: "2025-01-30" -> "30")
  String _getDayFromDate(String? date) {
    if (date == null || date.isEmpty) return '';
    final parts = date.split('-');
    if (parts.length >= 3) {
      return parts[2];
    }
    return '';
  }

  Widget _buildRidingCardItem(DailyRidingCard card) {
    return Obx(() {
      // cardTypeMap 변경 감지
      final _ = _ridingCardViewModel.cardTypeMap[card.cardId ?? 0];
      final currentCardType = _ridingCardViewModel.getCardType(card.cardId ?? 0);

      return GestureDetector(
        onTap: () {
          // 카드 탭 시 선택 다이얼로그 표시
          _showCardSelectionDialog(card);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 960 / 1524,
            child: Stack(
              children: [
                // 배경 이미지 (카드 타입에 따라 다름)
                Positioned.fill(
                  child: Image.asset(
                    currentCardType == 0
                        ? 'assets/imgs/imgs/img_summury_bg.png'
                        : 'assets/imgs/imgs/img_summury_bg_2.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // 상단: 프로필 이미지 + 닉네임 + 날짜
                Positioned(
                  top: 16,
                  left: 8,
                  right: 8,
                  child: Column(
                    children: [
                      // 프로필 이미지
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: (_userViewModel.user.profile_image_url_user?.isNotEmpty ?? false)
                              ? ExtendedImage.network(
                                  _userViewModel.user.profile_image_url_user!,
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
                      const SizedBox(height: 3),
                      // 닉네임
                      Text(
                        _userViewModel.user.display_name ?? '',
                        style: SDSTextStyle.bold.copyWith(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // 날짜 + 요일
                      Text(
                        '${card.date ?? ''} ${card.weekday ?? ''}',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 5,
                          color: Colors.white,
                        ),
                      ),
                      // 라이더 타이틀
                      if (card.riderTitle != null && card.riderTitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: currentCardType == 0
                                ? const Color(0xFF1B3A5C)
                                : const Color(0xFFE2EDF8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            card.riderTitle!,
                            style: SDSTextStyle.regular.copyWith(
                              fontSize: 5,
                              color: currentCardType == 0
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
                  top: 76,
                  bottom: 20,
                  left: 4,
                  right: 4,
                  child: Center(
                    child: currentCardType == 0
                        ? _buildLiveTalkCardType0Content(card)
                        : _buildLiveTalkCardType1Content(card),
                  ),
                ),
                // 하단: 스노우라이브 로고
                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Image.asset(
                      'assets/imgs/logos/snowliveLogo_main_white.png',
                      height: 4,
                    ),
                  ),
                ),
                // 좌상단: 날짜 뱃지
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_getDayFromDate(card.date)}일',
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 12,
                        color: SDSColor.snowliveBlack,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// 카드 선택 다이얼로그 - 카드 타입 변경 및 선택
  void _showCardSelectionDialog(DailyRidingCard card) {
    HapticFeedback.lightImpact();
    final GlobalKey repaintBoundaryKey = GlobalKey();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Obx(() {
            final currentCardType = _ridingCardViewModel.getCardType(card.cardId ?? 0);

            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Spacer(),

                // 카드 미리보기 (크게) - RepaintBoundary로 감싸서 캡처 가능하게
                RepaintBoundary(
                  key: repaintBoundaryKey,
                  child: SizedBox(
                    width: 320,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 960 / 1524,
                        child: _buildLargeCardPreview(card, currentCardType),
                      ),
                    ),
                  ),
                ),

                // 닫기 버튼 + 카드 변경 버튼
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // X 버튼 (닫기)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.pop(dialogContext),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.close,
                              size: 26,
                              color: SDSColor.gray900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 카드 변경 버튼
                      GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          final newType = currentCardType == 0 ? 1 : 0;
                          await _ridingCardViewModel.setCardType(card.cardId ?? 0, newType);
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/imgs/icons/icon_summury_change.svg',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 선택 버튼 (하단 고정)
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: GestureDetector(
                    onTap: () async {
                      // 카드 이미지 캡처
                      final capturedFile = await _captureCardAsImage(repaintBoundaryKey);

                      Navigator.pop(dialogContext); // 다이얼로그 닫기
                      Navigator.pop(context); // 바텀시트 닫기
                      _liveTalkViewModel.selectRidingCard(
                        card,
                        cardType: currentCardType,
                        capturedImage: capturedFile,
                      );
                    },
                    child: Container(
                      width: 160,
                      height: 56,
                      decoration: BoxDecoration(
                        color: SDSColor.snowliveBlue,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: Text(
                          '이 카드 선택',
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: 16,
                            color: SDSColor.snowliveWhite,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  /// 카드를 고화질 이미지로 캡처
  Future<File?> _captureCardAsImage(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // 고화질 캡처 (pixelRatio 3.0)
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final bytes = byteData.buffer.asUint8List();

      // 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/riding_card_$timestamp.png');
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      print('Error capturing card image: $e');
      return null;
    }
  }

  /// 다이얼로그용 큰 카드 미리보기
  Widget _buildLargeCardPreview(DailyRidingCard card, int cardType) {
    return Stack(
      children: [
        // 배경 이미지
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
          top: 40,
          left: 32,
          right: 32,
          child: Column(
            children: [
              // 프로필 이미지
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: (_userViewModel.user.profile_image_url_user?.isNotEmpty ?? false)
                      ? ExtendedImage.network(
                          _userViewModel.user.profile_image_url_user!,
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
              const SizedBox(height: 10),
              // 닉네임
              Text(
                _userViewModel.user.display_name ?? '',
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 20,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // 날짜 + 요일
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${card.date ?? ''} ${card.weekday ?? ''}',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
              // 라이더 타이틀
              if (card.riderTitle != null && card.riderTitle!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: cardType == 0
                        ? const Color(0xFF1B3A5C)
                        : const Color(0xFFE2EDF8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    card.riderTitle!,
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 13,
                      color: cardType == 0
                          ? Colors.white
                          : const Color(0xFF000000),
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
          top: 236,
          bottom: 80,
          left: 24,
          right: 24,
          child: Center(
            child: cardType == 0
                ? _buildDialogCardType0Content(card)
                : _buildDialogCardType1Content(card),
          ),
        ),
        // 하단: 스노우라이브 로고
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              'assets/imgs/logos/snowliveLogo_main_white.png',
              height: 12,
            ),
          ),
        ),
      ],
    );
  }

  // 다이얼로그용 타입 0 컨텐츠
  Widget _buildDialogCardType0Content(DailyRidingCard card) {
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
                      fontSize: 30,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '오늘 총 라이딩',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 12,
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
                      Text(
                        card.mostRiddenSlope?.isNotEmpty == true
                            ? card.mostRiddenSlope!
                            : '-',
                        style: SDSTextStyle.extraBold.copyWith(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      if ((card.mostRiddenCount ?? 0) > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '${card.mostRiddenCount}회',
                          style: SDSTextStyle.regular.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '최다 슬로프',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 라이딩 거리 & 평균 경사도 & 최고 속도 (3열)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 라이딩 거리
            Expanded(
              child: Column(
                children: [
                  (card.totalDistance ?? 0) == 0
                      ? Text(
                          '-',
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              (card.totalDistance ?? 0).toStringAsFixed(0),
                              style: SDSTextStyle.extraBold.copyWith(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'km',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 2),
                  Text(
                    '라이딩 거리',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // 평균 경사도
            Expanded(
              child: Column(
                children: [
                  (card.avgSlope ?? 0) == 0
                      ? Text(
                          '-',
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              (card.avgSlope ?? 0).toStringAsFixed(1),
                              style: SDSTextStyle.extraBold.copyWith(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '°',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 2),
                  Text(
                    '평균 경사도',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 12,
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
                  (card.topSpeed ?? 0) == 0
                      ? Text(
                          '-',
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              (card.topSpeed ?? 0).toStringAsFixed(0),
                              style: SDSTextStyle.extraBold.copyWith(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'km/h',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 2),
                  Text(
                    '최고 속도',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 12,
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

  // 다이얼로그용 타입 1 컨텐츠
  Widget _buildDialogCardType1Content(DailyRidingCard card) {
    final slopeEntries = card.slopeCountsByName?.entries.toList() ?? [];
    final firstSlope = slopeEntries.isNotEmpty ? slopeEntries.first : null;
    final restSlopes = slopeEntries.length > 1 ? slopeEntries.sublist(1) : <MapEntry<String, int>>[];

    // 사용 가능한 너비 (카드 너비 320 - 좌우 패딩 24*2)
    const double availableWidth = 320 - 48;
    const double spacing = 8;
    final textStyle = SDSTextStyle.bold.copyWith(fontSize: 14, color: Colors.white);

    // 2줄에 맞는 슬로프 개수 계산
    final displayCount = _getSlopeCountForTwoLines(restSlopes, availableWidth, textStyle, spacing);
    final displaySlopes = restSlopes.take(displayCount).toList();
    final remainingCount = restSlopes.length - displayCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 오늘 총 라이딩 숫자
        Text(
          '${card.totalSlopeCount ?? 0}',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 40,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        // 오늘 총 라이딩 라벨
        Text(
          '오늘 총 라이딩',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
        // 첫 번째 슬로프 이름 (큰 글씨)
        Text(
          firstSlope?.key ?? '-',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 24,
            color: Colors.white,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        // 나머지 슬로프들 (작은 텍스트, 최대 2줄)
        if (displaySlopes.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: spacing,
            runSpacing: 2,
            children: [
              ...displaySlopes.map((entry) {
                return Text(
                  entry.key,
                  style: textStyle,
                );
              }),
              if (remainingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+$remainingCount',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 11,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        // 라이딩 슬로프 라벨
        Text(
          '라이딩 슬로프',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // 텍스트 너비 계산
  double _getTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  // 2줄에 맞는 슬로프 개수 계산 (+N 포함 고려)
  int _getSlopeCountForTwoLines(List<MapEntry<String, int>> slopes, double maxWidth, TextStyle style, double spacing) {
    double currentLineWidth = 0;
    int lineCount = 1;
    int count = 0;

    for (int i = 0; i < slopes.length; i++) {
      final textWidth = _getTextWidth(slopes[i].key, style);

      if (currentLineWidth + textWidth > maxWidth) {
        lineCount++;
        if (lineCount > 2) {
          // 2줄 초과 시, "+N" 공간 확보를 위해 마지막 아이템 제거 필요할 수 있음
          final plusNWidth = _getTextWidth('+${slopes.length - count}', style);
          // 현재 줄에 +N이 들어갈 수 있는지 확인
          while (count > 0) {
            double lastLineWidth = 0;
            int tempLineCount = 1;
            for (int j = 0; j < count; j++) {
              final w = _getTextWidth(slopes[j].key, style);
              if (lastLineWidth + w > maxWidth) {
                tempLineCount++;
                lastLineWidth = w + spacing;
              } else {
                lastLineWidth += w + spacing;
              }
            }
            // +N이 현재 줄에 들어가는지 확인
            if (tempLineCount <= 2 && lastLineWidth + plusNWidth <= maxWidth) {
              break;
            }
            if (tempLineCount < 2) {
              break;
            }
            count--;
          }
          return count;
        }
        currentLineWidth = textWidth + spacing;
      } else {
        currentLineWidth += textWidth + spacing;
      }
      count++;
    }

    return slopes.length; // 모든 슬로프가 2줄에 들어감
  }

  // 라이브톡 카드 선택용 타입 0 컨텐츠
  Widget _buildLiveTalkCardType0Content(DailyRidingCard card) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 오늘 총 라이딩 & 최다 슬로프 (2열)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 오늘 총 라이딩
              Expanded(
                child: Column(
                  children: [
                    Text(
                      (card.totalSlopeCount ?? 0) == 0 ? '-' : '${card.totalSlopeCount}',
                      style: SDSTextStyle.extraBold.copyWith(
                        fontSize: 12,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '총 라이딩',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // 최다 슬로프
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            card.mostRiddenSlope?.isNotEmpty == true
                                ? card.mostRiddenSlope!
                                : '-',
                            style: SDSTextStyle.extraBold.copyWith(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          if ((card.mostRiddenCount ?? 0) > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 1, top: 5),
                              child: Text(
                                '${card.mostRiddenCount}회',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '최다 슬로프',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 5,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // 라이딩 거리 & 평균 경사도 & 최고 속도 (3열)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 라이딩 거리
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (card.totalDistance ?? 0) == 0 ? '-' : (card.totalDistance ?? 0).toStringAsFixed(0),
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                        if ((card.totalDistance ?? 0) != 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 1, top: 3),
                            child: Text(
                              'km',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '거리',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // 평균 경사도
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (card.avgSlope ?? 0) == 0 ? '-' : (card.avgSlope ?? 0).toStringAsFixed(1),
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                        if ((card.avgSlope ?? 0) != 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 1, top: 2),
                            child: Text(
                              '°',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '경사도',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 5,
                        color: Colors.white.withValues(alpha: 0.7),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (card.topSpeed ?? 0) == 0 ? '-' : (card.topSpeed ?? 0).toStringAsFixed(0),
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                        if ((card.topSpeed ?? 0) != 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 1, top: 3),
                            child: Text(
                              'km/h',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '최고속도',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 라이브톡 카드 선택용 타입 1 컨텐츠
  Widget _buildLiveTalkCardType1Content(DailyRidingCard card) {
    final slopeEntries = card.slopeCountsByName?.entries.toList() ?? [];
    final firstSlope = slopeEntries.isNotEmpty ? slopeEntries.first : null;
    final restSlopes = slopeEntries.length > 1 ? slopeEntries.sublist(1) : <MapEntry<String, int>>[];

    // 그리드에서는 최대 2개의 나머지 슬로프만 표시
    final displaySlopes = restSlopes.take(2).toList();
    final remainingCount = restSlopes.length - displaySlopes.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        // 오늘 총 라이딩 숫자
        Text(
          '${card.totalSlopeCount ?? 0}',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 12,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 1),
        // 오늘 총 라이딩 라벨
        Text(
          '오늘 총 라이딩',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 5,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),
        // 첫 번째 슬로프 이름 (큰 글씨)
        Text(
          firstSlope?.key ?? '-',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 8,
            color: Colors.white,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // 나머지 슬로프들
        if (displaySlopes.isNotEmpty) ...[
          const SizedBox(height: 2),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 1,
            children: [
              ...displaySlopes.map((entry) {
                return Text(
                  entry.key,
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 5,
                    color: Colors.white,
                  ),
                );
              }),
              if (remainingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '+$remainingCount',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 5,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ],
        // 라이딩 슬로프 라벨
        const SizedBox(height: 2),
        Text(
          '라이딩 슬로프',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 5,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: SDSColor.gray300,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 게시물이 없습니다',
            style: SDSTextStyle.regular.copyWith(
              fontSize: 16,
              color: SDSColor.gray500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 게시물을 올려보세요!',
            style: SDSTextStyle.regular.copyWith(
              fontSize: 14,
              color: SDSColor.gray400,
            ),
          ),
          const SizedBox(height: 80), // 입력 영역 높이만큼
        ],
      ),
    );
  }

  void _goToCommentScreen(LiveTalk liveTalk) {
    Get.toNamed(
      AppRoutes.liveTalkComment,
      arguments: {'liveTalk': liveTalk},
    );
  }

  void _showMoreBottomSheet(LiveTalk liveTalk, int index) {
    final isMyPost = liveTalk.userId == _userViewModel.user.user_id;

    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Wrap(
                children: [
                  if (isMyPost) ...[
                    // 수정하기
                    GestureDetector(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Center(
                          child: Text(
                            '수정하기',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 16,
                              color: SDSColor.gray900,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _liveTalkViewModel.startEditMode(liveTalk);
                        },
                      ),
                    ),
                    // 삭제하기
                    GestureDetector(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Center(
                          child: Text(
                            '삭제하기',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 16,
                              color: SDSColor.red,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteConfirmDialog(liveTalk.livetalkId!, index);
                        },
                      ),
                    ),
                  ] else ...[
                    // 신고하기
                    GestureDetector(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Center(
                          child: Text(
                            '신고하기',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 16,
                              color: SDSColor.gray900,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _showReportConfirmDialog(liveTalk.livetalkId!);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(int liveTalkId, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: SDSColor.snowliveWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '게시물 삭제',
            style: SDSTextStyle.bold.copyWith(fontSize: 18),
          ),
          content: Text(
            '이 게시물을 삭제하시겠습니까?',
            style: SDSTextStyle.regular.copyWith(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: SDSTextStyle.regular.copyWith(
                  color: SDSColor.gray600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await _liveTalkViewModel.deleteLiveTalk(liveTalkId);
                if (success) {
                  Get.snackbar(
                    '삭제 완료',
                    '게시물이 삭제되었습니다.',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: SDSColor.snowliveWhite,
                  );
                }
              },
              child: Text(
                '삭제',
                style: SDSTextStyle.bold.copyWith(
                  color: SDSColor.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReportConfirmDialog(int liveTalkId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: SDSColor.snowliveWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '게시물 신고',
            style: SDSTextStyle.bold.copyWith(fontSize: 18),
          ),
          content: Text(
            '이 게시물을 신고하시겠습니까?',
            style: SDSTextStyle.regular.copyWith(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: SDSTextStyle.regular.copyWith(
                  color: SDSColor.gray600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await _liveTalkViewModel.reportLiveTalk(liveTalkId);
                if (success) {
                  Get.snackbar(
                    '신고 완료',
                    '신고가 접수되었습니다.',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: SDSColor.snowliveWhite,
                  );
                }
              },
              child: Text(
                '신고',
                style: SDSTextStyle.bold.copyWith(
                  color: SDSColor.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
