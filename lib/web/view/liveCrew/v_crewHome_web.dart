import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewMemberRankingList.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_header_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_member_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_riding_stats_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_sidebar_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_talk_section_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_detail_overlay_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_upload_flow_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewDetail_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_back_icon_web.dart';
import 'package:com.snowlive/web/widget/w_web_floating_bottombar_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:com.snowlive/web/widget/w_web_section_link_button_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart' show showWebCrewApplyDialog;
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 1440 - GNB 사이드바 240 - 좌우 패딩 32*2 = 1136 (다른 화면과 같은 계산식).
/// 본문(목록) 폭 — 라이브크루 홈과 같은 874(목업 161:86732).
const double kCrewHomeListMaxWidth = 874;

/// 블록 전체 폭 = 본문 874 + 간격 40 + 사이드바 220.
const double kCrewHomeContentMaxWidth =
    kCrewHomeListMaxWidth + kWebSidebarGap + kWebSidebarWidth;

/// 목업의 `랭킹 TOP N 멤버` — PC·태블릿은 2열 × 5행으로 10명,
/// 모바일은 1열이라 5명만 보여준다(목업 161:101758 `랭킹 TOP 5 멤버`).
int crewHomeTopMemberCount(BuildContext context) =>
    context.screenType == WebScreenType.mobile ? 5 : 10;

/// 크루홈(크루별 상세). `#/livecrew-detail?id=334`로 직접 진입해도 동작한다.
class CrewHomeViewWeb extends StatefulWidget {
  const CrewHomeViewWeb({super.key});

  @override
  State<CrewHomeViewWeb> createState() => _CrewHomeViewWebState();
}

class _CrewHomeViewWebState extends State<CrewHomeViewWeb> {
  final CrewDetailViewModelWeb _vm = Get.find<CrewDetailViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();

  /// 라우트 파라미터는 initState에서 잡아둔다 — 이후 Get.parameters가 비워질 수 있다.
  int? _crewId;

  CrewTalkGroupMode _talkMode = CrewTalkGroupMode.all;

