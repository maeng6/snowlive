import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// [saveWebPngToDevice] 결과.
enum WebImageSaveResult {
  /// 공유 시트로 넘겼다(아이폰 — 사용자가 `이미지 저장`을 골라 사진 앱에 들어간다).
  shared,

  /// 브라우저 다운로드로 내려줬다(PC · 안드로이드 — 안드로이드는 갤러리 `Download` 앨범에 보인다).
  downloaded,

  /// 공유 시트를 사용자가 닫았다(실패가 아니다 — 안내하지 않는다).
  cancelled,

  /// 탭 직후가 아니라서 Safari가 공유 시트를 막았다(카드 캡처에 시간이 걸린 경우).
  /// 이미지는 준비됐으니 **한 번 더 탭**하면 열린다 — 화면이 버튼을 띄운다.
  needsUserTap,

  failed,
}

/// 아이폰·아이패드(Safari·인앱 브라우저 모두 WebKit)인지.
/// 아이패드 Safari는 데스크탑 UA(Macintosh)를 쓰므로 터치 포인트로 가린다.
bool get isAppleMobileWeb {
  final ua = web.window.navigator.userAgent;
  if (RegExp(r'iPhone|iPad|iPod').hasMatch(ua)) return true;
  return ua.contains('Macintosh') && web.window.navigator.maxTouchPoints > 1;
}

/// 라이딩 기록 카드 `이미지 저장` — **기기 갤러리에 들어가게** 저장한다.
///
/// 웹은 사진 앱에 직접 쓸 수 없다. `<a download>`는 아이폰에서 **파일 앱**으로만 가서
/// 사진 앱(갤러리)에 안 보였다(2026-10-12 QA). 아이폰에서 사진 앱으로 가는 유일한 길은
/// 공유 시트(`navigator.share`)의 `이미지 저장`이라 아이폰은 공유 시트를 띄운다.
/// 안드로이드 크롬은 다운로드가 갤러리 `Download` 앨범에 보이므로(공유 시트에는 저장
/// 항목이 없는 기기가 많다) 다운로드를 유지하고, PC도 다운로드다.
Future<WebImageSaveResult> saveWebPngToDevice({
  required Uint8List bytes,
  required String filename,
}) async {
  if (isAppleMobileWeb) {
    final result = await _share(bytes: bytes, filename: filename);
    if (result != WebImageSaveResult.failed) return result;
    // 공유를 아예 못 하는 구형 브라우저면 다운로드라도 한다.
  }
  return saveWebPng(bytes: bytes, filename: filename)
      ? WebImageSaveResult.downloaded
      : WebImageSaveResult.failed;
}

/// 준비된 PNG로 공유 시트를 바로 연다 — [WebImageSaveResult.needsUserTap] 뒤 **사용자 탭
/// 핸들러 안에서** 부른다(그래야 Safari가 막지 않는다).
Future<WebImageSaveResult> shareWebPngNow({
  required Uint8List bytes,
  required String filename,
}) =>
    _share(bytes: bytes, filename: filename);

Future<WebImageSaveResult> _share({required Uint8List bytes, required String filename}) async {
  try {
    final file = web.File(
      [bytes.toJS].toJS,
      filename,
      web.FilePropertyBag(type: 'image/png'),
    );
    final data = web.ShareData(files: [file].toJS);
    if (!web.window.navigator.canShare(data)) return WebImageSaveResult.failed;
    await web.window.navigator.share(data).toDart;
    return WebImageSaveResult.shared;
  } catch (e) {
    // DOMException 이름으로 가린다 — AbortError=사용자가 닫음, NotAllowedError=탭 직후가 아님.
    final name = e is web.DOMException ? e.name : '';
    if (name == 'AbortError') return WebImageSaveResult.cancelled;
    if (name == 'NotAllowedError') return WebImageSaveResult.needsUserTap;
    debugPrint('[RidingCard] 공유 시트 실패: $e');
    return WebImageSaveResult.failed;
  }
}

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
