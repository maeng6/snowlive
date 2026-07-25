import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_comment_flea.dart';
import 'package:com.snowlive/core/model/m_fleamarketDetail.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketCommentDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 댓글 입력(목록 위, 고정 아님) + 댓글 목록 + 댓글별 "답글 달기" 인라인 펼치기.
/// core의 FleamarketCommentDetailViewModel은 단일 인스턴스라 한 번에 하나의
/// 댓글만 펼쳐지도록(아코디언) 제한해서 상태 충돌을 피한다.
class FleamarketDetailCommentsWeb extends StatefulWidget {
  final FleamarketDetailModel detail;

  const FleamarketDetailCommentsWeb({super.key, required this.detail});

  @override
  State<FleamarketDetailCommentsWeb> createState() => _FleamarketDetailCommentsWebState();
}

class _FleamarketDetailCommentsWebState extends State<FleamarketDetailCommentsWeb> {
  final FleamarketDetailViewModel _detailVm = Get.find<FleamarketDetailViewModel>();
  final FleamarketCommentDetailViewModel _commentDetailVm = Get.find<FleamarketCommentDetailViewModel>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final _newCommentController = TextEditingController();
  int? _expandedCommentId;

  @override
  void dispose() {
    _newCommentController.dispose();
    super.dispose();
  }

  // uploadFleamarketComments/deleteComment는 core에서 fleamarketDetail을 직접
  // 뮤테이션만 하고 Rx 재할당을 안 해서(Obx가 못 감지) widget.detail(부모가 넘겨준
  // 스냅샷)은 갱신되지 않는다. 그래서 항상 VM에서 최신 값을 직접 읽고, 쓰기 액션
  // 뒤엔 이 위젯이 직접 setState로 다시 그린다.
  List<CommentModel_flea> get _comments =>
      (_detailVm.fleamarketDetail.commentList ?? []).whereType<CommentModel_flea>().toList();

