/// 공유 아이콘 공통 동작의 파사드.
///
/// 실제 구현은 `package:web`(navigator.share)을 쓰고 그건 **웹 타깃에서만
/// 컴파일된다** → `web_image_save.dart`와 같이 조건부 export로 갈라 둔다
/// (테스트·모바일은 복사만 하는 스텁).
export 'web_share_link_stub.dart'
    if (dart.library.js_interop) 'web_share_link_web.dart';
