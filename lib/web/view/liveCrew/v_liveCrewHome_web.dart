import 'package:com.snowlive/core/api/api_crew.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/viewmodel/crew/vm_crewHome.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_home_sections_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_crew_modal_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_filter_chips_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_gallery_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_list_grid_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_photo_viewer_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_sidebar_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_livecrew_top_carousel_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_detail_overlay_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkDetail_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_floating_bottombar_web.dart';
import 'package:com.snowlive/web/widget/w_web_sticky_footer_scroll_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 크루 목록 열 폭(목업 161:38007 — 240..1114).
const double kLiveCrewListMaxWidth = 874;

/// 목록 + 간격 + 사이드바를 합친 데스크탑 블록 폭.
/// (이전에는 `1440 − GNB 240 − 좌우 32×2`로 역산했는데, GNB는 실제로 200이고
/// 화면폭 역산식은 쓰지 않기로 한 규칙도 어긋났다.)
const double kLiveCrewContentMaxWidth =
    kLiveCrewListMaxWidth + kWebSidebarGap + kWebSidebarWidth;

/// 라이브크루 홈.
///
/// 네 섹션(일간 슬로프 점령 캐러셀 / 칩 필터 / 크루 목록 / 공개 사진 그리드)이
/// **`GET /api/crew/home/` 응답 하나**에서 나온다. 게스트도 그대로 볼 수 있다.
class LiveCrewHomeViewWeb extends StatefulWidget {
  const LiveCrewHomeViewWeb({super.key});

  @override
  State<LiveCrewHomeViewWeb> createState() => _LiveCrewHomeViewWebState();
}

/// 사진 그리드 한 번에 보여줄 장수. PC 5열 기준 4줄 — `사진 더보기`를 누르면
/// 이만큼 더 붙는다.
const int _kGalleryPageSize = 20;

class _LiveCrewHomeViewWebState extends State<LiveCrewHomeViewWeb> {
  final CrewHomeViewModel _vm = Get.find<CrewHomeViewModel>();
  final UserViewModel _userVm = Get.find<UserViewModel>();

  /// 선택한 칩. 데이터가 오기 전엔 알 수 없으므로 null로 두고 빌드 때 첫 칩으로 정한다.
  CrewHomeChip? _selectedChip;

  /// `스키장별 크루` 드롭다운에서 선택한 스키장.
  CrewHomeChip? _selectedResortChip;

  /// 상단 캐러셀에서 보고 있는 주제(좌우 화살표로 넘긴다).
  int _topicIndex = 0;

  /// `우리 이런 크루입니다` 사진 그리드에서 지금까지 그린 장수.
  /// 그리드가 shrinkWrap이라 **보이지 않는 셀까지 한 번에 만들고 이미지 요청도 전부
  /// 나간다** → 20장으로 끊고 `사진 더보기`로 늘린다(서버가 crew_talks를 한 번에
  /// 주므로 추가 요청은 없다).
  int _galleryVisibleCount = _kGalleryPageSize;

  /// 내가 가입한 크루. 있으면 우측 CTA(크루 만들기/가입하기) 자리에 이 크루를 보여준다.
  CrewDetailInfo? _myCrew;

  /// 지금 불러 둔 크루 id — 같은 크루를 중복 조회하지 않는다.
  int? _myCrewLoadedId;

