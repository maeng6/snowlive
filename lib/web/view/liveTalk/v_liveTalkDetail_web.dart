import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_comment_list_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_detail_body_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkDetail_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalk_web.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart' show showWebEditTextDialog;
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_comment_input_web.dart';
import 'package:com.snowlive/web/widget/w_web_image_viewer_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_page_header_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 모바일 전용 라이브톡 **게시물 상세** 화면 — 사진·글·좋아요·댓글이 한 화면에
/// 있고 입력창이 하단에 고정된다(인스타식, 사용자 확정). 피드에서 사진을 누르든
/// 댓글을 누르든 여기로 온다. 사진을 다시 누르면 공용 라이트박스로 확대된다.
///
/// 데스크탑·태블릿은 같은 내용을 오버레이로 본다 — 사진 칸·글 헤더는
/// [LiveTalkImagePane]/[LiveTalkPostHeader]로 **공유**한다.
///
/// `#/livetalk-detail?id=74`로 직접 진입(딥링크)해도 동작한다.
class LiveTalkDetailViewWeb extends StatefulWidget {
  const LiveTalkDetailViewWeb({super.key});

  @override
  State<LiveTalkDetailViewWeb> createState() =>
      _LiveTalkDetailViewWebState();
}

class _LiveTalkDetailViewWebState extends State<LiveTalkDetailViewWeb> {
  final LiveTalkDetailViewModelWeb _vm = Get.find<LiveTalkDetailViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final _commentController = TextEditingController();

  LiveTalkComment? _replyTarget;

  /// 라우트 파라미터는 initState에서 잡아둔다 — 이후 Get.parameters가 비워질 수 있다.
  int? _livetalkId;

