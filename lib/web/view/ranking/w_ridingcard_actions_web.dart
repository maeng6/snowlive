import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:com.snowlive/web/util/web_image_save.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart' show showWebConfirmDialog;
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

/// `이미지 저장` — 캡처해서 **기기 갤러리에 들어가게** 저장하고, 결과 안내까지 한다.
/// 시즌 카드와 데일리 카드 상세가 같이 쓴다.
///
/// 아이폰은 공유 시트(`이미지 저장` → 사진 앱), 안드로이드·PC는 다운로드다
/// ([saveWebPngToDevice] 참고). 캡처가 길어 Safari가 공유 시트를 막으면(탭 직후만 허용)
/// 준비된 이미지로 `사진에 저장` 버튼을 띄워 **한 번 더 탭**으로 연다.
Future<void> saveRidingCardWithFeedback(
  BuildContext context, {
  required GlobalKey boundaryKey,
  required String filename,
  required void Function(String message) toast,
}) async {
  final bytes = await captureRidingCardPng(boundaryKey);
  if (!context.mounted) return;
  if (bytes == null) {
    toast('이미지 저장에 실패했어요.');
    return;
  }
  var result = await saveWebPngToDevice(bytes: bytes, filename: filename);
  if (!context.mounted) return;

  if (result == WebImageSaveResult.needsUserTap) {
    final ok = await showWebConfirmDialog(
      context: context,
      title: '이미지가 준비됐어요',
      message: '사진 앱에 저장하려면 공유 화면에서\n‘이미지 저장’을 눌러주세요.',
      confirmLabel: '사진에 저장',
    );
    if (!ok || !context.mounted) return;
    // 이 탭 핸들러 안에서 바로 연다(캡처는 이미 끝났다).
    result = await shareWebPngNow(bytes: bytes, filename: filename);
    if (!context.mounted) return;
  }

  switch (result) {
    case WebImageSaveResult.shared:
    case WebImageSaveResult.cancelled:
      // 공유 시트에서 저장했거나 닫았다 — 따로 안내하지 않는다(무엇을 골랐는지 웹은 모른다).
      break;
    case WebImageSaveResult.downloaded:
      toast('이미지를 저장했어요.');
    case WebImageSaveResult.needsUserTap:
    case WebImageSaveResult.failed:
      toast('이미지 저장에 실패했어요.');
  }
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
