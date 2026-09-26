import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';

/// 웹 공용 팝업(comp_popup, 피그마 32:27568) 카드 폭.
/// 콘텐츠(버튼) 폭 240 + 좌우 패딩 24*2.
const double kWebPopupWidth = 288;

/// 팝업 카드 셸 — 흰색, 라운드 16, 상단 30 / 좌우 24 패딩.
/// 하단 패딩은 박스/텍스트 타입 공통 24 (눈으로 맞춘 확정값).
/// 타이틀 bold 16 gray900(lh24) ↔ 8 ↔ 본문 regular 14 gray600(lh22).
/// 본문 색은 피그마 #666 대신 가장 가까운 토큰 gray600(#777) — 토큰 우선 규칙
class _WebPopupCard extends StatelessWidget {
  final String title;
  final String? message;
  final Widget buttons;
  final double bottomPadding;

  /// 본문 ↔ 버튼 간격(박스 30 / 텍스트 20)
  final double buttonsGap;

  const _WebPopupCard({
    required this.title,
    required this.message,
    required this.buttons,
    required this.bottomPadding,
    required this.buttonsGap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // Overlay 직삽이라 Material 조상이 없다 → 카드 표면을 Material로 만든다
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kWebPopupWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 30, 24, bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 16,
                  height: 24 / 16,
                  color: SDSColor.gray900,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 14,
                    height: 22 / 14,
                    color: SDSColor.gray600,
                  ),
                ),
              ],
              SizedBox(height: buttonsGap),
              buttons,
            ],
          ),
        ),
      ),
    );
  }
}

/// 팝업 버튼 공통 — Material 리플 대신 웹 공통 인터랙션을 쓰기 위한 스타일.
/// (스플래시·오버레이 제거. hover 반응은 [_HoverFade]/배경 블렌드가 담당.)
ButtonStyle _noSplashStyle() => const ButtonStyle(
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStatePropertyAll(Colors.transparent),
      shadowColor: WidgetStatePropertyAll(Colors.transparent),
      // hover 색 전환을 애니메이션 없이 즉시 적용(사이드바 버튼과 동일).
      animationDuration: Duration.zero,
    );

/// 텍스트류 hover 시 60% 투명 — 애니메이션 없이 즉시 전환.
/// 버튼 child 안에서 MouseRegion만 감지하고 히트는 버튼이 그대로 가진다.
class _HoverFade extends StatefulWidget {
  final Widget child;
  const _HoverFade({required this.child});

  @override
  State<_HoverFade> createState() => _HoverFadeState();
}

class _HoverFadeState extends State<_HoverFade> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Opacity(
        opacity: _hovered ? 0.6 : 1.0,
        child: widget.child,
      ),
    );
  }
}

/// 웹 공용 확인 다이얼로그 — **텍스트 버튼 타입**(취소/확인 가로 1:1).
/// 모바일 앱이 신고·숨기기·삭제 전부 확인을 받으므로 맞춘다.
Future<bool> showWebConfirmDialog({
  required BuildContext context,
  required String title,
  String? message,
  String confirmLabel = '확인',
  String cancelLabel = '취소',
  bool isDestructive = false,
}) async {
  final result = await showWebOverlayModal<bool>(
    context: context,
    builder: (_, close) => _WebPopupCard(
      title: title,
      message: message,
      bottomPadding: 24,
      buttonsGap: 20,
      // 버튼 폰트 17·사이 간격 10 — 앱 표준 팝업과 동일.
      buttons: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => close(false),
              style: _noSplashStyle(),
              child: _HoverFade(
                child: Text(
                  cancelLabel,
                  style: SDSTextStyle.bold.copyWith(fontSize: 17, color: SDSColor.gray500),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextButton(
              onPressed: () => close(true),
              style: _noSplashStyle(),
              child: _HoverFade(
                child: Text(
                  confirmLabel,
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 17,
                    color: isDestructive ? SDSColor.red : SDSColor.snowliveBlue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}

/// 웹 공용 팝업 — **박스 버튼 타입**(피그마 32:27568).
/// 파란 채움 주 버튼(240×48, 라운드 5) 아래에 선택적 텍스트 부 버튼이 세로로 온다.
/// 주 버튼 탭 → true, 그 외(부 버튼/배경 탭) → false.
Future<bool> showWebBoxPopup({
  required BuildContext context,
  required String title,
  String? message,
  required String primaryLabel,
  String? secondaryLabel,
  bool barrierDismissible = true,
}) async {
  final result = await showWebOverlayModal<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_, close) => _WebPopupCard(
      title: title,
      message: message,
      bottomPadding: 24,
      buttonsGap: 30,
      buttons: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => close(true),
              // 리플 대신 hover 시 배경에 검정 10% 블렌드(사이드바·하단바와 동일).
              style: _noSplashStyle().copyWith(
                elevation: const WidgetStatePropertyAll(0),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.hovered)
                      ? Color.alphaBlend(
                          Colors.black.withValues(alpha: 0.1), SDSColor.snowliveBlue)
                      : SDSColor.snowliveBlue,
                ),
              ),
              child: Text(
                primaryLabel,
                style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.snowliveWhite),
              ),
            ),
          ),
          if (secondaryLabel != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () => close(false),
                style: _noSplashStyle().copyWith(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                child: _HoverFade(
                  child: Text(
                    secondaryLabel,
                    style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
  return result ?? false;
}
