import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkDetail_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_tap_web.dart';
import 'package:flutter/material.dart';

/// 댓글 빈 상태 아이콘 — 앱 라이브톡 댓글 화면과 같은 빈 말풍선.
const String kLiveTalkCommentsEmptyIcon =
    'assets/imgs/icons/icon_friendsTalk_nodata.png';

/// 빈 상태가 차지할 최소 높이. 이 안에서 가운데보다 [_kEmptyRaise]만큼 위에 놓는다
/// — 정확히 가운데면 아래로 처져 보인다(사용자 확정).
const double _kEmptyMinHeight = 160;
const double _kEmptyRaise = 20;

/// 라이브톡 댓글·답글 목록. 상세 오버레이(데스크탑·태블릿)와 모바일 댓글 화면이 공유한다.
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
            userId: comment.userId,
            name: comment.userInfo?.displayName ?? '익명',
            isAuthor: postUserId != null && comment.userId == postUserId,
            time: comment.uploadTime,
            content: comment.content ?? '',
            // 댓글 아바타 32 (피그마 80:220289). 답글은 한 단계 작은 26 유지.
            avatarSize: 32,
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
                userId: reply.userId,
                name: reply.userInfo?.displayName ?? '익명',
                isAuthor: postUserId != null && reply.userId == postUserId,
                time: reply.uploadTime,
                content: reply.content ?? '',
                // 멘션은 서버가 내려주지 않는 값이라 UI 합성을 하지 않는다
                // (커뮤니티와 동일 — 서버에 대상 필드가 생기면 다시 붙인다).
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
/// 댓글 빈 상태. 아이콘은 앱 라이브톡 댓글 화면·웹 방명록과 같은 빈 말풍선
/// (`icon_friendsTalk_nodata.png`, 74) — 문구만 웹 공통('댓글이 없어요' 14 gray500).
///
/// [fillHeight]면 남은 영역 **세로 중앙**에 놓는다(오버레이처럼 댓글 칸 높이가
/// 정해진 곳). 아니면 위아래 여백만 두고 흐름대로 놓는다.
class LiveTalkCommentsEmpty extends StatelessWidget {
  final bool fillHeight;

  const LiveTalkCommentsEmpty({super.key, this.fillHeight = false});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(kLiveTalkCommentsEmptyIcon, width: 74),
        Text('댓글이 없어요',
            style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500)),
      ],
    );
    // 가운데에서 [_kEmptyRaise]만큼 위로. Padding으로 아래를 키우면 영역 자체가
    // 커지고, Alignment는 "빈 공간의 비율"이라 콘텐츠 높이에 따라 이동량이
    // 달라진다 — 레이아웃을 건드리지 않는 Transform으로 정확히 그만큼만 올린다.
    final raised = Center(
      child: Transform.translate(
        offset: const Offset(0, -_kEmptyRaise),
        child: content,
      ),
    );

    if (!fillHeight) {
      // 카드 높이가 내용에 따라 줄어드는 자리(태블릿·모바일)에서는 남는 영역이
      // 없다 — 대신 최소 높이를 주고 그 안에 놓는다.
      return ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: double.infinity,
          minHeight: _kEmptyMinHeight,
        ),
        child: raised,
      );
    }
    return raised;
  }
}

/// 댓글/답글 한 줄. 둘의 차이는 아바타 크기뿐이다.
///
/// 답글 앞의 파란 멘션은 **서버가 대상 필드를 안 내려줘서** 뺐다(커뮤니티와 동일 —
/// 필드가 생기면 다시 붙인다).
class _CommentRow extends StatelessWidget {
  final String? avatarUrl;
  /// 프로필 사진 탭 → 프로필 팝업.
  final int? userId;
  final String name;
  final bool isAuthor;
  final String? time;
  final String content;
  final double avatarSize;
  final VoidCallback onReplyTap;
  final List<WebMoreAction> moreActions;
  final ValueChanged<WebMoreAction> onMoreAction;

  const _CommentRow({
    required this.avatarUrl,
    required this.userId,
    required this.name,
    required this.isAuthor,
    required this.time,
    required this.content,
    required this.avatarSize,
    required this.onReplyTap,
    required this.moreActions,
    required this.onMoreAction,
  });

  @override
  Widget build(BuildContext context) {
    final ago = time != null ? GetDatetime().getAgoString(time!) : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WebProfileTap(
          userId: userId,
          name: name,
          avatarUrl: avatarUrl,
          child: ClipOval(
            child: (avatarUrl?.isNotEmpty ?? false)
                ? WebNetworkImage(
                    url: avatarUrl,
                    width: avatarSize,
                    height: avatarSize,
                    fallback: _defaultAvatar(),
                  )
                : _defaultAvatar(),
          ),
        ),
        // 아바타 ↔ 내용 10 — 피드·상세 헤더와 같은 값(사용자 확정).
        const SizedBox(width: 10),
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
        // ⋯ 26(클릭 영역 28) — 피드·상세 헤더와 동일한 웹 공통 규격.
        WebMoreButton(
          iconSize: 26,
          hitPadding: 1,
          iconColor: SDSColor.gray500,
          actions: moreActions,
          onSelected: onMoreAction,
        ),
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
