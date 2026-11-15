/// 쿠팡 다이나믹 배너(위젯) iframe — 플랫폼별 구현을 고른다.
///
/// 웹이면 `dart:html`/`dart:ui_web` 구현([coupang_widget_web.dart]), 그 외(테스트 VM·
/// 모바일)는 빈 자리만 주는 스텁. `routes_web.dart`가 끌어오는 파일이 `dart:html`을
/// 직접 import하면 라우트를 건드리는 테스트가 컴파일조차 안 되므로 조건부로 가른다
/// (다음 우편번호 검색과 같은 이유).
export 'coupang_widget_stub.dart'
    if (dart.library.html) 'coupang_widget_web.dart';
