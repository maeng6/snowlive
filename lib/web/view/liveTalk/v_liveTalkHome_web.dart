import 'package:com.snowlive/core/api/api_liveTalk.dart';
import 'package:com.snowlive/core/api/api_user.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_card_share_flow_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_detail_overlay_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_feed_item_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_upload_flow_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalk_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_floating_bottombar_web.dart';
import 'package:com.snowlive/web/widget/w_web_sticky_sidebar_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 데스크탑 피드 열 폭(목업). SNS형 피드라 목록·상세(1136)보다 훨씬 좁다 —
/// 넓히면 사진이 과하게 커지고 한 줄 글자수가 늘어 읽기 흐름이 깨진다.
const double kLiveTalkFeedWidth = 480;

/// 데스크탑 우측 사이드바 폭. 목업은 246이지만 웹 사이드바 공통 폭 220으로 맞춘다
/// (중고거래·커뮤니티·랭킹·라이브크루와 동일 — 최대 폭이 화면마다 다르면 눈에 띈다).
const double kLiveTalkSidebarWidth = 220;

/// 피드 열과 사이드바 사이 간격(목업). 크루톡 목록도 같은 값을 쓴다.
const double kLiveTalkSidebarGap = 40;

/// 데스크탑에서 "피드 + 간격 + 사이드바"를 묶은 블록 폭. 이 블록이 GNB 오른쪽
/// 영역 가운데로 온다.
const double kLiveTalkContentMaxWidth =
    kLiveTalkFeedWidth + kLiveTalkSidebarGap + kLiveTalkSidebarWidth;

/// 웹 라이브톡 피드 화면.
class LiveTalkHomeViewWeb extends StatefulWidget {
  const LiveTalkHomeViewWeb({super.key});

  @override
  State<LiveTalkHomeViewWeb> createState() => _LiveTalkHomeViewWebState();
}

class _LiveTalkHomeViewWebState extends State<LiveTalkHomeViewWeb> {
  final LiveTalkListPaginationViewModelWeb _vm =
      Get.find<LiveTalkListPaginationViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();

  /// 바닥에서 이만큼 남았을 때 다음 페이지를 미리 받는다(스크롤이 끊기지 않게).
  static const double _loadMoreThreshold = 600;

  /// 사이드바를 제목 높이만큼 내려 피드 첫 글과 윗선을 맞추는 값
  /// (타이틀 40 + 타이틀↔첫 글 30).
  static const double _kSidebarTopOffset = 70;

  final ScrollController _scrollController = ScrollController();

  /// 다음 페이지 요청이 이번 프레임에 이미 예약됐는지. 스크롤 통지는 한 프레임에
  /// 여러 번 올 수 있어서 예약도 한 번으로 묶는다.
  bool _loadMoreScheduled = false;

  /// 첫 화면 사진을 미리 받는 중. 이 동안에는 목록 대신 스켈레톤을 유지한다
  /// ([_kWarmUpImageCount], [_kWarmUpTimeout] 참고).
  bool _warmingFirstImages = false;

  /// 첫 로딩에서 미리 받아둘 사진 수 — 첫 화면에 보이는 만큼만.
  /// 전부(30장) 기다리면 빈 화면이 너무 길어진다.
  static const int _kWarmUpImageCount = 2;

