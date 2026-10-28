import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// `dart:js_interop`이 없는 타깃(VM 테스트·모바일)용 스텁.
/// `navigator.share`가 없으니 복사 경로만 남긴다 — 웹 구현의 폴백과 같은 동작이다.
Future<void> shareOrCopyLink(
  BuildContext context, {
  required String url,
  required String title,
}) async {
  await Clipboard.setData(ClipboardData(text: url));
  if (context.mounted) showWebToast(context, '링크가 복사되었어요');
}
