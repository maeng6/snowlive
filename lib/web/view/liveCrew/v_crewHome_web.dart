import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewMemberRankingList.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
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
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 1440 - GNB 사이드바 240 - 좌우 패딩 32*2 = 1136 (다른 화면과 같은 계산식).
const double kCrewHomeContentMaxWidth = 1136;

/// 목업의 `랭킹 TOP 10 멤버` — 2열 × 5행.
const int kCrewHomeTopMemberCount = 10;

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
      await Get.toNamed('${WebRoutes.liveTalkComments}?id=$id');
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

  Future<void> _onApply() async {
    if (_userVm.user.user_id == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    final crewName = _vm.info?.crewName ?? '';
    final ok = await showWebConfirmDialog(
      context: context,
      title: '$crewName에\n가입 신청하시겠어요?',
      confirmLabel: '신청하기',
    );
    if (!ok || !mounted) return;

    final result = await _vm.applyForCrew();
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
    final isDesktop = context.isDesktop;

    return Container(
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
            constraints: const BoxConstraints(maxWidth: kCrewHomeContentMaxWidth),
            child: Obx(_buildBody),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final info = _vm.info;
    // 세 값을 무조건 먼저 읽어야 Obx 구독이 확실히 걸린다(분기 뒤로 미루면 놓친다).
    final isLoading = _vm.isLoading;
    final hasError = _vm.hasError;
    final members = _vm.members;

    if (_crewId == null) {
      return const WebEmptyState(message: '크루 정보를 찾을 수 없어요.');
    }
    if (info == null) {
      if (hasError) return WebErrorState(onRetry: _vm.refresh);
      return isLoading ? const _CrewHomeSkeleton() : const SizedBox(height: 240);
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CrewHomeHeaderWeb(info: info, showSettings: _vm.isMyCrew),
        const SizedBox(height: SDSSpacing.md),
        CrewHomeSummaryBarWeb(
          memberCount: info.crewMemberTotal,
          overallRank: _vm.season?.overallRank,
          totalScore: _vm.season?.overallTotalScore,
          // 내 크루가 아닐 때만 가입 신청을 노출한다(목업).
          onApply: _vm.isMyCrew ? null : _onApply,
          onMembersTap: () => Get.toNamed('${WebRoutes.crewMembers}?id=$_crewId'),
        ),
        const SizedBox(height: SDSSpacing.xl),
        CrewHomeRidingStatsWeb(
          season: _vm.season,
          crewName: info.crewName ?? '',
          crewLogoUrl: info.crewLogoUrl,
        ),
        const SizedBox(height: SDSSpacing.xl),
        _buildMemberSection(members),
        const SizedBox(height: SDSSpacing.xl),
        CrewHomeTalkSectionWeb(
          talks: _talks,
          mode: _talkMode,
          onModeChanged: (mode) => setState(() => _talkMode = mode),
          onTalkTap: _onTalkTap,
          onSeeAll: () => Get.toNamed('${WebRoutes.crewTalks}?id=$_crewId'),
        ),
        // 우측 열이 접히는 폭에서는 업로드 버튼과 기록 링크를 본문 끝으로 옮긴다.
        // 크루톡은 크루원만 올릴 수 있어서 **내 크루일 때만** 버튼을 노출한다.
        if (!context.isDesktop) ...[
          if (_vm.isMyCrew) ...[
            const SizedBox(height: SDSSpacing.xl),
            CrewTalkUploadButton(onTap: _onUploadTalk),
          ],
          const SizedBox(height: SDSSpacing.md),
          CrewRecordLinkCards(crewId: _crewId),
        ],
      ],
    );

    if (!context.isDesktop) return content;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: content),
        CrewHomeSidebarWeb(
          // 내 크루가 아니면 업로드 버튼 없이 링크 카드만 보인다.
          onUploadTalk: _vm.isMyCrew ? _onUploadTalk : null,
          crewId: _crewId,
        ),
      ],
    );
  }

  Widget _buildMemberSection(List<CrewRanking> members) {
    final top = members.take(kCrewHomeTopMemberCount).toList();
    final columns = context.isDesktop ? 2 : 1;
    final perColumn = (top.length / columns).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '랭킹 TOP $kCrewHomeTopMemberCount 멤버',
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => Get.toNamed('${WebRoutes.crewMembers}?id=$_crewId'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: SDSColor.gray200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                '전체 멤버',
                style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
              ),
            ),
          ],
        ),
        const SizedBox(height: SDSSpacing.md),
        if (top.isEmpty)
          const WebEmptyState(message: '아직 멤버 기록이 없어요.')
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < columns; i++) ...[
                if (i > 0) const SizedBox(width: SDSSpacing.lg),
                Expanded(
                  child: Column(
                    children: [
                      for (final member in top.skip(i * perColumn).take(perColumn))
                        CrewMemberRowWeb(member: member, onTap: () => _onMemberTap(member)),
                    ],
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}

class _CrewHomeSkeleton extends StatelessWidget {
  const _CrewHomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SkeletonBox(width: 64, height: 64, radius: 12),
              SizedBox(width: SDSSpacing.md),
              SkeletonBox(width: 220, height: 28),
            ],
          ),
          const SizedBox(height: SDSSpacing.md),
          const SkeletonBox(height: 56, radius: 10),
          const SizedBox(height: SDSSpacing.xl),
          const SkeletonBox(height: 260, radius: 10),
          const SizedBox(height: SDSSpacing.xl),
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            const SkeletonBox(height: 40, radius: 8),
          ],
        ],
      ),
    );
  }
}
