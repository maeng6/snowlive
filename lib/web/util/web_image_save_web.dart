import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// PNG 바이트를 브라우저 다운로드로 내려준다(라이딩 기록 카드 `이미지 저장`).
///
/// 앱은 갤러리에 저장하지만(`Gal.putImage`) 웹에는 갤러리가 없다 → Blob URL을 만들어
/// `<a download>`을 눌러주는 방식이 표준이다. URL은 바로 해제해야 메모리에 남지 않는다.
bool saveWebPng({required Uint8List bytes, required String filename}) {
  try {
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'image/png'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = url
      ..download = filename
      ..style.display = 'none';
    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
    return true;
  } catch (e) {
    debugPrint('[RidingCard] 이미지 저장 실패: $e');
    return false;
  }
}

/// PNG를 브라우저 공유 시트로 넘긴다(모바일 브라우저의 `navigator.share`).
///
/// 파일 공유는 지원 범위가 좁다(데스크탑 크롬은 대체로 불가) → 못 하면 false를 돌려주고
/// 화면이 `이미지 저장`을 안내한다.
Future<bool> shareWebPng({required Uint8List bytes, required String filename}) async {
  try {
    final file = web.File(
      [bytes.toJS].toJS,
      filename,
      web.FilePropertyBag(type: 'image/png'),
    );
    final data = web.ShareData(files: [file].toJS);
    if (!web.window.navigator.canShare(data)) return false;
    await web.window.navigator.share(data).toDart;
    return true;
  } catch (e) {
    debugPrint('[RidingCard] 공유 실패: $e');
    return false;
  }
}
