import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_dailyRidingCard.dart';
import 'package:com.snowlive/model/m_liveTalk.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/community/liveTalk/v_liveTalk_feedItem.dart';
import 'package:com.snowlive/view/community/liveTalk/v_liveTalk_inputArea.dart';
import 'package:com.snowlive/viewmodel/liveTalk/vm_liveTalk.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_ridingCard.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LiveTalkMainView extends StatefulWidget {
  const LiveTalkMainView({Key? key}) : super(key: key);

  @override
  State<LiveTalkMainView> createState() => _LiveTalkMainViewState();
}

class _LiveTalkMainViewState extends State<LiveTalkMainView> {
  final LiveTalkViewModel _liveTalkViewModel = Get.find<LiveTalkViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final RidingCardViewModel _ridingCardViewModel = Get.find<RidingCardViewModel>();

  @override
  void initState() {
    super.initState();
    _liveTalkViewModel.fetchLiveTalkList(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SDSColor.gray50,
      body: Stack(
        children: [
          // 피드 목록
          Obx(() {
            if (_liveTalkViewModel.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: SDSColor.snowliveBlue,
                ),
              );
            }

            if (_liveTalkViewModel.liveTalkList.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: _liveTalkViewModel.onRefresh,
              color: SDSColor.snowliveBlue,
              child: ListView.builder(
                controller: _liveTalkViewModel.scrollController,
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: 100, // 하단 입력 영역 높이만큼 여유
                ),
                itemCount: _liveTalkViewModel.liveTalkList.length + 1,
                itemBuilder: (context, index) {
                  // 마지막 아이템: 로딩 인디케이터
                  if (index == _liveTalkViewModel.liveTalkList.length) {
                    return Obx(() {
                      if (_liveTalkViewModel.isLoadingNextPage.value) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: SDSColor.snowliveBlue,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    });
                  }

                  final liveTalk = _liveTalkViewModel.liveTalkList[index];
                  return LiveTalkFeedItem(
                    liveTalk: liveTalk,
                    onLike: () => _liveTalkViewModel.toggleLikeByIndex(index),
                    onComment: () => _goToCommentScreen(liveTalk),
                    onMore: () => _showMoreBottomSheet(liveTalk, index),
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

          // 라이딩 카드 공유 FAB
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton.small(
              heroTag: 'ridingCard',
              onPressed: () => _showRidingCardSelection(),
              backgroundColor: SDSColor.snowliveBlue,
              elevation: 4,
              child: const Icon(
                Icons.snowboarding_rounded,
                color: SDSColor.snowliveWhite,
                size: 22,
              ),
            ),
          ),

          // 맨 위로 버튼 (FAB 위에 위치)
          Obx(() {
            if (_liveTalkViewModel.showScrollToTopButton.value) {
              return Positioned(
                right: 16,
                bottom: 156,
                child: FloatingActionButton.small(
                  heroTag: 'scrollToTop',
                  onPressed: _liveTalkViewModel.scrollToTop,
                  backgroundColor: SDSColor.snowliveWhite,
                  elevation: 4,
                  child: const Icon(
                    Icons.keyboard_arrow_up,
                    color: SDSColor.gray600,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  void _showRidingCardSelection() {
    HapticFeedback.lightImpact();

    // 라이딩 카드 목록 로드
    _ridingCardViewModel.fetchDailyRidingCardList(
      userId: _userViewModel.user.user_id,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: SDSColor.snowliveWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // 핸들
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SDSColor.gray200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 타이틀
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '라이딩 기록 카드 선택',
                        style: SDSTextStyle.bold.copyWith(
                          fontSize: 18,
                          color: SDSColor.gray900,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          color: SDSColor.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: SDSColor.gray100),
                // 카드 목록 (월별 그룹화)
                Expanded(
                  child: Obx(() {
                    if (_ridingCardViewModel.isLoadingDailyList.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: SDSColor.snowliveBlue,
                        ),
                      );
                    }

                    final groupedCards = _ridingCardViewModel.groupedDailyCardsByMonth;

                    if (groupedCards.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.snowboarding_rounded,
                              size: 48,
                              color: SDSColor.gray300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '아직 라이딩 기록 카드가 없습니다',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 14,
                                color: SDSColor.gray500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: groupedCards.keys.length,
                      itemBuilder: (context, sectionIndex) {
                        final monthKey = groupedCards.keys.elementAt(sectionIndex);
                        final monthCards = groupedCards[monthKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 월 헤더
                            Padding(
                              padding: EdgeInsets.only(bottom: 12, top: sectionIndex == 0 ? 0 : 16),
                              child: Text(
                                monthKey,
                                style: SDSTextStyle.bold.copyWith(
                                  fontSize: 16,
                                  color: SDSColor.gray900,
                                ),
                              ),
                            ),
                            // 그리드
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 960 / 1524,
                              ),
                              itemCount: monthCards.length,
                              itemBuilder: (context, index) {
                                final card = monthCards[index];
                                return _buildRidingCardItem(card);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }),
                ),
              ],
            );
          },
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
          borderRadius: BorderRadius.circular(12),
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
                // 좌상단: 날짜 뱃지
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_getDayFromDate(card.date)}일',
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 7,
                        color: SDSColor.gray900,
                      ),
                    ),
                  ),
                ),
                // 상단: 프로필 이미지 + 닉네임 + 날짜
                Positioned(
                  top: 10,
                  left: 6,
                  right: 6,
                  child: Column(
                    children: [
                      // 프로필 이미지
                      Container(
                        width: 24,
                        height: 24,
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
                      const SizedBox(height: 2),
                      // 닉네임
                      Text(
                        _userViewModel.user.display_name ?? '',
                        style: SDSTextStyle.bold.copyWith(
                          fontSize: 5,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // 날짜 + 요일
                      Text(
                        '${card.date ?? ''} ${card.weekday ?? ''}',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 3,
                          color: Colors.white,
                        ),
                      ),
                      // 라이더 타이틀
                      if (card.riderTitle != null && card.riderTitle!.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: currentCardType == 0
                                ? const Color(0xFF1B3A5C)
                                : const Color(0xFFE2EDF8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            card.riderTitle!,
                            style: SDSTextStyle.regular.copyWith(
                              fontSize: 3,
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
                  top: 60,
                  bottom: 16,
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
                  bottom: 5,
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
          ),
        ),
      );
    });
  }

  /// 카드 선택 다이얼로그 - 카드 타입 변경 및 선택
  void _showCardSelectionDialog(DailyRidingCard card) {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Obx(() {
            final currentCardType = _ridingCardViewModel.getCardType(card.cardId ?? 0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 카드 미리보기 (크게)
                Container(
                  width: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 960 / 1524,
                      child: _buildLargeCardPreview(card, currentCardType),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 카드 타입 변경 버튼 (크고 눈에 잘 띄게)
                Container(
                  decoration: BoxDecoration(
                    color: SDSColor.snowliveWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 타입 1 버튼
                      GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await _ridingCardViewModel.setCardType(card.cardId ?? 0, 0);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: currentCardType == 0
                                ? SDSColor.snowliveBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '스타일 1',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 14,
                              color: currentCardType == 0
                                  ? SDSColor.snowliveWhite
                                  : SDSColor.gray600,
                            ),
                          ),
                        ),
                      ),
                      // 타입 2 버튼
                      GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await _ridingCardViewModel.setCardType(card.cardId ?? 0, 1);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: currentCardType == 1
                                ? SDSColor.snowliveBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '스타일 2',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 14,
                              color: currentCardType == 1
                                  ? SDSColor.snowliveWhite
                                  : SDSColor.gray600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 선택 버튼
                GestureDetector(
                  onTap: () {
                    Navigator.pop(dialogContext); // 다이얼로그 닫기
                    Navigator.pop(context); // 바텀시트 닫기
                    _liveTalkViewModel.selectRidingCard(card, cardType: currentCardType);
                  },
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: SDSColor.snowliveBlue,
                      borderRadius: BorderRadius.circular(12),
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

                const SizedBox(height: 12),

                // 취소 버튼
                GestureDetector(
                  onTap: () => Navigator.pop(dialogContext),
                  child: Text(
                    '취소',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 14,
                      color: SDSColor.snowliveWhite,
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
          top: 20,
          left: 12,
          right: 12,
          child: Column(
            children: [
              // 프로필 이미지
              Container(
                width: 48,
                height: 48,
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
              const SizedBox(height: 6),
              // 닉네임
              Text(
                _userViewModel.user.display_name ?? '',
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 12,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // 날짜 + 요일
              Text(
                '${card.date ?? ''} ${card.weekday ?? ''}',
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 8,
                  color: Colors.white,
                ),
              ),
              // 라이더 타이틀
              if (card.riderTitle != null && card.riderTitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cardType == 0
                        ? const Color(0xFF1B3A5C)
                        : const Color(0xFFE2EDF8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    card.riderTitle!,
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 7,
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
        // 중앙: 라이딩 정보
        Positioned(
          top: 130,
          bottom: 30,
          left: 12,
          right: 12,
          child: Center(
            child: cardType == 0
                ? _buildDialogCardType0Content(card)
                : _buildDialogCardType1Content(card),
          ),
        ),
        // 하단: 스노우라이브 로고
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              'assets/imgs/logos/snowliveLogo_main_white.png',
              height: 8,
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
        Text(
          '${card.totalSlopeCount ?? 0}',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 36,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오늘 총 라이딩',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 10,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    card.mostRiddenSlope?.isNotEmpty == true
                        ? card.mostRiddenSlope!
                        : '-',
                    style: SDSTextStyle.extraBold.copyWith(
                      fontSize: 16,
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
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    '최다 슬로프',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 8,
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
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'km/h',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '최고 속도',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 8,
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
    final displaySlopes = restSlopes.take(2).toList();
    final remainingCount = restSlopes.length - displaySlopes.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${card.totalSlopeCount ?? 0}',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 36,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오늘 총 라이딩',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 10,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          firstSlope?.key ?? '-',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 20,
            color: Colors.white,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (displaySlopes.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              ...displaySlopes.map((entry) {
                return Text(
                  entry.key,
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                );
              }),
              if (remainingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+$remainingCount',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 8,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        Text(
          '라이딩 슬로프',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 8,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // 라이브톡 카드 선택용 타입 0 컨텐츠
  Widget _buildLiveTalkCardType0Content(DailyRidingCard card) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        Text(
          '오늘 총 라이딩',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 3,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
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
                      fontSize: 6,
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
                        fontSize: 4,
                        color: Colors.white,
                      ),
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
                          fontSize: 6,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'km/h',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 4,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '최고 속도',
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
      ],
    );
  }

  // 라이브톡 카드 선택용 타입 1 컨텐츠
  Widget _buildLiveTalkCardType1Content(DailyRidingCard card) {
    final slopeEntries = card.slopeCountsByName?.entries.toList() ?? [];
    final firstSlope = slopeEntries.isNotEmpty ? slopeEntries.first : null;
    final restSlopes = slopeEntries.length > 1 ? slopeEntries.sublist(1) : <MapEntry<String, int>>[];
    final displaySlopes = restSlopes.take(2).toList();
    final remainingCount = restSlopes.length - displaySlopes.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        Text(
          '오늘 총 라이딩',
          style: SDSTextStyle.regular.copyWith(
            fontSize: 3,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        // 첫 번째 슬로프 이름
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
            spacing: 3,
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
        const SizedBox(height: 1),
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
              if (isMyPost) ...[
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: SDSColor.gray600),
                  title: Text(
                    '수정하기',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 16,
                      color: SDSColor.gray900,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _liveTalkViewModel.startEditMode(liveTalk);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: SDSColor.red),
                  title: Text(
                    '삭제하기',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 16,
                      color: SDSColor.red,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    _showDeleteConfirmDialog(liveTalk.livetalkId!, index);
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.report_outlined, color: SDSColor.gray600),
                  title: Text(
                    '신고하기',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 16,
                      color: SDSColor.gray900,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    _showReportConfirmDialog(liveTalk.livetalkId!);
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
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
