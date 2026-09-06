import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewMemberRankingList.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_member_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewDetail_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_numbered_pagination_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double kCrewMembersContentMaxWidth = 1136;

/// 한 페이지에 보여줄 멤버 수(목업 데스크탑 2열 × 24행).
const int kCrewMembersPerPage = 48;

/// 크루 멤버 전체 목록. `#/livecrew-members?id=334`
///
/// 서버 멤버 랭킹 API에는 페이지네이션이 없다(전체를 한 번에 준다) →
/// **클라이언트에서 잘라** 목업의 번호식 페이지네이션을 만든다.
class CrewMembersViewWeb extends StatefulWidget {
  const CrewMembersViewWeb({super.key});

  @override
  State<CrewMembersViewWeb> createState() => _CrewMembersViewWebState();
}

class _CrewMembersViewWebState extends State<CrewMembersViewWeb> {
  final CrewDetailViewModelWeb _vm = Get.find<CrewDetailViewModelWeb>();

  int? _crewId;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _crewId = int.tryParse(Get.parameters['id'] ?? '');
    final id = _crewId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 크루홈에서 넘어왔으면 이미 로드돼 있다 → 같은 크루면 다시 받지 않는다.
        if (mounted && _vm.crewId != id) _vm.load(id);
      });
    }
  }

  void _goBack() {
    // URL 직접 진입이라 돌아갈 화면이 없으면 크루홈으로 보낸다.
    if (Navigator.of(context).canPop()) {
      Get.back();
      return;
    }
    Get.offAllNamed('${WebRoutes.crewHome}?id=$_crewId');
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
            constraints: const BoxConstraints(maxWidth: kCrewMembersContentMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: _goBack,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.arrow_back, size: 24, color: SDSColor.gray900),
                      ),
                    ),
                    const SizedBox(width: SDSSpacing.sm),
                    Text(
                      '멤버',
                      style: SDSTextStyle.extraBold.copyWith(fontSize: 28, color: SDSColor.gray900),
                    ),
                  ],
                ),
                const SizedBox(height: SDSSpacing.xl),
                Obx(_buildList),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    final members = _vm.members;
    final isLoading = _vm.isLoading;
    final hasError = _vm.hasError;
    final count = members.length;

    if (count == 0) {
      if (hasError) return WebErrorState(onRetry: _vm.refresh);
      if (isLoading) return const RankingListSkeleton();
      return const WebEmptyState(message: '아직 멤버 기록이 없어요.');
    }

    final totalPages = (count / kCrewMembersPerPage).ceil();
    final page = _page.clamp(1, totalPages);
    final start = (page - 1) * kCrewMembersPerPage;
    final pageItems = members.sublist(
      start,
      (start + kCrewMembersPerPage).clamp(0, count),
    );

    final columns = context.isDesktop ? 2 : 1;
    final perColumn = (pageItems.length / columns).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < columns; i++) ...[
              if (i > 0) const SizedBox(width: SDSSpacing.lg),
              Expanded(
                child: Column(
                  children: [
                    for (final member in pageItems.skip(i * perColumn).take(perColumn))
                      CrewMemberRowWeb(member: member, onTap: () => _onMemberTap(member)),
                  ],
                ),
              ),
            ],
          ],
        ),
        if (totalPages > 1) ...[
          const SizedBox(height: SDSSpacing.xl),
          NumberedPaginationBar(
            currentPage: page,
            totalPages: totalPages,
            hasPrevious: page > 1,
            hasNext: page < totalPages,
            pageWindow: _pageWindow(page, totalPages),
            onGotoPage: (next) => setState(() => _page = next),
          ),
        ],
      ],
    );
  }

  /// 번호 버튼으로 보여줄 페이지 범위(목업은 5개). 현재 페이지를 가운데 두되
  /// 양 끝에서는 밀어서 개수를 유지한다.
  List<int> _pageWindow(int page, int totalPages, {int span = 5}) {
    if (totalPages <= span) return [for (var i = 1; i <= totalPages; i++) i];
    var start = page - span ~/ 2;
    if (start < 1) start = 1;
    if (start + span - 1 > totalPages) start = totalPages - span + 1;
    return [for (var i = 0; i < span; i++) start + i];
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
