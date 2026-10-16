import 'dart:js_interop';

import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// 공유 아이콘 공통 동작.
///
/// - **PC(데스크탑)**: 링크를 클립보드에 복사하고 토스트로 알린다.
/// - **태블릿·모바일**: OS 공유 시트(`navigator.share`)를 띄운다. 공유를 지원하지
///   않는 브라우저면 복사로 폴백한다. 사용자가 공유 시트를 닫으면(AbortError) 아무것도
///   안 한다(실패가 아니다).
///
/// [url]은 카카오 등 미리보기(OG)를 위해 백엔드 share 링크를 넣는다
/// (fleamarketShareLink·profileShareLink 참고).
Future<void> shareOrCopyLink(
  BuildContext context, {
  required String url,
  required String title,
}) async {
  if (!context.isDesktop) {
    try {
      final data = web.ShareData(title: title, url: url);
      if (web.window.navigator.canShare(data)) {
        await web.window.navigator.share(data).toDart;
        return; // 공유 시트를 띄웠다(성공/취소 모두 여기서 끝).
      }
      // canShare=false → 아래 복사 폴백.
    } catch (e) {
      // AbortError=사용자가 공유 시트를 닫음 → 복사하지 않고 조용히 종료.
      final name = e is web.DOMException ? e.name : '';
      if (name == 'AbortError') return;
      // 그 외 오류는 복사로 폴백.
    }
  }
  await Clipboard.setData(ClipboardData(text: url));
  if (context.mounted) showWebToast(context, '링크가 복사되었어요');
}
