import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_desktop_topbar.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_drawer.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_sidebar.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_topbar.dart';
import 'package:com.snowlive/web/widget/w_top_loading_bar_web.dart';
import 'package:flutter/material.dart';

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
    _menuCtrl.dispose();
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
                    Expanded(child: widget.child),
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
    // 메뉴는 드로어 대신 **앱바 아래 영역**을 덮는 패널로 뜬다(요청).
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
                  widget.child,
                  // 메뉴 패널은 페이드 없이 바로 뜨고 바로 사라진다(요청).
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
