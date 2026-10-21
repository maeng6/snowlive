/// 브라우저 이미지 캐시 워밍업의 파사드.
///
/// 실제 구현은 `package:web`(`HTMLImageElement`)을 쓰고 그건 **웹 타깃에서만
/// 컴파일된다** → `web_share_link.dart`와 같이 조건부 export로 갈라 둔다.
/// 이 파일을 거치지 않고 `_web.dart`를 직접 import하면 VM 테스트가 통째로
/// 컴파일 실패한다(`vm_home_web.dart` → 거의 모든 웹 화면이 이어져 있다).
export 'web_image_preload_stub.dart'
    if (dart.library.js_interop) 'web_image_preload_web.dart';
