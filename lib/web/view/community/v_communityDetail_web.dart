import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_communityDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityListPagination_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/view/community/w_community_body_web.dart';
import 'package:com.snowlive/web/widget/w_web_comment_input_web.dart';
import 'package:com.snowlive/web/view/community/w_community_comments_web.dart';
import 'package:com.snowlive/web/widget/w_web_image_viewer_web.dart';
import 'package:com.snowlive/web/view/community/w_community_row_web.dart'
    show communityDateLabel;
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityDetail_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_tap_web.dart';
import 'package:com.snowlive/web/widget/w_web_back_icon_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
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
  final CommunityDetailViewModelWeb _vm =
      Get.find<CommunityDetailViewModelWeb>();
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
    final url =
        '${Uri.base.removeFragment()}#${WebRoutes.communityDetail}?id=$id';
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
      onHideUser: detail?.userId == null
          ? null
          : () => _vm.blockUser(detail!.userId!),
      onEdit: _openEdit,
    );
  }

  /// 수정 화면(올리기와 같은 폼)으로 갔다가 돌아오면 고친 내용으로 다시 받는다.
  Future<void> _openEdit() async {
    final id = _communityId;
    if (id == null) return;
    await Get.toNamed('${WebRoutes.communityUpdate}?id=$id');
    if (!mounted) return;
    await _vm.refresh();
    // 제목·게시판 종류가 바뀌었을 수 있다 → 목록은 지금 페이지·필터 그대로 다시 받는다.
    if (Get.isRegistered<CommunityListPaginationViewModelWeb>()) {
      final list = Get.find<CommunityListPaginationViewModelWeb>();
      await list.gotoPage(list.currentPage);
    }
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
      child: SingleChildScrollView(
        // 여백은 스크롤 영역 **안쪽**(웹 공통 규칙) — 바깥에 두면 스크롤바가
        // 브라우저 우측 끝이 아니라 콘텐츠 안쪽에 뜬다.
        padding: webSubPagePadding(context),
        child: Center(
          child: ConstrainedBox(
            // PC만 800 고정 중앙(피그마 64:127458) — 태블릿·모바일은 제한 없이
            // 화면(패딩 제외)을 가득 채운다(중고거래 상세와 동일 규칙).
            constraints: BoxConstraints(
              maxWidth: isDesktop
                  ? kWebSubPageMaxWidth
                  : double.infinity,
            ),
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
    // 바 66(패딩 10 + 입력 46 + 10, 피그마 64:138416), 답글 모드는 스트립 40 추가.
    final barHeight = _replyTargetCommentId != null ? 106.0 : 66.0;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: barHeight),
          child: scrollArea,
        ),
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

  Widget _mobileInputBarShell({
    required int? target,
    required String? targetName,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        // 답글 모드에서는 상단 라인이 대상 스트립 쪽에 있으므로 여기선 뺀다.
        border: (target != null && targetName != null)
            ? null
            : Border(top: BorderSide(color: SDSColor.gray100)),
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
            // 피그마 64:138416 — 바 66 = 패딩 10 + 입력 46 + 10.
            padding: const EdgeInsets.all(10),
            child: WebCommentInput(
              controller: target == null
                  ? _commentController
                  : _replyControllerFor(target),
              hintText: target == null ? '댓글을 남겨주세요' : '답글을 남겨주세요',
              isSubmitting: _isSubmitting,
              onSubmit: _vm.isLoggedIn
                  ? (text) => target == null
                        ? _submitComment(text)
                        : _submitReply(target, text)
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
        // 뒤로가기 ↔ 헤더 31 (피그마 64:127458).
        const SizedBox(height: 20),
        _buildHeader(detail),
        // 메타 ↔ 프로필 24 (피그마 64:127458).
        const SizedBox(height: 24),
        _buildAuthorCard(detail),
        // 프로필 ↔ 구분선 ↔ 본문: PC·태블릿 30 (피그마 64:127458) / 모바일 24
        SizedBox(
          height: context.screenType == WebScreenType.mobile ? 24 : 30,
        ),
        Container(height: 1, color: SDSColor.gray100),
        SizedBox(
          height: context.screenType == WebScreenType.mobile ? 24 : 30,
        ),
        CommunityBodyWeb(
          document: detail.description,
          onImageTap: _openImageViewer,
        ),
        // 본문 ↔ 댓글 48 (피그마 64:127458 — 회색 띠 없음).
        const SizedBox(height: 48),
        _buildCommentsSection(detail),
        // 댓글 영역 하단: PC·태블릿 32 / 모바일 0 (하단 고정 입력바가 여백 역할).
        if (context.screenType != WebScreenType.mobile)
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
          // bold 16 — 중고거래 댓글 헤더와 통일(목업 64:127630의 18 대신, 사용자 결정).
          style: SDSTextStyle.bold.copyWith(
            fontSize: 16,
            color: SDSColor.gray900,
          ),
        ),
        // PC·태블릿: 헤더 ↔ 입력창 12 (피그마 64:127628).
        // 모바일: 입력창이 하단 고정이라 헤더 ↔ 목록 30 (피그마 64:136666).
        SizedBox(height: isMobile ? 30 : 12),
        // 모바일은 입력창이 화면 하단에 고정이라 여기 두지 않는다.
        if (!isMobile) ...[
          WebCommentInput(
            controller: _commentController,
            hintText: '댓글을 남겨주세요',
            isSubmitting: _isSubmitting,
            onSubmit: _vm.isLoggedIn ? _submitComment : null,
            onGuestTap: _requireLogin,
          ),
          // 입력창 ↔ 목록 30 (피그마 64:127458).
          const SizedBox(height: 30),
        ],
        CommunityCommentsWeb(
          vm: _vm,
          postAuthorId: detail.userId,
          myUserId: _userVm.user.user_id,
          replyTargetCommentId: _replyTargetCommentId,
          onReplyTargetChanged: (id) =>
              setState(() => _replyTargetCommentId = id),
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
    final isMobile = context.screenType == WebScreenType.mobile;
    final back = IconButton(
      onPressed: _goBack,
      icon: const WebBackIcon(),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
    // 모바일은 공유·⋯가 제목 줄이 아니라 뒤로가기 줄 우측에 온다(피그마 64:138413).
    if (isMobile) {
      return Row(
        children: [back, const Spacer(), _buildTitleActions()],
      );
    }
    return Align(alignment: Alignment.centerLeft, child: back);
  }

  /// 제목 줄 우측 액션. 커뮤니티는 **공유 + 더보기 두 개뿐**이다(북마크 없음).
  Widget _buildTitleActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 웹 공통 아이콘 hover(60% 페이드) — 옆의 ⋯ 버튼과 동일. Material
        // IconButton의 원형 hover 배경을 쓰지 않는다.
        // 피그마 64:127537 — 아이콘 26, 사이 간격 16. 클릭 영역 28(패딩 1).
        WebIconButton(
          onTap: _copyLink,
          tooltip: '링크 복사',
          padding: const EdgeInsets.all(1),
          icon: SvgPicture.asset(
            'assets/imgs/icons/icon_header_share_web.svg',
            width: 26,
            height: 26,
          ),
        ),
        const SizedBox(width: 16),
        WebMoreButton(
          iconSize: 26,
          // 클릭 영역 28(아이콘 26 + 패딩 1).
          hitPadding: 1,
          // 내 글이면 수정·삭제(앱과 같은 순서), 남의 글이면 신고/숨기기
          actions: _vm.isAuthor
              ? const [WebMoreAction.edit, WebMoreAction.delete]
              : const [WebMoreAction.reportPost, WebMoreAction.hideUser],
          onSelected: _onPostMoreAction,
        ),
      ],
    );
  }

  Widget _buildHeader(CommunityDetailModel detail) {
    final sub = detail.categorySub;
    // 메타: regular 13 gray500 (중고거래·목록과 색 통일).
    final metaStyle = SDSTextStyle.regular.copyWith(
      fontSize: 13,
      color: SDSColor.gray500,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sub != null && sub.isNotEmpty) ...[
          // 상세 전용 배지 — 목록 칩(regular 11/r2)과 달리 bold 12·패딩 5/4·r4
          // (피그마 64:127533).
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            decoration: BoxDecoration(
              color: SDSColor.blue50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              sub,
              style: SDSTextStyle.bold.copyWith(
                fontSize: 12,
                color: SDSColor.snowliveBlue,
              ),
            ),
          ),
          // 배지 ↔ 제목 4 (피그마 64:127532).
          const SizedBox(height: 4),
        ],
        // 목업대로 제목과 같은 줄 오른쪽 끝에 공유·더보기를 둔다
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                detail.title ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                // 피그마 64:127536 — bold 20, lh 1.4.
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 20,
                  height: 1.4,
                  color: SDSColor.gray900,
                ),
              ),
            ),
            // 모바일은 공유·⋯가 뒤로가기 줄로 올라가고 제목이 전체폭을 쓴다.
            if (context.screenType != WebScreenType.mobile) ...[
              const SizedBox(width: SDSSpacing.md),
              _buildTitleActions(),
            ],
          ],
        ),
        // 제목 ↔ 메타 4 (피그마 64:127532).
        const SizedBox(height: 4),
        Row(
          children: [
            Text(detail.userInfo?.displayName ?? '', style: metaStyle),
            _metaDivider(),
            Text(communityDateLabel(detail.uploadTime), style: metaStyle),
            _metaDivider(),
            // 채움형 아이콘(폰트 글리프) — 구멍이 살아 있어 틴트해도 디테일 유지
            // 색은 메타 텍스트와 동일(gray600)
            Icon(Icons.visibility, size: 14, color: SDSColor.gray400),
            const SizedBox(width: 2),
            Text('${detail.viewsCount ?? 0}', style: metaStyle),
            // 조회수 그룹 ↔ 댓글수 그룹 8 (피그마 64:127543).
            const SizedBox(width: 8),
            Icon(Icons.comment, size: 14, color: SDSColor.gray400),
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
          // 피그마 64:127550 — 아바타 40, 텍스트와 간격 12.
          child: ClipOval(
            child: (photo != null && photo.isNotEmpty)
                ? WebNetworkImage(url: photo, width: 40, height: 40)
                : Container(
                    width: 40,
                    height: 40,
                    color: SDSColor.gray100,
                    child: Icon(
                      Icons.person,
                      size: 22,
                      color: SDSColor.gray400,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 피그마 64:127566 — 이름 14 gray900, 간격 2, 소속 13 gray500.
            Text(
              info?.displayName ?? '',
              style: SDSTextStyle.regular.copyWith(
                fontSize: 14,
                color: SDSColor.gray900,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              Text(
                subtitle,
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 13,
                  color: SDSColor.gray500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// 메타 구분자 — 1×10 세로선 gray200, 좌우 간격 10 (목록과 동일 규칙)
  Widget _metaDivider() => Container(
    width: 1,
    height: 10,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: SDSColor.gray200,
  );
}
