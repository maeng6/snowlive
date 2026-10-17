import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:com.snowlive/web/view/home/w_home_hero_web.dart';
import 'package:com.snowlive/web/view/home/w_home_quick_menu_web.dart';
import 'package:com.snowlive/web/view/home/w_home_open_chat_web.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart';
import 'package:com.snowlive/web/view/home/w_home_weather_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/home/vm_home_web.dart';
import 'package:com.snowlive/web/viewmodel/paid/vm_paidVisibility_web.dart';
import 'package:com.snowlive/web/widget/w_web_sticky_footer_scroll_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 웹 홈.
///
/// 섹션 순서 — 배너 / 날씨 / 오늘의 랭킹 / 중고거래 / 커뮤니티 / 우리 크루는요 / 푸터.
/// 우측 하단 오픈 채팅은 스크롤에 따라 바 ↔ 아이콘으로 바뀐다.
class HomeViewWeb extends StatefulWidget {
  const HomeViewWeb({super.key});

  @override
  State<HomeViewWeb> createState() => _HomeViewWebState();
}

class _HomeViewWebState extends State<HomeViewWeb> {
  final HomeViewModelWeb _vm = Get.find<HomeViewModelWeb>();
  final AuthCheckViewModelWeb _authVm = Get.find<AuthCheckViewModelWeb>();
  final ScrollController _scrollController = ScrollController();

  /// 오픈 채팅을 아이콘으로 줄일지(스크롤 여부).
  // 스크롤 중 setState로 홈 전체를 재빌드하면 버벅인다 → 오픈채팅만 반응하도록
  // ValueNotifier로 들고, 그 부분만 ValueListenableBuilder로 다시 그린다.
  final ValueNotifier<bool> _isScrolled = ValueNotifier<bool>(false);

  /// 푸터가 뷰포트에 들어오면 오픈 채팅을 푸터 위 20px까지 밀어 올린다.
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _footerKey = GlobalKey();
  final GlobalKey _chatKey = GlobalKey();
  final ValueNotifier<double> _chatBottomPush = ValueNotifier<double>(0);

