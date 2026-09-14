import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:com.snowlive/web/view/home/w_home_hero_web.dart';
import 'package:com.snowlive/web/view/home/w_home_open_chat_web.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart';
import 'package:com.snowlive/web/view/home/w_home_weather_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/home/vm_home_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 웹 홈.
///
/// 섹션 순서는 목업 그대로다 — 배너 / 날씨 / 오늘의 랭킹 / 우리 크루는요 / 중고거래 / 푸터.
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
  bool _isScrolled = false;

  /// 푸터가 뷰포트에 들어오면 오픈 채팅을 푸터 위 20px까지 밀어 올린다.
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _footerKey = GlobalKey();
  final GlobalKey _chatKey = GlobalKey();
  double _chatBottomPush = 0;

  Worker? _authWorker;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // 자동로그인이 늦게 확정되면 자주 가는 스키장·내 랭킹 기준이 달라진다 → 다시 맞춘다.
    _authWorker = ever(_authVm.statusRx, (_) {
      _vm.syncResortWithUser();
      _vm.loadTodayRanking();
    });
  }

  @override
  void dispose() {
    _authWorker?.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > kHomeChatCollapseOffset;
    if (isScrolled != _isScrolled) {
      setState(() => _isScrolled = isScrolled);
    }
    _updateChatBottomPush();
  }

  /// 푸터 상단이 화면 안으로 들어온 만큼 + 20px을 계산한다.
  /// (스크롤 끝에서 오픈 채팅이 푸터를 덮지 않고 그 위에 멈추게)
  /// 단, 오픈 채팅 자신이 뷰포트 위로 밀려나가지는 않게 상한을 둔다.
  void _updateChatBottomPush() {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final footerBox = _footerKey.currentContext?.findRenderObject() as RenderBox?;
    final chatBox = _chatKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || footerBox == null) return;
    final double footerTop =
        footerBox.localToGlobal(Offset.zero, ancestor: stackBox).dy;
    double push = stackBox.size.height - footerTop + 20;
    // 위젯(바/패널) 높이만큼은 화면 안에 남긴다.
    final double chatHeight = chatBox?.size.height ?? 0;
    final double maxPush = stackBox.size.height - chatHeight - 20;
    if (push > maxPush) push = maxPush;
    final double next = push > 0 ? push : 0;
    if ((next - _chatBottomPush).abs() > 0.5) {
      setState(() => _chatBottomPush = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;
    final isMobile = screenType == WebScreenType.mobile;
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
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kHomeMaxContentWidth),
                child: Padding(
                  // 상하 여백도 좌우와 동일 규칙(PC 40 / 태블릿 20 / 모바일 16).
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontal,
                    vertical: horizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 최상단 히어로 캐러셀 — Firestore `banner/home` 데이터로 그린다.
                      Obx(() => HomeHeroWeb(
                            banners: _vm.banners,
                            isLoaded: _vm.isBannerLoaded,
                          )),
                      // 히어로 ↔ 날씨 간격: PC 40 / 태블릿 30 / 모바일 16.
                      SizedBox(
                        height: switch (screenType) {
                          WebScreenType.desktop => 40.0,
                          WebScreenType.tablet => 30.0,
                          WebScreenType.mobile => 20,
                        },
                      ),
                      Obx(() => HomeWeatherBarWeb(
                            resort: _vm.resort,
                            weather: _vm.weather,
                            onResortSelected: _vm.selectResort,
                          )),
                      // 날씨 ↔ 오늘의 랭킹 간격 30.
                      SizedBox(height: 30),
                      Obx(() => HomeTodayRankingWeb(
                            today: _vm.today,
                            indiv: _vm.todayIndiv,
                            crew: _vm.todayCrew,
                            isLoading: _vm.isRankingLoading,
                          )),
                      SizedBox(height: isMobile ? SDSSpacing.xl : SDSSpacing.xxl),
                      Obx(() => HomeCrewCardsWeb(
                            cards: _vm.crewCards,
                            isLoading: _vm.isCrewLoading,
                          )),
                      SizedBox(height: isMobile ? SDSSpacing.xl : SDSSpacing.xxl),
                      Obx(() => HomeFleamarketWeb(
                            items: _vm.fleamarket,
                            isLoading: _vm.isFleamarketLoading,
                          )),
                      // 콘텐츠 ↔ 푸터 간격은 항상 120.
                      const SizedBox(height: 120),
                      HomeFooterWeb(key: _footerKey),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // 오픈 채팅은 스크롤과 무관하게 우측 하단에 떠 있는다.
        // 스크롤 끝에서는 푸터 위 20px에서 멈춘다(_chatBottomPush).
        Positioned(
          right: horizontal,
          bottom: horizontal > _chatBottomPush ? horizontal : _chatBottomPush,
          left: isMobile ? horizontal : null,
          child: Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              key: _chatKey,
              width: isMobile ? double.infinity : kHomeChatWidth,
              child: HomeOpenChatWeb(isScrolled: _isScrolled),
            ),
          ),
        ),
      ],
    );
  }
}

/// 홈 콘텐츠 최대폭(콘텐츠 1280 + 좌우 여백 40*2)
const double kHomeMaxContentWidth = 1360;

/// 오픈 채팅 바·패널 폭(데스크탑·태블릿, 피그마 328)
const double kHomeChatWidth = 328;
