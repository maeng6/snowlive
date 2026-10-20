import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// 전역 gtag 함수(웹). index.html에서 정의되며, GA 스크립트가 로드되기 전엔
/// dataLayer에 큐잉되었다가 로드 후 처리된다.
@JS('gtag')
external void _gtag(String command, String name, JSAny params);

/// GA4로 **수동 page_view**를 전송한다. 스라 웹은 해시 라우팅 SPA라 자동
/// page_view(send_page_view:false)를 끄고, 라우트 변경마다 이걸 호출한다.
/// gtag 미정의/오류 시 조용히 무시(분석 실패가 앱 동작을 막지 않게).
void sendPageViewWeb(String routePath) {
  try {
    final params = <String, Object?>{
      'page_path': routePath,
      'page_location': web.window.location.href,
      'page_title': web.document.title,
    }.jsify();
    if (params != null) _gtag('event', 'page_view', params);
  } catch (_) {
    // 분석 전송 실패는 무시.
  }
}
