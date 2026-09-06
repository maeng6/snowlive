import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:com.snowlive/web/util/web_image_save.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// 카드 캡처 배율. 앱의 공유 캡처와 같은 값(선명하게 저장된다).
const double kRidingCardCapturePixelRatio = 3;

/// [RepaintBoundary]로 감싼 카드를 PNG 바이트로 뽑는다.
///
/// ⚠️ `toImage`는 **캔버스에 그려진 것만** 담는다 → 카드 안 아바타는 `<img>` 폴백을 쓰는
/// [WebNetworkImage]가 아니라 `Image.network`로 그려야 한다(카드 위젯들이 그렇게 한다).
Future<Uint8List?> captureRidingCardPng(GlobalKey boundaryKey) async {
  try {
    final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: kRidingCardCapturePixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  } catch (e) {
    debugPrint('[RidingCard] 카드 캡처 실패: $e');
    return null;
  }
}

/// 캡처 → 브라우저 다운로드. 앱은 갤러리에 저장하지만 웹에는 갤러리가 없다.
Future<bool> saveRidingCardPng({
  required GlobalKey boundaryKey,
  required String filename,
}) async {
  final bytes = await captureRidingCardPng(boundaryKey);
  if (bytes == null) return false;
  return saveWebPng(bytes: bytes, filename: filename);
}

/// 캡처 → 공유 시트. 지원하지 않는 브라우저에서는 false(화면이 저장을 안내한다).
Future<bool> shareRidingCardPng({
  required GlobalKey boundaryKey,
  required String filename,
}) async {
  final bytes = await captureRidingCardPng(boundaryKey);
  if (bytes == null) return false;
  return shareWebPng(bytes: bytes, filename: filename);
}
