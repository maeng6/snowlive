import 'main.dart' as app;

/// 개발/어드민용 진입점.
/// 현재는 프로덕션 `main.dart`와 100% 동일하게 구동한다(같은 부트스트랩·MyApp 재사용).
/// 추후 개발/어드민 전용 기능(폴리곤 테스트 화면, 디버그 패널 등)을 여기서 분기해 붙인다.
///
/// 실행: flutter run -t lib/main_test.dart
void main() => app.main();
