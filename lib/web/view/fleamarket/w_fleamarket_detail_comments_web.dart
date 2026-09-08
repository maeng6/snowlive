import 'package:com.snowlive/core/api/api_fleamarket.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_comment_flea.dart';
import 'package:com.snowlive/core/model/m_fleamarketDetail.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketCommentDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_comment_input_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_tap_web.dart';
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
    // 서버는 문자열 `'true'`/`'false'`를 받는다(앱과 동일: `v_fleaMarketDetail.dart:2144`).
    final isSecret = _detailVm.isSecret;
    await _detailVm.uploadFleamarketComments({
      'flea_id': widget.detail.fleaId,
      'content': text,
      'user_id': userId,
      'secret': '$isSecret',
    });
    _newCommentController.clear();
    // 다음 댓글이 의도치 않게 비밀글이 되지 않도록 토글을 되돌린다.
    if (isSecret) _detailVm.changeSecret();
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
    final isSecret = _commentDetailVm.isSecret;
    _commentDetailVm.uploadFleamarketReply({
      'comment_id': comment.commentId.toString(),
      'content': text,
      'user_id': userId.toString(),
      'secret': isSecret,
    });
    _commentDetailVm.textEditingController.clear();
    if (isSecret) _commentDetailVm.changeSecret();
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
    // 커뮤니티와 같은 공용 입력 위젯(전송 버튼은 입력이 있을 때만 활성화) +
    // 목업의 자물쇠 토글(비밀댓글). 상태는 코어 뷰모델의 `isSecret`을 쓴다(앱과 동일).
    return Obx(() => WebCommentInput(
          controller: _newCommentController,
          hintText: _detailVm.isSecret ? '비밀 댓글을 남겨주세요' : '댓글을 남겨주세요',
          onSubmit: _userVm.user.user_id == null ? null : (_) => _postComment(),
          onGuestTap: () => Get.snackbar('알림', '로그인이 필요합니다.'),
          leading: _SecretToggle(
            isSecret: _detailVm.isSecret,
            onTap: _detailVm.changeSecret,
          ),
        ));
  }

  /// 비밀댓글을 볼 수 있는 사람 — **작성자와 게시글 주인**만(앱과 동일).
  bool _canSeeSecret(int? authorUserId) {
    final myId = _userVm.user.user_id;
    if (myId == null) return false;
    return myId == authorUserId || myId == widget.detail.userId;
  }

  Widget _buildCommentTile(CommentModel_flea comment) {
    // 비밀댓글은 작성자·게시글 주인 외에는 내용을 볼 수 없다(앱과 동일).
    if ((comment.secret ?? false) && !_canSeeSecret(comment.userId)) {
      return const _SecretPlaceholder(label: '이 글은 비밀글입니다.');
    }
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
          WebProfileTap(
            userId: comment.userId,
            name: comment.userInfo?.displayName,
            avatarUrl: comment.userInfo?.profileImageUrlUser,
            child: ClipOval(
              child: (comment.userInfo?.profileImageUrlUser?.isNotEmpty ?? false)
                  ? WebNetworkImage(
                      url: comment.userInfo!.profileImageUrlUser,
                      width: 28,
                      height: 28,
                      fallback: _defaultAvatar(),
                    )
                  : _defaultAvatar(),
            ),
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
                    if (comment.secret ?? false) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.lock, size: 12, color: SDSColor.gray400),
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
          // 커뮤니티와 같은 공용 메뉴(브레이크포인트별 프레젠테이션 + 확인 다이얼로그).
          WebMoreButton(
            iconSize: 18,
            actions: (isMine || isMyPost)
                ? const [WebMoreAction.delete]
                : const [WebMoreAction.report],
            onSelected: (action) {
              final userId = _userVm.user.user_id;
              if (userId == null) {
                Get.snackbar('알림', '로그인이 필요합니다.');
                return;
              }
              handleWebMoreAction(
                context,
                action: action,
                onDelete: () async {
                  await _commentDetailVm.deleteComment(
                      commentId: comment.commentId!, userId: userId);
                  // deleteComment는 fleamarketDetail.commentList를 안 건드리므로
                  // 서버에서 목록을 다시 받아와야 삭제가 화면에 반영된다.
                  await _detailVm.fetchFleamarketComments(
                    fleaId: widget.detail.fleaId!,
                    userId: userId,
                    isLoading_indi: false,
                  );
                  if (mounted) setState(() {});
                  return true;
                },
                onReport: () => mapWebActionResponse(
                  () => FleamarketAPI().reportComment({
                    'user_id': userId,
                    'comment_id': comment.commentId,
                  }),
                ),
              );
            },
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
            WebCommentInput(
              controller: _commentDetailVm.textEditingController,
              hintText: _commentDetailVm.isSecret ? '비밀 답글을 남겨주세요' : '답글을 남겨주세요',
              onSubmit: _userVm.user.user_id == null ? null : (_) async => _postReply(comment),
              onGuestTap: () => Get.snackbar('알림', '로그인이 필요합니다.'),
              leading: _SecretToggle(
                isSecret: _commentDetailVm.isSecret,
                onTap: _commentDetailVm.changeSecret,
                size: 30,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildReplyTile(Reply reply) {
    if ((reply.secret ?? false) && !_canSeeSecret(reply.userId)) {
      return const _SecretPlaceholder(label: '이 답글은 비밀글입니다.', size: 24);
    }
    final time = reply.uploadTime != null ? GetDatetime().getAgoString(reply.uploadTime!) : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: SDSSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WebProfileTap(
            userId: reply.userId,
            name: reply.userInfo?.displayName,
            avatarUrl: reply.userInfo?.profileImageUrlUser,
            child: ClipOval(
              child: (reply.userInfo?.profileImageUrlUser?.isNotEmpty ?? false)
                  ? WebNetworkImage(
                      url: reply.userInfo!.profileImageUrlUser,
                      width: 22,
                      height: 22,
                      fallback: _defaultAvatar(size: 22),
                    )
                  : _defaultAvatar(size: 22),
            ),
          ),
          const SizedBox(width: SDSSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(reply.userInfo?.displayName ?? '', style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.gray900)),
                    if (reply.secret ?? false) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.lock, size: 11, color: SDSColor.gray400),
                    ],
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


/// 비밀댓글 토글(자물쇠). 목업처럼 **원형 배경 없이 아이콘만** 두고, 켜지면 파란색이 된다.
class _SecretToggle extends StatelessWidget {
  final bool isSecret;
  final VoidCallback onTap;
  final double size;

  const _SecretToggle({required this.isSecret, required this.onTap, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isSecret ? '비밀댓글 끄기' : '비밀댓글로 남기기',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              Icons.lock,
              size: size * 0.5,
              color: isSecret ? SDSColor.snowliveBlue : SDSColor.gray400,
            ),
          ),
        ),
      ),
    );
  }
}

/// 볼 권한이 없는 비밀댓글 자리(앱과 같은 문구·모양).
class _SecretPlaceholder extends StatelessWidget {
  final String label;
  final double size;

  const _SecretPlaceholder({required this.label, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SDSSpacing.lg),
      child: Row(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: SDSColor.gray100),
            child: Icon(Icons.lock, size: size * 0.55, color: SDSColor.gray400),
          ),
          const SizedBox(width: SDSSpacing.sm),
          Text(label, style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500)),
        ],
      ),
    );
  }
}
