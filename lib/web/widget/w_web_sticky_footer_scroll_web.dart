import 'dart:math' as math;

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 푸터가 있는 페이지의 공통 스크롤 골격.
///
/// 콘텐츠가 뷰포트보다 길면 일반 플로우대로 흐르고(콘텐츠↔푸터 간격은
/// [footer] 블록 안의 SizedBox가 최소값으로 보장), 짧으면 남는 공간이
/// 콘텐츠와 푸터 사이에 들어가 **푸터가 뷰포트 하단에 붙는다**.
///
/// IntrinsicHeight를 쓰지 않는 이유: 그리드 등 내부의 LayoutBuilder가
/// intrinsic 측정을 지원하지 않아 예외가 난다. 대신 min 높이 제약 +
/// spaceBetween으로 같은 효과를 낸다(RenderFlex는 min 제약과 자식 합 중
/// 큰 쪽으로 사이징된다).
class WebStickyFooterScroll extends StatefulWidget {
  /// 스크롤 안쪽 페이지 패딩(웹 공통 규칙 — 바깥에 두면 스크롤바가
  /// 브라우저 끝에 붙지 않는다). min 높이 계산에서 상하분을 차감한다.
  final EdgeInsets padding;

  final ScrollController? controller;

  /// 상단 콘텐츠. 폭 제한(Center/ConstrainedBox)은 페이지가 구성한다.
  final Widget content;

  /// 간격 SizedBox + 푸터 블록. 간격·폭 정책이 화면마다 달라 페이지가 구성한다.
  final Widget footer;

  /// 주면 **당겨서 새로고침**이 붙는다(모바일 터치/데스크탑 드래그). 콘텐츠가 짧아도
  /// 당길 수 있게 overscroll 물리를 켠다. 완료될 때까지 스피너가 돈다.
  final Future<void> Function()? onRefresh;

  const WebStickyFooterScroll({
    super.key,
    this.padding = EdgeInsets.zero,
    this.controller,
    required this.content,
    required this.footer,
    this.onRefresh,
  });

  @override
  State<WebStickyFooterScroll> createState() => _WebStickyFooterScrollState();
}

class _WebStickyFooterScrollState extends State<WebStickyFooterScroll> {
  /// 호출자가 controller를 주지 않았을 때만 쓰는 내부 컨트롤러.
  /// 새로고침 뒤 최상단으로 되돌리려면 스크롤 위치를 직접 잡아야 하기 때문.
  ScrollController? _fallback;

  ScrollController get _effective {
    final passed = widget.controller;
    if (passed != null) return passed;
    return _fallback ??= ScrollController();
  }

  @override
  void dispose() {
    // 내부에서 만든 것만 해제한다(호출자가 준 컨트롤러는 호출자가 소유).
    _fallback?.dispose();
    super.dispose();
  }

  void _resetToTop() {
    final c = _effective;
    if (c.hasClients && c.offset != 0) c.jumpTo(0);
  }

  /// 당겨서 새로고침을 수행하고, **끝나면 최상단으로 정렬**한다.
  /// (overscroll settle·인디케이터 되감김으로 화면이 아래로 튀는 것을 막는다.)
  /// 되감김 애니메이션 뒤에 위치가 흔들릴 수 있어 프레임 직후 + 소폭 지연 두 번 되돌린다.
  Future<void> _handleRefresh() async {
    await widget.onRefresh!.call();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _resetToTop());
    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted) _resetToTop();
  }

  @override
  Widget build(BuildContext context) {
    final refresh = widget.onRefresh;
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.hasBoundedHeight
            ? math.max(0.0, constraints.maxHeight - widget.padding.vertical)
            : 0.0;
        return SingleChildScrollView(
          // 새로고침이 붙으면 위치 리셋을 위해 내부 컨트롤러라도 꼭 물린다.
          controller: refresh != null ? _effective : widget.controller,
          padding: widget.padding,
          // 당겨서 새로고침이 붙으면 짧은 페이지에서도 overscroll 되게 한다.
          physics: refresh != null ? const AlwaysScrollableScrollPhysics() : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [widget.content, widget.footer],
            ),
          ),
        );
      },
    );
    if (refresh == null) return body;
    // 스피너는 스노우라이브 블루, 원형 배경은 흰색(기본 보라/카드색 대체).
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: SDSColor.snowliveBlue,
      backgroundColor: SDSColor.snowliveWhite,
      child: body,
    );
  }
}
