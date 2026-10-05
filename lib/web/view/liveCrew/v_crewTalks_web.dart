import 'package:com.snowlive/core/api/api_liveTalk.dart';
import 'package:com.snowlive/core/api/api_user.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_sidebar_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_detail_overlay_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_feed_item_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_upload_flow_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewDetail_web.dart';
import 'package:com.snowlive/web/view/liveTalk/v_liveTalkHome_web.dart';
import 'package:com.snowlive/web/widget/w_web_floating_bottombar_web.dart';
import 'package:com.snowlive/web/widget/w_web_sticky_sidebar_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_page_header_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 크루톡 목록은 **라이브톡 피드와 완전히 같은 규격**을 쓴다(사용자 확정) —
/// 폭·간격·사이드바·하단 플로팅 바·끝 여백 전부 `v_liveTalkHome_web.dart`의
/// 상수를 그대로 참조한다. 값을 복제하면 한쪽만 고쳐질 때 어긋난다.
const double kCrewTalksFeedWidth = kLiveTalkFeedWidth;
const double kCrewTalksContentMaxWidth = kLiveTalkContentMaxWidth;

/// 사이드바가 스크롤을 따라붙기 시작하는 기준점 = 공통 헤더 줄 높이(PC Bold 30
/// 기준 38) + 헤더↔본문 간격. 라이브톡 홈의 `_kSidebarTopOffset`과 같은 역할이다.
const double _kCrewTalksSidebarTopOffset = 38 + SDSSpacing.xl;

/// 크루톡 목록. `#/livecrew-talks?id=334`
///
/// ⚠️ **크루별 크루톡 조회 API가 아직 없다** — `POST /api/livetalk/list/`는 `crew_id`를
/// 무시하고 전체 라이브톡을 돌려주고(실측), 크루 전용 경로는 404다. 그래서 지금은
/// 빈 상태만 보인다. 서버가 필터를 열어주면 [_talks]만 뷰모델 값으로 바꾸면 된다.
class CrewTalksViewWeb extends StatefulWidget {
  const CrewTalksViewWeb({super.key});

  @override
  State<CrewTalksViewWeb> createState() => _CrewTalksViewWebState();
}

class _CrewTalksViewWebState extends State<CrewTalksViewWeb> {
  final CrewDetailViewModelWeb _vm = Get.find<CrewDetailViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();

  int? _crewId;