  /// 하단 고정 입력바 높이 66 = 여백 10 + 입력창 46 (상세 오버레이와 같은 규격).
  /// 답글 대상 바가 뜨면 그만큼 더.
  static const double _barHeight = 66;
  static const double _barHeightWithReply = 106;

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
      child: SingleChildScrollView(
        // 좌우 여백은 스크롤 영역 **안쪽**(웹 공통 규칙). 사진 칸은 폭을 꽉 채워야
        // 해서 아래에서 따로 음수 여백 없이 헤더만 패딩을 받는다.
        padding: EdgeInsets.only(bottom: SDSSpacing.lg),
        child: Obx(() {
          if (_vm.isLoading && _vm.detail == null) {
            return Padding(
              padding: webSubPagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ],
              ),
            );
          }
          final detail = _vm.detail;
          if (detail == null) {
            return Padding(
              padding: webSubPagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  WebEmptyState(
                    message: '글을 불러오지 못했어요',
                    actionLabel: '다시 시도',
                    onAction: () => _vm.load(
                      livetalkId: _livetalkId!,
                      userId: _userVm.user.user_id,
                    ),
                  ),
                ],
              ),
            );
          }
          return _buildPost(detail);
        }),
      ),
    );

    // 셸이 페이지를 Expanded에 넣으므로 Stack의 bottom이 곧 뷰포트 하단이다.
    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: barHeight),
            child: scrollArea,
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildInputBar()),
        ],
      ),
    );
  }

  /// 사진 → 글 헤더 → 구분선 → `댓글 N` → 목록. 상세 오버레이와 같은 순서·규격.
  Widget _buildPost(LiveTalk detail) {
    final hasImage = detail.imageUrl != null && detail.imageUrl!.isNotEmpty;
    final pad = webSubPagePadding(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(pad.left, pad.top, pad.right, 0),
          child: _buildHeader(),
        ),
        // 뒤로가기 줄 ↔ 사진 10 (사용자 확정).
        const SizedBox(height: 10),
        if (hasImage)
          // 사진은 좌우 여백 안쪽 폭을 꽉 채우는 정사각(오버레이와 동일).
          // 다시 누르면 공용 라이트박스로 확대한다.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad.left),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _openLightbox(detail),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LiveTalkImagePane(url: detail.imageUrl),
                  ),
                ),
              ),
            ),
          ),
        LiveTalkPostHeader(
          detail: detail,
          padding: pad.left,
          isAuthor: _vm.isAuthor,
          onMoreAction: _onPostMoreAction,
          onToggleLike: _toggleLike,
        ),
        // 구분선은 화면 전체 폭(오버레이 패널과 같은 규칙).
        Container(height: 1, color: SDSColor.gray100),
        Padding(
          // 구분선 ↔ '댓글 N' 20, 목록 16.
          padding: EdgeInsets.fromLTRB(pad.left, 20, pad.right, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '댓글 ${_vm.commentCount}',
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 16,
                  color: SDSColor.gray900,
                ),
              ),
              const SizedBox(height: SDSSpacing.md),
              LiveTalkCommentListWeb(
                vm: _vm,
                postUserId: detail.userId,
                onReplyTap: (comment) => setState(() => _replyTarget = comment),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openLightbox(LiveTalk detail) async {
    final url = detail.imageUrl;
    if (url == null || url.isEmpty) return;
    await showWebImageViewer(
      context: context,
      title: detail.userInfo?.displayName ?? '라이브톡',
      imageUrls: [url],
      initialIndex: 0,
    );
  }

  Future<void> _toggleLike() async {
    if (_vm.detail == null) return;
    final updated = await _vm.toggleLike();
    if (updated == null) Get.snackbar('알림', '로그인이 필요합니다.');
  }

  void _onPostMoreAction(WebMoreAction action) {
    handleWebMoreAction(
      context,
      action: action,
      onEdit: () async {
        final text = await showWebEditTextDialog(
          context: context,
          title: '글 수정',
          initialText: _vm.detail?.description ?? '',
          hint: '내용을 입력하세요',
        );
        if (text == null) return;
        final ok = await _vm.updatePost(description: text);
        if (!ok) {
          Get.snackbar('오류', '수정에 실패했어요.');
          return;
        }
        // 목록도 반영되게 그 글만 다시 받는다(상세는 updatePost가 재조회).
        if (_vm.livetalkId != null &&
            Get.isRegistered<LiveTalkListPaginationViewModelWeb>()) {
          await Get.find<LiveTalkListPaginationViewModelWeb>().reloadItem(_vm.livetalkId!);
        }
      },
      onDelete: () async {
        final deletedId = _vm.livetalkId;
        final ok = await _vm.deletePost();
        if (ok) {
          // 목록에 돌아갔을 때 지워진 글이 그대로 남지 않게 미리 뺀다.
          if (deletedId != null &&
              Get.isRegistered<LiveTalkListPaginationViewModelWeb>()) {
            Get.find<LiveTalkListPaginationViewModelWeb>().removeItem(deletedId);
          }
          // 지운 글의 상세에 남아 있을 이유가 없다.
          if (mounted) Get.back();
        }
        return ok;
      },
      onReport: _vm.reportPost,
      onHideUser: () => _vm.blockAuthor(_vm.detail?.userId),
    );
  }

  /// 서브 페이지 공통 헤더([WebPageHeader]) — 다만 **타이틀은 비운다**(사용자 확정).
  /// 바로 아래 사진·글이 이어져서 제목이 없어도 무엇을 보는 화면인지 분명하다.
  ///
  /// ⚠️ Obx로 감싸지 않는다 — 관찰할 Rx가 없으면 "improper use of a GetX" 오류가
  /// 난다(예전엔 타이틀이 '댓글 N'이라 Obx가 필요했다).
  Widget _buildHeader() {
    return WebPageHeader(
      title: '',
      onBack: () => Get.key.currentState?.canPop() == true
          ? Get.back()
          : Get.offNamed(WebRoutes.liveTalk),
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
            // 입력 바 66 = 여백 10 + 입력창 46 (상세 오버레이와 같은 규격).
            padding: const EdgeInsets.all(10),
            child: Obx(
              () => WebCommentInput(
                controller: _commentController,
                hintText: target == null ? '댓글을 남겨주세요' : '답글을 남겨주세요',
                isSubmitting: _vm.isSubmitting,
                onSubmit: _vm.isGuest ? null : (_) => _submit(),
                onGuestTap: () => Get.snackbar('알림', '로그인이 필요합니다.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
