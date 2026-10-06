import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_comment_flea.dart';
import 'package:com.snowlive/core/model/m_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketCommentDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketList.dart'
    show FleamarketStatus;
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart'
    show HomeFooterWeb;
import 'package:com.snowlive/web/widget/w_web_sticky_footer_scroll_web.dart';
import 'package:com.snowlive/web/widget/w_web_comment_input_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_body_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_comments_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_gallery_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_owner_actions_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_recommend_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_seller_row_web.dart';
import 'package:com.snowlive/web/widget/w_web_back_icon_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// 대표 이미지 한 변(피그마 46:12903).
const double kFleamarketDetailPhotoSize = 377;

/// 중고거래 웹 상세화면.
///
/// 커뮤니티 상세처럼 **URL의 id로 조회**한다(`/fleamarket-detail?id=1365`).
/// 목록 카드 탭 시에는 즉시 표시를 위해 목록 데이터를 먼저 주입하고, 진입 후 그 id로
/// API 재조회한다. 그래서 새로고침·링크 공유로 직접 들어와도(=주입 데이터가 없어도) 열린다.
class FleamarketDetailView extends StatefulWidget {
  const FleamarketDetailView({super.key});

  @override
  State<FleamarketDetailView> createState() => _FleamarketDetailViewState();
}

class _FleamarketDetailViewState extends State<FleamarketDetailView> {
  final FleamarketDetailViewModel _detailVm =
      Get.find<FleamarketDetailViewModel>();
  final FleamarketCommentDetailViewModel _commentDetailVm =
      Get.find<FleamarketCommentDetailViewModel>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final AuthCheckViewModelWeb _authVm = Get.find<AuthCheckViewModelWeb>();

  int? _fleaId;
  bool _loadingById = false;
  Worker? _authWorker;

