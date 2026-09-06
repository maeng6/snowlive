import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/viewmodel/crew/vm_crewHome.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_home_sections_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_crew_modal_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_filter_chips_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_gallery_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_list_grid_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_photo_viewer_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_sidebar_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_top_carousel_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_detail_overlay_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkDetail_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 1440 - GNB 사이드바 240 - 좌우 패딩 32*2 = 1136 (랭킹·커뮤니티와 같은 계산식).
const double kLiveCrewContentMaxWidth = 1136;

/// 라이브크루 홈.
///
/// 네 섹션(일간 슬로프 점령 캐러셀 / 칩 필터 / 크루 목록 / 공개 사진 그리드)이
/// **`GET /api/crew/home/` 응답 하나**에서 나온다. 게스트도 그대로 볼 수 있다.
class LiveCrewHomeViewWeb extends StatefulWidget {
  const LiveCrewHomeViewWeb({super.key});

  @override
  State<LiveCrewHomeViewWeb> createState() => _LiveCrewHomeViewWebState();
}

class _LiveCrewHomeViewWebState extends State<LiveCrewHomeViewWeb> {
  final CrewHomeViewModel _vm = Get.find<CrewHomeViewModel>();
  final UserViewModel _userVm = Get.find<UserViewModel>();

  /// 선택한 칩. 데이터가 오기 전엔 알 수 없으므로 null로 두고 빌드 때 첫 칩으로 정한다.
  CrewHomeChip? _selectedChip;

  /// `스키장별`을 골랐을 때 2단에서 선택한 스키장 칩.
  CrewHomeChip? _selectedResortChip;

  /// 상단 캐러셀에서 보고 있는 주제(좌우 화살표로 넘긴다).
  int _topicIndex = 0;

