import 'dart:async';

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 짧은 완료 안내용 다크 알약 토스트.
///
/// `Get.snackbar`로는 목업 모양이 안 나온다 — 기본값이 **하단 전체폭 연회색 카드 +
/// 제목/본문 2줄** 구조라서, 목업의 "한 줄 다크 알약"과 다르다. 그래서 팝업들과 같이
/// 최상위 [Overlay]에 엔트리를 직접 꽂고 타이머로 걷는다.
///
/// 딤이 없고 입력을 가로막지 않는다([IgnorePointer]) — 토스트는 알림일 뿐이라
/// 뜬 동안에도 아래를 계속 조작할 수 있어야 한다.
void showWebToast(
  BuildContext context,
  String message, {
  /// 목업: 데스크탑·태블릿은 상단, 모바일은 하단.
  AlignmentGeometry alignment = Alignment.bottomCenter,
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);

  late final OverlayEntry entry;
  var isRemoved = false;
  void remove() {
    if (isRemoved) return;
    isRemoved = true;
    entry.remove();
  }

  entry = OverlayEntry(
    builder: (_) => Positioned.fill(
      child: IgnorePointer(
        child: SafeArea(
          child: Align(
            alignment: alignment,
            child: Padding(
              padding: const EdgeInsets.all(SDSSpacing.lg),
              child: Material(
                color: SDSColor.gray900,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Text(
                    message,
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Timer(duration, remove);
}
