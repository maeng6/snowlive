import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// 웹캠을 렌더한다. 주어진 제약을 가득 채운다(카드 셀 크기에 맞춤).
///
/// URL 종류에 따라 분기한다:
///  · `.m3u8`(HLS 생 스트림) → `<video>` + **hls.js**(크롬·파폭) 또는 네이티브(사파리).
///    iframe에 m3u8을 넣으면 재생 안 됨 → 전용 플레이어가 필요하다.
///  · 그 외(유튜브 라이브/임베드 페이지) → iframe.
///
/// 포인터는 꺼서(`pointer-events:none`) 영상 위에서 **페이지 스크롤이 통과**하게 한다
/// (클릭은 카드의 GestureDetector가 받아 새 탭으로 연다).
final Set<String> _registered = {};

Widget webcamEmbedView({required String url}) {
  if (_isHls(url)) {
    _ensureHlsScript();
    final viewType = 'cam-hls-${url.hashCode}';
    if (_registered.add(viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        final video = html.VideoElement()
          ..autoplay = true
          ..muted = true
          ..controls = false
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'cover'
          ..style.pointerEvents = 'none'
          ..setAttribute('playsinline', 'true')
          ..setAttribute('muted', 'true');
        _attachHls(video, url);
        return video;
      });
    }
    return HtmlElementView(viewType: viewType);
  }

  final src = _autoplayUrl(url);
  final viewType = 'webcam-${src.hashCode}';
  if (_registered.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      return html.IFrameElement()
        ..src = src
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.pointerEvents = 'none'
        ..allowFullscreen = true
        ..setAttribute('allow', 'autoplay; fullscreen; encrypted-media')
        ..setAttribute('referrerpolicy', 'no-referrer-when-downgrade');
    });
  }
  return HtmlElementView(viewType: viewType);
}

bool _isHls(String url) => url.toLowerCase().contains('.m3u8');

/// 자동재생을 위해 유튜브 URL에 autoplay·mute 파라미터를 붙인다.
String _autoplayUrl(String url) {
  final isYoutube = url.contains('youtube.com') || url.contains('youtu.be');
  if (!isYoutube) return url;
  final sep = url.contains('?') ? '&' : '?';
  var u = url;
  if (!u.contains('autoplay=')) u = '$u${sep}autoplay=1';
  if (!u.contains('mute=')) u = '$u&mute=1';
  return u;
}

/// hls.js를 한 번만 CDN에서 로드한다.
bool _hlsRequested = false;
void _ensureHlsScript() {
  if (js_util.hasProperty(html.window, 'Hls')) return;
  if (_hlsRequested) return;
  _hlsRequested = true;
  final s = html.ScriptElement()
    ..src = 'https://cdn.jsdelivr.net/npm/hls.js@1'
    ..async = true;
  html.document.head?.append(s);
}

/// 비디오에 HLS 소스를 붙인다. 사파리는 네이티브, 그 외는 hls.js(로드될 때까지 대기).
void _attachHls(html.VideoElement video, String url) {
  // 사파리는 m3u8을 네이티브로 재생.
  if (video.canPlayType('application/vnd.apple.mpegurl').isNotEmpty) {
    video.src = url;
    video.play();
    return;
  }

  var tries = 0;
  void tryAttach() {
    tries++;
    if (js_util.hasProperty(html.window, 'Hls')) {
      final hlsCtor = js_util.getProperty(html.window, 'Hls');
      final supported = js_util.callMethod(hlsCtor, 'isSupported', const []);
      if (supported == true) {
        final hls = js_util.callConstructor(hlsCtor, const []);
        js_util.callMethod(hls, 'loadSource', [url]);
        js_util.callMethod(hls, 'attachMedia', [video]);
        video.play();
        return;
      }
    }
    if (tries < 40) {
      Future.delayed(const Duration(milliseconds: 300), tryAttach); // 최대 ~12초 대기
    }
  }

  tryAttach();
}
