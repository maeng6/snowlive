import 'dart:math' as math;

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
class WebStickyFooterScroll extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.hasBoundedHeight
            ? math.max(0.0, constraints.maxHeight - padding.vertical)
            : 0.0;
        return SingleChildScrollView(
          controller: controller,
          padding: padding,
          // 당겨서 새로고침이 붙으면 짧은 페이지에서도 overscroll 되게 한다.
          physics: onRefresh != null ? const AlwaysScrollableScrollPhysics() : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [content, footer],
            ),
          ),
        );
      },
    );
    final refresh = onRefresh;
    if (refresh == null) return body;
    return RefreshIndicator(onRefresh: refresh, child: body);
  }
}
