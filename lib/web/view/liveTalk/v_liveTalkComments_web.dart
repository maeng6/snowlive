import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_comment_list_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkDetail_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_comment_input_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 모바일 전용 라이브톡 댓글 화면(목업: `← 댓글 4`).
/// 데스크탑·태블릿은 사진+댓글 오버레이 안에서 보므로 이 화면을 쓰지 않는다.
///
/// `#/livetalk-comments?id=74`로 직접 진입(딥링크)해도 동작한다.
class LiveTalkCommentsViewWeb extends StatefulWidget {
  const LiveTalkCommentsViewWeb({super.key});

  @override
  State<LiveTalkCommentsViewWeb> createState() => _LiveTalkCommentsViewWebState();
}

class _LiveTalkCommentsViewWebState extends State<LiveTalkCommentsViewWeb> {
  final LiveTalkDetailViewModelWeb _vm = Get.find<LiveTalkDetailViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final _commentController = TextEditingController();

  LiveTalkComment? _replyTarget;

  /// 라우트 파라미터는 initState에서 잡아둔다 — 이후 Get.parameters가 비워질 수 있다.
  int? _livetalkId;

  /// 하단 고정 입력바 높이(답글 대상 바가 뜨면 그만큼 더).
  static const double _barHeight = 76;
  static const double _barHeightWithReply = 116;

  @override
  void initState() {
    super.initState();
    _livetalkId = int.tryParse(Get.parameters['id'] ?? '');
    final id = _livetalkId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _vm.load(livetalkId: id, userId: _userVm.user.user_id);
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final target = _replyTarget;
    final ok = target == null
        ? await _vm.postComment(text)
        : await _vm.postReply(commentId: target.commentId!, content: text);
    if (!ok) {
      Get.snackbar('오류', '등록에 실패했어요. 잠시 후 다시 시도해주세요.');
      return;
    }
    _commentController.clear();
    if (mounted) setState(() => _replyTarget = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_livetalkId == null) {
      return WebEmptyState(
        message: '글을 찾을 수 없어요',
        actionLabel: '라이브톡으로',
        onAction: () => Get.offNamed(WebRoutes.liveTalk),
      );
    }

    final barHeight = _replyTarget == null ? _barHeight : _barHeightWithReply;

    final scrollArea = Container(
      color: SDSColor.snowliveWhite,
      padding: const EdgeInsets.fromLTRB(SDSSpacing.md, SDSSpacing.md, SDSSpacing.md, SDSSpacing.lg),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: SDSSpacing.lg),
            Obx(() {
              if (_vm.isLoading && _vm.detail == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              if (_vm.detail == null) {
                return WebEmptyState(
                  message: '글을 불러오지 못했어요',
                  actionLabel: '다시 시도',
                  onAction: () => _vm.load(
                      livetalkId: _livetalkId!, userId: _userVm.user.user_id),
                );
              }
              return LiveTalkCommentListWeb(
                vm: _vm,
                postUserId: _vm.detail?.userId,
                onReplyTap: (comment) => setState(() => _replyTarget = comment),
              );
            }),
          ],
        ),
      ),
    );

    // 셸이 페이지를 Expanded에 넣으므로 Stack의 bottom이 곧 뷰포트 하단이다.
    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          Padding(padding: EdgeInsets.only(bottom: barHeight), child: scrollArea),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildInputBar()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () =>
              Get.key.currentState?.canPop() == true ? Get.back() : Get.offNamed(WebRoutes.liveTalk),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(Icons.arrow_back, color: SDSColor.gray900, size: 24),
        ),
        const SizedBox(width: SDSSpacing.md),
        Obx(() => Text(
              '댓글 ${_vm.commentCount}',
              style: SDSTextStyle.extraBold.copyWith(fontSize: 18, color: SDSColor.gray900),
            )),
      ],
    );
  }

  Widget _buildInputBar() {
    final target = _replyTarget;
    return Container(
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        border: Border(top: BorderSide(color: SDSColor.gray100)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (target != null)
            WebReplyTargetBar(
              targetName: target.userInfo?.displayName ?? '',
              onCancel: () => setState(() => _replyTarget = null),
            ),
          Padding(
            padding: const EdgeInsets.all(SDSSpacing.md),
            child: Obx(() => WebCommentInput(
                  controller: _commentController,
                  hintText: target == null ? '댓글을 남겨주세요' : '답글을 남겨주세요',
                  isSubmitting: _vm.isSubmitting,
                  onSubmit: _vm.isGuest ? null : (_) => _submit(),
                  onGuestTap: () => Get.snackbar('알림', '로그인이 필요합니다.'),
                )),
          ),
        ],
      ),
    );
  }
}
