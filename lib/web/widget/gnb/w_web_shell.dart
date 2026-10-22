import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/web_profile_nav_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/w_home_open_chat_web.dart';
import 'package:com.snowlive/web/viewmodel/home/vm_openChat_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_current_route_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_desktop_topbar.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_drawer.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_sidebar.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_topbar.dart';
import 'package:com.snowlive/web/widget/w_top_loading_bar_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 모든 웹 페이지를 감싸는 최상위 셸. 데스크탑에서는 좌측 사이드바,
/// 태블릿/모바일에서는 상단바 + (앱바 아래로 뜨는) 전체 화면 메뉴로 렌더링한다.
class WebAppShell extends StatefulWidget {
  final Widget child;

  const WebAppShell({super.key, required this.child});

  @override
  State<WebAppShell> createState() => _WebAppShellState();
}

class _WebAppShellState extends State<WebAppShell>
    with SingleTickerProviderStateMixin {
  /// 햄버거↔X 모프와 패널 페이드를 함께 구동한다.
  late final AnimationController _menuCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  /// 라우트가 바뀌면 메뉴 패널을 닫는다.
  ///
  /// 패널은 라우트가 아니라 **셸의 Stack 위층**이라, 패널 위에서 뜬 팝업
  /// (아바타를 눌러 뜨는 프로필 미리보기 등)이 `Get.toNamed`로 화면을 바꿔도
  /// 패널이 그대로 덮고 있어 "이동했는데 아무 일도 안 일어난 것"처럼 보였다.
  /// 패널 안의 메뉴 항목들은 각자 `onClose`를 부르지만, 패널 **위에 뜬 팝업**은
  /// 패널 상태를 모르므로 여기서 라우트를 보고 닫는다.
  late final Worker _routeWorker;

  /// 같은 라우트로 **교체**되는 이동(프로필→프로필)은 라우트명이 그대로라
  /// [currentRouteWeb]이 안 바뀐다 → 공용 네비 헬퍼의 신호도 함께 구독한다.
  late final Worker _navWorker;

  @override
  void initState() {
    super.initState();
    void closeIfOpen(_) {
      if (mounted && !_menuCtrl.isDismissed) _closeMenu();
    }

    _routeWorker = ever(currentRouteWeb, closeIfOpen);
    _navWorker = ever(webRouteNavigationTick, closeIfOpen);
  }

  void _toggleMenu() {
    if (_menuCtrl.isDismissed || _menuCtrl.status == AnimationStatus.reverse) {
      _menuCtrl.forward();
    } else {
      _menuCtrl.reverse();
    }
  }

  void _closeMenu() => _menuCtrl.reverse();

  @override
  void dispose() {
    _routeWorker.dispose();
    _navWorker.dispose();
    _menuCtrl.dispose();
    _chatScrolled.dispose();
    super.dispose();
  }

  /// 브라우저 창 크기 조절이나 모바일 키보드 전환 중에는 뷰포트 높이가 한 프레임
  /// 동안 몇 px까지 떨어질 수 있다. 셸은 로딩바(2)+상단바(56)를 고정 높이로 깔기
  /// 때문에 그보다 낮으면 RenderFlex 오버플로우 에러가 난다 — 그런 순간에는
  /// 고정 영역만큼 최소 높이를 보장하고 넘치는 부분은 잘라서 에러 없이 그린다.
  Widget _minHeightGuard({required double minHeight, required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight >= minHeight) return child;
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            minHeight: minHeight,
            maxHeight: minHeight,
            child: child,
          ),
        );
      },
    );
  }

  /// TopLoadingBar가 로딩 여부와 무관하게 항상 차지하는 높이.
  static const double _loadingBarHeight = 2;

  /// 데스크탑에서 오픈채팅 바의 폭(홈과 동일).
  static const double _chatWidth = 328;

  /// 오픈채팅은 스크롤 중 아이콘으로 접힌다. 셸이 모든 페이지의 스크롤을
  /// 가로채(NotificationListener) 전역으로 접힘 상태를 공유한다.
  final ValueNotifier<bool> _chatScrolled = ValueNotifier<bool>(false);

  bool _onScrollNotification(ScrollNotification n) {
    if (n.metrics.axis == Axis.vertical) {
      final scrolled = n.metrics.pixels > 8;
      if (scrolled != _chatScrolled.value) _chatScrolled.value = scrolled;
    }
    return false; // 알림을 가로채지 않는다(스크롤은 그대로 동작).
  }

  /// 콘텐츠 위에 오픈채팅을 띄운 Stack. 빈 영역은 포인터를 가로채지 않아
  /// 뒤 콘텐츠 상호작용은 그대로 유지된다.
  Widget _withOpenChat(Widget child, {required bool isMobile}) {
    // 오픈채팅은 이제 전 페이지에 뜨므로, 홈 바인딩이 안 돈 화면에서도
    // 뷰모델이 있도록 여기서 보장한다(홈 전용 바인딩에만 있으면 Get.find가 터진다).
    if (!Get.isRegistered<OpenChatViewModelWeb>()) {
      Get.lazyPut<OpenChatViewModelWeb>(() => OpenChatViewModelWeb(), fenix: true);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: child,
        ),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(
              right: isMobile ? 16 : 24,
              left: isMobile ? 16 : 0,
              bottom: isMobile ? 16 : 24,
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: isMobile ? double.infinity : _chatWidth,
                // 홈에서만 스크롤에 따라 펼침/접힘. 그 외 화면에선 항상 접힌 아이콘.
                child: Obx(() {
                  final r = currentRouteWeb.value;
                  // 로그인 화면에서는 오픈채팅 플로팅 버튼을 숨긴다.
                  if (r == WebRoutes.login) return const SizedBox.shrink();
                  final isHome = r == WebRoutes.home || r == '/';
                  return ValueListenableBuilder<bool>(
                    valueListenable: _chatScrolled,
                    builder: (_, scrolled, __) => HomeOpenChatWeb(
                        isScrolled: isHome ? scrolled : true),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;

    if (screenType == WebScreenType.desktop) {
      return Scaffold(
        body: _minHeightGuard(
          minHeight: _loadingBarHeight + kGnbDesktopTopBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TopLoadingBar(),
              const WebGnbDesktopTopBar(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WebGnbSidebar(),
                    Expanded(child: _withOpenChat(widget.child, isMobile: false)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 진행바는 데스크탑과 동일하게 뷰포트 최상단에 둔다. Scaffold의 appBar 슬롯에
    // 상단바를 넣으면 진행바가 그 아래로 밀려서 최상단이 아니게 되므로, 상단바도
    // body Column 안으로 내린다(WebGnbTopbar 내부가 고정 높이라 그대로 동작한다)
    // 메뉴는 드로어 대신 **앱바 아래 영역**을 덮는 패널로 뜬다.
    final topbar = WebGnbTopbar(
      menuProgress: _menuCtrl,
      onMenuTap: _toggleMenu,
      onLogoTap: _closeMenu,
    );
    return Scaffold(
      body: _minHeightGuard(
        minHeight: _loadingBarHeight + topbar.preferredSize.height,
        child: Column(
          children: [
            const TopLoadingBar(),
            topbar,
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _withOpenChat(widget.child, isMobile: true),
                  // 메뉴 패널은 페이드 없이 바로 뜨고 바로 사라진다.
                  // 아이콘 모프(햄버거↔X)만 컨트롤러로 애니메이션한다.
                  AnimatedBuilder(
                    animation: _menuCtrl,
                    builder: (context, _) {
                      final bool opening =
                          _menuCtrl.status == AnimationStatus.forward ||
                          _menuCtrl.status == AnimationStatus.completed;
                      if (!opening) return const SizedBox.shrink();
                      return WebGnbMenuPanel(onClose: _closeMenu);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
