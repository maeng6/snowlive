import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// 웹캠 URL을 iframe으로 렌더한다. 주어진 제약을 가득 채운다(카드 셀 크기에 맞춤).
/// 플랫폼뷰(factory)는 viewType마다 한 번만 등록할 수 있어, 등록한 건 건너뛴다.
final Set<String> _registered = {};

/// 자동재생을 위해 URL을 보정한다. 유튜브/유튜브라이브는 `autoplay=1&mute=1`이 있어야
/// 브라우저 정책(소리 있는 자동재생 차단)에 걸리지 않고 자동 재생된다. 그 외 주소는
/// 그대로 두되(이미 스트림 자동재생인 경우가 많음) iframe `allow=autoplay`로 허용한다.
String _autoplayUrl(String url) {
  final isYoutube = url.contains('youtube.com') || url.contains('youtu.be');
  if (!isYoutube) return url;
  final sep = url.contains('?') ? '&' : '?';
  var u = url;
  if (!u.contains('autoplay=')) u = '$u${sep}autoplay=1';
  if (!u.contains('mute=')) u = '$u&mute=1';
  return u;
}

Widget webcamEmbedView({required String url}) {
  final src = _autoplayUrl(url);
  final viewType = 'webcam-${src.hashCode}';
  if (_registered.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      return html.IFrameElement()
        ..src = src
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
