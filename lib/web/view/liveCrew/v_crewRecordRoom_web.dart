import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList_recordRoom.dart'
    show RankingFilter_season;
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_record_sections_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_record_scaffold_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_record_widgets_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_riding_stats_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewRecord_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
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

  @override
  Widget build(BuildContext context) {
    return CrewRecordScaffoldWeb(
      title: '시즌 기록실',
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
          child: WebTextTabs<RankingFilter_season>(
            values: crewRecordSeasons(),
            selected: crewRecordSeasons()
                .firstWhere((s) => s.dbSeason == season, orElse: () => crewRecordSeasons().first),
            labelOf: (s) => '${s.korean.replaceAll('시즌', '')} 시즌',
            onSelected: (s) => _vm.setSeason(s.dbSeason),
          ),
        ),
        const SizedBox(height: SDSSpacing.lg),
        // 첫 프레임(로드 시작 전)에도 0점 요약이 번쩍이지 않게 스켈레톤을 보여준다.
        if (info == null)
          hasError ? WebErrorState(onRetry: _vm.refreshSeason) : const _RecordRoomSkeleton()
        else ...[
          CrewRecordSummaryCard(
            overallRank: stats?.overallRank,
            totalScore: stats?.overallTotalScore,
            isMobile: context.screenType == WebScreenType.mobile,
            onOpenRanking: () => Get.toNamed(
                '${WebRoutes.crewSeasonRanking}?id=$_crewId&season=$season'),
          ),
          const SizedBox(height: SDSSpacing.xl),
          CrewHomeRidingStatsWeb(
            season: stats,
            crewName: info?.crewName ?? '',
            crewLogoUrl: info?.crewLogoUrl,
          ),
          const SizedBox(height: SDSSpacing.xl),
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
              crewName: info?.crewName,
              resortName: info?.baseResortFullname ?? info?.baseResortNickname,
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonBox(height: 76, radius: 10),
        SizedBox(height: SDSSpacing.xl),
        SkeletonBox(height: 240, radius: 10),
        SizedBox(height: SDSSpacing.xl),
        CrewRecordListSkeleton(),
      ],
    );
  }
}
