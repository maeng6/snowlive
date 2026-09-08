import 'dart:io';

import 'package:com.snowlive/web/widget/gnb/w_gnb_nav_items.dart';
import 'package:flutter_test/flutter_test.dart';

/// 사이드바·드로어 메뉴 아이콘. 활성은 채워진 `_select`, 비활성은 외곽선을 쓴다.
void main() {
  test('1차 메뉴 9개 모두 벡터 아이콘 on/off 쌍을 갖는다', () {
    expect(kGnbPrimaryItems, hasLength(9));
    for (final item in kGnbPrimaryItems) {
      expect(item.assetIconSvgOff, isNotNull, reason: item.label);
      expect(item.assetIconSvgOn, isNotNull, reason: item.label);
      // 활성 아이콘은 `_select` 버전이다.
      expect(item.assetIconSvgOn, endsWith('_select.svg'), reason: item.label);
      expect(item.assetIconSvgOff, isNot(endsWith('_select.svg')), reason: item.label);
    }
  });

  test('1차 메뉴에는 라우트가 다 붙어 있고 빈 메뉴가 없다', () {
    for (final item in kGnbPrimaryItems) {
      expect(item.routePrefix, isNotNull, reason: item.label);
      expect(item.isPlaceholder, isFalse, reason: item.label);
    }
    for (final item in kGnbSecondaryItems) {
      expect(item.isPlaceholder, isFalse, reason: item.label);
    }
    expect(kGnbSecondaryItems.map((i) => i.label), ['친구', '설정']);
  });

  test('2차 메뉴(친구·설정)는 아이콘이 없다 — 텍스트만', () {
    for (final item in kGnbSecondaryItems) {
      expect(item.assetIconSvgOn, isNull, reason: item.label);
      expect(item.assetIconSvgOff, isNull, reason: item.label);
      expect(item.assetIconOn, isNull, reason: item.label);
      expect(item.assetIconOff, isNull, reason: item.label);
      expect(item.materialIcon, isNull, reason: item.label);
    }
  });

  test('아이콘 에셋 파일이 실제로 있다', () async {
    for (final item in [...kGnbPrimaryItems, ...kGnbSecondaryItems]) {
      for (final path in [item.assetIconSvgOn, item.assetIconSvgOff]) {
        if (path == null) continue;
        expect(
          await _assetExists(path),
          isTrue,
          reason: '$path (${item.label})',
        );
      }
    }
  });
}

Future<bool> _assetExists(String path) async {
  // pubspec에 등록된 디렉터리라 파일 존재만 확인하면 된다.
  return File(path).existsSync();
}
