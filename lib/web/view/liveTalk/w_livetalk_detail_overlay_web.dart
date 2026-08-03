import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_comment_list_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_feed_item_web.dart'
    show LiveTalkCountButton, kLiveTalkLikeOnAsset, kLiveTalkLikeOffAsset, kLiveTalkReplyOnAsset, kLiveTalkReplyOffAsset;
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkDetail_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_comment_input_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 라이브톡 상세 — 사진 + 글 + 댓글을 한 오버레이에 담는다(목업).
/// 데스크탑은 좌 사진 / 우 댓글 패널, 태블릿은 1열(사진 위 · 댓글 아래).
/// **모바일에서는 쓰지 않는다** — 사진은 공용 라이트박스, 댓글은 별도 화면이다.
///
/// 리턴값이 true면 좋아요·댓글·삭제 등으로 목록을 갱신해야 한다는 뜻이다.
Future<bool> showLiveTalkDetailOverlay({
  required BuildContext context,
  required int livetalkId,
  int? userId,
}) async {
  final vm = Get.find<LiveTalkDetailViewModelWeb>();
  // 이전에 열었던 글이 한 프레임 비치지 않도록 먼저 로드한다.
  await vm.load(livetalkId: livetalkId, userId: userId);

  final changed = await showWebOverlayModal<bool>(
    context: context,
    // 목업의 오버레이는 화면을 거의 가득 채운다.
    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
    builder: (ctx, close) => _LiveTalkDetailCard(vm: vm, onClose: close),
  );
  return changed ?? false;
}

class _LiveTalkDetailCard extends StatefulWidget {
  final LiveTalkDetailViewModelWeb vm;
  final void Function([bool? result]) onClose;

  const _LiveTalkDetailCard({required this.vm, required this.onClose});

  @override
  State<_LiveTalkDetailCard> createState() => _LiveTalkDetailCardState();
}

class _LiveTalkDetailCardState extends State<_LiveTalkDetailCard> {
  final _commentController = TextEditingController();

  /// 답글을 달 대상 댓글. null이면 일반 댓글 입력.
  LiveTalkComment? _replyTarget;

  /// 좋아요/댓글이 하나라도 바뀌면 닫을 때 목록을 갱신해야 한다.
  bool _changed = false;

  LiveTalkDetailViewModelWeb get _vm => widget.vm;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _close() => widget.onClose(_changed);

  Future<void> _submitComment() async {
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
    if (mounted) setState(() { _replyTarget = null; _changed = true; });
  }

