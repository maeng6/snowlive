import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/core/model/m_slope_rush.dart';
import 'package:com.snowlive/core/viewmodel/crew/vm_crewHome.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/ranking/w_slopecraft_list_web.dart';
import 'package:com.snowlive/web/view/ranking/w_slopecraft_map_web.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_slopeCraft_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_text_tabs_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 목업 실측 폭(지도 + 점령 현황 두 열).
const double kSlopeCraftContentMaxWidth = 1160;

/// 상단 TOP 5에 보여줄 크루 수.
const int kSlopeCraftTopCrewCount = 5;

enum _SeasonTab { current, past }

/// 슬로프크래프트 — 스키장 지도에서 슬로프별 점령 크루를 본다. `#/slopecraft`
class SlopeCraftViewWeb extends StatefulWidget {
  const SlopeCraftViewWeb({super.key});

  @override
  State<SlopeCraftViewWeb> createState() => _SlopeCraftViewWebState();
}

class _SlopeCraftViewWebState extends State<SlopeCraftViewWeb> {
  final SlopeCraftViewModelWeb _vm = Get.find<SlopeCraftViewModelWeb>();
  final CrewHomeViewModel _crewHomeVm = Get.find<CrewHomeViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _vm.load();
      // TOP 5는 전용 API가 없어 크루홈 집계를 쓴다(사용자 확정). 이미 받아 뒀으면 생략.
      if (_crewHomeVm.home == null && !_crewHomeVm.isLoading) {
        _crewHomeVm.fetchCrewHome();
      }
    });
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
            constraints: const BoxConstraints(maxWidth: kSlopeCraftContentMaxWidth),
            child: Obx(_buildBody),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // ⚠️ 분기 전에 관찰값을 모두 읽어야 Obx 구독이 확실히 걸린다.
    final items = _vm.items.toList();
    final isLoading = _vm.isLoading;
    final hasError = _vm.hasError;
    final isPast = _vm.isPastSeason;
    final season = _vm.season;
    final resortId = _vm.effectiveResortId;
    final selectedKey = _vm.selectedSlopeKey;
    final selectedSlope = _vm.selectedSlope;
    final topCrews = _topCrews();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: SDSSpacing.lg),
        Align(
          alignment: Alignment.centerLeft,
          child: WebTextTabs<_SeasonTab>(
            values: _SeasonTab.values,
            selected: isPast ? _SeasonTab.past : _SeasonTab.current,
            labelOf: (t) => t == _SeasonTab.current ? '현재 시즌' : '지난 시즌 점령 기록',
            onSelected: (t) => _vm.setPastSeason(t == _SeasonTab.past),
          ),
        ),
        if (isPast) ...[
          const SizedBox(height: SDSSpacing.md),
          Row(
            children: [
              for (final entry in SlopeCraftViewModelWeb.kSeasons) ...[
                _SeasonPill(
                  label: entry.label,
                  isActive: entry.season == season,
                  onTap: () => _vm.setSeason(entry.season),
                ),
                const SizedBox(width: SDSSpacing.sm),
              ],
            ],
          ),
        ],
        // TOP 5는 이번 시즌 집계만 있어서 지난 시즌 탭에서는 그리지 않는다(사용자 확정).
        if (!isPast && topCrews.isNotEmpty) ...[
          const SizedBox(height: SDSSpacing.lg),
          SlopeCraftTopCrewsWeb(crews: topCrews),
        ],
        const SizedBox(height: SDSSpacing.xl),
        if (items.isEmpty && isLoading)
          const _SlopeCraftSkeleton()
        else if (items.isEmpty && hasError)
          WebErrorState(onRetry: _vm.load)
        else
          _buildContent(
            resortId: resortId,
            items: items,
            selectedKey: selectedKey,
            selectedSlope: selectedSlope,
          ),
      ],
    );
  }

  Widget _buildHeader() {
    final isMobile = context.screenType == WebScreenType.mobile;
    final title = Text(
      '슬로프크래프트',
      style: SDSTextStyle.extraBold
          .copyWith(fontSize: isMobile ? 22 : 28, color: SDSColor.gray900),
    );
    final note = Text(
      '슬로프에서 가장 최근 라이딩 횟수 500회 기준으로 계산',
      style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 4), note],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [title, const Spacer(), note],
    );
  }

  Widget _buildContent({
    required int resortId,
    required List<SlopeRushItem> items,
    required String? selectedKey,
    required SlopeRushItem? selectedSlope,
  }) {
    final map = SlopeCraftMapWeb(
      resortId: resortId,
      resortName: _vm.resortName,
      items: items,
      selectedSlopeKey: selectedKey,
      slopeKeyOf: _vm.slopeKeyOf,
      leaderOf: _vm.leaderOf,
      onSelectSlope: _vm.toggleSlope,
      onSelectResort: _vm.selectResort,
    );

    final listTitle = selectedSlope == null
        ? '${_vm.resortName} 점령 현황'
        : '${selectedSlope.slopeNickname.isNotEmpty ? selectedSlope.slopeNickname : selectedSlope.slopeFullname} 점령 현황';

    final list = SlopeCraftListWeb(
      title: listTitle,
      items: items,
      selectedSlope: selectedSlope,
      leaderOf: _vm.leaderOf,
      onSlopeTap: (item) {
        final key = _vm.slopeKeyOf(item);
        if (key != null) _vm.toggleSlope(key);
      },
      onShowAll: _vm.clearSlope,
    );

    if (!context.isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [map, const SizedBox(height: SDSSpacing.xl), list],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 4, child: map),
        const SizedBox(width: SDSSpacing.xl),
        Expanded(flex: 3, child: list),
      ],
    );
  }

  /// 크루홈 집계에서 `이번 시즌 슬로프 점령` 상위 5개.
  List<CrewCard> _topCrews() {
    final home = _crewHomeVm.home;
    if (home == null) return const [];
    return home.slopeOccupied.take(kSlopeCraftTopCrewCount).toList();
  }
}

class _SeasonPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SeasonPill({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? SDSColor.snowliveBlack : SDSColor.snowliveWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
        side: BorderSide(color: isActive ? SDSColor.snowliveBlack : SDSColor.gray200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Text(
            label,
            style: SDSTextStyle.bold.copyWith(
              fontSize: 13,
              color: isActive ? SDSColor.snowliveWhite : SDSColor.gray900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SlopeCraftSkeleton extends StatelessWidget {
  const _SlopeCraftSkeleton();

  @override
  Widget build(BuildContext context) {
    final map = const AspectRatio(
      aspectRatio: 780 / 900,
      child: SkeletonBox(radius: 16),
    );
    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SkeletonBox(height: 20, radius: 6),
        const SizedBox(height: SDSSpacing.md),
        for (var i = 0; i < 8; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          const SkeletonBox(height: 44, radius: 8),
        ],
      ],
    );

    return SkeletonShimmer(
      child: context.isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: map),
                const SizedBox(width: SDSSpacing.xl),
                Expanded(flex: 3, child: list),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [map, const SizedBox(height: SDSSpacing.xl), list],
            ),
    );
  }
}
