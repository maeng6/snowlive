/// 웹캠 iframe 임베드 — 플랫폼별 구현을 고른다(쿠팡 위젯과 동일 패턴).
/// 웹이면 dart:html 구현, 그 외(테스트 VM)는 빈 자리 스텁.
export 'webcam_embed_stub.dart'
    if (dart.library.html) 'webcam_embed_web.dart';
