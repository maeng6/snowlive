import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_communityDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/community/v_communityHome_web.dart' show kCommunityContentMaxWidth;
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/view/community/w_community_body_web.dart';
import 'package:com.snowlive/web/widget/w_web_comment_input_web.dart';
import 'package:com.snowlive/web/view/community/w_community_comments_web.dart';
import 'package:com.snowlive/web/widget/w_web_image_viewer_web.dart';
import 'package:com.snowlive/web/view/community/w_community_row_web.dart'
    show CommunityCategoryChip, communityDateLabel;
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityDetail_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_tap_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// 웹 커뮤니티 게시글 상세.
///
/// 목록에서 VM을 미리 채우고 이동하는 중고거래 방식이 아니라 **URL의 id로 조회**한다.
/// 그래서 새로고침·링크 공유로 직접 들어와도 열린다.
class CommunityDetailViewWeb extends StatefulWidget {
  const CommunityDetailViewWeb({super.key});

  @override
  State<CommunityDetailViewWeb> createState() => _CommunityDetailViewWebState();
}

class _CommunityDetailViewWebState extends State<CommunityDetailViewWeb> {
  final CommunityDetailViewModelWeb _vm = Get.find<CommunityDetailViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final AuthCheckViewModelWeb _authVm = Get.find<AuthCheckViewModelWeb>();

  int? _communityId;
  Worker? _authWorker;

  /// 댓글 입력 컨트롤러는 **위젯이 소유**한다. core VM의 단일 컨트롤러를 공유하면
  /// fenix 수명 때문에 다른 글에서 쓰다 만 텍스트가 남는다.
  final TextEditingController _commentController = TextEditingController();
  final Map<int, TextEditingController> _replyControllers = {};