  @override
  void initState() {
    super.initState();
    // 이 뷰모델은 onInit에서 자동 조회하지 않는다(중복 요청 방지 설계) → 화면이 부른다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _vm.fetchCrewHome();
      _syncMyCrew();
    });
    // 홈 데이터는 재조회하지 않는다 — `crew/home/`은 user_id를 받지 않아 게스트와
    // 로그인 응답이 같다. 다만 **내 크루**는 로그인이 확정돼야 알 수 있어 그때 읽는다.
    ever(Get.find<AuthCheckViewModelWeb>().statusRx, (WebAuthStatus status) {
      if (status == WebAuthStatus.checking || !mounted) return;
      _syncMyCrew();
    });
  }

  /// 내 크루 정보를 맞춘다. 크루가 없으면 비우고, 바뀌었으면 다시 받는다.
  Future<void> _syncMyCrew() async {
    final crewId = _userVm.user.crew_id;
    if (crewId == null) {
      if (_myCrew != null || _myCrewLoadedId != null) {
        setState(() {
          _myCrew = null;
          _myCrewLoadedId = null;
        });
      }
      return;
    }
    if (_myCrewLoadedId == crewId) return;
    _myCrewLoadedId = crewId;
    final res = await CrewAPI().getCrewDetails(crewId);
    if (!mounted || !res.success) return;
    setState(() => _myCrew =
        CrewDetailResponse.fromJson(res.data as Map<String, dynamic>).crewDetailInfo);
  }

  Future<void> _openLiveTalk(LiveTalk talk) async {
    final id = talk.livetalkId;
    if (id == null) return;
    // 라이브톡 홈의 분기를 그대로 따른다 — 모바일만 별도 화면, 그 외는 오버레이.
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
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '라이브크루',
          // 홈 타이틀 공통: PC 32 / 태블릿·모바일 24 (중고거래 홈 기준).
          style: SDSTextStyle.extraBold.copyWith(
              fontSize: webHomeTitleSize(context), color: SDSColor.gray900),
        ),
        // 타이틀 ↔ 본문: PC 32 / 좁은 폭 12.
        // 좁은 폭은 바로 아래가 캐러셀 레일인데, 레일이 카드 위아래로 그림자 여유
        // 16씩을 품고 있다 → 목업의 타이틀↔카드 28.5를 맞추려면 12를 줘야 한다.
        SizedBox(height: context.isDesktop ? SDSSpacing.xl : 12),
        Obx(_buildSections),
      ],
    );

    // 콘텐츠가 짧으면 푸터가 뷰포트 하단에 붙는다(공통 골격). 여백은 스크롤
    // 영역 안쪽에 둔다(웹 공통 규칙 — 바깥에 두면 스크롤바가 브라우저 끝에 안 붙는다).
    final isDesktop = context.isDesktop;

    final scroll = WebStickyFooterScroll(
        // 홈 공통 여백(중고거래 홈 기준). 좁은 폭에서는 하단 플로팅 바 뒤로
        // 콘텐츠가 지나가므로 바 높이만큼 더 비운다(중고거래·커뮤니티와 동일).
        padding: webHomePagePadding(
          context,
          bottom: isDesktop ? 32 : kWebFloatingBottomBarHeight + SDSSpacing.md,
        ),
        content: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kLiveCrewContentMaxWidth),
            // 사이드바는 페이지 우측이 아니라 **크루 목록 섹션 옆**에 붙는다(목업) —
            // 캐러셀·사진 그리드는 목록과 같은 874 폭을 쓰고, CTA 버튼만 칩 줄과
            // 같은 선에서 시작한다.
            child: content,
          ),
        ),
        // 홈·목록 화면과 동일한 푸터 — 끝 여백 PC 120 / 그 외 80.
        footer: Column(
          children: [
            SizedBox(height: webFooterTopGap(context)),
            const HomeFooterWeb(),
          ],
        ),
      );

    return Container(
      color: SDSColor.snowliveWhite,
      // 우측 열이 접히는 폭에서는 CTA가 하단 고정 바로 내려간다(목업 161:62309 —
      // 중고거래·커뮤니티와 같은 공용 바).
      child: isDesktop
          ? scroll
          : Stack(
              children: [
                scroll,
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: WebFloatingBottomBar(
                    // 이미 크루가 있으면 만들기·가입하기 대신 **내 크루로 가는 버튼**
                    // 하나만 둔다(한 계정 한 크루).
                    child: _myCrew != null
                        ? WebBottomBarButton(
                            label: '내 크루 보기',
                            background: SDSColor.snowliveBlue,
                            foreground: SDSColor.snowliveWhite,
                            onTap: () => Get.toNamed(
                                '${WebRoutes.crewHome}?id=${_myCrew!.crewId}'),
                          )
                        : Row(
                            children: [
                              // 목업은 왼쪽이 회색 `크루 가입하기`, 오른쪽이 파란 `크루 만들기`다.
                              Expanded(
                                child: WebBottomBarButton(
                                  label: '크루 가입하기',
                                  background: SDSColor.gray100,
                                  foreground: SDSColor.gray900,
                                  onTap: () => Get.toNamed(WebRoutes.crewJoin),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: WebBottomBarButton(
                                  label: '크루 만들기',
                                  background: SDSColor.snowliveBlue,
                                  foreground: SDSColor.snowliveWhite,
                                  onTap: () => Get.toNamed(WebRoutes.crewCreate),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  /// 데스크탑에서 [child] 오른쪽에 CTA 사이드바를 붙인다.
  /// 목업(161:38007)에서 사이드바 상단이 칩 줄과 같은 선이라, 페이지 우측 열이
  /// 아니라 **목록 섹션과 같은 Row**에 둔다.
  /// 데스크탑에서 [child]를 목록 폭(874)으로 제한한다 — 사이드바를 목록 섹션 안으로
  /// 옮기면서 콘텐츠 열이 블록 전체(1154)가 됐는데, 사진 그리드처럼 목업이 874인
  /// 섹션은 목록 선에 맞춰야 한다. 캐러셀은 블록 전체를 쓰므로 감싸지 않는다.
  Widget _listWidth(bool isDesktop, Widget child) => isDesktop
      ? Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(width: kLiveCrewListMaxWidth, child: child),
        )
      : child;

  Widget _withSidebar(bool isDesktop, Widget child) {
    if (!isDesktop) return child;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: child),
        const SizedBox(width: kWebSidebarGap),
        LiveCrewSidebarWeb(myCrew: _myCrew),
      ],
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

    // 크루가 한 곳도 없는 주제(비시즌의 `오늘 라이브온 많은 크루` 등)는 안내 문구를
    // 띄우는 대신 **주제 자체를 뺀다** — 넘겨도 빈 칸만 나오던 것을 없앴다.
    final sections = crewHomeSections(home).where((s) => s.crews.isNotEmpty).toList();
    final chips = crewHomeChips(home);
    final selected = _resolveChip(chips);
    // 스키장 목록은 **항상** 만든다 — `스키장별` 칩이 드롭다운 pill이라 눌리기 전에도
    // 열 목록이 필요하다.
    final resortChips = crewHomeResortChips(home);
    final isByResort = selected?.kind == CrewHomeChipKind.byResort;
    final selectedResort = isByResort ? _resolveResortChip(resortChips) : null;
    // `스키장별`은 칩 자체에 목록이 없다 → 드롭다운에서 고른 스키장의 크루를 쓴다.
    final gridChip = isByResort ? selectedResort : selected;
    final crews = crewsForChip(home, gridChip);
    final resortFullnames = crewResortFullnames(home);
    final crewIndex = crewIndexOf(home);
    final gallery = crewGalleryTalks(home);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단은 주제 하나만 보여주고 화살표로 넘긴다
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
              // 마지막 주제에서 더 넘기면 **처음으로 돌아간다**(양방향 순환) —
              // 끝에서 화살표가 죽어 더 못 보는 것처럼 보이던 걸 없앴다.
              onPrevTopic: sections.length < 2
                  ? null
                  : () => setState(() =>
                      _topicIndex = (index - 1 + sections.length) % sections.length),
              onNextTopic: sections.length < 2
                  ? null
                  : () => setState(() => _topicIndex = (index + 1) % sections.length),
              // 전환 방향·점 인디케이터용.
              topicIndex: index,
              topicCount: sections.length,
              onSelectTopic: (i) => setState(() => _topicIndex = i),
            );
          }),
          // 캐러셀 ↔ `어떤 크루가 있을까요?`: PC 48 / 좁은 폭 60 (목업 — 문구 블록
          // 끝 370, 제목 430). 좁은 폭은 문구가 레일 아래에 와서 더 띄워야 섞이지 않는다.
          SizedBox(height: context.isDesktop ? SDSSpacing.xxl : 60),
        ],
        _withSidebar(
          context.isDesktop,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LiveCrewFilterChipsWeb(
                chips: chips,
          selected: selected,
          onSelected: (chip) => setState(() {
            _selectedChip = chip;
            // 다른 칩으로 옮기면 스키장 선택은 버린다(다시 들어오면 첫 스키장부터).
            if (chip.kind != CrewHomeChipKind.byResort) _selectedResortChip = null;
          }),
                resortChips: resortChips,
                selectedResort: selectedResort,
                onResortSelected: (chip) => setState(() => _selectedResortChip = chip),
              ),
              // 칩 줄 ↔ 목록: PC 24 / 좁은 폭 30 (목업).
              SizedBox(height: context.isDesktop ? SDSSpacing.lg : 20),
              LiveCrewListGridWeb(
                crews: crews,
                onCrewTap: (crew) =>
                    showLiveCrewModal(context, crew, resortFullnames: resortFullnames),
              ),
            ],
          ),
        ),
        // 순위 칩(대형 크루·시즌 최다 라이브온)은 서버가 상위 30개만 준다. 전체 조회 API가
        // 없어 화면 이동은 못 하므로 30개가 전부가 아니라는 것만 알린다
        if (crewHomeChipIsRankedTop(gridChip) && crews.isNotEmpty) ...[
          const SizedBox(height: SDSSpacing.md),
          // 목록 폭(874) 안에서 가운데 — 사이드바까지 포함한 블록 기준으로 잡으면
          // 목록보다 오른쪽으로 치우쳐 보인다
          _listWidth(
            context.isDesktop,
            Center(
              child: Text(
                '상위 ${crews.length}개 크루입니다.',
                style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
              ),
            ),
          ),
        ],
        // 스키장별 목록은 서버가 리조트별 30개로 잘라 준다 → 30개면 더 있다는 뜻이므로
        // 그 스키장의 크루를 전부 보는 화면으로 갈 길을 만든다
        // 가운데 작은 알약 대신 **목록 폭 전체를 쓰는 높이 48 · 라운드 8** 버튼이라
        // 크루 행 하나가 더 붙은 것처럼 읽힌다(= 아래에 더 있다는 신호).
        if (gridChip != null && crewHomeListIsCapped(gridChip, crews)) ...[
          // 목록 ↔ 버튼 26 (기본 16 + 10) — 마지막 행과 너무 붙으면 행처럼 읽힌다.
          const SizedBox(height: 26),
          // 버튼 폭은 **목록(874)** 과 같다 — 사이드바 몫까지 늘리면 목록 오른쪽 선을
          // 넘어가 행의 연장처럼 보이지 않는다.
          _listWidth(
            context.isDesktop,
            _CrewListMoreButton(
              label: '${gridChip.label} 크루 전체보기',
              onTap: () => Get.toNamed('${WebRoutes.crewJoin}?resort=${gridChip.resortId}'),
            ),
          ),
        ],
        // 목록 ↔ `우리 이런 크루입니다` 64 — 다른 구역 간격(48)보다 넓다.
        // 사진 모자이크가 간격 2로 빽빽해서 48에서는 목록에 붙어 보인다.
        const SizedBox(height: 64),
        // 사진 그리드는 목업에서 목록과 같은 874 폭이다(블록 전체가 아니라).
        _listWidth(
          context.isDesktop,
          // 확대 뷰어에는 **전체 목록**을 넘긴다 — 보이는 건 앞쪽 일부지만 인덱스가
          // 그대로 맞고, 뷰어에서는 더보기 없이 끝까지 넘길 수 있다.
          LiveCrewGalleryWeb(
            talks: gallery.take(_galleryVisibleCount).toList(),
            onPhotoTap: (index) => _openPhoto(gallery, crewIndex, index),
          ),
        ),
        if (gallery.length > _galleryVisibleCount) ...[
          // 그리드 ↔ 버튼 26 — 목록의 `○○ 크루 전체보기`와 같은 값.
          // 사진이 간격 2로 빽빽해서 16에서는 그리드에 붙어 보인다.
          const SizedBox(height: 26),
          _listWidth(
            context.isDesktop,
            _CrewListMoreButton(
              label: '사진 더보기',
              onTap: () => setState(() {
                _galleryVisibleCount =
                    (_galleryVisibleCount + _kGalleryPageSize).clamp(0, gallery.length);
              }),
            ),
          ),
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

  /// 스키장 드롭다운 선택 결정. 같은 규칙으로 첫 스키장을 기본값으로 쓴다.
  CrewHomeChip? _resolveResortChip(List<CrewHomeChip> resortChips) {
    if (resortChips.isEmpty) return null;
    final current = _selectedResortChip;
    if (current != null && resortChips.contains(current)) return current;
    return resortChips.first;
  }
}

/// 목록 아래에 붙는 `○○ 크루 전체보기` 버튼. 크루 행과 같은 높이 48 · 라운드 8에
/// 목록 폭을 꽉 채워서 **행이 하나 더 붙은 것처럼** 보이게 한다
class _CrewListMoreButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _CrewListMoreButton({required this.label, required this.onTap});

  @override
  State<_CrewListMoreButton> createState() => _CrewListMoreButtonState();
}