  /// 사진이 느리면 기다리지 않고 그냥 보여준다(느린 회선에서 멈춘 것처럼 보이지 않게).
  static const Duration _kWarmUpTimeout = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadFirstPage();
    });
  }

  /// 첫 로딩 — 글을 받은 뒤 **첫 화면 사진까지 준비된 다음** 목록을 드러낸다.
  /// 글만 먼저 보여주면 사진이 도착할 때 높이가 한 번 더 튀어서 어수선하다.
  Future<void> _loadFirstPage() async {
    setState(() => _warmingFirstImages = true);
    await _vm.loadFirstPage(userId: _userVm.user.user_id);
    if (!mounted) return;
    await _precacheFirstImages();
    if (mounted) setState(() => _warmingFirstImages = false);
  }

  Future<void> _precacheFirstImages() async {
    final urls = _vm.items
        .map((item) => item.imageUrl)
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .take(_kWarmUpImageCount)
        .toList();
    if (urls.isEmpty) return;
    await Future.wait(
      // 한 장이 404·CORS로 실패해도 나머지를 막지 않는다.
      urls.map((url) => precacheImage(NetworkImage(url), context).catchError((_) {})),
    ).timeout(_kWarmUpTimeout, onTimeout: () => const <void>[]);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// 무한 스크롤. 중복 호출·마지막 페이지 가드는 뷰모델의 [loadMore]가 한다.
  ///
  /// ⚠️ 여기서 바로 [loadMore]를 부르면 안 된다 — 목록이 길어지면 스크롤 통지가
  /// **레이아웃 도중**(applyContentDimensions)에 오는데, 그때 Rx를 건드리면
  /// "build 중 markNeedsBuild" 오류가 난다. 프레임이 끝난 뒤로 미룬다.
  void _onScroll() {
    if (_loadMoreScheduled || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - _loadMoreThreshold) return;

    _loadMoreScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadMoreScheduled = false;
      if (mounted) await _vm.loadMore();
    });
  }

  bool _isMine(LiveTalk item) =>
      item.userId != null && item.userId == _userVm.user.user_id;

  Future<void> _onUploadLiveTalk() async {
    final userId = _userVm.user.user_id;
    if (userId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    final done = await showLiveTalkUploadFlow(context: context, userId: userId);
    if (done) await _vm.gotoPage(1);
  }

  /// 로그인하지 않아도 열린다 — 기록이 없으면 "앱 다운로드" 안내 상태가 뜬다(목업).
  Future<void> _onShareRidingCard() async {
    final done = await showLiveTalkCardShareFlow(
      context: context,
      userId: _userVm.user.user_id,
    );
    if (done) await _vm.gotoPage(1);
  }

  /// 사진·댓글 어디를 눌러도 **같은 상세**로 간다(인스타식, 사용자 확정).
  /// 데스크탑·태블릿은 오버레이, 모바일은 게시물 상세 화면이고 확대는 그 안에서 한다.
  Future<void> _openDetail(LiveTalk item) async {
    final id = item.livetalkId;
    if (id == null) return;

    if (context.screenType == WebScreenType.mobile) {
      await Get.toNamed('${WebRoutes.liveTalkDetail}?id=$id');
      // 상세에서 쓴 댓글·좋아요가 피드에 반영되도록 그 글만 다시 받는다.
      await _vm.reloadItem(id);
      return;
    }
    final changed = await showLiveTalkDetailOverlay(
      context: context,
      livetalkId: id,
      userId: _userVm.user.user_id,
    );
    if (changed) await _vm.reloadItem(id);
  }

  Future<void> _onTapLike(LiveTalk item) async {
    final ok = await _vm.toggleLike(item);
    if (!ok) Get.snackbar('알림', '로그인이 필요합니다.');
  }

  void _onMoreAction(LiveTalk item, WebMoreAction action) {
    final userId = _userVm.user.user_id;
    if (userId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    handleWebMoreAction(
      context,
      action: action,
      onDelete: () async {
        final response = await LiveTalkAPI().delete({
          'livetalk_id': item.livetalkId,
          'user_id': userId,
        });
        if (response.success) await _vm.gotoPage(_vm.currentPage);
        return response.success;
      },
      // core VM의 신고/차단은 내부에서 Get.back()을 불러 화면을 pop시킨다 → API 직접 호출.
      onReport: () => mapWebActionResponse(
        () => LiveTalkAPI().report({
          'livetalk_id': item.livetalkId,
          'user_id': userId,
        }),
      ),
      onHideUser: () => mapWebActionResponse(
        () => UserAPI().blockUser({
          'user_id': userId,
          'block_user_id': item.userId,
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    // 무한 스크롤 화면이라 **푸터를 두지 않는다**(스크롤 끝이 없으니 닿을 수
    // 없고, 닿더라도 다음 페이지 로딩과 겹친다 — 사용자 결정).
    // 여백은 스크롤 영역 안쪽(웹 공통 규칙 — 바깥에 두면 스크롤바가 브라우저
    // 우측 끝에 안 붙는다).
    final scrollArea = SingleChildScrollView(
      controller: _scrollController,
      // 홈 공통 여백(중고거래 홈 기준) — 태블릿·모바일은 콘텐츠가 하단
      // 플로팅 바 뒤로 지나가도록 바 높이만큼 하단 여백을 확보한다.
      padding: webHomePagePadding(
        context,
        bottom: isDesktop
            ? SDSSpacing.xl
            : kWebFloatingBottomBarHeight + SDSSpacing.md,
      ),
      child: Center(
        child: ConstrainedBox(
          // 블록 폭 제한은 PC만 — 태블릿·모바일은 좌우 여백만 두고 꽉 채운다
          // (피그마 80:226593 — 800폭에서 콘텐츠 760).
          constraints: BoxConstraints(
            maxWidth: isDesktop ? kLiveTalkContentMaxWidth : double.infinity,
          ),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: kLiveTalkFeedWidth, child: _buildFeedColumn()),
                    const SizedBox(width: kLiveTalkSidebarGap),
                    _buildDesktopSidebar(),
                  ],
                )
              : _buildFeedColumn(),
        ),
      ),
    );

    // ⚠️ PC·태블릿·모바일이 **같은 트리 모양**을 쓴다(홈 화면과 동일한 골격).
    // 한쪽만 Stack으로 감싸면 창 폭이 브레이크포인트를 넘을 때 스크롤 위젯이
    // 재사용되지 못하고 새로 만들어지는데, 옛 위젯이 해제되기 전에 새 위젯이
    // 같은 [_scrollController]를 붙어 "ScrollController attached to multiple
    // scroll views"로 죽는다.
    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          Positioned.fill(child: scrollArea),
          // 태블릿·모바일만 액션 버튼이 뷰포트 하단에 고정된다(목업). 공용 플로팅
          // 바(커뮤니티·중고거래와 동일) — 콘텐츠가 바 뒤로 지나가며 페이드로 사라진다.
          if (!isDesktop)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: WebFloatingBottomBar(child: _buildBottomBarButtons()),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 홈 타이틀 공통: PC 32 / 태블릿·모바일 24 (중고거래 홈 기준).
        // 홈 타이틀 공통 크기(PC 32 / 태블릿 24 / 모바일 20).
        Text(
          '라이브톡',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: webHomeTitleSize(context),
            color: SDSColor.gray900,
          ),
        ),
        // 타이틀 ↔ 첫 글 30 (목업 19에서 넓힘 — 사용자 확정).
        const SizedBox(height: 30),
        Obx(() {
          // ⚠️ Rx는 **조건 없이** 먼저 읽는다 — 아래 조기 반환에 걸리면 Obx가
          // 구독 대상을 못 잡아 "improper use of GetX"가 난다.
          final items = _vm.items;
          final isLoading = _vm.isLoading;
          final hasError = _vm.hasError;
          final isLoadingMore = _vm.isLoadingMore;

          // 첫 로딩은 사진까지 준비된 뒤에 드러낸다(_loadFirstPage 참고).
          if (_warmingFirstImages || (isLoading && items.isEmpty)) {
            return const LiveTalkFeedSkeleton();
          }
          if (hasError) {
            return WebEmptyState(
              message: '라이브톡을 불러오지 못했어요',
              actionLabel: '다시 시도',
              onAction: _vm.retry,
            );
          }
          if (items.isEmpty) {
            return const WebEmptyState(message: '아직 올라온 라이브톡이 없어요');
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                // 카드 사이 32 — 카드 자체에는 상하 패딩·구분선이 없다.
                if (i > 0) SizedBox(height: liveTalkFeedItemGap(context)),
                LiveTalkFeedItemWeb(
                  item: items[i],
                  onTapImage: () => _openDetail(items[i]),
                  onTapComment: () => _openDetail(items[i]),
                  onTapLike: () => _onTapLike(items[i]),
                  moreActions: _isMine(items[i])
                      ? const [WebMoreAction.delete]
                      : const [WebMoreAction.reportPost, WebMoreAction.hideUser],
                  onMoreAction: (action) => _onMoreAction(items[i], action),
                ),
              ],
              // 무한 스크롤 — 다음 페이지를 받는 동안만 스피너를 둔다.
              // 마지막까지 받으면 아무것도 그리지 않는다("끝" 문구 없음).
              if (isLoadingMore)
                Padding(
                  padding: EdgeInsets.only(top: liveTalkFeedItemGap(context)),
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          SDSColor.gray900,
                        ),
                      ),
                    ),
                  ),
                ),
              // 마지막 글 아래 여백 — 푸터가 없어서 목록 끝이 화면 바닥에 딱
              // 붙지 않게 한다. 하단 바가 있는 태블릿·모바일은 이미 바 높이만큼
              // 스크롤 여백을 잡아둬서 그만큼 덜 준다(마지막 글이 페이드에 묻히지
              // 않을 정도만).
              SizedBox(height: context.isDesktop ? 100 : 40),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildDesktopSidebar() {
    final buttons = Padding(
      // 피드 첫 글과 버튼 윗선이 맞도록 제목 높이만큼 내린다
      // (타이틀 40 + 타이틀↔첫 글 30).
      padding: const EdgeInsets.only(top: _kSidebarTopOffset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // PC 사이드바 버튼은 bold 14(웹 사이드바 공통) — 하단 플로팅 바는 16 유지.
          _PrimaryActionButton(
              label: '게시글 올리기', onTap: _onUploadLiveTalk, fontSize: 14),
          // 버튼 사이 10 (피그마 80:217015/217252).
          const SizedBox(height: 10),
          _SecondaryActionButton(
              label: '라이딩 카드 공유', onTap: _onShareRidingCard, fontSize: 14),
        ],
      ),
    );

    // 스크롤을 내리면 버튼이 화면 상단 30에 멈춰 따라붙는다(공용 WebStickySidebar).
    return SizedBox(
      width: kLiveTalkSidebarWidth,
      child: WebStickySidebar(
        controller: _scrollController,
        naturalTop: webHomePagePadding(context).top + _kSidebarTopOffset,
        child: buttons,
      ),
    );
  }

  /// 태블릿·모바일 하단 바 버튼 줄 — 두 버튼이 폭을 반씩 나눠 갖고 간격 10
  /// (피그마 80:226593 — 800폭에서 385씩). 버튼 규격은 사이드바와 같은 48/r5/bold16.
  Widget _buildBottomBarButtons() {
    return Row(
      children: [
        Expanded(
          child: _SecondaryActionButton(
            label: '라이딩 카드 공유',
            onTap: _onShareRidingCard,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PrimaryActionButton(
            label: '게시글 올리기',
            onTap: _onUploadLiveTalk,
          ),
        ),
      ],
    );
  }
}