  Future<void> _toggleLike() async {
    if (_vm.detail == null) return;
    final updated = await _vm.toggleLike();
    if (updated == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    if (mounted) setState(() => _changed = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    // 높이는 Flexible이 알아서 줄여준다(모달이 이미 padding으로 여백을 줬으므로
    // 여기서 또 빼면 이중 계산이 된다). 폭만 목업 값으로 묶는다.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Material(
            // Overlay 직삽이라 Material 조상이 없다 → 카드 표면을 Material로.
            color: SDSColor.snowliveWhite,
            borderRadius: BorderRadius.circular(4),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 1256 : 480),
              child: Obx(() {
                if (_vm.isLoading && _vm.detail == null) {
                  return const SizedBox(
                    height: 320,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                final detail = _vm.detail;
                if (detail == null) {
                  return SizedBox(
                    height: 240,
                    child: Center(
                      child: Text('글을 불러오지 못했어요',
                          style: SDSTextStyle.regular
                              .copyWith(fontSize: 14, color: SDSColor.gray500)),
                    ),
                  );
                }
                return isDesktop ? _buildDesktop(detail) : _buildTablet(detail);
              }),
            ),
          ),
        ),
        const SizedBox(height: SDSSpacing.lg),
        _CircleIconButton(icon: Icons.close, onTap: _close),
      ],
    );
  }

  /// 데스크탑: 좌 사진 / 우 380~436 댓글 패널.
  Widget _buildDesktop(LiveTalk detail) {
    final hasImage = detail.imageUrl != null && detail.imageUrl!.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasImage) Expanded(child: _buildImagePane(detail)),
        SizedBox(width: 436, child: _buildPanel(detail)),
      ],
    );
  }

  /// 태블릿: 사진 위 · 글 · 댓글 아래 1열.
  Widget _buildTablet(LiveTalk detail) {
    final hasImage = detail.imageUrl != null && detail.imageUrl!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasImage) SizedBox(height: 300, child: _buildImagePane(detail)),
        Flexible(child: _buildPanel(detail)),
      ],
    );
  }

  /// 사진(또는 라이딩 카드) 영역. 카드는 세로로 길어서 꽉 채우면 잘리므로
  /// 검정 배경 + contain으로 둘 다 자연스럽게 담는다.
  Widget _buildImagePane(LiveTalk detail) {
    return ColoredBox(
      color: SDSColor.snowliveBlack,
      child: WebNetworkImage(url: detail.imageUrl, fit: BoxFit.contain),
    );
  }

  Widget _buildPanel(LiveTalk detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPostHeader(detail),
        Container(height: 1, color: SDSColor.gray100),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(SDSSpacing.md, SDSSpacing.md, SDSSpacing.md, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('댓글 ${_vm.commentCount}',
                    style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900)),
                const SizedBox(height: SDSSpacing.md),
                LiveTalkCommentListWeb(
                  vm: _vm,
                  postUserId: detail.userId,
                  onReplyTap: (comment) => setState(() => _replyTarget = comment),
                ),
              ],
            ),
          ),
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildPostHeader(LiveTalk detail) {
    final userInfo = detail.userInfo;
    final time = detail.uploadTime != null ? GetDatetime().getAgoString(detail.uploadTime!) : '';
    final hasText = detail.description != null && detail.description!.trim().isNotEmpty;
    final isLiked = detail.isLiked == true;

    return Padding(
      padding: const EdgeInsets.all(SDSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: (userInfo?.profileImageUrl?.isNotEmpty ?? false)
                    ? WebNetworkImage(
                        url: userInfo!.profileImageUrl,
                        width: 28,
                        height: 28,
                        fallback: _defaultAvatar())
                    : _defaultAvatar(),
              ),
              const SizedBox(width: SDSSpacing.sm),
              Expanded(
                child: Text(userInfo?.displayName ?? '익명',
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Text(time, style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray400)),
              const SizedBox(width: 4),
              WebMoreButton(
                iconSize: 20,
                actions: _vm.isAuthor
                    ? const [WebMoreAction.delete]
                    : const [WebMoreAction.reportPost, WebMoreAction.hideUser],
                onSelected: _onPostMoreAction,
              ),
            ],
          ),
          if (hasText) ...[
            const SizedBox(height: SDSSpacing.sm),
            Text(detail.description!,
                style: SDSTextStyle.regular
                    .copyWith(fontSize: 14, color: SDSColor.gray900, height: 1.45)),
          ],
          const SizedBox(height: SDSSpacing.sm),
          Row(
            children: [
              // 피드와 같은 버튼·같은 에셋(모바일 앱 아이콘)을 쓴다.
              LiveTalkCountButton(
                asset: isLiked ? kLiveTalkLikeOnAsset : kLiveTalkLikeOffAsset,
                textColor: isLiked ? SDSColor.gray900 : SDSColor.gray400,
                count: detail.likeCount ?? 0,
                onTap: _toggleLike,
              ),
              const SizedBox(width: SDSSpacing.md),
              LiveTalkCountButton(
                asset: (detail.commentCount ?? 0) > 0
                    ? kLiveTalkReplyOnAsset
                    : kLiveTalkReplyOffAsset,
                textColor: SDSColor.gray400,
                count: detail.commentCount ?? 0,
                onTap: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final target = _replyTarget;
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: SDSColor.gray100))),
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
            child: WebCommentInput(
              controller: _commentController,
              hintText: target == null ? '댓글을 남겨주세요' : '답글을 남겨주세요',
              isSubmitting: _vm.isSubmitting,
              // onSubmit이 null이면 WebCommentInput이 게스트로 취급한다.
              onSubmit: _vm.isGuest ? null : (_) => _submitComment(),
              onGuestTap: () => Get.snackbar('알림', '로그인이 필요합니다.'),
            ),
          ),
        ],
      ),
    );
  }

  void _onPostMoreAction(WebMoreAction action) {
    handleWebMoreAction(
      context,
      action: action,
      onDelete: () async {
        final ok = await _vm.deletePost();
        if (ok) {
          _changed = true;
          _close();
        }
        return ok;
      },
      onReport: _vm.reportPost,
      onHideUser: () => _vm.blockAuthor(_vm.detail?.userId),
    );
  }

  Widget _defaultAvatar() => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(shape: BoxShape.circle, color: SDSColor.gray100),
        child: Icon(Icons.person, size: 16, color: SDSColor.gray400),
      );
}

/// 오버레이 아래에 떠 있는 흰 원형 버튼(목업의 ✕ / ‹ / ›).
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, size: 24, color: SDSColor.gray900),
        ),
      ),
    );
  }
}
