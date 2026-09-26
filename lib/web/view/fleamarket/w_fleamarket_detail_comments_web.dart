import 'package:com.snowlive/core/api/api_fleamarket.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_comment_flea.dart';
import 'package:com.snowlive/core/model/m_communityList.dart' show UserInfo;
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

  /// false면(모바일) 헤더 아래·스레드의 인라인 입력창을 그리지 않는다 —
  /// 작성은 부모(상세 화면)의 하단 고정바가 담당한다(피그마 46:9059).
  final bool inlineInput;

  /// 모바일에서 "답글 달기" 탭 시 부모에게 대상 댓글을 알린다(하단 바 답글 모드).
  final ValueChanged<CommentModel_flea>? onReplyTarget;

  const FleamarketDetailCommentsWeb({
    super.key,
    required this.detail,
    this.inlineInput = true,
    this.onReplyTarget,
  });

  @override
  State<FleamarketDetailCommentsWeb> createState() => _FleamarketDetailCommentsWebState();
}

class _FleamarketDetailCommentsWebState extends State<FleamarketDetailCommentsWeb> {
  final FleamarketDetailViewModel _detailVm = Get.find<FleamarketDetailViewModel>();
  final FleamarketCommentDetailViewModel _commentDetailVm = Get.find<FleamarketCommentDetailViewModel>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final _newCommentController = TextEditingController();
  int? _expandedCommentId;

  final _replyInputFocus = FocusNode();

  @override
  void dispose() {
    _newCommentController.dispose();
    _replyInputFocus.dispose();
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

  /// 스레드를 연다 — 입력창(댓글 바로 아래) + 답글 목록이 함께 노출되고, 해당
  /// 댓글의 액션 텍스트("답글 달기/답글 N개 보기")는 숨는다. 다른 댓글이 펼쳐져
  /// 있었다면 아코디언으로 닫힌다.
  /// [requestReply]가 false면(모바일의 "답글 N개 보기") 목록만 펼치고
  /// 하단 바 답글 모드는 켜지 않는다.
  void _openThread(CommentModel_flea comment, {bool requestReply = true}) {
    setState(() => _expandedCommentId = comment.commentId);
    _commentDetailVm.fetchFleamarketCommentDetailFromModel(commentModel_flea: comment);
    if (!widget.inlineInput) {
      // 모바일: 작성은 하단 고정바에서 — 대상만 부모에게 넘긴다.
      if (requestReply) widget.onReplyTarget?.call(comment);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _replyInputFocus.requestFocus();
    });
  }