/// 라이딩 카드 공유 버튼 배경(피그마 comp_button 80:217252). 청회색이라 맞는
/// 그레이 토큰이 없어 목업 값을 그대로 쓴다(사용자 확정).
const Color _kLiveTalkSecondaryColor = Color(0xFF7C899D);

/// 파란 채움 버튼(게시글 올리기).
class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  /// 사이드바에서는 14(웹 사이드바 공통), 하단 플로팅 바에서는 기본 16.
  final double fontSize;

  const _PrimaryActionButton({required this.label, required this.onTap, this.fontSize = 16});

  @override
  Widget build(BuildContext context) => _FilledActionButton(
        label: label,
        background: SDSColor.snowliveBlue,
        onTap: onTap,
        fontSize: fontSize,
      );
}

/// 청회색 채움 버튼(라이딩 카드 공유) — 목업에서 게시글 올리기보다 약한 위계다.
class _SecondaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double fontSize;

  const _SecondaryActionButton({required this.label, required this.onTap, this.fontSize = 16});

  @override
  Widget build(BuildContext context) => _FilledActionButton(
        label: label,
        background: _kLiveTalkSecondaryColor,
        onTap: onTap,
        fontSize: fontSize,
      );
}

/// 사이드바·하단바 공통 채움 버튼 — 라운드 5
/// (피그마 comp_button 80:217015). hover는 웹 공통 규칙(검정 10% 즉시 혼합).
/// 높이는 공용 [webActionButtonHeight](PC 44 / 태블릿·모바일 48).
///
/// 글자는 **하단 플로팅 바에서 bold 16, PC 사이드바에서는 bold 14** — 사이드바
/// 버튼은 다른 화면과 함께 14로 통일했고(사용자 확정), 하단 바는 목업값을 유지한다.
class _FilledActionButton extends StatelessWidget {
  final String label;
  final Color background;
  final VoidCallback onTap;
  final double fontSize;

  const _FilledActionButton({
    required this.label,
    required this.background,
    required this.onTap,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final height = webActionButtonHeight(context);
    // visualDensity(웹 기본 compact)가 minimumSize 높이를 깎으므로 강제한다.
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: Size(0, height),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          // 그림자·리플 없이 색만 즉시 어두워진다(웹 공통 채움 버튼 hover).
          animationDuration: Duration.zero,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return Color.alphaBlend(SDSColor.snowliveBlack.withValues(alpha: 0.1), background);
            }
            return background;
          }),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
        child: Text(
          label,
          style: SDSTextStyle.bold.copyWith(fontSize: fontSize, color: SDSColor.snowliveWhite),
        ),
      ),
    );
  }
}
