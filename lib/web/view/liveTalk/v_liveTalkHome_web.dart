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
import 'package:com.snowlive/web/widget/w_numbered_pagination_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_image_viewer_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 데스크탑 피드 열 폭(목업). SNS형 피드라 목록·상세(1136)보다 훨씬 좁다 —
/// 넓히면 사진이 과하게 커지고 한 줄 글자수가 늘어 읽기 흐름이 깨진다.
const double kLiveTalkFeedWidth = 480;

/// 데스크탑 우측 사이드바 폭(목업).
const double kLiveTalkSidebarWidth = 246;

/// 피드 열과 사이드바 사이 간격(목업).
const double _kSidebarGap = 40;

/// 데스크탑에서 "피드 + 간격 + 사이드바"를 묶은 블록 폭. 이 블록이 GNB 오른쪽
/// 영역 가운데로 온다.
const double kLiveTalkContentMaxWidth =
    kLiveTalkFeedWidth + _kSidebarGap + kLiveTalkSidebarWidth;

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

  /// 하단 고정바 높이(패딩 16*2 + 버튼 48).
  static const double _bottomBarHeight = 80;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.loadFirstPage(userId: _userVm.user.user_id);
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

  /// 사진 탭 — 데스크탑·태블릿은 사진+댓글 오버레이, 모바일은 공용 라이트박스(사용자 확정).
  Future<void> _onTapImage(LiveTalk item) async {
    final url = item.imageUrl;
    if (url == null || url.isEmpty) return;
    if (context.screenType == WebScreenType.mobile) {
      await showWebImageViewer(
        context: context,
        title: item.userInfo?.displayName ?? '라이브톡',
        imageUrls: [url],
        initialIndex: 0,
      );
      return;
    }
    await _openDetail(item);
  }

  /// 댓글 탭 — 모바일만 별도 화면(목업), 그 외는 오버레이 안에서 본다.
  Future<void> _onTapComment(LiveTalk item) async {
    if (item.livetalkId == null) return;
    if (context.screenType == WebScreenType.mobile) {
      await Get.toNamed('${WebRoutes.liveTalkComments}?id=${item.livetalkId}');
      // 댓글 화면에서 쓴 댓글이 피드 카운트에 반영되도록 그 글만 다시 받는다.
      await _vm.reloadItem(item.livetalkId!);
      return;
    }
    await _openDetail(item);
  }

  Future<void> _openDetail(LiveTalk item) async {
    if (item.livetalkId == null) return;
    final changed = await showLiveTalkDetailOverlay(
      context: context,
      livetalkId: item.livetalkId!,
      userId: _userVm.user.user_id,
    );
    if (changed) await _vm.reloadItem(item.livetalkId!);
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
            constraints: const BoxConstraints(maxWidth: kLiveTalkContentMaxWidth),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: kLiveTalkFeedWidth, child: _buildFeedColumn()),
                      const SizedBox(width: _kSidebarGap),
                      _buildDesktopSidebar(),
                    ],
                  )
                : _buildFeedColumn(),
          ),
        ),
      ),
    );

    if (isDesktop) return scrollArea;

    // 태블릿·모바일은 액션 버튼이 뷰포트 하단에 고정된다(목업). 셸이 페이지를
    // Expanded에 넣으므로 Stack의 bottom이 곧 뷰포트 하단이다.
    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          Padding(padding: const EdgeInsets.only(bottom: _bottomBarHeight), child: scrollArea),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomBar()),
        ],
      ),
    );
  }

  Widget _buildFeedColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('라이브톡', style: SDSTextStyle.extraBold.copyWith(fontSize: 28, color: SDSColor.gray900)),
        const SizedBox(height: SDSSpacing.md),
        Obx(() {
          if (_vm.isLoading && _vm.items.isEmpty) return const CommunityListSkeleton();
          if (_vm.hasError) {
            return WebEmptyState(
              message: '라이브톡을 불러오지 못했어요',
              actionLabel: '다시 시도',
              onAction: _vm.retry,
            );
          }
          if (_vm.items.isEmpty) {
            return const WebEmptyState(message: '아직 올라온 라이브톡이 없어요');
          }
          final items = _vm.items;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++)
                LiveTalkFeedItemWeb(
                  item: items[i],
                  isLast: i == items.length - 1,
                  onTapImage: () => _onTapImage(items[i]),
                  onTapComment: () => _onTapComment(items[i]),
                  onTapLike: () => _onTapLike(items[i]),
                  moreActions: _isMine(items[i])
                      ? const [WebMoreAction.delete]
                      : const [WebMoreAction.reportPost, WebMoreAction.hideUser],
                  onMoreAction: (action) => _onMoreAction(items[i], action),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SDSSpacing.lg),
                child: NumberedPaginationBar(
                  currentPage: _vm.currentPage,
                  totalPages: _vm.totalPages,
                  hasPrevious: _vm.hasPrevious,
                  hasNext: _vm.hasNext,
                  pageWindow: _vm.pageWindow(),
                  onGotoPage: _vm.gotoPage,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: kLiveTalkSidebarWidth,
      // 피드 첫 글과 버튼 윗선이 맞도록 제목 높이만큼 내린다(다른 화면과 같은 규격).
      padding: const EdgeInsets.only(top: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PrimaryActionButton(label: '라이브톡 올리기', onTap: _onUploadLiveTalk),
          const SizedBox(height: SDSSpacing.sm),
          _SecondaryActionButton(label: '라이딩 카드 공유', onTap: _onShareRidingCard),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        border: Border(top: BorderSide(color: SDSColor.gray100)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: SDSSpacing.md, vertical: SDSSpacing.md),
      child: Row(
        children: [
          Expanded(child: _SecondaryActionButton(label: '라이딩 카드 공유', onTap: _onShareRidingCard)),
          const SizedBox(width: SDSSpacing.sm),
          Expanded(child: _PrimaryActionButton(label: '라이브톡 올리기', onTap: _onUploadLiveTalk)),
        ],
      ),
    );
  }

}

/// 파란 채움 버튼(라이브톡 올리기).
class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: SDSColor.snowliveBlue,
        elevation: 0,
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveWhite)),
    );
  }
}

/// 회색 채움 버튼(라이딩 카드 공유) — 목업에서 라이브톡 올리기보다 약한 위계다.
class _SecondaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: SDSColor.gray300,
        elevation: 0,
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveWhite)),
    );
  }
}
