import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_liveTalk.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/liveTalk/vm_liveTalk.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  }

  @override
  void dispose() {
    _commentFocusNode.dispose();
    _liveTalkViewModel.cancelAllInputModes();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: SDSColor.snowliveWhite,
        appBar: AppBar(
        backgroundColor: SDSColor.snowliveWhite,
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
      body: Column(
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
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: SDSColor.gray300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '첫 번째 댓글을 남겨보세요',
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _liveTalkViewModel.commentList.length,
                itemBuilder: (context, index) {
                  final comment = _liveTalkViewModel.commentList[index];
                  return _buildCommentItem(comment, index);
                },
              );
            }),
          ),

          // 모드 표시 (답글 / 댓글 수정 / 답글 수정)
          Obx(() {
            // 댓글 수정 모드
            if (_liveTalkViewModel.isEditCommentMode.value &&
                _liveTalkViewModel.editingComment.value != null) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: SDSColor.snowliveBlue.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 16, color: SDSColor.snowliveBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '댓글 수정 중',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 13,
                          color: SDSColor.snowliveBlue,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _liveTalkViewModel.cancelEditCommentMode(),
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
            // 답글 수정 모드
            if (_liveTalkViewModel.isEditReplyMode.value &&
                _liveTalkViewModel.editingReply.value != null) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: SDSColor.snowliveBlue.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 16, color: SDSColor.snowliveBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '답글 수정 중',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 13,
                          color: SDSColor.snowliveBlue,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _liveTalkViewModel.cancelEditReplyMode(),
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
            // 답글 작성 모드
            if (_liveTalkViewModel.isReplyMode.value &&
                _liveTalkViewModel.replyTargetComment.value != null) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: SDSColor.gray50,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_liveTalkViewModel.replyTargetComment.value!.userInfo?.displayName ?? '익명'}님에게 답글 작성 중',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 13,
                          color: SDSColor.gray600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _liveTalkViewModel.cancelReplyMode(),
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

          // 댓글 입력 영역
          _buildCommentInput(),
        ],
      ),
      ),
    );
  }

  Widget _buildCommentItem(LiveTalkComment comment, int index) {
    final isMyComment = comment.userId == _userViewModel.user.user_id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 댓글 본문
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 이미지
              GestureDetector(
                onTap: () => _navigateToProfile(comment.userId),
                child: Container(
                  width: 36,
                  height: 36,
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
                          )
                        : Icon(Icons.person, color: SDSColor.gray400, size: 20),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 댓글 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _navigateToProfile(comment.userId),
                          child: Text(
                            comment.userInfo?.displayName ?? '익명',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 13,
                              color: SDSColor.gray900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          comment.uploadTime != null
                              ? GetDatetime().getAgoString(comment.uploadTime!)
                              : '',
                          style: SDSTextStyle.regular.copyWith(
                            fontSize: 12,
                            color: SDSColor.gray500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content ?? '',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 14,
                        color: SDSColor.gray900,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 게시 중 상태 또는 좋아요 + 답글 달기
                    if (comment.isPending)
                      Text(
                        '게시중...',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 12,
                          color: SDSColor.gray400,
                        ),
                      )
                    else
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _liveTalkViewModel.toggleCommentLikeByIndex(index),
                            child: Row(
                              children: [
                                Icon(
                                  (comment.isLiked ?? false)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 16,
                                  color: (comment.isLiked ?? false)
                                      ? SDSColor.red
                                      : SDSColor.gray500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${comment.likeCount ?? 0}',
                                  style: SDSTextStyle.regular.copyWith(
                                    fontSize: 12,
                                    color: SDSColor.gray500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              _liveTalkViewModel.setReplyMode(comment);
                              _commentFocusNode.requestFocus();
                            },
                            child: Text(
                              '답글 달기',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 12,
                                color: SDSColor.gray500,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // 더보기 버튼 (게시 중에는 숨김)
              if (!comment.isPending)
                GestureDetector(
                  onTap: () => _showCommentOptions(comment, isMyComment, index),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.more_horiz,
                      size: 18,
                      color: SDSColor.gray400,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 답글 목록
        if (comment.replies != null && comment.replies!.isNotEmpty)
          ...comment.replies!.asMap().entries.map((entry) =>
            _buildReplyItem(entry.value, index, entry.key)).toList(),

        const Divider(height: 1, color: SDSColor.gray100),
      ],
    );
  }

  Widget _buildReplyItem(LiveTalkReply reply, int commentIndex, int replyIndex) {
    final isMyReply = reply.userId == _userViewModel.user.user_id;

    return Container(
      margin: const EdgeInsets.only(left: 48),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: SDSColor.gray50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 이미지
          GestureDetector(
            onTap: () => _navigateToProfile(reply.userId),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SDSColor.gray200,
              ),
              child: ClipOval(
                child: reply.userInfo?.profileImageUrl != null &&
                        reply.userInfo!.profileImageUrl!.isNotEmpty
                    ? ExtendedImage.network(
                        reply.userInfo!.profileImageUrl!,
                        fit: BoxFit.cover,
                        cache: true,
                      )
                    : Icon(Icons.person, color: SDSColor.gray400, size: 16),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 답글 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _navigateToProfile(reply.userId),
                      child: Text(
                        reply.userInfo?.displayName ?? '익명',
                        style: SDSTextStyle.bold.copyWith(
                          fontSize: 12,
                          color: SDSColor.gray900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      reply.uploadTime != null
                          ? GetDatetime().getAgoString(reply.uploadTime!)
                          : '',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 11,
                        color: SDSColor.gray500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reply.content ?? '',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 13,
                    color: SDSColor.gray900,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                // 게시 중 상태 또는 좋아요 버튼
                if (reply.isPending)
                  Text(
                    '게시중...',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 11,
                      color: SDSColor.gray400,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _liveTalkViewModel.toggleReplyLikeByIndex(commentIndex, replyIndex),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (reply.isLiked ?? false)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 14,
                          color: (reply.isLiked ?? false)
                              ? SDSColor.red
                              : SDSColor.gray500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${reply.likeCount ?? 0}',
                          style: SDSTextStyle.regular.copyWith(
                            fontSize: 11,
                            color: SDSColor.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 더보기 버튼 (게시 중에는 숨김)
          if (!reply.isPending)
            GestureDetector(
              onTap: () => _showReplyOptions(reply, isMyReply, commentIndex, replyIndex),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.more_horiz,
                  size: 16,
                  color: SDSColor.gray400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        border: Border(
          top: BorderSide(color: SDSColor.gray100),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Obx(() {
            final isEnabled = _liveTalkViewModel.isCommentButtonEnabled.value;
            final isEditMode = _liveTalkViewModel.isEditCommentMode.value ||
                _liveTalkViewModel.isEditReplyMode.value;

            return ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 40,
                maxHeight: 100,
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
                  color: SDSColor.gray900,
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
                    left: 12,
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
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: isEditMode
                        ? Icon(
                            Icons.check,
                            color: isEnabled ? SDSColor.snowliveBlue : SDSColor.gray300,
                            size: 24,
                          )
                        : Image.asset(
                            isEnabled
                                ? 'assets/imgs/icons/icon_livetalk_send.png'
                                : 'assets/imgs/icons/icon_livetalk_send_g.png',
                            width: 24,
                            height: 24,
                          ),
                    onPressed: isEnabled
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
              if (isMyComment) ...[
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: SDSColor.gray600),
                  title: Text(
                    '수정하기',
                    style: SDSTextStyle.regular.copyWith(color: SDSColor.gray900),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _liveTalkViewModel.startEditCommentMode(comment, commentIndex);
                    _commentFocusNode.requestFocus();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: SDSColor.red),
                  title: Text(
                    '삭제하기',
                    style: SDSTextStyle.regular.copyWith(color: SDSColor.red),
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
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.report_outlined, color: SDSColor.gray600),
                  title: Text(
                    '신고하기',
                    style: SDSTextStyle.regular.copyWith(color: SDSColor.gray900),
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
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showReplyOptions(LiveTalkReply reply, bool isMyReply, int commentIndex, int replyIndex) {
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
              if (isMyReply) ...[
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: SDSColor.gray600),
                  title: Text(
                    '수정하기',
                    style: SDSTextStyle.regular.copyWith(color: SDSColor.gray900),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _liveTalkViewModel.startEditReplyMode(reply, commentIndex, replyIndex);
                    _commentFocusNode.requestFocus();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: SDSColor.red),
                  title: Text(
                    '삭제하기',
                    style: SDSTextStyle.regular.copyWith(color: SDSColor.red),
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
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.report_outlined, color: SDSColor.gray600),
                  title: Text(
                    '신고하기',
                    style: SDSTextStyle.regular.copyWith(color: SDSColor.gray900),
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
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
