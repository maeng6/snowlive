import 'package:flutter/material.dart';

/// [coupang_widget_web.dart]의 **비웹 대체**(테스트 VM·모바일 빌드) — `dart:html`/
/// `dart:ui_web`이 컴파일 체인에 들어오지 않게 한다. 쿠팡 위젯은 웹 전용이라 여기선
/// 빈 자리만 돌려준다.
Widget coupangWidgetView({required String embedUrl}) => const SizedBox.shrink();