  Worker? _authWorker;
  Worker? _scrollTopWorker;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // 자동로그인이 늦게 확정되면 자주 가는 스키장·내 랭킹 기준이 달라진다 → 다시 맞춘다.
    _authWorker = ever(_authVm.statusRx, (_) {
      _vm.syncResortWithUser();
      _vm.loadTodayRanking();
    });
    // 로고·사이드바 `홈`을 다시 누르면 맨 위로(새로고침은 뷰모델이 한다).
    _scrollTopWorker = ever(_vm.scrollToTopTick, (_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _authWorker?.dispose();
    _scrollTopWorker?.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _isScrolled.dispose();
    _chatBottomPush.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > kHomeChatCollapseOffset;
    if (isScrolled != _isScrolled.value) {
      _isScrolled.value = isScrolled; // 오픈채팅만 반응(홈 전체 재빌드 안 함)
    }
    _updateChatBottomPush();
  }

  /// 푸터 상단이 화면 안으로 들어온 만큼 + 20px을 계산한다.
  /// (스크롤 끝에서 오픈 채팅이 푸터를 덮지 않고 그 위에 멈추게)
  /// 단, 오픈 채팅 자신이 뷰포트 위로 밀려나가지는 않게 상한을 둔다.
  void _updateChatBottomPush() {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final footerBox =
        _footerKey.currentContext?.findRenderObject() as RenderBox?;
    final chatBox = _chatKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || footerBox == null) return;
    final double footerTop = footerBox
        .localToGlobal(Offset.zero, ancestor: stackBox)
        .dy;
    double push = stackBox.size.height - footerTop + 20;
    // 위젯(바/패널) 높이만큼은 화면 안에 남긴다.
    final double chatHeight = chatBox?.size.height ?? 0;
    final double maxPush = stackBox.size.height - chatHeight - 20;
    if (push > maxPush) push = maxPush;
    final double next = push > 0 ? push : 0;
    if ((next - _chatBottomPush.value).abs() > 0.5) {
      _chatBottomPush.value = next; // 오픈채팅 위치만 갱신(홈 전체 재빌드 안 함)
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;
    final isMobile = screenType == WebScreenType.mobile;
    // 홈 본문 섹션 사이 간격 — 랭킹 아래(중고거래 위)부터 전부 40(사용자 확정).
    // 예전에는 PC·태블릿 48 / 모바일 32였다.
    const sectionGap = 40.0;
    // 여백: PC 40 / 태블릿 20 / 모바일 16 (피그마 기준).
    final horizontal = switch (screenType) {
      WebScreenType.desktop => 40.0,
      WebScreenType.tablet => 20.0,
      WebScreenType.mobile => SDSSpacing.md,
    };

    return Stack(
      key: _stackKey,
      children: [
        Positioned.fill(
          // 콘텐츠가 짧으면 푸터가 뷰포트 하단에 붙는다(공통 골격).
          // 패딩은 1280 박스 안쪽 구조를 유지해야 해서(폭이 변하면 안 됨)
          // 래퍼 패딩 대신 content/footer 각자의 Padding으로 나눠 든다.
          child: WebStickyFooterScroll(
            controller: _scrollController,
            onRefresh: _vm.refreshAll, // 당겨서 새로고침
            // 푸터를 콘텐츠 바로 아래에 붙인다(크루 카드↔푸터 사이 공백 제거).
            pinFooterToBottom: false,

            content: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: kHomeMaxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 최상단 히어로 캐러셀 — Firestore `banner/homeHeroWeb` 데이터.
                    //
                    // ⚠️ 모바일은 **패딩 바깥**에 둔다 — 상단·좌우 여백 없이 화면
                    // 끝까지 꽉 차야 해서다(사용자 확정). 그래서 아래 본문 Padding을
                    // 히어로와 나눠 든다.
                    if (isMobile)
                      Obx(
                        () => HomeHeroWeb(
                          banners: _vm.banners,
                          isLoaded: _vm.isBannerLoaded,
                        ),
                      ),
                    Padding(
                      // 상하 여백도 좌우와 동일 규칙(PC 40 / 태블릿 20 / 모바일 16).
                      // 모바일은 히어로가 위를 덮으므로 상단 여백을 주지 않는다.
                      padding: EdgeInsets.fromLTRB(
                        horizontal,
                        isMobile ? 0 : horizontal,
                        horizontal,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isMobile)
                            Obx(
                              () => HomeHeroWeb(
                                banners: _vm.banners,
                                isLoaded: _vm.isBannerLoaded,
                              ),
                            ),
                          // 히어로 ↔ 다음 블록 — PC는 퀵메뉴가 없어 날씨가 바로
                          // 붙으므로 40, 태블릿·모바일은 **히어로 ↔ 퀵메뉴 24**
                          // (모두 사용자 확정).
                          SizedBox(
                            height: screenType == WebScreenType.desktop
                                ? 40
                                : 24,
                          ),
                          // 퀵메뉴 — 태블릿·모바일만(데스크탑은 좌측 사이드바가 그 역할).
                          // **히어로 바로 아래**(사용자 확정). 모바일은 히어로가 없어
                          // 콘텐츠 맨 위에 온다.
                          if (screenType != WebScreenType.desktop) ...[
                            const HomeQuickMenuWeb(),
                            // 퀵메뉴 ↔ 날씨 24.
                            const SizedBox(height: 24),
                          ],
                          Obx(
                            () => HomeWeatherBarWeb(
                              resort: _vm.resort,
                              weather: _vm.weather,
                              isLoading: _vm.isWeatherLoading,
                              onResortSelected: _vm.selectResort,
                              linkUrls: _vm.resortLinks, // 셔틀 등 링크는 DB값 우선
                            ),
                          ),
                          // 순서: 오늘의 랭킹 → 중고거래 → 커뮤니티 → 우리 크루는요.
                          // 오늘의 랭킹은 어드민 토글(비시즌 등)로 끄면 숨김(테스트 대상은 노출)
                          //
                          // 날씨 뒤 간격을 이 Obx **안에서** 만든다 — 랭킹이 숨겨질 때
                          // 바깥에 고정 간격을 두면 중고거래 위만 좁아졌다(사용자 지적).
                          //  · 랭킹 보임: 날씨 30 랭킹, 랭킹 아래는 섹션 간격
                          //  · 랭킹 숨김: 날씨 아래가 바로 섹션 간격
                          // → 어느 경우든 **중고거래 위는 섹션 간격**(PC·태블릿 48 /
                          //   모바일 32)으로 다른 섹션 사이와 같다
                          Obx(
                            () =>
                                PaidVisibilityControllerWeb.todayRankingVisible
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // 날씨 ↔ 오늘의 랭킹 30(한 묶음처럼 붙인다).
                                      const SizedBox(height: 30),
                                      HomeTodayRankingWeb(
                                        today: _vm.today,
                                        indiv: _vm.todayIndiv,
                                        crew: _vm.todayCrew,
                                        isLoading: _vm.isRankingLoading,
                                      ),
                                      const SizedBox(height: sectionGap),
                                    ],
                                  )
                                : const SizedBox(height: sectionGap),
                          ),
                          // 중고거래
                          Obx(
                            () => HomeFleamarketWeb(
                              items: _vm.fleamarket,
                              isLoading: _vm.isFleamarketLoading,
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          // 커뮤니티
                          Obx(
                            () => HomeCommunityWeb(
                              posts: _vm.community,
                              isLoading: _vm.isCommunityLoading,
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          // 각종소식 — 커뮤니티 아래로 배치(사용자 요청), 같은 가로 그리드.
                          Obx(
                            () => HomeEventWeb(
                              items: _vm.events,
                              isLoading: _vm.isEventLoading,
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          Obx(
                            () => HomeCrewCardsWeb(
                              cards: _vm.crewCards,
                              isLoading: _vm.isCrewLoading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 콘텐츠 ↔ 푸터 간격(위 pinFooterToBottom:false라 푸터가 콘텐츠 바로 아래).
            footer: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: kHomeMaxContentWidth,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    48,
                    horizontal,
                    horizontal,
                  ),
                  child: HomeFooterWeb(key: _footerKey),
                ),
              ),
            ),
          ),
        ),
        // 오픈 채팅은 스크롤과 무관하게 우측 하단에 떠 있는다.
        // 스크롤 끝에서는 푸터 위 20px에서 멈춘다(_chatBottomPush).
        // ⚠️ Positioned.fill + ValueListenableBuilder로 감싸, 스크롤 시 **이 부분만**
        // 다시 그린다(홈 전체 재빌드 방지 = 스크롤 버벅임 해결). 빈 영역은 포인터를
        // 가로채지 않아 뒤 스크롤은 그대로 동작한다.
        Positioned.fill(
          child: ValueListenableBuilder<double>(
            valueListenable: _chatBottomPush,
            builder: (context, push, _) {
              final bottom = horizontal > push ? horizontal : push;
              return Padding(
                padding: EdgeInsets.only(
                  right: horizontal,
                  bottom: bottom,
                  left: isMobile ? horizontal : 0,
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    key: _chatKey,
                    width: isMobile ? double.infinity : kHomeChatWidth,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isScrolled,
                      builder: (context, scrolled, _) =>
                          HomeOpenChatWeb(isScrolled: scrolled),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 홈 콘텐츠 최대폭(콘텐츠 1280(웹 공통) + 좌우 여백 40*2).
/// 홈은 좌우 패딩이 ConstrainedBox 안쪽에 있어서 여백 몫 80을 더해 둔다.
const double kHomeMaxContentWidth = kWebDesktopListMaxWidth + 80;

/// 오픈 채팅 바·패널 폭(데스크탑·태블릿, 피그마 328)
const double kHomeChatWidth = 328;
