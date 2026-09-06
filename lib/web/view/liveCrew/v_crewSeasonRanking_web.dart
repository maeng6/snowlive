import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewMemberRankingList.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_record_sections_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_record_scaffold_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_member_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewRecord_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_numbered_pagination_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 크루원 시즌 랭킹. `#/livecrew-season-ranking?id=334&season=2526`
const double kCrewSeasonRankingMaxWidth = 800;

/// 한 페이지에 보여줄 인원(목업 번호식 페이지네이션).
const int kCrewSeasonRankingPerPage = 30;

const String _kRankingEmptyIcon = 'assets/imgs/icons/icon_no_member.png';

class CrewSeasonRankingViewWeb extends StatefulWidget {
  const CrewSeasonRankingViewWeb({super.key});

  @override
  State<CrewSeasonRankingViewWeb> createState() => _CrewSeasonRankingViewWebState();
}

class _CrewSeasonRankingViewWebState extends State<CrewSeasonRankingViewWeb> {
  final CrewRecordViewModelWeb _vm = Get.find<CrewRecordViewModelWeb>();

  int? _crewId;
  String? _season;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _crewId = int.tryParse(Get.parameters['id'] ?? '');
    _season = Get.parameters['season'];
    final id = _crewId;
    if (id == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final season = _season ?? _vm.season;
      // 기록실에서 넘어왔으면 같은 시즌 랭킹을 이미 갖고 있다 → 다시 받지 않는다.
      final alreadyLoaded =
          _vm.crewId == id && _vm.season == season && _vm.memberRanking.isNotEmpty;
      if (!alreadyLoaded) _vm.loadRanking(id, season: season);
    });
  }

  /// 어느 시즌 랭킹인지 목록 위에 함께 적는다(제목은 목업대로 고정).
  String get _seasonLabel {
    final season = _season ?? _vm.season;
    final matched = crewRecordSeasons().firstWhere(
      (s) => s.dbSeason == season,
      orElse: () => crewRecordSeasons().first,
    );
    return '${matched.korean.replaceAll('시즌', '')} 시즌';
  }

  @override
  Widget build(BuildContext context) {
    return CrewRecordScaffoldWeb(
      title: '크루원 시즌 랭킹',
      maxWidth: kCrewSeasonRankingMaxWidth,
      fallbackRoute: '${WebRoutes.crewRecordRoom}?id=$_crewId',
      child: Obx(_buildBody),
    );
  }

  Widget _buildBody() {
    // 분기 전에 관찰값을 모두 읽는다(Obx 구독).
    final members = _vm.memberRanking.toList();
    final isInitialLoading = _vm.isInitialLoading;
    final hasError = _vm.hasError;

    if (_crewId == null) {
      return const WebEmptyState(message: '크루 정보를 찾을 수 없어요.');
    }
    if (members.isEmpty) {
      // 첫 조회 전에도 스켈레톤을 보여준다(빈 상태가 번쩍이지 않게).
      if (isInitialLoading) return const RankingListSkeleton();
      if (hasError) return WebErrorState(onRetry: () => _vm.loadRanking(_crewId!));
      return const WebEmptyState(
        message: '랭킹전에 참여한 크루원이 없습니다.',
        iconAsset: _kRankingEmptyIcon,
        iconWidth: 96,
        iconFit: BoxFit.contain,
      );
    }

    final totalPages = (members.length / kCrewSeasonRankingPerPage).ceil();
    final page = _page.clamp(1, totalPages);
    final start = (page - 1) * kCrewSeasonRankingPerPage;
    final pageItems = members.sublist(
      start,
      (start + kCrewSeasonRankingPerPage).clamp(0, members.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '크루원 ${members.length}',
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
            ),
            const SizedBox(width: SDSSpacing.sm),
            Text(
              _seasonLabel,
              style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
            ),
          ],
        ),
        const SizedBox(height: SDSSpacing.md),
        for (var i = 0; i < pageItems.length; i++)
          _RankingRow(
            // 서버 `overall_rank`는 전체 랭킹 순위라 크루 안에서는 맞지 않는다 →
            // 목록 순서로 번호를 붙인다(앱과 동일).
            rank: start + i + 1,
            member: pageItems[i],
            onTap: () => _onMemberTap(pageItems[i]),
          ),
        if (totalPages > 1) ...[
          const SizedBox(height: SDSSpacing.xl),
          NumberedPaginationBar(
            currentPage: page,
            totalPages: totalPages,
            hasPrevious: page > 1,
            hasNext: page < totalPages,
            pageWindow: crewRecordPageWindow(page, totalPages),
            onGotoPage: (next) => setState(() => _page = next),
          ),
        ],
      ],
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
}

class _RankingRow extends StatelessWidget {
  final int rank;
  final CrewRanking member;
  final VoidCallback onTap;

  const _RankingRow({required this.rank, required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            '$rank',
            textAlign: TextAlign.center,
            maxLines: 1,
            style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
          ),
        ),
        // 아바타·닉네임·상태메시지·점수·티어는 크루홈·멤버 목록과 같은 줄을 쓴다.
        Expanded(child: CrewMemberRowWeb(member: member, onTap: onTap)),
      ],
    );
  }
}