  Future<void> _postReply(CommentModel_flea comment) async {
    final text = _commentDetailVm.textEditingController.text.trim();
    if (text.isEmpty) return;
    final userId = _userVm.user.user_id;
    if (userId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    final isSecret = _commentDetailVm.isSecret;
    await _commentDetailVm.uploadFleamarketReply({
      'comment_id': comment.commentId.toString(),
      'content': text,
      'user_id': userId.toString(),
      'secret': isSecret,
    });
    _commentDetailVm.textEditingController.clear();
    if (isSecret) _commentDetailVm.changeSecret();
    // 스레드는 입력창까지 열린 채 유지하고, 바깥 "답글 N개 보기" 카운트만
    // 서버 기준으로 갱신한다(댓글 삭제와 같은 패턴).
    await _detailVm.fetchFleamarketComments(
      fleaId: widget.detail.fleaId!,
      userId: userId,
      isLoading_indi: false,
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final comments = _comments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('댓글 ${comments.length}', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
        // 피그마 55:20206 — 헤더↔입력 12, 입력↔목록 30.
        // 모바일(inlineInput=false)은 인라인 입력창 없이 헤더↔목록 20
        if (widget.inlineInput) ...[
          const SizedBox(height: 12),
          _buildCommentInput(),
        ],
        SizedBox(height: widget.inlineInput ? 30 : 20),
        if (comments.isEmpty)
          // 목록 빈 상태와 같은 구성(icon_nodata + 문구), 가운데 정렬.
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Image.asset('assets/imgs/icons/icon_nodata.png', width: 64, height: 64),
                  const SizedBox(height: 6),
                  Text('댓글이 없어요',
                      style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500)),
                ],
              ),
            ),
          )
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
          leading: FleamarketSecretToggle(
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
      padding: const EdgeInsets.only(bottom: 20),
      child: _buildTileLayout(
        userId: comment.userId,
        userInfo: comment.userInfo,
        time: time,
        isAuthor: isAuthor,
        isSecret: comment.secret ?? false,
        content: comment.content ?? '',
        // 닫혀 있을 때는 답글 유무에 따라 "답글 달기"/"답글 N개 보기" — 누르면
        // 입력창+목록이 한 번에 열린다. 열린 스레드에서는 텍스트를 숨기되,
        // 모바일(inlineInput=false)은 하단 바 답글 모드로 재진입해야 하므로
        // "답글 달기"를 계속 보여준다.
        actionLabel: isExpanded
            ? (widget.inlineInput ? null : '답글 달기')
            : (repliesCount > 0 ? '답글 $repliesCount개 보기' : '답글 달기'),
        onActionTap: (isExpanded && widget.inlineInput)
            ? null
            : () => _openThread(
                  comment,
                  // "답글 N개 보기"(펼치기 전 + 답글 있음)는 목록만 펼친다.
                  requestReply: isExpanded || repliesCount == 0,
                ),
        moreButton: _buildMoreButton(
          canDelete: isMine || isMyPost,
          onDelete: () async {
            final userId = _userVm.user.user_id!;
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
              'user_id': _userVm.user.user_id,
              'comment_id': comment.commentId,
            }),
          ),
        ),
        below: isExpanded ? _buildRepliesSection(comment) : null,
      ),
    );
  }

  /// 댓글·답글 공통 타일(피그마 55:20206 — 답글도 댓글과 완전히 같은 구성).
  /// 아바타 32 + 간격 8, 이름줄(이름 bold12 · 시간 12 · 배지 · 우측 ··· 26),
  /// 이름줄↔본문 6, 본문 14/1.4, 본문↔액션 6, 액션 bold13 검정.
  Widget _buildTileLayout({
    required int? userId,
    required UserInfo? userInfo,
    required String time,
    required bool isAuthor,
    required bool isSecret,
    required String content,
    String? actionLabel,
    VoidCallback? onActionTap,
    required Widget moreButton,
    Widget? below,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WebProfileTap(
          userId: userId,
          name: userInfo?.displayName,
          avatarUrl: userInfo?.profileImageUrlUser,
          child: ClipOval(
            child: (userInfo?.profileImageUrlUser?.isNotEmpty ?? false)
                ? WebNetworkImage(
                    url: userInfo!.profileImageUrlUser,
                    width: 32,
                    height: 32,
                    fallback: _defaultAvatar(size: 32),
                  )
                : _defaultAvatar(size: 32),
          ),
        ),
        const SizedBox(width: SDSSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(userInfo?.displayName ?? '',
                      style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.gray900)),
                  const SizedBox(width: 6),
                  Text(time, style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500)),
                  if (isAuthor) ...[
                    const SizedBox(width: 6),
                    Container(
                      constraints: const BoxConstraints(minHeight: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: SDSColor.blue50),
                      child: Text('작성자', style: SDSTextStyle.regular.copyWith(fontSize: 11, color: SDSColor.snowliveBlue)),
                    ),
                  ],
                  if (isSecret) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.lock, size: 12, color: SDSColor.gray400),
                  ],
                  const Spacer(),
                  moreButton,
                ],
              ),
              Text(content,
                  style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900, height: 1.4)),
              if (actionLabel != null) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onActionTap,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      actionLabel,
                      style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
                    ),
                  ),
                ),
              ],
              if (below != null) below,
            ],
          ),
        ),
      ],
    );
  }

  /// 커뮤니티와 같은 공용 메뉴(브레이크포인트별 프레젠테이션 + 확인 다이얼로그)
  Widget _buildMoreButton({
    required bool canDelete,
    required Future<bool> Function() onDelete,
    required Future<WebActionResult> Function() onReport,
  }) {
    return WebMoreButton(
      iconSize: 26,
      iconColor: SDSColor.gray500,
      // 태블릿도 PC와 같은 앵커 드롭다운.
      dropdownOnTablet: true,
      actions: canDelete ? const [WebMoreAction.delete] : const [WebMoreAction.report],
      onSelected: (action) {
        if (_userVm.user.user_id == null) {
          Get.snackbar('알림', '로그인이 필요합니다.');
          return;
        }
        handleWebMoreAction(
          context,
          action: action,
          onDelete: onDelete,
          onReport: onReport,
        );
      },
    );
  }

  Widget _buildRepliesSection(CommentModel_flea comment) {
    // 들여쓰기는 부모 콘텐츠 열 시작선(아바타 32+간격 8 = 40)과 같다 — 이 위젯은
    // 이미 그 열 안에 있으므로 추가 들여쓰기는 없다(피그마 55:19785의 x40).
    return Obx(() {
      final loaded = _commentDetailVm.commentModel_flea;
      final replies = loaded.commentId == comment.commentId ? (loaded.replies ?? <Reply>[]) : <Reply>[];
      // 모바일(inlineInput=false)은 입력창을 안 그리므로, 답글이 없으면 섹션
      // 자체가 빈 껍데기다 — 상단 간격만 남지 않게 아예 그리지 않는다.
      if (!widget.inlineInput && replies.isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final reply in replies) _buildReplyTile(comment, reply),
            // 답글이 없으면 댓글 바로 아래(피그마 55:19785), 있으면 목록 맨 아래에
            // 답글 텍스트 시작선(프사 32+간격 8)만큼 들여써서(55:20206) 노출한다.
            // 모바일은 하단 고정바가 담당하므로 그리지 않는다.
            if (widget.inlineInput)
              Padding(
                padding: EdgeInsets.only(left: replies.isEmpty ? 0 : 40),
                child: WebCommentInput(
                  controller: _commentDetailVm.textEditingController,
                  focusNode: _replyInputFocus,
                  hintText: _commentDetailVm.isSecret ? '비밀 답글을 남겨주세요' : '답글을 남겨주세요',
                  onSubmit: _userVm.user.user_id == null ? null : (_) async => _postReply(comment),
                  onGuestTap: () => Get.snackbar('알림', '로그인이 필요합니다.'),
                  leading: FleamarketSecretToggle(
                    isSecret: _commentDetailVm.isSecret,
                    onTap: _commentDetailVm.changeSecret,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildReplyTile(CommentModel_flea comment, Reply reply) {
    if ((reply.secret ?? false) && !_canSeeSecret(reply.userId)) {
      return const _SecretPlaceholder(label: '이 답글은 비밀글입니다.');
    }
    final isAuthor = reply.userId != null && reply.userId == widget.detail.userId;
    final isMine = reply.userId != null && reply.userId == _userVm.user.user_id;
    final isMyPost = widget.detail.userId != null && widget.detail.userId == _userVm.user.user_id;
    final time = reply.uploadTime != null ? GetDatetime().getAgoString(reply.uploadTime!) : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: _buildTileLayout(
        userId: reply.userId,
        userInfo: reply.userInfo,
        time: time,
        isAuthor: isAuthor,
        isSecret: reply.secret ?? false,
        content: reply.content ?? '',
        // 답글 구조는 1단계(댓글→답글)라 답글에는 답글 달기가 없다.
        moreButton: _buildMoreButton(
          canDelete: isMine || isMyPost,
          onDelete: () async {
            final userId = _userVm.user.user_id!;
            await _commentDetailVm.deleteFleamarketReply(
              replyID: reply.replyId,
              userID: userId.toString(),
            );
            // 스레드(답글 목록)와 바깥 목록(답글 수)을 서버 기준으로 갱신.
            await _commentDetailVm.fetchFleamarketCommentDetail(
                commentId: comment.commentId!);
            await _detailVm.fetchFleamarketComments(
              fleaId: widget.detail.fleaId!,
              userId: userId,
              isLoading_indi: false,
            );
            if (mounted) setState(() {});
            return true;
          },
          onReport: () => mapWebActionResponse(
            () => FleamarketAPI().reportReply({
              'user_id': _userVm.user.user_id.toString(),
              'reply_id': reply.replyId,
            }),
          ),
        ),
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


/// 비밀댓글 토글(자물쇠). 목업처럼 **원형 배경 없이 아이콘만** 두고, 켜지면 검정이 된다.
/// 상세 화면의 모바일 하단 고정바에서도 써야 해서 공개 위젯이다.
class FleamarketSecretToggle extends StatelessWidget {
  final bool isSecret;
  final VoidCallback onTap;

  /// 댓글·답글 입력창 공통 크기.
  static const double size = 30;

  const FleamarketSecretToggle({super.key, required this.isSecret, required this.onTap});

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
              size: size*0.6,
              // 켜짐 = 검정.
              color: isSecret ? SDSColor.snowliveBlack : SDSColor.gray400,
            ),
          ),
        ),
      ),
    );
  }
}

/// 볼 권한이 없는 비밀댓글 자리(앱과 같은 문구·모양)
class _SecretPlaceholder extends StatelessWidget {
  final String label;

  // 댓글 아바타(32)와 나란히 놓이는 자물쇠 원
  static const double size = 28;

  const _SecretPlaceholder({required this.label});

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