  Future<void> _postComment() async {
    final text = _newCommentController.text.trim();
    if (text.isEmpty) return;
    final userId = _userVm.user.user_id;
    if (userId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    await _detailVm.uploadFleamarketComments({
      'flea_id': widget.detail.fleaId,
      'content': text,
      'user_id': userId,
      'secret': 'false',
    });
    _newCommentController.clear();
    if (mounted) setState(() {});
  }

  void _toggleReplies(CommentModel_flea comment) {
    final isExpanding = _expandedCommentId != comment.commentId;
    setState(() => _expandedCommentId = isExpanding ? comment.commentId : null);
    if (isExpanding) {
      _commentDetailVm.fetchFleamarketCommentDetailFromModel(commentModel_flea: comment);
    }
  }

  void _postReply(CommentModel_flea comment) {
    final text = _commentDetailVm.textEditingController.text.trim();
    if (text.isEmpty) return;
    final userId = _userVm.user.user_id;
    if (userId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    _commentDetailVm.uploadFleamarketReply({
      'comment_id': comment.commentId.toString(),
      'content': text,
      'user_id': userId.toString(),
      'secret': false,
    });
    _commentDetailVm.textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final comments = _comments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('댓글 ${comments.length}', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
        const SizedBox(height: SDSSpacing.md),
        _buildCommentInput(),
        const SizedBox(height: SDSSpacing.lg),
        if (comments.isEmpty)
          Text('댓글이 없어요', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400))
        else
          for (final comment in comments) _buildCommentTile(comment),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _newCommentController,
            decoration: InputDecoration(
              hintText: '댓글을 남겨주세요',
              hintStyle: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400),
              filled: true,
              fillColor: SDSColor.gray50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: SDSSpacing.sm),
        IconButton(onPressed: _postComment, icon: Icon(Icons.send, color: SDSColor.snowliveBlue)),
      ],
    );
  }

  Widget _buildCommentTile(CommentModel_flea comment) {
    final isAuthor = comment.userId != null && comment.userId == widget.detail.userId;
    final isMine = comment.userId != null && comment.userId == _userVm.user.user_id;
    final isMyPost = widget.detail.userId != null && widget.detail.userId == _userVm.user.user_id;
    final time = comment.uploadTime != null ? GetDatetime().getAgoString(comment.uploadTime!) : '';
    final repliesCount = comment.replies?.length ?? 0;
    final isExpanded = _expandedCommentId == comment.commentId;

    return Padding(
      padding: const EdgeInsets.only(bottom: SDSSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: (comment.userInfo?.profileImageUrlUser?.isNotEmpty ?? false)
                ? Image.network(
                    comment.userInfo!.profileImageUrlUser!,
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _defaultAvatar(),
                  )
                : _defaultAvatar(),
          ),
          const SizedBox(width: SDSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.userInfo?.displayName ?? '',
                        style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900)),
                    if (isAuthor) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: SDSColor.blue50),
                        child: Text('글쓴이', style: SDSTextStyle.bold.copyWith(fontSize: 10, color: SDSColor.snowliveBlue)),
                      ),
                    ],
                    const SizedBox(width: 6),
                    Text(time, style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content ?? '', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _toggleReplies(comment),
                  child: Text(
                    repliesCount == 0 ? '답글 달기' : '답글 $repliesCount개 보기',
                    style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.snowliveBlue),
                  ),
                ),
                if (isExpanded) _buildRepliesSection(comment),
              ],
            ),
          ),
          if (isMine || isMyPost)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz, size: 18, color: SDSColor.gray400),
              onSelected: (value) async {
                final userId = _userVm.user.user_id;
                if (userId == null) {
                  Get.snackbar('알림', '로그인이 필요합니다.');
                  return;
                }
                if (value == 'delete') {
                  await _commentDetailVm.deleteComment(commentId: comment.commentId!, userId: userId);
                  // deleteComment는 fleamarketDetail.commentList를 안 건드리므로
                  // 서버에서 목록을 다시 받아와야 삭제가 화면에 반영된다.
                  await _detailVm.fetchFleamarketComments(
                    fleaId: widget.detail.fleaId!,
                    userId: userId,
                    isLoading_indi: false,
                  );
                  if (mounted) setState(() {});
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'delete', child: Text('삭제하기')),
              ],
            )
          else
            PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz, size: 18, color: SDSColor.gray400),
              onSelected: (value) {
                final userId = _userVm.user.user_id;
                if (userId == null) {
                  Get.snackbar('알림', '로그인이 필요합니다.');
                  return;
                }
                if (value == 'report') {
                  _commentDetailVm.reportComment({'user_id': userId, 'comment_id': comment.commentId});
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'report', child: Text('신고하기')),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRepliesSection(CommentModel_flea comment) {
    return Obx(() {
      final loaded = _commentDetailVm.commentModel_flea;
      final replies = loaded.commentId == comment.commentId ? (loaded.replies ?? <Reply>[]) : <Reply>[];
      return Padding(
        padding: const EdgeInsets.only(top: SDSSpacing.sm, left: SDSSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final reply in replies) _buildReplyTile(reply),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentDetailVm.textEditingController,
                    decoration: InputDecoration(
                      hintText: '답글을 남겨주세요',
                      hintStyle: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray400),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: SDSColor.gray50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: SDSSpacing.xs),
                IconButton(
                  onPressed: () => _postReply(comment),
                  icon: Icon(Icons.send, size: 18, color: SDSColor.snowliveBlue),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildReplyTile(Reply reply) {
    final time = reply.uploadTime != null ? GetDatetime().getAgoString(reply.uploadTime!) : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: SDSSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: (reply.userInfo?.profileImageUrlUser?.isNotEmpty ?? false)
                ? Image.network(
                    reply.userInfo!.profileImageUrlUser!,
                    width: 22,
                    height: 22,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _defaultAvatar(size: 22),
                  )
                : _defaultAvatar(size: 22),
          ),
          const SizedBox(width: SDSSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(reply.userInfo?.displayName ?? '', style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.gray900)),
                    const SizedBox(width: 6),
                    Text(time, style: SDSTextStyle.regular.copyWith(fontSize: 11, color: SDSColor.gray400)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(reply.content ?? '', style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar({double size = 28}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: SDSColor.gray100),
      child: Icon(Icons.person, size: size * 0.6, color: SDSColor.gray400),
    );
  }
}