  @override
  void initState() {
    super.initState();
    // 이 뷰모델은 onInit에서 자동 조회하지 않는다(중복 요청 방지 설계) → 화면이 부른다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.fetchCrewHome();
    });
    // 다른 화면들과 달리 `ever(authVm.statusRx)` 재조회 워커를 두지 않는다 —
    // `crew/home/`은 user_id를 받지 않아 게스트와 로그인 응답이 완전히 같다.
  }

  Future<void> _openLiveTalk(LiveTalk talk) async {
    final id = talk.livetalkId;
    if (id == null) return;
    // 라이브톡 홈의 분기를 그대로 따른다 — 모바일만 별도 화면, 그 외는 오버레이.
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

  Future<void> _onPhotoMoreAction(LiveTalk talk, WebMoreAction action) async {
    final myUserId = _userVm.user.user_id;
    if (myUserId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    final detailVm = Get.find<LiveTalkDetailViewModelWeb>();
    await handleWebMoreAction(
      context,
      action: action,
      // `reportPost`는 **로드된 글**에 동작한다 → 대상 글을 먼저 읽어둔다.
      onReport: () async {
        await detailVm.load(livetalkId: talk.livetalkId!, userId: myUserId);
        return detailVm.reportPost();
      },
      // 숨기기는 대상 유저 id만 있으면 되므로 로드가 필요 없다.
      onHideUser: () => detailVm.blockAuthor(talk.userId),
    );
  }

  void _openPhoto(List<LiveTalk> gallery, Map<int, CrewCard> crewIndex, int index) {
    showLiveCrewPhotoViewer(
      context,
      talks: gallery,
      initialIndex: index,
      crewIndex: crewIndex,
      onOpenLiveTalk: _openLiveTalk,
      onMoreAction: _onPhotoMoreAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '라이브크루',
          style: SDSTextStyle.extraBold.copyWith(fontSize: 28, color: SDSColor.gray900),
        ),
        const SizedBox(height: SDSSpacing.xl),
        Obx(_buildSections),
      ],
    );

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
            constraints: const BoxConstraints(maxWidth: kLiveCrewContentMaxWidth),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: content),
                      const LiveCrewSidebarWeb(),
                    ],
                  )
                : content,
          ),
        ),
      ),
    );
  }

  Widget _buildSections() {
    final home = _vm.home;
    // 세 값을 모두 무조건 읽어야 Obx 구독이 확실히 걸린다(분기 뒤로 미루면 놓친다).
    final isLoading = _vm.isLoading;
    final hasError = _vm.hasError;

    if (home == null) {
      if (hasError) {
        return WebErrorState(onRetry: _vm.refresh);
      }
      return isLoading ? const _LiveCrewSkeleton() : const SizedBox(height: 240);
    }

    final sections = crewHomeSections(home);
    final chips = crewHomeChips(home);
    final selected = _resolveChip(chips);
    final resortChips =
        selected?.kind == CrewHomeChipKind.byResort ? crewHomeResortChips(home) : const <CrewHomeChip>[];
    final selectedResort = _resolveResortChip(resortChips);
    // `스키장별`은 1단 자체에 목록이 없다 → 2단에서 고른 스키장의 크루를 쓴다.
    final gridChip = resortChips.isEmpty ? selected : selectedResort;
    final crews = crewsForChip(home, gridChip);
    final resortFullnames = crewResortFullnames(home);
    final crewIndex = crewIndexOf(home);
    final gallery = crewGalleryTalks(home);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단은 주제 하나만 보여주고 화살표로 넘긴다(사용자 확정).
        if (sections.isNotEmpty) ...[
          Builder(builder: (context) {
            final index = _topicIndex.clamp(0, sections.length - 1);
            final section = sections[index];
            return LiveCrewTopCarouselWeb(
              title: section.title,
              subtitle: section.subtitle,
              emptyMessage: section.emptyMessage,
              crews: section.crews,
              highlightFirst: section.highlightFirst,
              resortFullnames: resortFullnames,
              onCrewTap: (crew) =>
                  showLiveCrewModal(context, crew, resortFullnames: resortFullnames),
              onPrevTopic: index > 0 ? () => setState(() => _topicIndex = index - 1) : null,
              onNextTopic: index < sections.length - 1
                  ? () => setState(() => _topicIndex = index + 1)
                  : null,
            );
          }),
          const SizedBox(height: SDSSpacing.xxl),
        ],
        LiveCrewFilterChipsWeb(
          chips: chips,
          selected: selected,
          onSelected: (chip) => setState(() {
            _selectedChip = chip;
            // 다른 칩으로 옮기면 2단 선택은 버린다(다시 들어오면 첫 스키장부터).
            if (chip.kind != CrewHomeChipKind.byResort) _selectedResortChip = null;
          }),
          resortChips: resortChips,
          selectedResort: selectedResort,
          onResortSelected: (chip) => setState(() => _selectedResortChip = chip),
        ),
        const SizedBox(height: SDSSpacing.lg),
        LiveCrewListGridWeb(
          crews: crews,
          onCrewTap: (crew) => showLiveCrewModal(context, crew, resortFullnames: resortFullnames),
        ),
        // 순위 칩(멤버 많은 순·라이브온 순)은 서버가 상위 30개만 준다. 전체 조회 API가
        // 없어 화면 이동은 못 하므로 30개가 전부가 아니라는 것만 알린다.
        if (crewHomeChipIsRankedTop(gridChip) && crews.isNotEmpty) ...[
          const SizedBox(height: SDSSpacing.md),
          Center(
            child: Text(
              '상위 ${crews.length}개 크루입니다.',
              style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
            ),
          ),
        ],
        // 스키장별 목록은 서버가 리조트별 30개로 잘라 준다 → 30개면 더 있다는 뜻이므로
        // 그 스키장의 크루를 전부 보는 화면으로 갈 길을 만든다.
        if (gridChip != null && crewHomeListIsCapped(gridChip, crews)) ...[
          const SizedBox(height: SDSSpacing.md),
          Center(
            child: OutlinedButton(
              onPressed: () =>
                  Get.toNamed('${WebRoutes.crewJoin}?resort=${gridChip.resortId}'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: SDSColor.gray200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              child: Text(
                '${gridChip.label} 크루 전체보기',
                style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
              ),
            ),
          ),
        ],
        const SizedBox(height: SDSSpacing.xxl),
        LiveCrewGalleryWeb(
          talks: gallery,
          onPhotoTap: (index) => _openPhoto(gallery, crewIndex, index),
        ),
        // 우측 열이 접히는 폭에서는 CTA를 본문 끝으로 옮긴다.
        if (!context.isDesktop) ...[
          const SizedBox(height: SDSSpacing.xl),
          const LiveCrewCtaButtons(),
        ],
      ],
    );
  }

  /// 선택 칩 결정. 아직 안 골랐거나 (데이터가 바뀌어) 사라진 칩이면 첫 칩으로.
  CrewHomeChip? _resolveChip(List<CrewHomeChip> chips) {
    if (chips.isEmpty) return null;
    final current = _selectedChip;
    if (current != null && chips.contains(current)) return current;
    return chips.first;
  }

  /// 2단(스키장) 선택 결정. 같은 규칙으로 첫 스키장을 기본값으로 쓴다.
  CrewHomeChip? _resolveResortChip(List<CrewHomeChip> resortChips) {
    if (resortChips.isEmpty) return null;
    final current = _selectedResortChip;
    if (current != null && resortChips.contains(current)) return current;
    return resortChips.first;
  }
}

class _LiveCrewSkeleton extends StatelessWidget {
  const _LiveCrewSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 캐러셀이 5개라 두 줄 분량만 보여준다(나머지는 스크롤 아래).
          for (var row = 0; row < 2; row++) ...[
            if (row > 0) const SizedBox(height: SDSSpacing.xxl),
            SizedBox(
              height: 186,
              // ListView가 넘치는 카드를 잘라 준다(Row로 두면 좁은 폭에서 오버플로).
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var i = 0; i < 5; i++) ...[
                    if (i > 0) const SizedBox(width: SDSSpacing.md),
                    const SkeletonBox(width: 186, height: 186, radius: 12),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: SDSSpacing.xxl),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < 5; i++) ...[
                  if (i > 0) const SizedBox(width: SDSSpacing.sm),
                  const SkeletonBox(width: 92, height: 38, radius: 50),
                ],
              ],
            ),
          ),
          const SizedBox(height: SDSSpacing.lg),
          for (var i = 0; i < 6; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            const SkeletonBox(height: 44, radius: 8),
          ],
        ],
      ),
    );
  }
}
