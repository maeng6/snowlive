import 'package:flutter/services.dart';

/// 앱 런처 아이콘(홈화면 아이콘)을 '미리 번들된 대체 아이콘' 중 하나로 전환한다.
///
/// 중요: 홈화면 아이콘은 서버 이미지로 바꿀 수 없다. iOS는 Info.plist의
/// `CFBundleAlternateIcons`에, Android는 `activity-alias`에 **빌드 시점에 미리
/// 번들된** 변형들 중에서만 고를 수 있다. 서버(check-wb)는 "어떤 변형을 쓸지"
/// 키(`app_icon_variant`)만 내려주고, 실제 전환은 네이티브가 수행한다.
///
/// - iOS: `UIApplication.setAlternateIconName` (AppDelegate의 MethodChannel)
/// - Android: `activity-alias` enable/disable (MainActivity의 MethodChannel)
///
/// 네이티브 미구현/실패 시 전부 조용히 무시(no-op)한다 — 아이콘 전환 실패가
/// 앱 동작에 영향을 주면 안 된다.
class AppIconService {
  AppIconService._();

  static const MethodChannel _channel = MethodChannel('app_icon');

  /// 서버가 내려준 변형 키. 네이티브에 선언된 값과 반드시 일치해야 한다.
  ///   'default' → 기본 아이콘, 그 외는 번들된 대체 아이콘.
  static const String _kDefault = 'default';
  static const Set<String> _knownVariants = {'default', 'xmas', 'newyear'};

  /// 마지막으로 적용한(또는 적용 시도한) 변형. 같은 값이면 네이티브 호출을 건너뛴다.
  static String? _applied;

  /// 서버 응답(JSON Map)에서 `app_icon_variant`를 읽어 적용한다.
  /// 앱 시작 시 리조트인포(resort-home) 응답에 담겨 온다.
  /// 키가 없거나 알 수 없는 값이면 'default'로 간주한다.
  static Future<void> applyFromResponse(Map<String, dynamic>? data) async {
    final raw = data == null ? null : data['app_icon_variant'];
    final variant = (raw is String && _knownVariants.contains(raw)) ? raw : _kDefault;
    await apply(variant);
  }

  /// 지정한 변형으로 아이콘을 전환한다. (중복/불필요 호출은 내부에서 가드)
  static Future<void> apply(String variant) async {
    final v = _knownVariants.contains(variant) ? variant : _kDefault;
    if (_applied == v) return; // 이미 같은 아이콘 — 네이티브 호출 불필요
    _applied = v;
    try {
      await _channel.invokeMethod('setIcon', {'variant': v});
    } on MissingPluginException {
      // 네이티브 미구현(구버전 앱/웹) — 무시.
    } catch (_) {
      // 전환 실패(미지원 기기 등) — 무시. 다음 기회에 재시도되도록 _applied 롤백.
      _applied = null;
    }
  }

  /// 현재 적용된 대체 아이콘 키를 네이티브에서 조회(없으면 'default').
  static Future<String> current() async {
    try {
      final r = await _channel.invokeMethod<String>('currentIcon');
      return (r != null && _knownVariants.contains(r)) ? r : _kDefault;
    } catch (_) {
      return _kDefault;
    }
  }
}