  @override
  void initState() {
    super.initState();
    _crewId = int.tryParse(Get.parameters['id'] ?? '');
    final id = _crewId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _vm.load(id);
      });
    }
  }

  /// 크루톡 목록. **크루별 조회 API가 아직 없어서 항상 빈 목록이다**
  /// (`/livetalk/list/`가 crew_id를 무시하고 전체를 준다 — 실측).
  /// 서버가 필터를 열어주면 이 getter만 뷰모델 값으로 바꾸면 된다.
  List<LiveTalk> get _talks => const [];

  SeasonRankingInfo? get _season => _vm.season;

  List<CrewRanking> get _memberList => _vm.members;

  Future<void> _onUploadTalk() async {
    final userId = _userVm.user.user_id;
    final crewId = _crewId;
    if (crewId == null) return;
    if (userId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    final done = await showLiveTalkUploadFlow(
      context: context,
      userId: userId,
      crewId: crewId,
    );
    if (done && mounted) await _vm.refresh();
  }

  Future<void> _onTalkTap(LiveTalk talk) async {
    final id = talk.livetalkId;
    if (id == null) return;
    // 라이브톡과 같은 분기 — 모바일만 별도 화면, 그 외는 사진+댓글 오버레이(목업).
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

  void _onMemberTap(CrewRanking member) {
    showCrewMemberProfileModal(
      context,
      member: member,
      crewName: _vm.info?.crewName,
      resortName: _vm.info?.baseResortFullname ?? _vm.info?.baseResortNickname,
    );
  }

  void _goBack() {
    // URL 직접 진입이라 돌아갈 화면이 없으면 라이브크루 홈으로 보낸다.
    if (Navigator.of(context).canPop()) {
      Get.back();
      return;
    }
    Get.offAllNamed(WebRoutes.liveCrew);
  }

  Future<void> _onApply() async {
    if (_userVm.user.user_id == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    final crewName = _vm.info?.crewName ?? '';
    // 앱처럼 신청 메시지 입력창을 띄운다(취소면 중단).
    final title = await showWebCrewApplyDialog(context: context, crewName: crewName);
    if (title == null || !mounted) return;

    final result = await _vm.applyForCrew(title: title);
    if (!mounted) return;
    showWebToast(
      context,
      result.ok
          ? '가입 신청을 보냈습니다.'
          // 서버가 사유를 주면 그대로 보여준다(중복 신청 등).
          : (result.message ?? '이미 신청했거나 잠시 후 다시 시도해 주세요.'),
      alignment: context.screenType == WebScreenType.mobile
          ? Alignment.bottomCenter
          : Alignment.topCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SDSColor.snowliveWhite,
      child: Obx(() {
        // 좁은 폭에서는 `크루톡 올리기`가 본문 끝이 아니라 **뷰포트 하단 플로팅 바**에
        // 고정된다(목업 161:93978 — 바 68, 버튼 780×48). 크루톡은 크루원만 올린다.
        final hasFloatingBar = !context.isDesktop && _vm.isMyCrew;

        return Stack(
          children: [
            Positioned.fill(
              // 페이지 여백은 서브 페이지 공통(PC 40/58 · 태블릿 20/20 · 모바일 16/16).
              // ⚠️ 여백은 **스크롤 영역 안쪽**에 둔다(웹 공통) — 바깥에 주면 스크롤바가
              // 여백 안쪽에 생겨 브라우저 오른쪽 끝에 붙지 않는다.
              child: SingleChildScrollView(
                padding: webSubPagePadding(
                  context,
                  // 콘텐츠가 플로팅 바 뒤로 지나가도록 바 높이만큼 비우고, 끝까지
                  // 내렸을 때 마지막 사진이 버튼에 닿지 않도록 40을 더 둔다.
                  bottom: hasFloatingBar
                      ? kWebFloatingBottomBarHeight + 40
                      : SDSSpacing.xl,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: kCrewHomeContentMaxWidth),
                    child: _buildBody(),
                  ),
                ),
              ),
            ),
            if (hasFloatingBar)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: WebFloatingBottomBar(
                  child: CrewTalkUploadButton(onTap: _onUploadTalk),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildBody() {
    final info = _vm.info;
    // 세 값을 무조건 먼저 읽어야 Obx 구독이 확실히 걸린다(분기 뒤로 미루면 놓친다).
    final isLoading = _vm.isLoading;
    final hasError = _vm.hasError;
    final members = _memberList;

    if (_crewId == null) {
      return const WebEmptyState(message: '크루 정보를 찾을 수 없어요.');
    }
    if (info == null) {
      if (hasError) return WebErrorState(onRetry: _vm.refresh);
      return isLoading ? const _CrewHomeSkeleton() : const SizedBox(height: 240);
    }

    // 헤더는 **블록 전체 폭**(목업 — 로고~설정 아이콘이 사이드바 오른쪽 끝까지 간다).
    // 그 아래부터 본문 874 / 사이드바 220으로 나뉜다.
    final header = CrewHomeHeaderWeb(
      info: info,
      showSettings: _vm.isMyCrew,
      visitorToday: _vm.visitorToday,
      visitorTotal: _vm.visitorTotal,
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CrewHomeSummaryBarWeb(
          memberCount: info.crewMemberTotal,
          overallRank: _season?.overallRank,
          totalScore: _season?.overallTotalScore,
          // 내 크루가 아닐 때만 가입 신청을 노출한다(목업).
          onApply: _vm.isMyCrew ? null : _onApply,
          onMembersTap: () => Get.toNamed('${WebRoutes.crewMembers}?id=$_crewId'),
        ),
        // 크루 소개글(있을 때만) — 앱처럼 통계 바 아래 별도 블록으로 둔다.
        if (info.description?.trim().isNotEmpty ?? false) ...[
          SizedBox(height: context.screenType == WebScreenType.mobile ? 16 : 20),
          CrewHomeDescriptionWeb(description: info.description),
        ],
        // 통계 바 ↔ 라이딩 통계 (PC·태블릿 40 / 모바일 32 — 목업).
        SizedBox(height: context.screenType == WebScreenType.mobile ? 32 : 40),
        CrewHomeRidingStatsWeb(
          season: _season,
          crewName: info.crewName ?? '',
          crewLogoUrl: info.crewLogoUrl,
          crewColor: info.color,
        ),
        // 라이딩 통계 ↔ 랭킹 40 / 랭킹 ↔ 크루톡 48 (목업).
        const SizedBox(height: 40),
        _buildMemberSection(members),
        const SizedBox(height: 48),
        CrewHomeTalkSectionWeb(
          talks: _talks,
          mode: _talkMode,
          onModeChanged: (mode) => setState(() => _talkMode = mode),
          onTalkTap: _onTalkTap,
          onSeeAll: () => Get.toNamed('${WebRoutes.crewTalks}?id=$_crewId'),
        ),
      ],
    );

    if (!context.isDesktop) {
      final isMobile = context.screenType == WebScreenType.mobile;
      // 좁은 폭 구성(목업 161:93085): 뒤로가기 줄 → 크루 헤더 → 기록 링크 줄 → 본문
      // 우측 열이 접히므로 기록 링크는 크루명 바로 아래 텍스트 줄로 내려온다
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WebIconButton(
            onTap: _goBack,
            // 좌측 히트 여백 0 — 화살표가 콘텐츠 좌측선에 붙는다(공통 헤더와 같은 처리).
            padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
            // 서브 페이지 공통 뒤로가기 크기(PC·태블릿 30 / 모바일 24) — 목업은
            // 26이지만 다른 화면과 같은 값을 쓴다(확정 표준).
            icon: WebBackIcon(
              size: context.screenType == WebScreenType.mobile ? 24 : 30,
            ),
          ),
          // 뒤로가기 ↔ 로고 줄 (목업 — 태블릿 28 / 모바일 18).
          SizedBox(height: isMobile ? 18 : 28),
          header,
          // 로고 줄 ↔ 링크 줄 (태블릿 10 / 모바일 12), 링크 줄 ↔ 통계 바는
          // 헤더 블록 아래 여백으로 태블릿 20 / 모바일 16 (목업 161:94357·102331).
          SizedBox(height: isMobile ? 12 : 10),
          CrewRecordLinkRow(crewId: _crewId),
          SizedBox(height: isMobile ? 16 : 20),
          content,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        // 헤더 ↔ 통계 바 10 (목업 — 헤더 블록 196, 통계 바 206)
        const SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: content),
            const SizedBox(width: kWebSidebarGap),
            CrewHomeSidebarWeb(
              // 내 크루가 아니면 업로드 버튼 없이 링크 카드만 보인다
              onUploadTalk: _vm.isMyCrew ? _onUploadTalk : null,
              crewId: _crewId,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemberSection(List<CrewRanking> members) {
    final topCount = crewHomeTopMemberCount(context);
    final top = members.take(topCount).toList();
    // 2열은 태블릿까지(목업 161:93789 — 760 안에 356 × 2, 간격 48). 모바일만 1열.
    final columns = context.screenType == WebScreenType.mobile ? 1 : 2;
    final perColumn = (top.length / columns).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '랭킹 TOP $topCount 멤버',
              style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
            ),
            const Spacer(),
            WebSectionLinkButton(
              label: '전체 멤버',
              onTap: () => Get.toNamed('${WebRoutes.crewMembers}?id=$_crewId'),
            ),
          ],
        ),
        const SizedBox(height: SDSSpacing.md),
        if (top.isEmpty)
          const WebEmptyState(message: '아직 멤버 기록이 없어요.')
        else
          CrewMemberListInset(
            rowCount: perColumn,
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < columns; i++) ...[
                // 열 사이 48 (목업 — 열 413, 다음 열 461).
                if (i > 0) const SizedBox(width: 48),
                Expanded(
                  child: Column(
                    children: [
                      for (final (index, member)
                          in top.skip(i * perColumn).take(perColumn).indexed) ...[
                        if (index > 0) SizedBox(height: crewMemberRowGap(context)),
                        CrewMemberRowWeb(member: member, onTap: () => _onMemberTap(member)),
                      ],
                    ],
                  ),
                ),
              ],
            ],
            ),
          ),
      ],
    );
  }
}