class _CrewListMoreButtonState extends State<_CrewListMoreButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            // 라인 버튼 hover — 테두리는 그대로, 면이 gray50으로 어두워진다(웹 공통).
            color: _hovered ? SDSColor.gray50 : SDSColor.snowliveWhite,
            // 테두리는 버튼 공통값 gray200이 아니라 **gray100** — 바로 위 목록의
            // 열 구분선·로고 테두리와 같은 톤이라야 목록의 연장으로 보인다.
            border: Border.all(color: SDSColor.gray100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveCrewSkeleton extends StatelessWidget {
  const _LiveCrewSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isMobile = context.screenType == WebScreenType.mobile;
    final cardWidth = crewCarouselCardWidth(context);
    final cardHeight = crewCarouselCardHeight(context);
    final railHeight = crewCarouselRailHeight(context);

    // 캐러셀 좌측(PC) / 아래(좁은 폭) 문구 — 제목 두 줄 + 부제 + 점 + 화살표.
    final lead = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLine(width: 220, height: isMobile ? 25 : 27),
        const SizedBox(height: 4),
        SkeletonLine(width: 180, height: isMobile ? 25 : 27),
        SizedBox(height: isDesktop ? 6 : 4),
        const SkeletonLine(width: 160, height: 16),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 5),
              const SkeletonBox(width: 6, height: 6, isCircle: true),
            ],
          ],
        ),
      ],
    );

    // 화살표 두 개(36 원형, 간격 10).
    const arrows = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonBox(width: 36, height: 36, isCircle: true),
        SizedBox(width: 10),
        SkeletonBox(width: 36, height: 36, isCircle: true),
      ],
    );

    final rail = SizedBox(
      height: railHeight,
      // ListView가 넘치는 카드를 잘라 준다(Row로 두면 좁은 폭에서 오버플로).
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var i = 0; i < 8; i++) ...[
            // 카드 사이 — PC·태블릿 16 / 모바일 6 (실제 레일과 동일).
            if (i > 0) SizedBox(width: isMobile ? 6 : SDSSpacing.md),
            Center(
              child: SkeletonBox(width: cardWidth, height: cardHeight, radius: 12),
            ),
          ],
        ],
      ),
    );

    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 캐러셀 — PC는 [문구 | 레일], 좁은 폭은 [레일(풀블리드)] 위 [문구 + 화살표].
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 279, child: lead),
                Expanded(child: rail),
              ],
            )
          else ...[
            _fullBleed(context, rail, height: railHeight),
            SizedBox(height: isMobile ? 8 : 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: lead),
                const SizedBox(width: SDSSpacing.md),
                arrows,
              ],
            ),
          ],
          // 캐러셀 ↔ `어떤 크루가 있을까요?`: PC 48 / 좁은 폭 60 (실제와 동일).
          SizedBox(height: isDesktop ? SDSSpacing.xxl : 60),
          const SkeletonLine(width: 140, height: 19),
          // 제목 ↔ 칩: PC 16 / 좁은 폭 20.
          SizedBox(height: isDesktop ? SDSSpacing.md : 20),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final width in const [116, 84, 128, 112, 108]) ...[
                  if (width != 116) const SizedBox(width: SDSSpacing.sm),
                  SkeletonBox(width: width.toDouble(), height: 36, radius: 50),
                ],
              ],
            ),
          ),
          // 칩 ↔ 목록: PC 24 / 좁은 폭 30.
          SizedBox(height: isDesktop ? SDSSpacing.lg : 30),
          isDesktop ? _desktopListSkeleton() : _pagerListSkeleton(context),
          // 목록 ↔ `우리 이런 크루입니다` 64, 제목 ↔ 사진 16 (실제와 동일).
          const SizedBox(height: 64),
          const SkeletonLine(width: 140, height: 19),
          const SizedBox(height: 16),
          _gallerySkeleton(context),
        ],
      ),
    );
  }

  /// PC 목록 — 3열 × 10행을 한 화면에 그린다(실제와 같은 구성).
  Widget _desktopListSkeleton() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var c = 0; c < 3; c++) ...[
            if (c > 0) const SizedBox(width: kCrewDesktopColumnGutter),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var r = 0; r < kCrewRowsPerColumn; r++) ...[
                    if (r > 0) const SizedBox(height: kCrewRowGap),
                    const SkeletonBox(height: kCrewRowHeight, radius: 8),
                  ],
                ],
              ),
            ),
          ],
        ],
      );

  /// 좁은 폭 목록 — 실제는 가로 스와이프라, 스켈레톤도 **같은 열 폭으로 풀블리드**에
  /// 깔고 다음 열이 걸쳐 보이게 둔다(스크롤은 하지 않는다).
  Widget _pagerListSkeleton(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = crewNarrowColumnWidth(context, constraints.maxWidth);
        final gutter = crewColumnGutter(context);
        final screenWidth = MediaQuery.sizeOf(context).width;
        final pagePadding = ((screenWidth - constraints.maxWidth) / 2).clamp(0.0, 40.0);

        return _fullBleed(
          context,
          ClipRect(
            child: Padding(
              padding: EdgeInsets.only(left: pagePadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 보이는 열 + 걸쳐 보이는 다음 열까지만 그리면 충분하다.
                  for (var c = 0; c < crewVisibleColumns(context) + 1; c++) ...[
                    if (c > 0) SizedBox(width: gutter),
                    SizedBox(
                      width: columnWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var r = 0; r < kCrewRowsPerColumn; r++) ...[
                            if (r > 0) const SizedBox(height: kCrewRowGap),
                            const SkeletonBox(height: kCrewRowHeight, radius: 8),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          height: kCrewPagerHeight,
        );
      },
    );
  }

  /// 사진 그리드 — 실제와 같은 열 수(5·4·2)·간격 2·셀 비율.
  Widget _gallerySkeleton(BuildContext context) {
    final columns = switch (context.screenType) {
      WebScreenType.desktop => 5,
      WebScreenType.tablet => 4,
      WebScreenType.mobile => 2,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 2.0;
        final cellWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final cellHeight = cellWidth * (175.8 / 173.2);
        return Column(
          children: [
            for (var row = 0; row < 2; row++) ...[
              if (row > 0) const SizedBox(height: spacing),
              Row(
                children: [
                  for (var c = 0; c < columns; c++) ...[
                    if (c > 0) const SizedBox(width: spacing),
                    SkeletonBox(width: cellWidth, height: cellHeight, radius: 0),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  /// 페이지 여백 밖(화면 좌우 끝)까지 넓힌다 — 실제 레일·목록과 같은 처리.
  /// ⚠️ 높이를 못 박지 않으면 OverflowBox 자식이 아예 안 그려진다.
  Widget _fullBleed(BuildContext context, Widget child, {required double height}) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return SizedBox(
      height: height,
      child: OverflowBox(
        minWidth: screenWidth,
        maxWidth: screenWidth,
        minHeight: height,
        maxHeight: height,
        child: child,
      ),
    );
  }
}
