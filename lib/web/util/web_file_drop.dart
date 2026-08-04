/// 파일 드롭 수신기 파사드.
///
/// 실제 구현은 `package:web`을 쓰는데, 그건 **웹 타깃에서만 컴파일된다.**
/// 그런데 `w_livetalk_upload_flow_web.dart` → `routes_web.dart`로 이어지는
/// import 그래프가 넓어서, 직접 import하면 `flutter test`(VM 타깃)에서
/// lib/web의 상당 부분이 컴파일 자체가 안 된다.
///
/// 그래서 조건부 export로 갈라둔다 — 웹은 실제 구현, 그 외(테스트·모바일)는 무동작 스텁.
/// 호출부는 이 파일만 import하면 된다.
export 'web_file_drop_stub.dart'
    if (dart.library.js_interop) 'web_file_drop_web.dart';