  int? _replyTargetCommentId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Get.parameters는 전역 가변 맵이라 build에서 읽으면 다른 라우트 값에 덮인다.
    _communityId = int.tryParse(Get.parameters['id'] ?? '');
    if (_communityId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
      // 자동로그인이 늦게 확정되면 user_id 없이 조회된 상태다 → 확정 후 다시 받는다.
      _authWorker = ever<WebAuthStatus>(_authVm.statusRx, (status) {
        if (status == WebAuthStatus.authenticated) _load();
      });
    }
  }

  @override
  void dispose() {
    // 해제하지 않으면 라우트를 왕복할 때마다 리스너가 쌓인다.
    _authWorker?.dispose();
    _commentController.dispose();
    for (final c in _replyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _replyControllerFor(int commentId) =>
      _replyControllers.putIfAbsent(commentId, TextEditingController.new);

  void _requireLogin() => Get.snackbar('알림', '로그인이 필요해요.');

  Future<void> _submitComment(String text) async {
    setState(() => _isSubmitting = true);
    final ok = await _vm.postComment(text);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (ok) _commentController.clear();
  }

  Future<void> _submitReply(int commentId, String text) async {
    setState(() => _isSubmitting = true);
    final ok = await _vm.postReply(commentId, text);
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      if (ok) _replyTargetCommentId = null;
    });
    if (ok) _replyControllerFor(commentId).clear();
  }

  void _load() {
    if (_communityId == null) return;
    _vm.load(communityId: _communityId!, userId: _userVm.user.user_id);
  }

  void _goBack() {
    // 딥링크로 바로 들어왔으면 pop할 히스토리가 없다.
    if (Navigator.of(context).canPop()) {
      Get.back();
    } else {
      Get.offAllNamed(WebRoutes.community);
    }
  }

  void _copyLink() {
    final id = _communityId;
    if (id == null) return;
    // 웹은 해시 URL 전략이라 '#'을 포함해야 같은 화면으로 다시 들어온다.
    final url = '${Uri.base.removeFragment()}#${WebRoutes.communityDetail}?id=$id';
    Clipboard.setData(ClipboardData(text: url));
    Get.snackbar('링크 복사 완료', '게시글 주소가 복사되었어요.');
  }

  Future<void> _onPostMoreAction(WebMoreAction action) async {
    // 게스트는 신고/차단이 안 된다(API가 user_id 필수). 실패 안내 대신 로그인을 유도한다.
    if (!_vm.isLoggedIn) {
      _requireLogin();
      return;
    }
    final detail = _vm.detail;
    await handleWebMoreAction(
      context,
      action: action,
      onDelete: () async {
        final ok = await _vm.deletePost();
        // 삭제되면 더 이상 볼 글이 없으니 목록으로 돌아간다.
        if (ok) Get.offAllNamed(WebRoutes.community);
        return ok;
      },
      onReport: _vm.reportPost,
      onHideUser: detail?.userId == null ? null : () => _vm.blockUser(detail!.userId!),
    );
  }

  void _openImageViewer(List<String> urls, int index) {
    showWebImageViewer(
      context: context,
      title: _vm.detail?.title ?? '',
      imageUrls: urls,
      initialIndex: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isMobile = context.screenType == WebScreenType.mobile;

    final scrollArea = Container(
      color: SDSColor.snowliveWhite,
      padding: EdgeInsets.fromLTRB(
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        32,
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        SDSSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kCommunityContentMaxWidth),
            child: Obx(_buildContent),
          ),
        ),
      ),
    );

    if (!isMobile) return scrollArea;

    // 모바일만 입력창이 화면 하단에 고정된다. 셸이 페이지를 Expanded에 넣으므로
    // Stack의 bottom이 곧 뷰포트 하단이다. 콘텐츠가 가려지지 않도록 바깥 Padding으로
    // 스크롤 영역 자체를 줄인다(스크롤뷰 내부 padding이면 트랙이 바 뒤로 지나간다).
    // 바 높이는 _replyTargetCommentId(State 필드)만 따라가므로 setState로 충분하다.
    // 여기를 Obx로 감싸면 안 된다 — 답글 대상이 없을 때 빌더가 관찰 대상을 하나도
    // 읽지 않아 GetX가 "improper use of a GetX" 예외를 던지고 화면이 통째로 죽는다.
    final barHeight = _replyTargetCommentId != null ? 116.0 : 76.0;
    return Stack(
      children: [
        Padding(padding: EdgeInsets.only(bottom: barHeight), child: scrollArea),
        Positioned(left: 0, right: 0, bottom: 0, child: _buildMobileInputBar()),
      ],
    );
  }

  Widget _buildMobileInputBar() {
    return Obx(() {
      final target = _replyTargetCommentId;
      // 답글 대상 이름은 목록이 나중에 도착해도 갱신돼야 한다 → Obx를 유지한다.
      // 단 **조건 없이 한 번은 관찰 대상을 읽어야** 한다. 삼항 뒤에서만 읽으면
      // target이 null일 때 아무것도 관찰하지 않아 GetX가 예외를 던진다.
      // `_vm.comments`는 RxList 객체 자체를 돌려줘서 그냥 참조만 하면 등록되지
      // 않는다 — length처럼 값을 읽는 멤버를 건드려야 구독이 걸린다.
      final commentCount = _vm.comments.length;
      final targetName = target == null || commentCount == 0
          ? null
          : _vm.comments
              .firstWhereOrNull((c) => c.commentId == target)
              ?.userInfo
              ?.displayName;

      return _mobileInputBarShell(target: target, targetName: targetName);
    });
  }

  Widget _mobileInputBarShell({required int? target, required String? targetName}) {
    return Container(
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        border: Border(top: BorderSide(color: SDSColor.gray100)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (target != null && targetName != null)
            WebReplyTargetBar(
              targetName: targetName,
              onCancel: () => setState(() => _replyTargetCommentId = null),
            ),
          Padding(
            padding: const EdgeInsets.all(SDSSpacing.md),
            child: WebCommentInput(
              controller: target == null ? _commentController : _replyControllerFor(target),
              hintText: target == null ? '댓글을 남겨주세요' : '답글을 남겨주세요',
              isSubmitting: _isSubmitting,
              onSubmit: _vm.isLoggedIn
                  ? (text) => target == null ? _submitComment(text) : _submitReply(target, text)
                  : null,
              onGuestTap: _requireLogin,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_communityId == null) {
      return WebEmptyState(
        message: '게시글을 찾을 수 없어요.',
        actionLabel: '커뮤니티 목록으로',
        onAction: () => Get.offAllNamed(WebRoutes.community),
      );
    }
    if (_vm.hasError) return WebErrorState(onRetry: _vm.retry);

    final detail = _vm.detail;
    if (detail == null) {
      // 첫 로딩. 전역 상단 진행바가 이미 돌고 있어 여백만 잡아둔다.
      return const SizedBox(height: 320);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopActions(),
        const SizedBox(height: SDSSpacing.md),
        _buildHeader(detail),
        const SizedBox(height: SDSSpacing.md),
        _buildAuthorCard(detail),
        Divider(color: SDSColor.gray50, height: 32, thickness: 1),
        CommunityBodyWeb(document: detail.description, onImageTap: _openImageViewer),
        const SizedBox(height: SDSSpacing.xl),
        Container(height: 8, color: SDSColor.gray50),
        const SizedBox(height: SDSSpacing.lg),
        _buildCommentsSection(detail),
        const SizedBox(height: SDSSpacing.xl),
      ],
    );
  }

  Widget _buildCommentsSection(CommunityDetailModel detail) {
    final isMobile = context.screenType == WebScreenType.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '댓글 ${detail.commentCount ?? 0}',
          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
        ),
        const SizedBox(height: SDSSpacing.md),
        // 모바일은 입력창이 화면 하단에 고정이라 여기 두지 않는다.
        if (!isMobile) ...[
          WebCommentInput(
            controller: _commentController,
            hintText: '댓글을 남겨주세요',
            isSubmitting: _isSubmitting,
            onSubmit: _vm.isLoggedIn ? _submitComment : null,
            onGuestTap: _requireLogin,
          ),
          const SizedBox(height: SDSSpacing.lg),
        ],
        CommunityCommentsWeb(
          vm: _vm,
          postAuthorId: detail.userId,
          myUserId: _userVm.user.user_id,
          replyTargetCommentId: _replyTargetCommentId,
          onReplyTargetChanged: (id) => setState(() => _replyTargetCommentId = id),
          // 태블릿·데스크탑은 스레드 아래에 인라인 답글 입력창이 열린다.
          inlineReplyInputBuilder: isMobile
              ? null
              : (commentId) => WebCommentInput(
                    controller: _replyControllerFor(commentId),
                    hintText: '답글을 남겨주세요',
                    isSubmitting: _isSubmitting,
                    onSubmit: _vm.isLoggedIn
                        ? (text) => _submitReply(commentId, text)
                        : null,
                    onGuestTap: _requireLogin,
                  ),
        ),
      ],
    );
  }

  Widget _buildTopActions() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: _goBack,
        icon: Icon(Icons.arrow_back, color: SDSColor.gray900),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  /// 제목 줄 우측 액션. 커뮤니티는 **공유 + 더보기 두 개뿐**이다(북마크 없음).
  Widget _buildTitleActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _copyLink,
          icon: SvgPicture.asset(
            'assets/imgs/icons/icon_header_share_web.svg',
            width: 22,
            height: 22,
          ),
          tooltip: '링크 복사',
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 4),
        WebMoreButton(
          iconSize: 22,
          // 내 글이면 삭제, 남의 글이면 신고/숨기기 (중고거래와 동일한 구성)
          actions: _vm.isAuthor
              ? const [WebMoreAction.delete]
              : const [WebMoreAction.reportPost, WebMoreAction.hideUser],
          onSelected: _onPostMoreAction,
        ),
      ],
    );
  }

  Widget _buildHeader(CommunityDetailModel detail) {
    final sub = detail.categorySub;
    final metaStyle = SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sub != null && sub.isNotEmpty)
          CommunityCategoryChip(
            label: sub,
            background: SDSColor.blue50,
            textColor: SDSColor.snowliveBlue,
          ),
        const SizedBox(height: 10),
        // 목업대로 제목과 같은 줄 오른쪽 끝에 공유·더보기를 둔다.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                detail.title ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: SDSTextStyle.bold.copyWith(fontSize: 18, color: SDSColor.gray900),
              ),
            ),
            const SizedBox(width: SDSSpacing.md),
            _buildTitleActions(),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(detail.userInfo?.displayName ?? '', style: metaStyle),
            _metaDivider(),
            Text(communityDateLabel(detail.uploadTime), style: metaStyle),
            _metaDivider(),
            Image.asset('assets/imgs/icons/icon_eye_rounded.png', width: 14, height: 14),
            const SizedBox(width: 2),
            Text('${detail.viewsCount ?? 0}', style: metaStyle),
            const SizedBox(width: 6),
            Image.asset('assets/imgs/icons/icon_reply_rounded.png', width: 14, height: 14),
            const SizedBox(width: 2),
            Text('${detail.commentCount ?? 0}', style: metaStyle),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthorCard(CommunityDetailModel detail) {
    final info = detail.userInfo;
    final photo = info?.profileImageUrlUser;
    final subtitle = [
      if (info?.resortNickname?.isNotEmpty ?? false) info!.resortNickname,
      if (info?.crewName?.isNotEmpty ?? false) info!.crewName,
    ].join(' · ');

    return Row(
      children: [
        WebProfileTap(
          userId: detail.userId,
          name: info?.displayName,
          avatarUrl: photo,
          child: ClipOval(
            child: (photo != null && photo.isNotEmpty)
                ? WebNetworkImage(url: photo, width: 32, height: 32)
                : Container(
                    width: 32,
                    height: 32,
                    color: SDSColor.gray100,
                    child: Icon(Icons.person, size: 18, color: SDSColor.gray400),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              info?.displayName ?? '',
              style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray900),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
              ),
          ],
        ),
      ],
    );
  }

  Widget _metaDivider() => Text(
        '  |  ',
        style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray300),
      );
}
