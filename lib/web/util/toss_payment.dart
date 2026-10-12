/// 토스페이먼츠 표준 Payment SDK(리다이렉트) 연동 파사드.
/// 웹에서는 실제 JS 호출, 그 외 플랫폼에서는 무동작 stub.
export 'toss_payment_stub.dart'
    if (dart.library.js_interop) 'toss_payment_web.dart';