  /// 사이드바를 스크롤에 따라붙이기 위한 컨트롤러(라이브톡 홈과 같은 구성).
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _crewId = int.tryParse(Get.parameters['id'] ?? '');
    final id = _crewId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _vm.crewId != id) _vm.load(id);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<LiveTalk> get _talks => const [];

  void _goBack() {
    // URL 직접 진입이라 돌아갈 화면이 없으면 크루홈으로 보낸다(멤버 화면과 같은 처리).
    if (Navigator.of(context).canPop()) {
      Get.back();
      return;
    }
    Get.offAllNamed('${WebRoutes.crewHome}?id=$_crewId');
  }

  Future<void> _onUpload() async {
    final userId = _userVm.user.user_id;
    final crewId = _crewId;
    if (crewId == null) return;
    if (userId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    await showLiveTalkUploadFlow(context: context, userId: userId, crewId: crewId);
  }

  Future<void> _openDetail(LiveTalk item) async {
    final id = item.livetalkId;
    if (id == null) return;
    if (context.screenType == WebScreenType.mobile) {
      await Get.toNamed('${WebRoutes.liveTalkDetail}?id=$id');
      return;
    }
    await showLiveTalkDetailOverlay(
      context: context,
      livetalkId: id,
      userId: _userVm.user.user_id,
    );
  }

  void _onMoreAction(LiveTalk item, WebMoreAction action) {
    final userId = _userVm.user.user_id;
    if (userId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    // 라이브톡 홈과 같은 처리 — 코어 VM의 신고/차단은 내부에서 Get.back()을 부른다.
    handleWebMoreAction(
      context,
      action: action,
      onDelete: () async {
        final response = await LiveTalkAPI().delete({
          'livetalk_id': item.livetalkId,
          'user_id': userId,
        });
        return response.success;
      },
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

  bool _isMine(LiveTalk item) =>
      item.userId != null && item.userId == _userVm.user.user_id;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    // 크루톡은 크루원만 올릴 수 있다.
    final canUpload = _vm.isMyCrew;

    // ⚠️ 페이지 여백은 **스크롤 영역 안쪽**에(웹 공통) — 바깥에 주면 스크롤바가
    // 여백 안쪽에 생겨 브라우저 오른쪽 끝에 붙지 않는다. 좁은 폭은 콘텐츠가
    // 하단 플로팅 바 뒤로 지나가도록 바 높이만큼 아래를 비운다(라이브톡과 동일).
    final scrollArea = SingleChildScrollView(
      controller: _scrollController,
      padding: webSubPagePadding(
        context,
        bottom: isDesktop || !canUpload
            ? SDSSpacing.xl
            : kWebFloatingBottomBarHeight + SDSSpacing.md,
      ),
      child: Center(
        child: ConstrainedBox(
          // 블록 폭 제한은 PC만 — 태블릿·모바일은 좌우 여백만 두고 꽉 채운다.
          constraints: BoxConstraints(
            maxWidth: isDesktop ? kCrewTalksContentMaxWidth : double.infinity,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 서브 페이지 공통 헤더 — 피드 폭이 아니라 **블록 전체 폭**에 걸친다
              // (크루홈과 같은 처리). 그래서 오른쪽 열은 따로 내려줄 필요가 없다.
              WebPageHeader(title: '크루톡', onBack: _goBack),
              // 헤더 ↔ 첫 글 30 — 라이브톡 홈의 타이틀↔첫 글과 같은 값으로 맞춘다
              // (서브 페이지 표준 32 대신, 같은 피드를 쓰는 화면끼리 통일).
              const SizedBox(height: 30),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: kCrewTalksFeedWidth, child: _buildFeedColumn()),
                    const SizedBox(width: kLiveTalkSidebarGap),
                    if (canUpload) _buildDesktopSidebar(),
                  ],
                )
              else
                _buildFeedColumn(),
            ],
          ),
        ),
      ),
    );

    // ⚠️ PC·태블릿·모바일이 **같은 트리 모양**을 쓴다 — 한쪽만 Stack으로 감싸면
    // 창 폭이 브레이크포인트를 넘을 때 옛 위젯이 해제되기 전에 새 위젯이 같은
    // [_scrollController]를 붙어 "attached to multiple scroll views"로 죽는다.
    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          Positioned.fill(child: scrollArea),
          // 좁은 폭에서는 올리기 버튼이 뷰포트 하단에 고정된다(라이브톡과 동일).
          if (!isDesktop && canUpload)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: WebFloatingBottomBar(child: CrewTalkUploadButton(onTap: _onUpload)),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedColumn() {
    final talks = _talks;
    if (talks.isEmpty) {
      return const WebEmptyState(message: '아직 크루톡이 없어요');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < talks.length; i++) ...[
          // 카드 사이 간격 — 카드 자체에는 상하 패딩·구분선이 없다(라이브톡 공통).
          if (i > 0) SizedBox(height: liveTalkFeedItemGap(context)),
          LiveTalkFeedItemWeb(
            item: talks[i],
            onTapImage: () => _openDetail(talks[i]),
            onTapComment: () => _openDetail(talks[i]),
            onTapLike: () => Get.snackbar('알림', '준비 중이에요.'),
            moreActions: _isMine(talks[i])
                ? const [WebMoreAction.delete]
                : const [WebMoreAction.reportPost, WebMoreAction.hideUser],
            onMoreAction: (action) => _onMoreAction(talks[i], action),
          ),
        ],
        // 마지막 글 아래 여백 — 목록 끝이 화면 바닥에 딱 붙지 않게 한다. 하단 바가
        // 있는 좁은 폭은 이미 바 높이만큼 잡아둬서 덜 준다(라이브톡과 같은 값).
        SizedBox(height: context.isDesktop ? 100 : 40),
      ],
    );
  }

  /// 스크롤을 내리면 버튼이 화면 상단 30에 멈춰 따라붙는다(공용 WebStickySidebar).
  Widget _buildDesktopSidebar() {
    return SizedBox(
      width: kLiveTalkSidebarWidth,
      child: WebStickySidebar(
        controller: _scrollController,
        naturalTop:
            webSubPagePadding(context).top + _kCrewTalksSidebarTopOffset,
        child: CrewTalkUploadButton(onTap: _onUpload),
      ),
    );
  }
}
