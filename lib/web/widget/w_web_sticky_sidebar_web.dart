import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 화면 상단에서 사이드바가 멈춰 따라붙는 기본 여백(사용자 확정).
const double kWebStickySidebarTop = 30;

/// 스크롤을 내려도 사이드바가 화면 상단 [stickyTop]에 **멈춰 따라붙게** 한다.
/// 콘텐츠 열만 계속 올라간다.
///
/// 레이아웃이 아니라 [Transform]으로 밀기 때문에 옆 콘텐츠 열의 높이·폭에
/// 영향을 주지 않는다(사이드바를 스크롤뷰 바깥으로 빼면 페이지 스크롤바가
/// 브라우저 우측 끝에서 떨어지므로 그렇게 하지 않는다).
///
/// 사이드바가 화면보다 길면 끝까지 따라붙지 못한다 — 아래가 잘리지 않도록
/// **자기 바닥이 화면 아래에 닿는 지점까지만** 밀린다.
class WebStickySidebar extends StatefulWidget {
  /// 페이지 스크롤뷰의 컨트롤러.
  final ScrollController controller;

  /// 문서 좌표에서 사이드바가 원래 시작하는 y(= 페이지 상단 여백 + 자체 오프셋).
  final double naturalTop;

  /// 멈춰 붙을 화면 상단 여백.
  final double stickyTop;

  /// 사이드바가 길어 바닥을 맞출 때 화면 아래에 남길 여백.
  final double bottomGap;

  final Widget child;

  const WebStickySidebar({
    super.key,
    required this.controller,
    required this.naturalTop,
    required this.child,
    this.stickyTop = kWebStickySidebarTop,
    this.bottomGap = kWebStickySidebarTop,
  });

  @override
  State<WebStickySidebar> createState() => _WebStickySidebarState();
}

class _WebStickySidebarState extends State<WebStickySidebar> {
  final GlobalKey _childKey = GlobalKey();

  /// 실측 높이. 화면보다 긴지 판단하는 데만 쓴다(모르면 짧다고 본다).
  double? _height;

  void _measure() {
    final box = _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    if (_height != box.size.height) {
      setState(() => _height = box.size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 내용이 바뀌면 높이도 바뀐다 — 매 프레임 뒤에 다시 잰다(값이 같으면 no-op).
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());

    final viewport = MediaQuery.sizeOf(context).height;
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final offset =
            widget.controller.hasClients ? widget.controller.offset : 0.0;
        // 아무것도 안 밀었을 때 사이드바 상단이 화면에서 보이는 위치.
        final natural = widget.naturalTop - offset;

        final height = _height;
        final fits = height == null ||
            height <= viewport - widget.stickyTop - widget.bottomGap;
        // 짧으면 상단에, 길면 바닥이 보이는 자리에 멈춘다.
        final pinned = fits
            ? widget.stickyTop
            : viewport - widget.bottomGap - height;

        // natural이 멈출 자리보다 위로 올라가려 할 때만 되민다.
        final shift = math.max(0.0, pinned - natural);
        return Transform.translate(offset: Offset(0, shift), child: child);
      },
      child: KeyedSubtree(key: _childKey, child: widget.child),
    );
  }
}