  /// 모바일 하단 고정 댓글 바의 답글 대상(null=댓글 작성 모드).
  CommentModel_flea? _mobileReplyTarget;
  final _mobileCommentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Get.parameters는 전역 가변 맵이라 build에서 읽으면 다른 라우트 값에 덮인다.
    _fleaId = int.tryParse(Get.parameters['id'] ?? '');
    if (_fleaId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
      // 자동로그인이 늦게 확정되면 user_id 없이 조회된 상태다 → 확정 후 다시 받는다(찜 상태 등).
      _authWorker = ever<WebAuthStatus>(_authVm.statusRx, (status) {
        if (status == WebAuthStatus.authenticated) _load();
      });
    }
  }

  @override
  void dispose() {
    _authWorker?.dispose();
    _mobileCommentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_fleaId == null) return;
    if (mounted) setState(() => _loadingById = true);
    // 게스트면 user_id는 null로 나가고, 서버는 로그인 없이도 상세를 준다.
    await _detailVm.fetchFleamarketDetailFromAPI(
      fleamarketId: _fleaId!,
      userId: _userVm.user.user_id,
    );
    if (mounted) setState(() => _loadingById = false);
  }

  void _goBack() {
    // 딥링크로 바로 들어왔으면 pop할 히스토리가 없다.
    if (Navigator.of(context).canPop()) {
      Get.back();
    } else {
      Get.offAllNamed(WebRoutes.fleamarketList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isMobile = context.screenType == WebScreenType.mobile;

    return Obx(() {
      final detail = _detailVm.fleamarketDetail;
      if (detail.fleaId == null) {
        // id로 조회 중이면 스피너를, 조회할 id조차 없으면(비정상 진입) 안내를 준다.
        if (_loadingById) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return WebEmptyState(
          message: '상품 정보를 불러올 수 없어요.\n목록에서 다시 선택해주세요.',
          actionLabel: '중고거래 목록으로',
          onAction: () => Get.offAllNamed(WebRoutes.fleamarketList),
        );
      }

      final gallery = FleamarketDetailGalleryWeb(photos: detail.photos ?? []);
      final infoColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FleamarketDetailSellerRowWeb(detail: detail),
          const SizedBox(height: SDSSpacing.lg),
          FleamarketDetailBodyWeb(detail: detail),
          FleamarketDetailOwnerActionsWeb(detail: detail),
        ],
      );

      final Widget content = Container(
        color: SDSColor.snowliveWhite,
        // 콘텐츠가 짧으면 푸터가 뷰포트 하단에 붙는다(공통 골격).
        child: WebStickyFooterScroll(
          // 여백은 스크롤뷰 **안쪽** — 바깥에 두면 스크롤바가 브라우저 우측 끝이
          // 아니라 콘텐츠 안쪽에 뜬다(목록과 동일 규칙)
          // 좌우: PC 40(웹 공통) / 태블릿 20 / 모바일 16.
          // 상단: PC 32 / 태블릿 16 / 모바일 10.
          // 서브 페이지 공통 여백(이 화면이 기준값).
          padding: webSubPagePadding(context),
          content: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  // PC만 800 고정 중앙(피그마 46:12903) — 태블릿·모바일은 제한 없이
                  // 화면(패딩 제외)을 가득 채운다.
                  constraints: BoxConstraints(
                    maxWidth: isDesktop
                        ? kWebSubPageMaxWidth
                        : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          WebIconButton(
                            onTap: _goBack,
                            // 좌측 히트 여백만 0 — 아이콘이 콘텐츠 좌측선에 붙는다.
                            padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
                            // 상세 뒤로가기: PC·태블릿 30 / 모바일 24.
                            icon: WebBackIcon(size: isMobile ? 24 : 30),
                          ),
                          const Spacer(),
                          _KakaoContactButton(
                            snsUrl: detail.snsUrl,
                            status: detail.status,
                          ),
                        ],
                      ),
                      // 시안의 줄 간격 32에서 IconButton 자체 하단 여백(~12)을 뺀 값
                      // 모바일은 10 (피그마 46:9059).
                      SizedBox(height: isMobile ? 10 : 20),
                      if (!isMobile)
                        // 태블릿도 PC처럼 2열 — PC는 이미지 377 고정(확정값),
                        // 태블릿은 이미지:정보 = 1:1 반반. 간격 PC 40 / 태블릿 30
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isDesktop)
                              SizedBox(
                                width: kFleamarketDetailPhotoSize,
                                child: gallery,
                              )
                            else
                              Expanded(child: gallery),
                            SizedBox(width: isDesktop ? 40 : 30),
                            Expanded(child: infoColumn),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            gallery,
                            // 이미지 ↔ 판매자행 30 (피그마 46:9059).
                            const SizedBox(height: 30),
                            infoColumn,
                          ],
                        ),
                      // 목업에는 댓글 위 구분선(회색 밴드)이 없다.
                      // 댓글 위 간격: PC·태블릿 48, 모바일 64 (피그마 46:9059).
                      SizedBox(height: isMobile ? 64 : SDSSpacing.xxl),
                      FleamarketDetailCommentsWeb(
                        detail: detail,
                        // 모바일은 하단 고정바가 작성을 담당한다.
                        inlineInput: !isMobile,
                        onReplyTarget: isMobile
                            ? (c) => setState(() => _mobileReplyTarget = c)
                            : null,
                      ),
                      // 댓글 ↔ 추천 64 (피그마).
                      const SizedBox(height: 64),
                      FleamarketDetailRecommendWeb(
                        categoryMain: detail.categoryMain,
                        excludeFleaId: detail.fleaId,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 홈과 동일한 푸터 — 800 제한 밖, 콘텐츠 영역 폭. 간격은 최소값.
          footer: Column(
            children: [
              SizedBox(height: webFooterTopGap(context)),
              const HomeFooterWeb(),
            ],
          ),
        ),
      );

      if (!isMobile) return content;

      // 모바일은 댓글 입력이 화면 하단 고정바다(피그마 46:9059). 바를 컬럼 하단에
      // 실제 높이 그대로 앉혀서(고정 높이 상수 없음) 바 위에 빈 띠가 생기지 않는다.
      return Column(
        children: [
          Expanded(child: content),
          _buildMobileCommentBar(detail),
        ],
      );
    });
  }

  /// 모바일 하단 고정 댓글 바 — 기본은 댓글 작성, "답글 달기"를 누르면
  /// 대상 스트립("OOO님에게 답글쓰는중")과 함께 답글 모드로 바뀐다.
  Widget _buildMobileCommentBar(FleamarketDetailModel detail) {
    final target = _mobileReplyTarget;
    return Container(
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        // 답글 모드에서는 상단 라인이 대상 스트립 쪽에 있으므로 여기선 뺀다.
        border: target == null
            ? Border(top: BorderSide(color: SDSColor.gray100))
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (target != null)
            WebReplyTargetBar(
              targetName: target.userInfo?.displayName ?? '',
              onCancel: () => setState(() => _mobileReplyTarget = null),
            ),
          Padding(
            // 피그마 46:9059 — 바 안쪽 여백 10.
            padding: const EdgeInsets.all(10),
            child: Obx(() {
              final isSecret = target == null
                  ? _detailVm.isSecret
                  : _commentDetailVm.isSecret;
              return WebCommentInput(
                controller: target == null
                    ? _mobileCommentController
                    : _commentDetailVm.textEditingController,
                hintText: target == null
                    ? (isSecret ? '비밀 댓글을 남겨주세요' : '댓글을 남겨주세요')
                    : (isSecret ? '비밀 답글을 남겨주세요' : '답글을 남겨주세요'),
                onSubmit: _userVm.user.user_id == null
                    ? null
                    : (_) async => target == null
                        ? _postMobileComment(detail)
                        : _postMobileReply(detail, target),
                onGuestTap: () => Get.snackbar('알림', '로그인이 필요합니다.'),
                leading: FleamarketSecretToggle(
                  isSecret: isSecret,
                  onTap: target == null
                      ? _detailVm.changeSecret
                      : _commentDetailVm.changeSecret,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _postMobileComment(FleamarketDetailModel detail) async {
    final text = _mobileCommentController.text.trim();
    if (text.isEmpty) return;
    final userId = _userVm.user.user_id;
    if (userId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    // 서버는 문자열 `'true'`/`'false'`를 받는다(댓글 위젯과 동일).
    final isSecret = _detailVm.isSecret;
    await _detailVm.uploadFleamarketComments({
      'flea_id': detail.fleaId,
      'content': text,
      'user_id': userId,
      'secret': '$isSecret',
    });
    _mobileCommentController.clear();
    if (isSecret) _detailVm.changeSecret();
    if (mounted) setState(() {});
  }

  Future<void> _postMobileReply(
    FleamarketDetailModel detail,
    CommentModel_flea target,
  ) async {
    final text = _commentDetailVm.textEditingController.text.trim();
    if (text.isEmpty) return;
    final userId = _userVm.user.user_id;
    if (userId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    final isSecret = _commentDetailVm.isSecret;
    await _commentDetailVm.uploadFleamarketReply({
      'comment_id': target.commentId.toString(),
      'content': text,
      'user_id': userId.toString(),
      'secret': isSecret,
    });
    _commentDetailVm.textEditingController.clear();
    if (isSecret) _commentDetailVm.changeSecret();
    // 스레드·바깥 카운트를 서버 기준으로 갱신하고 답글 모드를 해제한다.
    await _detailVm.fetchFleamarketComments(
      fleaId: detail.fleaId!,
      userId: userId,
      isLoading_indi: false,
    );
    if (mounted) setState(() => _mobileReplyTarget = null);
  }
}

/// 상단 우측 "카카오톡 연락하기" 버튼(피그마 46:12903, 146×36 알약).
///
/// 판매글의 오픈채팅 URL(`sns_url`)을 새 탭으로 연다(앱과 동일 동작).
/// 앱처럼 URL이 없거나 거래완료면 아예 그리지 않는다.
class _KakaoContactButton extends StatefulWidget {
  final String? snsUrl;
  final String? status;

  const _KakaoContactButton({required this.snsUrl, required this.status});

  @override
  State<_KakaoContactButton> createState() => _KakaoContactButtonState();
}

class _KakaoContactButtonState extends State<_KakaoContactButton> {
  static const Color _kakaoYellow = Color(0xFFFEE500);

  bool _hovered = false;

  void _openSnsUrl() {
    // 입력 폼에 검증이 없어 스킴 없는 주소(`open.kakao.com/...`)가 올 수 있다 → 보정.
    var raw = widget.snsUrl!.trim();
    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      raw = 'https://$raw';
    }
    final uri = Uri.tryParse(raw);
    // http/https만 연다(javascript: 같은 스킴 차단).
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      showWebToast(context, '연락처 링크를 열 수 없어요');
      return;
    }
    // 팝업 차단을 피하려고 탭 핸들러에서 동기적으로 호출한다(await 금지).
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final hasUrl = widget.snsUrl != null && widget.snsUrl!.trim().isNotEmpty;
    if (!hasUrl || widget.status == FleamarketStatus.soldOut.korean) {
      return const SizedBox.shrink();
    }
    // 모바일은 컴팩트(높이 30, 패딩·로고·폰트 비례 축소).
    final isMobile = context.screenType == WebScreenType.mobile;
    final double height = isMobile ? 30 : 36;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _openSnsUrl,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 18),
          decoration: BoxDecoration(
            // hover 시 배경에 검정 10%를 섞어 어둡게(웹 공통 hover 규칙).
            color: _hovered
                ? Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.1),
                    _kakaoYellow,
                  )
                : _kakaoYellow,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/imgs/logos/kakao_logo.svg',
                width: isMobile ? 12 : 14,
                height: isMobile ? 12 : 14,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                '카카오톡 연락하기',
                style: SDSTextStyle.bold.copyWith(
                  fontSize: isMobile ? 12 : 13,
                  color: SDSColor.gray900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
