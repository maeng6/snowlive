/// 소셜 로그인(카카오/네이버) 팝업 파사드.
/// 웹에서는 팝업 + postMessage 수신, 그 외 플랫폼에선 미지원 stub.
export 'social_oauth_popup_stub.dart'
    if (dart.library.js_interop) 'social_oauth_popup_web.dart';
