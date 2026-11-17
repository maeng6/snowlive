import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// 웹캠 URL을 iframe으로 렌더한다. 주어진 제약을 가득 채운다(카드 셀 크기에 맞춤).
/// 플랫폼뷰(factory)는 viewType마다 한 번만 등록할 수 있어, 등록한 건 건너뛴다.
final Set<String> _registered = {};

Widget webcamEmbedView({required String url}) {
  final viewType = 'webcam-${url.hashCode}';
  if (_registered.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      return html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true
        ..setAttribute('allow', 'autoplay; fullscreen; encrypted-media')
        ..setAttribute('referrerpolicy', 'no-referrer-when-downgrade');
    });
  }
  return HtmlElementView(viewType: viewType);
}
