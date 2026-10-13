import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList_recordRoom.dart'
    show RankingFilter_season;
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_record_sections_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewHome_web.dart' show kCrewHomeListMaxWidth;
import 'package:com.snowlive/web/view/liveCrew/w_crew_record_scaffold_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_record_widgets_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_riding_stats_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewRecord_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_stats_bar_web.dart';
import 'package:com.snowlive/web/widget/w_web_text_tabs_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 시즌 기록실. `#/livecrew-record?id=334`
///
/// 시즌 탭은 `25/26`·`24/25` 두 개뿐이다 — `23/24`는 서버가 거부한다(실측 400
/// `Ranking_record_2324 모델을 찾을 수 없습니다`, `crew_record_sections_web.dart` 참고).
class CrewRecordRoomViewWeb extends StatefulWidget {
  const CrewRecordRoomViewWeb({super.key});

  @override
  State<CrewRecordRoomViewWeb> createState() => _CrewRecordRoomViewWebState();
}

class _CrewRecordRoomViewWebState extends State<CrewRecordRoomViewWeb> {
  final CrewRecordViewModelWeb _vm = Get.find<CrewRecordViewModelWeb>();

  int? _crewId;

  @override
  void initState() {
    super.initState();
    _crewId = int.tryParse(Get.parameters['id'] ?? '');
    final id = _crewId;
    if (id != null) {
      // 뷰모델은 라우트 사이에 살아 있으므로(fenix) 이전 화면이 고른 시즌이 남는다 →
      // 새로 들어올 때는 URL의 season, 없으면 최신 시즌으로 맞춘다.
      final season = Get.parameters['season'] ?? crewRecordSeasons().first.dbSeason;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _vm.loadSeason(id, season: season);
      });
    }
  }

  /// `25/26시즌` → `25/26 시즌` (랭킹 기록실 관례).
  String _seasonLabel(RankingFilter_season s) =>
      '${s.korean.replaceAll('시즌', '')} 시즌';

  @override
  Widget build(BuildContext context) {
    return CrewRecordScaffoldWeb(
      title: '시즌 기록실',
      // 랭킹 진입은 **타이틀 줄 오른쪽 끝**에 둔다(사용자 확정) — 요약 바 안에
      // 두면 모바일에서 바 아래로 내려가 흐름이 끊긴다.
      headerActions: [
        WebStatsBarLink(
          label: '크루원 시즌 랭킹',
          // 바로 아래 시즌 탭·드롭다운 글자와 같은 15(사용자 확정).
          fontSize: 15,
          onTap: () => Get.toNamed(
              '${WebRoutes.crewSeasonRanking}?id=$_crewId&season=${_vm.season}'),
        ),
      ],
      // 목업(174:59963) 콘텐츠 폭 874 — 크루홈 본문과 같아서 라이딩 통계 카드가
      // 두 화면에서 같은 크기로 보인다.
      maxWidth: kCrewHomeListMaxWidth,
      fallbackRoute: '${WebRoutes.crewHome}?id=$_crewId',
      child: Obx(_buildBody),
    );
  }

  Widget _buildBody() {
    // ⚠️ 분기 전에 관찰값을 모두 읽어야 Obx 구독이 확실히 걸린다(뒤로 미루면 놓친다).
    final isInitialLoading = _vm.isInitialLoading;
    final hasError = _vm.hasError;
    final records = _vm.records.toList();
    final stats = _vm.stats;
    final info = _vm.info;
    final season = _vm.season;
    final selectedSeason = crewRecordSeasons()
        .firstWhere((s) => s.dbSeason == season, orElse: () => crewRecordSeasons().first);

    if (_crewId == null) {
      return const WebEmptyState(message: '크루 정보를 찾을 수 없어요.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 일별 현황과 같은 텍스트 탭(목업). 라벨은 랭킹 기록실 관례를 따른다
        // ('25/26시즌' → '25/26 시즌').
        Align(
          alignment: Alignment.centerLeft,
          // PC·태블릿은 텍스트 탭(목업 174:60828 — 글줄 19, 1×15 세로선, 간격 10),
          // **모바일은 드롭다운**(목업 174:73678 — 세 시즌을 한 줄에 못 넣는다).
          child: SizedBox(
            height: 36,
            child: Align(
              alignment: Alignment.centerLeft,
              child: context.screenType == WebScreenType.mobile
                  ? WebDropdownTextButton<RankingFilter_season>(
                      label: _seasonLabel(selectedSeason),
                      values: crewRecordSeasons(),
                      labelOf: _seasonLabel,
                      onSelected: (s) => _vm.setSeason(s.dbSeason),
                      title: '시즌',
                      // 꺾쇠는 공용 기본 18보다 크게 — 목업의 11×5 벡터에 맞추면 22쯤이다.
                      // 공용 기본값은 커뮤니티·중고거래가 같이 쓰므로 호출부에서만 키운다.
                      iconSize: 22,
                    )
                  : WebTextTabs<RankingFilter_season>(
                      values: crewRecordSeasons(),
                      selected: selectedSeason,
                      labelOf: _seasonLabel,
                      onSelected: (s) => _vm.setSeason(s.dbSeason),
                      lineDivider: true,
                      dividerGap: 10,
                    ),
            ),
          ),
        ),
        // 시즌 탭 ↔ 요약 바 — PC 40(목업 174:60434) / 태블릿·모바일 22(174:65716).
        SizedBox(height: context.isDesktop ? 40 : 16),
        // 첫 프레임(로드 시작 전)에도 0점 요약이 번쩍이지 않게 스켈레톤을 보여준다.
        if (info == null)
          hasError ? WebErrorState(onRetry: _vm.refreshSeason) : const _RecordRoomSkeleton()
        else ...[
          CrewRecordSummaryCard(
            overallRank: stats?.overallRank,
            totalScore: stats?.overallTotalScore,
          ),
          // 요약 바 ↔ 섹션 제목 40 (목업 — 바 끝 319, 제목 359).
          const SizedBox(height: 40),
          CrewHomeRidingStatsWeb(
            season: stats,
            crewName: info.crewName ?? '',
            crewLogoUrl: info.crewLogoUrl,
            crewColor: info.color,
            sectionTitle: '시즌 라이딩 통계',
          ),
          // 라이딩 통계 ↔ 첫 월 섹션 40 (목업 — 카드 끝 717, 월 제목 757).
          const SizedBox(height: 40),
          if (records.isEmpty)
            // 첫 조회 전에도 스켈레톤을 보여준다(빈 상태가 번쩍이지 않게).
            isInitialLoading
                ? const CrewRecordListSkeleton()
                : const WebEmptyState(message: '이 시즌 기록이 없어요.')
          else
            CrewRecordMonthList(
              // 시즌을 바꾸면 펼침 상태를 새로 시작한다.
              key: ValueKey('season-$season'),
              records: records,
              crewName: info.crewName,
              resortName: info.baseResortFullname ?? info.baseResortNickname,
            ),
        ],
      ],
    );
  }
}

class _RecordRoomSkeleton extends StatelessWidget {
  const _RecordRoomSkeleton();

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ⚠️ 색은 SkeletonShimmer가 입힌다 — 안 감싸면 흰 배경에 흰 박스다.
        // 자리값은 **실제 레이아웃과 같은 수치**로 둔다(요약 바 54 / 모바일 73,
        // 섹션 제목 줄 36, 라이딩 통계 카드 310).
        SkeletonShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SkeletonBox(height: isMobile ? 73 : 54, radius: 16),
              const SizedBox(height: 40),
              SizedBox(
                height: 36,
                child: Row(
                  children: const [
                    SkeletonBox(width: 110, height: 19),
                    Spacer(),
                    SkeletonBox(width: 109, height: 36, radius: 6),
                  ],
                ),
              ),
              const SizedBox(height: 12),
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
                  children: const [
                    Expanded(flex: 423, child: SkeletonBox(height: 310, radius: 16)),
                    SizedBox(width: 21),
                    Expanded(flex: 430, child: SkeletonBox(height: 310, radius: 16)),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        // 단독으로도 쓰이는 위젯이라 자기 shimmer를 갖고 있다.
        const CrewRecordListSkeleton(),
      ],
    );
  }
}
