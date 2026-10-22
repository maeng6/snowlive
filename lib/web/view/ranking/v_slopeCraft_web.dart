import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/core/model/m_slope_rush.dart';
import 'package:com.snowlive/core/viewmodel/crew/vm_crewHome.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart'
    show HomeFooterWeb;
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

/// 스켈레톤의 목록 제목 줄 높이(실제 화면과 같다).
const double _kListHeaderHeightSkeleton = 36;

/// 지난 시즌 탭의 시즌 칩 줄 — 탭과의 간격(목업 82:65604)과 그 아래 간격.
const double _kTabsToSeasonChipsGap = 32;
const double _kSeasonChipsToContentGap = 20;

/// 목업 실측 간격(82:64717).
const double _kTabsToTopCrewsGap = 42;
const double _kTopCrewsToContentGap = 48;
const double _kMapToListGap = 40;

enum _SeasonTab { current, past }

/// 슬로프크래프트 — 스키장 지도에서 슬로프별 점령 크루를 본다. `#/slopecraft'
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
      // TOP 5는 전용 API가 없어 크루홈 집계를 쓴다. 이미 받아 뒀으면 생략
      if (_crewHomeVm.home == null && !_crewHomeVm.isLoading) {
        _crewHomeVm.fetchCrewHome();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SDSColor.snowliveWhite,
      // 홈 공통 여백(중고거래 홈 기준).
      // ⚠️ 페이지 여백은 **스크롤 영역 안쪽**에 둔다(웹 공통) — 바깥에 주면
      // 스크롤바가 여백 안쪽에 생겨 브라우저 오른쪽 끝에 붙지 않는다.
      child: SingleChildScrollView(
        padding: webHomePagePadding(context),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: kSlopeCraftContentMaxWidth,
            ),
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
        // 타이틀 ↔ 탭은 라이딩 기록 카드와 같은 40.
        const SizedBox(height: 40),
        Align(
          alignment: Alignment.centerLeft,
          // 목업은 bold 16 · 비활성 gray200 · 1px 세로선 구분자(간격 10) —
          // 라이딩 기록 카드와 같은 공통 스타일이다.
          child: WebTextTabs<_SeasonTab>(
            values: _SeasonTab.values,
            selected: isPast ? _SeasonTab.past : _SeasonTab.current,
            labelOf: (t) => t == _SeasonTab.current ? '현재 시즌' : '지난 시즌 점령 기록',
            onSelected: (t) => _vm.setPastSeason(t == _SeasonTab.past),
            fontSize: 16,
            inactiveBold: true,
            inactiveColor: SDSColor.gray200,
            lineDivider: true,
            dividerGap: 10,
          ),
        ),
        if (isPast) ...[
          // 목업 실측: 탭 ↔ 시즌 칩 줄 32.
          const SizedBox(height: _kTabsToSeasonChipsGap),
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
        // TOP 5는 이번 시즌 집계만 있어서 지난 시즌 탭에서는 그리지 않는다.
        // ⚠️ 목업(82:65604)에는 지난 시즌에도 `25/26 시즌 전체 스키장 점령 TOP 5 크루`
        // 줄이 있지만, 전용 API가 없어 크루홈의 **이번 시즌** 집계를 빌려 쓰는 중이라
        // 그대로 두면 지난 시즌 자리에 이번 시즌 순위가 나온다 → 숨기는 쪽으로 확정.
        // 시즌별 TOP 5 API가 생기면 그때 되살린다.
        if (!isPast && topCrews.isNotEmpty) ...[
          const SizedBox(height: _kTabsToTopCrewsGap),
          SlopeCraftTopCrewsWeb(crews: topCrews),
        ],
        // 지난 시즌 탭은 칩 줄 바로 아래가 지도라 간격을 좁게 둔다(사용자 확정).
        SizedBox(
          height: isPast ? _kSeasonChipsToContentGap : _kTopCrewsToContentGap,
        ),
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
        // 홈·랭킹과 같은 공통 푸터.
        SizedBox(height: webFooterTopGap(context)),
        const HomeFooterWeb(),
      ],
    );
  }

  Widget _buildHeader() {
    final isMobile = context.screenType == WebScreenType.mobile;
    final title = Text(
      '슬로프크래프트',
      // 홈 타이틀 공통: PC 32 / 태블릿·모바일 24 (중고거래 홈 기준).
      style: SDSTextStyle.extraBold.copyWith(
        fontSize: webHomeTitleSize(context),
        color: SDSColor.gray900,
      ),
    );
    final note = Text(
      '슬로프에서 가장 최근 라이딩 횟수 500회 기준으로 계산',
      style: SDSTextStyle.regular.copyWith(
        fontSize: 12,
        color: SDSColor.gray400,
      ),
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
        children: [
          map,
          // PC의 지도↔목록 간격과 같은 값으로 둔다(태블릿·모바일 목업은 아직 없음).
          const SizedBox(height: _kMapToListGap),
          list,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 목업 실측: 지도 640 · 간격 40 · 목록 480(= 1160 안에서 4:3).
        Expanded(flex: 4, child: map),
        const SizedBox(width: _kMapToListGap),
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

  const _SeasonPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 목업 실측(82:66330): 67x36 · 라운드 20 · 패딩 좌14/우12/상하10 ·
    // Bold 14(줄높이 16). 선택은 검정 바탕 + 흰 글자, 비선택은 흰 바탕 +
    // gray100 테두리. hover는 라인 버튼 규칙대로 **면만** 어두워진다.
    return Material(
      color: isActive ? SDSColor.snowliveBlack : SDSColor.snowliveWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isActive ? SDSColor.snowliveBlack : SDSColor.gray100,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: isActive
            ? SDSColor.snowliveWhite.withValues(alpha: 0.12)
            : SDSColor.gray50,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
          child: Text(
            label,
            style: SDSTextStyle.bold.copyWith(
              fontSize: 14,
              height: 16 / 14,
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
    // ⚠️ 바탕색을 직접 칠하지 말 것 — 셰이머가 그 위에 또 회색을 입혀 두 겹이 된다.
    // 다른 조각들처럼 흰 `SkeletonBox`만 두고 색은 셰이머에 맡긴다.
    // 라운드만 실제 지도 카드와 같은 12로 맞춘다.
    const map = AspectRatio(
      aspectRatio: 780 / 900,
      child: SkeletonBox(radius: 12),
    );

    // 목록: 제목 줄 36 + (줄 48 · 줄 사이 12).
    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SkeletonBox(height: _kListHeaderHeightSkeleton, radius: 6),
        const SizedBox(height: 16),
        for (var i = 0; i < 8; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          const SkeletonBox(height: 48, radius: 8),
        ],
      ],
    );

    return SkeletonShimmer(
      child: context.isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: map),
                const SizedBox(width: _kMapToListGap),
                Expanded(flex: 3, child: list),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                map,
                const SizedBox(height: _kMapToListGap),
                list,
              ],
            ),
    );
  }
}
