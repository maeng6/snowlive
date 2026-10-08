import 'dart:math' as math;

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_comment_list_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_detail_body_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkDetail_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalk_web.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart' show showWebEditTextDialog;
import 'package:com.snowlive/web/widget/w_web_comment_input_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:com.snowlive/web/widget/w_web_image_viewer_web.dart'
    show kWebImageViewerBackdropColor;
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
    // 딤·닫기 버튼 자리 모두 공용 이미지 뷰어와 동일하게 맞춘다(사용자 확정).
    barrierColor: kWebImageViewerBackdropColor,
    padding: const EdgeInsets.symmetric(
      horizontal: _kModalPaddingH,
      vertical: _kModalPaddingV,
    ),
    builder: (ctx, close) => _LiveTalkDetailCard(vm: vm, onClose: close),
  );
  return changed ?? false;
}

/// 모달 바깥 여백 — 공용 이미지 뷰어와 같은 값. 닫기 ✕도 이 안쪽 상단에 붙으므로
/// **✕의 윗선 = 상단 여백**이다.
const double _kModalPaddingH = 24;
const double _kModalPaddingV = 16;

/// 데스크탑 우측 댓글 패널 폭(피그마 80:219869 — 카드 1257 = 사진 821 + 패널 436).
const double _kPanelWidth = 436;

/// 태블릿 카드 폭 — **화면 폭 비례**(피그마 80:228894는 800에서 480이지만
/// 사용자 요청으로 더 넓게). 768에서 614, 800에서 640, 1023에서 818이 된다.
///
/// 이 비율이 쓰이는 구간은 768~1023뿐이다 — 태블릿 가로모드는 대부분 1024를
/// 넘겨 PC 2열 레이아웃으로 빠진다(iPad 가로 1180 등).
const double _kTabletCardWidthRatio = 0.8;

/// 태블릿 카드 상하 여백(사용자 확정). 닫기 ✕(모달 여백 16 안쪽)보다 살짝 아래에서
/// 시작하지만 ✕는 카드 오른쪽 바깥이라 겹치지 않는다.
const double _kTabletCardMarginV = 24;

/// 태블릿 사진 칸이 카드 높이에서 차지할 수 있는 상한. 화면이 낮을 때 정사각을
/// 포기하는 기준이다 — 사진이 카드를 다 먹으면 댓글 볼 자리가 없다.
const double _kTabletImageShare = 0.65;

/// 마지막 댓글 아래 여백(사용자 확정 — 16에서 10 줄임).
const double _kCommentsBottomGap = 6;

/// 패널 좌우·상단 여백. PC 24 / 태블릿 20 (각 목업 실측).
double _panelPadding(bool isDesktop) => isDesktop ? 24 : 20;

/// 카드 사방 여백 — **화면 크기에 비례**한다(각 축의 길이 × 이 비율).
/// 고정 px로 두면 큰 모니터에서 카드가 과하게 커지고 작은 화면에선 여백이 아깝다.
/// 기준은 1080 높이에서 40px(사용자 확정 — 인스타그램식).
/// ⚠️ 좌우 여백은 이 값이 아니라 **결과**다 — 사진 칸이 정사각이라 카드 폭이
/// 높이를 따라가므로, 상하 여백을 키우면 좌우 빈 공간도 함께 커진다.
const double _kOverlayMarginRatio = 40 / 1080;

/// 사진 칸 높이의 하한. 여기까지 줄면 여백을 포기하고 크기를 유지한다.
const double _kMinImageSide = 320;

/// 사진 없는 글(패널만)의 높이 상한.
const double _kTextOnlyMaxHeight = 640;

/// 댓글 입력 바 높이 66 = 여백 10 + 입력창 46 (피그마 80:221670).
const double _kInputBarHeight = 66;

/// 답글 대상 표시 줄이 떠 있을 때 늘어나는 높이.
const double _kReplyTargetBarHeight = 40;

