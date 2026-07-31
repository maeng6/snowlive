import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_liveTalk.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/liveTalk/vm_liveTalk.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';

class LiveTalkCommentView extends StatefulWidget {
  const LiveTalkCommentView({Key? key}) : super(key: key);

  @override
  State<LiveTalkCommentView> createState() => _LiveTalkCommentViewState();
}

class _LiveTalkCommentViewState extends State<LiveTalkCommentView> {
  final LiveTalkViewModel _liveTalkViewModel = Get.find<LiveTalkViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final FocusNode _commentFocusNode = FocusNode();
  final GlobalKey _inputAreaKey = GlobalKey();
  double _inputAreaHeight = 60;

  void _navigateToProfile(int? userId) async {
    if (userId == null) return;

    Get.toNamed(AppRoutes.friendDetail);
    await _friendDetailViewModel.fetchFriendDetailInfo(
      userId: _userViewModel.user.user_id,
      friendUserId: userId,
      season: _friendDetailViewModel.seasonDate,
    );
  }

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['liveTalk'] != null) {
      final liveTalk = arguments['liveTalk'] as LiveTalk;
      _liveTalkViewModel.fetchCommentsForLiveTalk(liveTalk);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureInputAreaHeight());
  }

  void _measureInputAreaHeight() {
    final RenderBox? renderBox = _inputAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _inputAreaHeight = renderBox.size.height;
      });
    }
  }

  @override
  void dispose() {
    _commentFocusNode.dispose();
    _liveTalkViewModel.cancelAllInputModes();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureInputAreaHeight());
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: SDSColor.snowliveWhite,
        appBar: AppBar(
        backgroundColor: SDSColor.snowliveWhite,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: SDSColor.gray900),
          onPressed: () => Get.back(),
        ),
        title: Text(
          '댓글',
          style: SDSTextStyle.bold.copyWith(
            fontSize: 18,
            color: SDSColor.gray900,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 댓글 목록
              Expanded(
                child: Obx(() {
                  // 초기 로딩 시에만 로딩 인디케이터 표시 (댓글 목록이 비어있을 때)
                  if (_liveTalkViewModel.isLoadingComments.value &&
                      _liveTalkViewModel.commentList.isEmpty) {
                    return Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          backgroundColor: SDSColor.gray100,
                          color: SDSColor.gray300.withOpacity(0.6),
                        ),
                      ),
                    );
                  }

                  if (_liveTalkViewModel.commentList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/imgs/icons/icon_friendsTalk_nodata.png',
                            width: 74,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '첫 번째 댓글을 남겨보세요',
                            style: SDSTextStyle.regular.copyWith(
                              fontSize: 14,
                              color: const Color(0xFF949494),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _liveTalkViewModel.commentList.length,
                    itemBuilder: (context, index) {
                      final comment = _liveTalkViewModel.commentList[index];
                      final isLast = index == _liveTalkViewModel.commentList.length - 1;
                      return _buildCommentItem(comment, index, isLast: isLast);
                    },
                  );
                }),
              ),

              // 댓글 입력 영역
              Container(
                key: _inputAreaKey,
                child: _buildCommentInput(),
              ),
            ],
          ),

          // 답글 작성 모드 (플로팅)
          Obx(() {
            if (_liveTalkViewModel.isReplyMode.value &&
                _liveTalkViewModel.replyTargetComment.value != null) {
              return Positioned(
                left: 0,
                right: 0,
                bottom: _inputAreaHeight + 12,
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
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: _liveTalkViewModel.replyTargetComment.value!.userInfo?.displayName ?? '익명',
                                style: SDSTextStyle.bold.copyWith(
                                  fontSize: 13,
                                  color: SDSColor.snowliveBlack,
                                ),
                              ),
                              TextSpan(
                                text: '님에게 답글 작성 중',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 13,
                                  color: SDSColor.snowliveBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _liveTalkViewModel.cancelReplyMode(),
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

          // 댓글 수정 모드 (플로팅)
          Obx(() {
            if (_liveTalkViewModel.isEditCommentMode.value &&
                _liveTalkViewModel.editingComment.value != null) {
              return Positioned(
                left: 0,
                right: 0,
                bottom: _inputAreaHeight + 12,
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
                          '댓글 수정 중',
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: 13,
                            color: SDSColor.snowliveBlack,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _liveTalkViewModel.cancelEditCommentMode(),
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

          // 답글 수정 모드 (플로팅)
          Obx(() {
            if (_liveTalkViewModel.isEditReplyMode.value &&
                _liveTalkViewModel.editingReply.value != null) {
              return Positioned(
                left: 0,
                right: 0,
                bottom: _inputAreaHeight + 12,
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
                          '답글 수정 중',
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: 13,
                            color: SDSColor.snowliveBlack,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _liveTalkViewModel.cancelEditReplyMode(),
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
        ],
      ),
      ),
    );
  }

  Widget _buildCommentItem(LiveTalkComment comment, int index, {bool isLast = false}) {
    final isMyComment = comment.userId == _userViewModel.user.user_id;
    final isLiked = comment.isLiked ?? false;
    final likeCount = comment.likeCount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 댓글 본문
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 이미지 (30x30)
              GestureDetector(
                onTap: () => _navigateToProfile(comment.userId),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SDSColor.gray100,
                  ),
                  child: ClipOval(
                    child: comment.userInfo?.profileImageUrl != null &&
                            comment.userInfo!.profileImageUrl!.isNotEmpty
                        ? ExtendedImage.network(
                            comment.userInfo!.profileImageUrl!,
                            fit: BoxFit.cover,
                            cache: true,
                            cacheWidth: 90,
                            cacheHeight: 90,
                            loadStateChanged: (state) {
                              switch (state.extendedImageLoadState) {
                                case LoadState.loading:
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      color: Colors.white,
                                    ),
                                  );
                                case LoadState.failed:
                                  return _buildDefaultAvatar();
                                case LoadState.completed:
                                  return null;
                              }
                            },
                          )
                        : _buildDefaultAvatar(),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 댓글 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 닉네임
                        GestureDetector(
                          onTap: () => _navigateToProfile(comment.userId),
                          child: Text(
                            comment.userInfo?.displayName ?? '익명',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 14,
                              color: SDSColor.snowliveBlack,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // 시간
                        Text(
                          comment.uploadTime != null
                              ? GetDatetime().getAgoString(comment.uploadTime!)
                              : '',
                          style: SDSTextStyle.regular.copyWith(
                            fontSize: 13,
                            color: SDSColor.gray400,
                          ),
                        ),
                        // 더보기 버튼 (게시 중에는 숨김)
                        if (!comment.isPending)
                          GestureDetector(
                            onTap: () => _showCommentOptions(comment, isMyComment, index),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Icon(
                                Icons.more_horiz,
                                color: SDSColor.gray300,
                                size: 24,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // 본문
                    Text(
                      comment.content ?? '',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 15,
                        color: SDSColor.snowliveBlack,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 게시 중 상태 또는 좋아요 + 답글 달기
                    if (comment.isPending)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LoadingAnimationWidget.waveDots(
                            color: SDSColor.gray400,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '게시중',
                            style: SDSTextStyle.regular.copyWith(
                              fontSize: 13,
                              color: SDSColor.gray400,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          // 좋아요 버튼
                          GestureDetector(
                            onTap: () => _liveTalkViewModel.toggleCommentLikeByIndex(index),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  isLiked
                                      ? 'assets/imgs/icons/icon_livetalk_like_on.svg'
                                      : 'assets/imgs/icons/icon_livetalk_like_off.svg',
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  likeCount > 0 ? '$likeCount' : '좋아요',
                                  style: SDSTextStyle.regular.copyWith(
                                    fontSize: 13,
                                    color: isLiked ? SDSColor.snowliveBlack : SDSColor.gray500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          // 답글 달기 버튼
                          GestureDetector(
                            onTap: () {
                              _liveTalkViewModel.setReplyMode(comment);
                              _commentFocusNode.requestFocus();
                            },
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/imgs/icons/icon_livetalk_reply_off.svg',
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '답글',
                                  style: SDSTextStyle.regular.copyWith(
                                    fontSize: 13,
                                    color: SDSColor.gray500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 답글 목록
        if (comment.replies != null && comment.replies!.isNotEmpty)
          ...comment.replies!.asMap().entries.map((entry) =>
            _buildReplyItem(entry.value, index, entry.key)).toList(),

        if (!isLast)
          const Divider(height: 12, thickness: 1, color: SDSColor.gray50),
        if (isLast)
          const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: SDSColor.gray100,
      child: Center(
        child: Icon(
          Icons.person,
          color: SDSColor.gray300,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildReplyItem(LiveTalkReply reply, int commentIndex, int replyIndex) {
    final isMyReply = reply.userId == _userViewModel.user.user_id;
    final isLiked = reply.isLiked ?? false;
    final likeCount = reply.likeCount ?? 0;

    return Container(
      margin: const EdgeInsets.only(left: 38),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: SDSColor.snowliveWhite,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 이미지 (26x26)
          GestureDetector(
            onTap: () => _navigateToProfile(reply.userId),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SDSColor.gray100,
              ),
              child: ClipOval(
                child: reply.userInfo?.profileImageUrl != null &&
                        reply.userInfo!.profileImageUrl!.isNotEmpty
                    ? ExtendedImage.network(
                        reply.userInfo!.profileImageUrl!,
                        fit: BoxFit.cover,
                        cache: true,
                        cacheWidth: 78,
                        cacheHeight: 78,
                        loadStateChanged: (state) {
                          switch (state.extendedImageLoadState) {
                            case LoadState.loading:
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  color: Colors.white,
                                ),
                              );
                            case LoadState.failed:
                              return _buildSmallDefaultAvatar();
                            case LoadState.completed:
                              return null;
                          }
                        },
                      )
                    : _buildSmallDefaultAvatar(),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 답글 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 닉네임
                    GestureDetector(
                      onTap: () => _navigateToProfile(reply.userId),
                      child: Text(
                        reply.userInfo?.displayName ?? '익명',
                        style: SDSTextStyle.bold.copyWith(
                          fontSize: 13,
                          color: SDSColor.snowliveBlack,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // 시간
                    Text(
                      reply.uploadTime != null
                          ? GetDatetime().getAgoString(reply.uploadTime!)
                          : '',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 12,
                        color: SDSColor.gray400,
                      ),
                    ),
                    // 더보기 버튼 (게시 중에는 숨김)
                    if (!reply.isPending)
                      GestureDetector(
                        onTap: () => _showReplyOptions(reply, isMyReply, commentIndex, replyIndex),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Icon(
                            Icons.more_horiz,
                            color: SDSColor.gray300,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // 본문
                Text(
                  reply.content ?? '',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 14,
                    color: SDSColor.snowliveBlack,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                // 게시 중 상태 또는 좋아요 버튼
                if (reply.isPending)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '게시중',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 13,
                          color: SDSColor.gray400,
                        ),
                      ),
                      const SizedBox(width: 6),
                      LoadingAnimationWidget.waveDots(
                        color: SDSColor.gray300,
                        size: 16,
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: () => _liveTalkViewModel.toggleReplyLikeByIndex(commentIndex, replyIndex),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          isLiked
                              ? 'assets/imgs/icons/icon_livetalk_like_on.svg'
                              : 'assets/imgs/icons/icon_livetalk_like_off.svg',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          likeCount > 0 ? '$likeCount' : '좋아요',
                          style: SDSTextStyle.regular.copyWith(
                            fontSize: 13,
                            color: isLiked ? SDSColor.snowliveBlack : SDSColor.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDefaultAvatar() {
    return Container(
      color: SDSColor.gray100,
      child: Center(
        child: Icon(
          Icons.person,
          color: SDSColor.gray300,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Obx(() {
            final isEnabled = _liveTalkViewModel.isCommentButtonEnabled.value;

            return ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 36,
                maxHeight: 120,
              ),
              child: TextFormField(
                controller: _liveTalkViewModel.commentController,
                focusNode: _commentFocusNode,
                cursorColor: SDSColor.snowliveBlue,
                cursorHeight: 16,
                cursorWidth: 2,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 14,
                  color: SDSColor.snowliveBlack,
                  height: 1.3,
                ),
                decoration: InputDecoration(
                  hintText: _liveTalkViewModel.isEditCommentMode.value
                      ? '댓글을 수정하세요...'
                      : _liveTalkViewModel.isEditReplyMode.value
                          ? '답글을 수정하세요...'
                          : _liveTalkViewModel.isReplyMode.value
                              ? '답글을 입력하세요...'
                              : '댓글을 입력하세요...',
                  hintStyle: SDSTextStyle.regular.copyWith(
                    fontSize: 14,
                    color: SDSColor.gray400,
                  ),
                  contentPadding: const EdgeInsets.only(
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
                    onTap: isEnabled
                        ? () async {
                            FocusScope.of(context).unfocus();
                            if (_liveTalkViewModel.isEditCommentMode.value) {
                              // 댓글 수정
                              final success = await _liveTalkViewModel.updateCommentFromController();
                              if (success) {
                                Get.snackbar('수정 완료', '댓글이 수정되었습니다.',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: SDSColor.snowliveWhite);
                              }
                            } else if (_liveTalkViewModel.isEditReplyMode.value) {
                              // 답글 수정
                              final success = await _liveTalkViewModel.updateReplyFromController();
                              if (success) {
                                Get.snackbar('수정 완료', '답글이 수정되었습니다.',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: SDSColor.snowliveWhite);
                              }
                            } else if (_liveTalkViewModel.isReplyMode.value) {
                              // 답글 작성
                              await _liveTalkViewModel.createReplyFromController();
                            } else {
                              // 댓글 작성
                              await _liveTalkViewModel.createCommentFromController();
                            }
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Image.asset(
                        isEnabled
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
      ),
    );
  }

  void _showCommentOptions(LiveTalkComment comment, bool isMyComment, int commentIndex) {
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
                  if (isMyComment) ...[
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
                          _liveTalkViewModel.startEditCommentMode(comment, commentIndex);
                          _commentFocusNode.requestFocus();
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
                        onTap: () async {
                          Navigator.pop(context);
                          final success = await _liveTalkViewModel.deleteComment(comment.commentId!);
                          if (success) {
                            Get.snackbar('삭제 완료', '댓글이 삭제되었습니다.',
                                snackPosition: SnackPosition.TOP);
                          }
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
                        onTap: () async {
                          Navigator.pop(context);
                          final success = await _liveTalkViewModel.reportComment(comment.commentId!);
                          if (success) {
                            Get.snackbar('신고 완료', '신고가 접수되었습니다.',
                                snackPosition: SnackPosition.TOP);
                          }
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

  void _showReplyOptions(LiveTalkReply reply, bool isMyReply, int commentIndex, int replyIndex) {
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
                  if (isMyReply) ...[
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
                          _liveTalkViewModel.startEditReplyMode(reply, commentIndex, replyIndex);
                          _commentFocusNode.requestFocus();
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
                        onTap: () async {
                          Navigator.pop(context);
                          final success = await _liveTalkViewModel.deleteReply(reply.replyId!);
                          if (success) {
                            Get.snackbar('삭제 완료', '답글이 삭제되었습니다.',
                                snackPosition: SnackPosition.TOP);
                          }
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
                        onTap: () async {
                          Navigator.pop(context);
                          final success = await _liveTalkViewModel.reportReply(reply.replyId!);
                          if (success) {
                            Get.snackbar('신고 완료', '신고가 접수되었습니다.',
                                snackPosition: SnackPosition.TOP);
                          }
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
}
