import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// 쿠팡 다이나믹 배너(위젯)를 iframe으로 렌더한다. 쿠팡이 이미지·제목·**실시간 가격**을
/// 직접 그려주므로 가격이 항상 최신이고 파트너스 정책상 안전하다.
///
/// 플랫폼뷰(factory)는 viewType마다 한 번만 등록할 수 있어, 이미 등록한 건 건너뛴다.
final Set<String> _registered = {};

Widget coupangWidgetView({required String embedUrl}) {
  final viewType = 'coupang-widget-${embedUrl.hashCode}';
  if (_registered.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      return html.IFrameElement()
        ..src = embedUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..setAttribute('scrolling', 'no')
        ..setAttribute('referrerpolicy', 'unsafe-url');
    });
  }
  // HtmlElementView는 주어진 제약을 가득 채운다(카드 셀 크기에 맞춤).
  return HtmlElementView(viewType: viewType);
}
