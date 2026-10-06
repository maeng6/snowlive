import 'dart:io';

import 'package:com.snowlive/web/util/web_external_links.dart';
import 'package:flutter_test/flutter_test.dart';

/// 약관·스토어 링크는 `web_external_links.dart` 한곳에만 둔다.
///
/// 푸터가 스토어 URL을 직접 적었다가 둘 다 404로 나간 적이 있어서(앱 ID·패키지명 오기),
/// 값 자체와 "다른 파일에 다시 적지 않았는지"를 함께 지킨다.
void main() {
  test('스토어 링크는 앱과 같은 ID / 패키지를 가리킨다', () {
    expect(kAppStoreUrlIos, contains('id6444235991'));
    expect(kAppStoreUrlAndroid, endsWith('details?id=com.snowlive'));
  });

  test('약관 3종이 모두 정의돼 있다', () {
    expect(kTermsOfServiceUrl, contains('snowlive-termsofservice'));
    expect(kPrivacyPolicyUrl, contains('134creativelabprivacypolicy'));
    expect(kLocationTermsUrl, contains('134creativelablocationinfo'));
  });

  test('웹 코드 어디에도 약관·스토어 URL을 직접 적지 않는다', () {
    const patterns = [
      'apps.apple.com',
      'play.google.com/store',
      'snowlive-termsofservice',
      '134creativelabprivacypolicy',
      '134creativelablocationinfo',
    ];
    final offenders = <String>[];
    for (final entity in Directory('lib/web').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('web_external_links.dart')) continue;
      final source = entity.readAsStringSync();
      for (final pattern in patterns) {
        if (source.contains(pattern)) offenders.add('${entity.path} ← $pattern');
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
