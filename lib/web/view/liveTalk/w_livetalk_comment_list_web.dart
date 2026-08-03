import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkDetail_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:flutter/material.dart';

/// 라이브톡 댓글·답글 목록. 상세 오버레이(데스크탑·태블릿)와 모바일 댓글 화면이 공유한다.
///
/// 답글 앞에는 **그 스레드 댓글 작성자의 닉네임을 파란색으로** 붙인다(목업).
/// 서버가 멘션 텍스트를 주지 않으므로 UI가 합성한다 — 커뮤니티와 같은 규칙.
class LiveTalkCommentListWeb extends StatelessWidget {
  final LiveTalkDetailViewModelWeb vm;

  /// 글 작성자 id — `작성자` 배지 판단에 쓴다.
  final int? postUserId;

  /// 답글 대상 댓글 id를 바꿔 달라는 요청.
  final ValueChanged<LiveTalkComment> onReplyTap;

  const LiveTalkCommentListWeb({
    super.key,
    required this.vm,
    required this.postUserId,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    final comments = vm.comments;
    if (comments.isEmpty) return const LiveTalkCommentsEmpty();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final comment in comments) _buildComment(context, comment),
      ],
    );
  }

  Widget _buildComment(BuildContext context, LiveTalkComment comment) {
    final replies = comment.replies ?? const <LiveTalkReply>[];
    return Padding(
      padding: const EdgeInsets.only(bottom: SDSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommentRow(
            avatarUrl: comment.userInfo?.profileImageUrl,
            name: comment.userInfo?.displayName ?? '익명',
            isAuthor: postUserId != null && comment.userId == postUserId,
            time: comment.uploadTime,
            content: comment.content ?? '',
            avatarSize: 28,
            onReplyTap: () => onReplyTap(comment),
            moreActions: vm.isMyComment(comment.userId)
                ? const [WebMoreAction.delete]
                : const [WebMoreAction.report],
            onMoreAction: (action) => handleWebMoreAction(
              context,
              action: action,
              onDelete: () => vm.deleteComment(comment.commentId!),
              onReport: () => vm.reportComment(comment.commentId!),
            ),
          ),
          for (final reply in replies)
            Padding(
              padding: const EdgeInsets.only(left: SDSSpacing.lg, top: SDSSpacing.md),
              child: _CommentRow(
                avatarUrl: reply.userInfo?.profileImageUrl,
                name: reply.userInfo?.displayName ?? '익명',
                isAuthor: postUserId != null && reply.userId == postUserId,
                time: reply.uploadTime,
                content: reply.content ?? '',
                // 목업: 답글 본문 앞에 스레드 댓글 작성자 닉네임을 파란색으로.
                mention: comment.userInfo?.displayName,
                avatarSize: 26,
                onReplyTap: () => onReplyTap(comment),
                moreActions: vm.isMyComment(reply.userId)
                    ? const [WebMoreAction.delete]
                    : const [WebMoreAction.report],
                onMoreAction: (action) => handleWebMoreAction(
                  context,
                  action: action,
                  onDelete: () => vm.deleteReply(reply.replyId!),
                  onReport: () => vm.reportReply(reply.replyId!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 댓글 0건 상태(목업: 말풍선 아이콘 + 문구).
class LiveTalkCommentsEmpty extends StatelessWidget {
  const LiveTalkCommentsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 32, color: SDSColor.gray200),
          const SizedBox(height: SDSSpacing.sm),
          Text('댓글이 없어요',
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400)),
        ],
      ),
    );
  }
}

/// 댓글/답글 한 줄. 둘의 차이는 아바타 크기와 멘션뿐이다.
class _CommentRow extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final bool isAuthor;
  final String? time;
  final String content;
  final String? mention;
  final double avatarSize;
  final VoidCallback onReplyTap;
  final List<WebMoreAction> moreActions;
  final ValueChanged<WebMoreAction> onMoreAction;

  const _CommentRow({
    required this.avatarUrl,
    required this.name,
    required this.isAuthor,
    required this.time,
    required this.content,
    required this.avatarSize,
    required this.onReplyTap,
    required this.moreActions,
    required this.onMoreAction,
    this.mention,
  });

  @override
  Widget build(BuildContext context) {
    final ago = time != null ? GetDatetime().getAgoString(time!) : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: (avatarUrl?.isNotEmpty ?? false)
              ? WebNetworkImage(
                  url: avatarUrl,
                  width: avatarSize,
                  height: avatarSize,
                  fallback: _defaultAvatar(),
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
                  Text(name, style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900)),
                  const SizedBox(width: 6),
                  Text(ago, style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400)),
                  if (isAuthor) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: SDSColor.blue50,
                      ),
                      child: Text('작성자',
                          style: SDSTextStyle.bold
                              .copyWith(fontSize: 11, color: SDSColor.snowliveBlue)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    if (mention != null && mention!.isNotEmpty)
                      TextSpan(
                        text: '$mention ',
                        style: SDSTextStyle.bold
                            .copyWith(fontSize: 14, color: SDSColor.snowliveBlue, height: 1.4),
                      ),
                    TextSpan(
                      text: content,
                      style: SDSTextStyle.regular
                          .copyWith(fontSize: 14, color: SDSColor.gray900, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onReplyTap,
                  child: Text('답글 달기',
                      style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.gray700)),
                ),
              ),
            ],
          ),
        ),
        WebMoreButton(iconSize: 18, actions: moreActions, onSelected: onMoreAction),
      ],
    );
  }

  Widget _defaultAvatar() => Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(shape: BoxShape.circle, color: SDSColor.gray100),
        child: Icon(Icons.person, size: avatarSize * 0.6, color: SDSColor.gray400),
      );
}
