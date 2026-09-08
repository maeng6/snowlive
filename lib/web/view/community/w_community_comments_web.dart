import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_communityList.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityDetail_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_tap_web.dart';
import 'package:flutter/material.dart';

/// 댓글/답글 목록.
///
/// 상세 응답에 댓글과 답글이 **중첩되어** 오므로 아코디언(펼침 시 지연 조회)이 필요 없다.
/// 목업대로 모든 스레드의 답글을 항상 그린다.
class CommunityCommentsWeb extends StatelessWidget {
  final CommunityDetailViewModelWeb vm;
  final int? postAuthorId;
  final int? myUserId;

  /// 답글을 작성 중인 댓글 id(태블릿·데스크탑은 인라인 입력창 위치, 모바일은 하단 바 표시).
  final int? replyTargetCommentId;
  final ValueChanged<int?> onReplyTargetChanged;

  /// 태블릿·데스크탑에서 스레드 아래에 그릴 인라인 입력창 빌더.
  final Widget Function(int commentId)? inlineReplyInputBuilder;

  const CommunityCommentsWeb({
    super.key,
    required this.vm,
    required this.postAuthorId,
    required this.myUserId,
    required this.replyTargetCommentId,
    required this.onReplyTargetChanged,
    this.inlineReplyInputBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final comments = vm.comments;
    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            '첫 댓글을 남겨보세요.',
            style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final comment in comments) _buildThread(context, comment),
      ],
    );
  }

  Widget _buildThread(BuildContext context, CommentModel_community comment) {
    // whereType은 타입이 틀리면 조용히 빈 목록이 된다(Reply가 두 파일에 중복 정의됨).
    // 이 파일은 m_communityList.dart만 import하므로 cast로 즉시 드러나게 한다.
    final replies = (comment.replies ?? const []).cast<Reply>();
    final commentId = comment.commentId;
    final isReplying = commentId != null && commentId == replyTargetCommentId;
    final showInlineInput =
        isReplying && !context.isMobileWidth && inlineReplyInputBuilder != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: SDSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommentTile(
            avatarSize: 32,
            displayName: comment.userInfo?.displayName,
            photoUrl: comment.userInfo?.profileImageUrlUser,
            userId: comment.userId,
            uploadTime: comment.uploadTime,
            content: comment.content ?? '',
            isPostAuthor: postAuthorId != null && comment.userId == postAuthorId,
            contentStyle: SDSTextStyle.regular
                .copyWith(fontSize: 14, color: SDSColor.gray900, height: 1.4),
            onReply: commentId == null
                ? null
                : () => onReplyTargetChanged(isReplying ? null : commentId),
            replyLabel: isReplying ? '답글 취소' : '답글 달기',
            trailing: _buildMenu(
              context,
              isMine: myUserId != null && comment.userId == myUserId,
              targetUserId: comment.userId,
              onDelete: commentId == null ? null : () => vm.deleteComment(commentId),
              onReport: commentId == null ? null : () => vm.reportCommentById(commentId),
            ),
          ),
          if (showInlineInput)
            Padding(
              padding: const EdgeInsets.only(left: 42, top: SDSSpacing.sm),
              child: inlineReplyInputBuilder!(commentId),
            ),
          for (final reply in replies)
            Padding(
              // 답글 들여쓰기
              padding: const EdgeInsets.only(left: 42, top: SDSSpacing.md),
              child: _CommentTile(
                avatarSize: 26,
                displayName: reply.userInfo?.displayName,
                photoUrl: reply.userInfo?.profileImageUrlUser,
                userId: reply.userId,
                uploadTime: reply.uploadTime,
                content: reply.content ?? '',
                isPostAuthor: postAuthorId != null && reply.userId == postAuthorId,
                contentStyle: SDSTextStyle.regular
                    .copyWith(fontSize: 13, color: SDSColor.gray900, height: 1.4),
                // 서버 답글 데이터에는 멘션이 없다. 그 스레드의 댓글 작성자 닉네임을
                // UI가 파란색으로 붙여서 목업과 같은 모양을 만든다.
                mentionName: comment.userInfo?.displayName,
                trailing: _buildMenu(
                  context,
                  isMine: myUserId != null && reply.userId == myUserId,
                  targetUserId: reply.userId,
                  onDelete: reply.replyId == null ? null : () => vm.deleteReply(reply.replyId!),
                  onReport:
                      reply.replyId == null ? null : () => vm.reportReplyById(reply.replyId!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenu(
    BuildContext context, {
    required bool isMine,
    required int? targetUserId,
    required Future<bool> Function()? onDelete,
    required Future<WebActionResult> Function()? onReport,
  }) {
    // 게스트는 신고/차단할 수 없다.
    if (myUserId == null) return const SizedBox.shrink();
    return WebMoreButton(
      actions: isMine
          ? const [WebMoreAction.delete]
          : const [WebMoreAction.report, WebMoreAction.hideUser],
      onSelected: (action) => handleWebMoreAction(
        context,
        action: action,
        onDelete: onDelete,
        onReport: onReport,
        onHideUser: targetUserId == null ? null : () => vm.blockUser(targetUserId),
      ),
    );
  }
}

extension _MobileWidth on BuildContext {
  bool get isMobileWidth => screenType == WebScreenType.mobile;
}

class _CommentTile extends StatelessWidget {
  final double avatarSize;
  final String? displayName;
  final String? photoUrl;
  /// 프로필 사진 탭 → 프로필 팝업.
  final int? userId;
  final String? uploadTime;
  final String content;
  final bool isPostAuthor;
  final TextStyle contentStyle;
  final String? mentionName;
  final VoidCallback? onReply;
  final String replyLabel;
  final Widget trailing;

  const _CommentTile({
    required this.avatarSize,
    required this.displayName,
    required this.photoUrl,
    required this.userId,
    required this.uploadTime,
    required this.content,
    required this.isPostAuthor,
    required this.contentStyle,
    required this.trailing,
    this.mentionName,
    this.onReply,
    this.replyLabel = '답글 달기',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WebProfileTap(
          userId: userId,
          name: displayName,
          avatarUrl: photoUrl,
          child: ClipOval(
            child: (photoUrl != null && photoUrl!.isNotEmpty)
                ? WebNetworkImage(url: photoUrl, width: avatarSize, height: avatarSize)
                : Container(
                    width: avatarSize,
                    height: avatarSize,
                    color: SDSColor.blue50,
                    child: Icon(Icons.person, size: avatarSize * 0.55, color: SDSColor.gray400),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      displayName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _relativeTime(uploadTime),
                    style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
                  ),
                  if (isPostAuthor) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: SDSColor.blue50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '작성자',
                        style:
                            SDSTextStyle.bold.copyWith(fontSize: 11, color: SDSColor.snowliveBlue),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    if (mentionName != null && mentionName!.isNotEmpty)
                      TextSpan(
                        text: '$mentionName ',
                        style: contentStyle.copyWith(
                          color: SDSColor.snowliveBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    TextSpan(text: content),
                  ],
                ),
                style: contentStyle,
              ),
              if (onReply != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onReply,
                  child: Text(
                    replyLabel,
                    style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  /// `getAgoString`은 내부에서 DateTime.parse를 무방비로 호출한다.
  static String _relativeTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      return GetDatetime().getAgoString(raw);
    } catch (_) {
      return '';
    }
  }
}
