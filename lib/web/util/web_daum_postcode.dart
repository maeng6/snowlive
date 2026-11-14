/// 다음(카카오) 우편번호 검색 — 플랫폼별 구현을 고른다.
///
/// 웹이면 `dart:html` 팝업 구현([web_daum_postcode_html.dart]), 그 외(단위 테스트 VM·
/// 모바일)는 호출 시 예외만 던지는 스텁. ⚠️ `dart:html`을 직접 import하는 파일을
/// `routes_web.dart`가 끌어오면 **라우트를 건드리는 모든 테스트가 컴파일조차 안 된다**
/// (maeng_4.5.8 이후 실측) — 그래서 조건부 export로 갈라 둔다.
export 'web_daum_postcode_stub.dart'
    if (dart.library.html) 'web_daum_postcode_html.dart';
