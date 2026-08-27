/// 캡처한 PNG를 브라우저에서 내려받는 기능의 파사드.
///
/// 실제 구현은 `package:web`을 쓰고 그건 **웹 타깃에서만 컴파일된다** →
/// `web_file_drop.dart`와 같이 조건부 export로 갈라 둔다(테스트·모바일은 무동작 스텁).
export 'web_image_save_stub.dart'
    if (dart.library.js_interop) 'web_image_save_web.dart';
