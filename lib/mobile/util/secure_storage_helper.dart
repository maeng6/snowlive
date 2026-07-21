import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// iOS Keychain 접근성 옵션이 설정된 FlutterSecureStorage 인스턴스 반환
///
/// iOS에서 앱이 백그라운드에서 종료된 후 재시작할 때도
/// Keychain 데이터에 접근할 수 있도록 first_unlock 옵션 사용
FlutterSecureStorage getSecureStorage() {
  return const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
}