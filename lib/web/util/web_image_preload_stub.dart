/// `dart:js_interop`이 없는 타깃(VM 테스트·모바일)용 스텁.
///
/// 브라우저 이미지 캐시가 없는 환경이라 미리 받아둘 곳도 없다 → 아무것도 안 한다.
void preloadImageWeb(String? url) {}