class _CrewHomeSkeleton extends StatelessWidget {
  const _CrewHomeSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isMobile = context.screenType == WebScreenType.mobile;
    // 실제 레이아웃과 같은 값으로만 자리를 잡는다 — 하나라도 다르면 데이터가
    // 도착하는 순간 화면이 튄다.
    final double logoSize = switch (context.screenType) {
      WebScreenType.desktop => 64,
      WebScreenType.tablet => 56,
      WebScreenType.mobile => 36,
    };
    final double titleHeight = webSubPageTitleSize(context);

    final header = Row(
      children: [
        SkeletonBox(
          width: logoSize,
          height: logoSize,
          radius: crewLogoRadius(logoSize),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SkeletonBox(width: isMobile ? 140 : 180, height: titleHeight),
            const SizedBox(height: 2),
            const SkeletonBox(width: 120, height: 16),
          ],
        ),
        const Spacer(),
        // 알림·설정 아이콘 자리(26 + 간격 12 + 26).
        const SkeletonBox(width: 26, height: 26, radius: 6),
        const SizedBox(width: 12),
        const SkeletonBox(width: 26, height: 26, radius: 6),
      ],
    );

    // 통계 바 — PC·태블릿 54, 모바일은 값/라벨 2줄이라 73.
    final summaryBar = SkeletonBox(height: isMobile ? 73 : 54, radius: 16);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        summaryBar,
        SizedBox(height: isMobile ? 32 : 40),
        const _SectionTitleSkeleton(buttonWidth: 109),
        const SizedBox(height: 12),
        // 라이딩 통계 카드 — 모바일만 세로 2단.
        if (isMobile)
          const Column(
            children: [
              SkeletonBox(height: 310, radius: 16),
              SizedBox(height: 20),
              SkeletonBox(height: 310, radius: 16),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: isDesktop ? 423 : 1,
                child: const SkeletonBox(height: 310, radius: 16),
              ),
              SizedBox(width: isDesktop ? 21 : 20),
              Expanded(
                flex: isDesktop ? 430 : 1,
                child: const SkeletonBox(height: 310, radius: 16),
              ),
            ],
          ),
        const SizedBox(height: 40),
        const _SectionTitleSkeleton(buttonWidth: 72),
        const SizedBox(height: SDSSpacing.md),
        CrewMemberListSkeleton(
          count: crewHomeTopMemberCount(context),
          columnGap: 48,
        ),
        const SizedBox(height: 48),
        const _SectionTitleSkeleton(buttonWidth: 73),
        const SizedBox(height: SDSSpacing.md),
        const _TalkGridSkeleton(),
      ],
    );

    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop) ...[
            // 뒤로가기 줄(PC·태블릿 30 / 모바일 24)과 그 아래 간격.
            SkeletonBox(width: isMobile ? 24 : 30, height: isMobile ? 24 : 30, radius: 4),
            SizedBox(height: isMobile ? 18 : 28),
            header,
            // 기록 링크 줄(`시즌 기록실 · 일별 현황`).
            SizedBox(height: isMobile ? 12 : 10),
            const SkeletonBox(width: 180, height: 17),
            SizedBox(height: isMobile ? 16 : 20),
            content,
          ] else ...[
            header,
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: content),
                const SizedBox(width: kWebSidebarGap),
                // 우측 열 — 올리기 버튼(44) + 30 + 링크 카드 2장(52, 사이 8).
                const SizedBox(
                  width: kWebSidebarWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SkeletonBox(height: 44, radius: 5),
                      SizedBox(height: 30),
                      SkeletonBox(height: 52, radius: 12),
                      SizedBox(height: 8),
                      SkeletonBox(height: 52, radius: 12),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 섹션 제목줄(높이 36) — 제목 글줄 + 오른쪽 링크 버튼.
class _SectionTitleSkeleton extends StatelessWidget {
  final double buttonWidth;

  const _SectionTitleSkeleton({required this.buttonWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          const SkeletonBox(width: 110, height: 19),
          const Spacer(),
          SkeletonBox(width: buttonWidth, height: 36, radius: 6),
        ],
      ),
    );
  }
}

/// 크루톡 사진 그리드 — 실제와 같은 열 수·간격으로 두 줄만 깔아 둔다.
class _TalkGridSkeleton extends StatelessWidget {
  const _TalkGridSkeleton();

  @override
  Widget build(BuildContext context) {
    final columns = switch (context.screenType) {
      WebScreenType.desktop => 5,
      WebScreenType.tablet => 4,
      WebScreenType.mobile => 2,
    };
    const spacing = 2.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cell = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Column(
          children: [
            for (var row = 0; row < 2; row++) ...[
              if (row > 0) const SizedBox(height: spacing),
              Row(
                children: [
                  for (var i = 0; i < columns; i++) ...[
                    if (i > 0) const SizedBox(width: spacing),
                    SkeletonBox(width: cell, height: cell),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