/// 입력 바 위 투명→흰색 페이드 높이 — 댓글이 바 아래로 녹아 사라진다.
const double _kInputFadeHeight = 32;

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
    if (mounted)
      setState(() {
        _replyTarget = null;
        _changed = true;
      });
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

    // 닫기 ✕는 **뷰포트 기준 우상단**(공용 이미지 뷰어와 동일). 그래서 카드만
    // 반환하지 않고 딤 영역을 채우는 Stack을 만든다.
    return Stack(
      children: [
        // 모달이 builder 결과를 GestureDetector로 감싸 배경 탭을 막으므로,
        // 딤 탭으로 닫는 동작을 여기서 직접 준다(자식이 제스처를 먼저 가져간다).
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
            child: const SizedBox.expand(),
          ),
        ),
        Center(
          // 카드 안쪽 빈 곳을 눌러도 닫히지 않게 막는다.
          child: GestureDetector(
            onTap: () {},
            child: Material(
              // Overlay 직삽이라 Material 조상이 없다 → 카드 표면을 Material로.
              color: SDSColor.snowliveWhite,
              borderRadius: BorderRadius.circular(4),
              clipBehavior: Clip.antiAlias,
              child: Obx(() {
                if (_vm.isLoading && _vm.detail == null) {
                  return const SizedBox(
                    width: 320,
                    height: 320,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final detail = _vm.detail;
                if (detail == null) {
                  return SizedBox(
                    width: 320,
                    height: 240,
                    child: Center(
                      child: Text(
                        '글을 불러오지 못했어요',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 14,
                          color: SDSColor.gray500,
                        ),
                      ),
                    ),
                  );
                }
                return isDesktop ? _buildDesktop(detail) : _buildTablet(detail);
              }),
            ),
          ),
        ),
        // 상단 바 48 안에서 우측 정렬 — 이미지 뷰어의 ✕와 같은 규격·자리.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 48,
            child: Align(
              alignment: Alignment.centerRight,
              child: WebIconButton(
                icon: const Icon(
                  Icons.close,
                  size: 28,
                  color: SDSColor.snowliveWhite,
                ),
                onTap: _close,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 데스크탑: 좌 **정사각 사진** / 우 댓글 패널 436 (피그마 80:219869).
  ///
  /// 카드 크기는 사진 한 변이 정한다. 세로를 먼저 채우고(여백은 화면 비례 —
  /// [_kOverlayMarginRatio]), 창이 좁아져 좌우 여백에 닿으면 그때부터 폭에 맞춰
  /// 함께 줄어든다. 기준은 모달 패딩 안쪽 제약이 아니라 **뷰포트**다 — 그래야
  /// 여백이 의도대로 나온다.
  ///
  /// 사진이 정사각이 아니면 남는 자리는 검정으로 둔다(전체화면 뷰어와 동일).
  /// 칸을 사진 비율에 맞추는 인스타식도 해봤지만, 서버가 이미지 크기를 안 줘서
  /// 로드된 뒤 카드가 한 번 바뀌는 게 어색해 되돌렸다(2026-09-26).
  Widget _buildDesktop(LiveTalk detail) {
    final hasImage = detail.imageUrl != null && detail.imageUrl!.isNotEmpty;
    final viewport = MediaQuery.sizeOf(context);
    final marginV = viewport.height * _kOverlayMarginRatio;
    final marginH = viewport.width * _kOverlayMarginRatio;
    // ⚠️ 정수로 내림한다. 비율 계산은 740.74 같은 소수를 내놓는데, 그러면 검정
    // 사진 칸 가장자리가 반 픽셀에 걸려 아래 흰 카드가 실선처럼 비친다(실측).
    final side = math
        .max(
          _kMinImageSide,
          math.min(
            viewport.height - marginV * 2,
            viewport.width - marginH * 2 - _kPanelWidth,
          ),
        )
        .floorToDouble();

    if (!hasImage) {
      // 사진이 없으면 패널만. 사진 기준 높이를 그대로 쓰면 436폭에 900 높이처럼
      // 지나치게 길쭉해져서 상한을 둔다(입력창은 그 바닥에 고정).
      return SizedBox(
        width: _kPanelWidth,
        height: math.min(side, _kTextOnlyMaxHeight),
        child: _buildPanel(detail, fillHeight: true),
      );
    }
    return SizedBox(
      width: side + _kPanelWidth,
      height: side,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: side,
            child: LiveTalkImagePane(url: detail.imageUrl),
          ),
          SizedBox(
            width: _kPanelWidth,
            child: _buildPanel(detail, fillHeight: true),
          ),
        ],
      ),
    );
  }

  /// 태블릿: 사진 위 · 글 · 댓글 아래 1열 (피그마 80:228894 — 카드 480,
  /// 사진은 카드 폭과 같은 **정사각**).
  ///
  /// 높이는 **내용만큼**이되 상하 여백 [_kTabletCardMarginV]를 남기는 선이 상한이다
  /// — 댓글이 적으면 카드가 그만큼 짧아지고, 길어지면 상한까지 커진 뒤 그 안에서
  /// 스크롤한다(사용자 확정). 입력창은 늘 카드 바닥에 온다.
  Widget _buildTablet(LiveTalk detail) {
    final hasImage = detail.imageUrl != null && detail.imageUrl!.isNotEmpty;
    final viewport = MediaQuery.sizeOf(context);
    // ⚠️ 정수로 내림 — 소수 크기는 가장자리에 흰 실선을 남긴다(PC와 같은 이유).
    final cardHeight = (viewport.height - _kTabletCardMarginV * 2)
        .floorToDouble();
    // 폭도 화면 비례. 모달 바깥 여백은 최소한 남긴다.
    final cardWidth = math
        .min(
          viewport.width * _kTabletCardWidthRatio,
          viewport.width - _kModalPaddingH * 2,
        )
        .floorToDouble();
    // 사진 칸은 **정사각 고정**(PC와 같은 방식). 사진은 contain이라 잘리지 않고,
    // 세로가 길면 위아래가 꽉 차고 가로가 길면 좌우가 꽉 찬다 — 남는 자리는 블러.
    // 화면이 낮을 때만 정사각을 포기하고 카드 높이의 일부로 제한한다.
    final imageHeight = math.min(cardWidth, cardHeight * _kTabletImageShare);

    return SizedBox(
      width: cardWidth,
      // 높이는 고정이 아니라 **상한**이다 — Column(min)이 내용만큼만 차지하고,
      // 넘칠 때만 Flexible이 패널을 줄여 그 안에서 스크롤하게 만든다.
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: cardHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasImage)
              SizedBox(
                height: imageHeight,
                child: LiveTalkImagePane(url: detail.imageUrl),
              ),
            Flexible(child: _buildPanel(detail, fillHeight: false)),
          ],
        ),
      ),
    );
  }

  /// 패널은 [글 헤더 · 구분선 · 댓글 · 입력창] 4단이다. 입력창은 항상 바닥,
  /// 스크롤 범위는 폭에 따라 다르다:
  ///  - **데스크탑**: 사진이 옆에 있어 글 헤더를 고정하고 댓글만 스크롤한다.
  ///  - **태블릿**: 사진만 위에 고정하고 **글 헤더까지 함께 스크롤**한다
  ///    (1열이라 헤더까지 고정하면 정작 댓글 볼 자리가 거의 없다 — 사용자 확정).
  ///
  /// [fillHeight]면 주어진 높이를 꽉 채우고 입력창을 **플로팅**으로 바닥에 띄운다
  /// — 댓글이 그 뒤로 지나가며 페이드로 사라진다.
  Widget _buildPanel(LiveTalk detail, {required bool fillHeight}) {
    final isDesktop = context.isDesktop;
    // 마지막 댓글 아래 여백. 플로팅일 때는 댓글이 입력 바 뒤까지 이어지도록
    // 바 높이를 더한다.
    final double bottomInset = fillHeight
        ? _inputBarHeight + _kCommentsBottomGap
        : _kCommentsBottomGap;
    // 구분선 ↔ '댓글 N' 20, 좌우 PC 24 / 태블릿 20 (피그마 80:220284).
    final pad = _panelPadding(isDesktop);
    final listPadding = EdgeInsets.fromLTRB(pad, 20, pad, bottomInset);
    final header = Text(
      '댓글 ${_vm.commentCount}',
      style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
    );
    final commentList = LiveTalkCommentListWeb(
      vm: _vm,
      postUserId: detail.userId,
      onReplyTap: (comment) => setState(() => _replyTarget = comment),
    );

    // 글 헤더 + 구분선. 데스크탑은 패널 위에 고정, 태블릿은 스크롤 안으로 들어간다.
    final postBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LiveTalkPostHeader(
          detail: detail,
          padding: _panelPadding(context.isDesktop),
          isAuthor: _vm.isAuthor,
          onMoreAction: _onPostMoreAction,
          onToggleLike: _toggleLike,
        ),
        // 구분선은 패널 전체 폭(피그마 80:220283 — 좌우 패딩 밖).
        Container(height: 1, color: SDSColor.gray100),
      ],
    );

    // 댓글이 없고 칸 높이가 정해진 데스크탑에서는 빈 상태를 **남은 영역 중앙**에
    // 놓는다. 스크롤뷰 안에서는 세로 중앙을 잡을 수 없어 분기한다.
    if (isDesktop && fillHeight && _vm.comments.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          postBlock,
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: listPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        header,
                        const Expanded(
                          child: LiveTalkCommentsEmpty(fillHeight: true),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildInputArea(floating: true),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final commentsBlock = Padding(
      padding: listPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          // '댓글 N' ↔ 목록 16.
          const SizedBox(height: SDSSpacing.md),
          commentList,
        ],
      ),
    );

    final scroll = SingleChildScrollView(
      child: isDesktop
          ? commentsBlock
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [postBlock, commentsBlock],
            ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (isDesktop) postBlock,
        if (fillHeight)
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: scroll),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildInputArea(floating: true),
                ),
              ],
            ),
          )
        else ...[
          Flexible(child: scroll),
          _buildInputArea(floating: false),
        ],
      ],
    );
  }

  /// 답글 대상 바가 떠 있으면 그만큼 입력 바가 높아진다 —
  /// 댓글 스크롤의 하단 여백도 같이 늘려야 마지막 댓글이 가려지지 않는다.
  double get _inputBarHeight =>
      _kInputBarHeight + (_replyTarget != null ? _kReplyTargetBarHeight : 0);

  /// 댓글 입력 바. [floating]이면 댓글 위에 떠서 바닥에 붙는다 — 경계선 대신
  /// 투명→흰색 페이드를 위에 얹어 댓글이 바 아래로 녹아 사라지게 한다
  /// (목록 하단바와 같은 방식). 아니면 기존처럼 위에 구분선을 둔다.
  Widget _buildInputArea({required bool floating}) {
    final target = _replyTarget;
    final bar = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (target != null)
          WebReplyTargetBar(
            targetName: target.userInfo?.displayName ?? '',
            onCancel: () => setState(() => _replyTarget = null),
          ),
        Padding(
          // 입력 바 66 = 여백 10 + 입력창 46 (피그마 80:221670).
          padding: const EdgeInsets.all(10),
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
    );

    if (!floating) {
      return Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: SDSColor.gray100)),
        ),
        child: bar,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 페이드는 클릭을 통과시킨다 — 뒤 댓글을 가려 누르지 못하면 안 된다.
        IgnorePointer(
          child: Container(
            height: _kInputFadeHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  SDSColor.snowliveWhite.withValues(alpha: 0),
                  SDSColor.snowliveWhite,
                ],
              ),
            ),
          ),
        ),
        ColoredBox(color: SDSColor.snowliveWhite, child: bar),
      ],
    );
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
        // 상세는 updatePost가 재조회한다. 목록도 반영되게 그 글만 다시 받는다.
        _changed = true;
        if (_vm.livetalkId != null &&
            Get.isRegistered<LiveTalkListPaginationViewModelWeb>()) {
          await Get.find<LiveTalkListPaginationViewModelWeb>().reloadItem(_vm.livetalkId!);
        }
        if (mounted) setState(() {});
      },
      onDelete: () async {
        final deletedId = _vm.livetalkId;
        final ok = await _vm.deletePost();
        if (ok) {
          // 지워진 글은 reloadItem으로 못 지우므로 목록에서 직접 뺀다.
          if (deletedId != null &&
              Get.isRegistered<LiveTalkListPaginationViewModelWeb>()) {
            Get.find<LiveTalkListPaginationViewModelWeb>().removeItem(deletedId);
          }
          _changed = true;
          _close();
        }
        return ok;
      },
      onReport: _vm.reportPost,
      onHideUser: () => _vm.blockAuthor(_vm.detail?.userId),
    );
  }
}
