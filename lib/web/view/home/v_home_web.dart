import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:com.snowlive/web/view/home/w_home_banner_web.dart';
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
    if (isScrolled == _isScrolled) return;
    setState(() => _isScrolled = isScrolled);
  }

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;
    final isMobile = screenType == WebScreenType.mobile;
    final horizontal = isMobile ? SDSSpacing.md : SDSSpacing.lg;

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kHomeMaxContentWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontal,
                    vertical: isMobile ? SDSSpacing.md : SDSSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Obx(() => HomeBannerWeb(banners: _vm.banners, isLoaded: _vm.isBannerLoaded)),
                      SizedBox(height: isMobile ? SDSSpacing.md : SDSSpacing.lg),
                      Obx(() => HomeWeatherBarWeb(
                            resort: _vm.resort,
                            weather: _vm.weather,
                            onResortSelected: _vm.selectResort,
                          )),
                      SizedBox(height: isMobile ? SDSSpacing.md : SDSSpacing.lg),
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
                      SizedBox(height: isMobile ? SDSSpacing.xl : SDSSpacing.xxl),
                      const HomeFooterWeb(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // 오픈 채팅은 스크롤과 무관하게 우측 하단에 떠 있는다.
        Positioned(
          right: horizontal,
          bottom: horizontal,
          left: isMobile ? horizontal : null,
          child: Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              width: isMobile ? double.infinity : kHomeChatWidth,
              child: HomeOpenChatWeb(isScrolled: _isScrolled),
            ),
          ),
        ),
      ],
    );
  }
}

/// 홈 콘텐츠 최대폭(목업 데스크탑 1164 + 좌우 여백).
const double kHomeMaxContentWidth = 1212;

/// 오픈 채팅 바·패널 폭(데스크탑·태블릿).
const double kHomeChatWidth = 340;
