import 'dart:async';

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_desktop_topbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 토스트가 상단바 아래로 띄우는 간격.
const double kWebToastTopGap = 16;

/// 토스트 글자 크기. 제목·본문 모두 같은 값을 쓰고 **굵기로만** 구분한다 —
/// 알약 한 덩어리라 크기까지 벌리면 공통 팝업(제목 16/본문 14)처럼 커져 버린다.
const double kWebToastFontSize = 14;

/// 등장/퇴장 애니메이션. 상단에서 내려오듯 **위에서 8px 아래로** 밀려들어오고,
/// 나갈 때는 그 반대로 올라가며 사라진다. 퇴장을 더 짧게 둬야 끝이 질척이지 않는다.
const Duration kWebToastFadeIn = Duration(milliseconds: 220);
const Duration kWebToastFadeOut = Duration(milliseconds: 160);
const double _kToastSlide = 8;

/// 짧은 완료 안내용 다크 알약 토스트.
///
/// `Get.snackbar`로는 목업 모양이 안 나온다 — 기본값이 **하단 전체폭 연회색 카드**
/// 라서, 목업의 "상단 다크 알약"과 다르다. 그래서 팝업들과 같이 최상위 [Overlay]에
/// 엔트리를 직접 꽂고 타이머로 걷는다.
///
/// 생김새·위치는 **웹 전체가 하나로 통일**돼 있다(사용자 확정):
/// 검정 80% 배경 · 흰 글자 · **상단바 바로 아래 16**. 화면이나 폭에 따라 아래에
/// 띄우지 않는다 — 어디서 떠도 같은 자리에서 보이게 하기 위함이다.
///
/// [title]을 주면 두 줄이 된다: **윗줄 Bold · 아랫줄 Regular**(사용자 확정).
/// 안 주면 한 줄이고, 그 한 줄은 Bold다.
///
/// [context]를 비우면 앱 루트 오버레이에 띄운다 — 뷰모델처럼 `BuildContext`가
/// 없는 자리에서 부르기 위함이다. 루트가 아직 없으면 조용히 넘긴다.
///
/// 딤이 없고 입력을 가로막지 않는다([IgnorePointer]) — 토스트는 알림일 뿐이라
/// 뜬 동안에도 아래를 계속 조작할 수 있어야 한다.
void showWebToast(
  BuildContext? context,
  String message, {
  String? title,
  Duration duration = const Duration(seconds: 2),
}) {
  final host = context ?? Get.overlayContext ?? Get.context;
  if (host == null) return;

  final overlay = Overlay.maybeOf(host, rootOverlay: true);
  if (overlay == null) return;

  late final OverlayEntry entry;
  var isRemoved = false;
  void remove() {
    if (isRemoved) return;
    isRemoved = true;
    entry.remove();
  }

  entry = OverlayEntry(
    builder: (_) => Positioned(
      // 루트 Overlay는 고정 상단바까지 덮는다 → 상단바 높이만큼 내려야 그 아래에
      // 선다. 상단바는 PC·태블릿(WebGnbDesktopTopBar)과 모바일(WebGnbTopBar) 모두
      // 56이라 폭에 상관없이 같은 값을 쓴다 — 한쪽을 바꾸면 여기도 같이 봐야 한다.
      top: kGnbDesktopTopBarHeight + kWebToastTopGap,
      left: SDSSpacing.lg,
      right: SDSSpacing.lg,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: _WebToast(
            title: title,
            message: message,
            duration: duration,
            onDismissed: remove,
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
}

/// 알약 본체. 등장/퇴장과 표시 시간을 **스스로** 관리한다 — 바깥에서 타이머로
/// 걷어 버리면 퇴장 애니메이션이 재생될 틈 없이 사라진다.
class _WebToast extends StatefulWidget {
  final String? title;
  final String message;
  final Duration duration;
  final VoidCallback onDismissed;

  const _WebToast({
    required this.title,
    required this.message,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_WebToast> createState() => _WebToastState();
}

class _WebToastState extends State<_WebToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: kWebToastFadeIn,
    reverseDuration: kWebToastFadeOut,
  );

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _anim.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _anim.reverse();
    // reverse 중에 화면이 바뀌어 엔트리가 먼저 걷혔을 수 있다.
    if (mounted) widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: _anim,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, -_kToastSlide * (1 - curve.value)),
          child: child,
        ),
      ),
      child: Material(
        // 검정 80% — 뒤 내용이 살짝 비쳐 '떠 있는 알림'으로 읽힌다.
        color: SDSColor.snowliveBlack.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.title != null) ...[
                Text(
                  widget.title!,
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: kWebToastFontSize,
                    height: 20 / kWebToastFontSize,
                    color: SDSColor.snowliveWhite,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: (widget.title == null
                        ? SDSTextStyle.bold
                        : SDSTextStyle.regular)
                    .copyWith(
                  fontSize: kWebToastFontSize,
                  height: 20 / kWebToastFontSize,
                  color: SDSColor.snowliveWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
