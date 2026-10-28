import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/util/web_external_links.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart'
    show kWebPopupWidth, WebPopupCloseButton;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// 가입 완료 모달. 닫히는 방식과 무관하게(버튼·X·배경 탭) 항상 완료 처리로 본다 —
/// 계정은 이미 만들어졌으므로 프로필 화면에 남겨두면 안 된다. 호출자가 await 후
/// 홈으로 보낸다.
Future<void> showOnboardingCompleteModal(
  BuildContext context, {
  required String displayName,
}) {
  final isMobile = context.screenType == WebScreenType.mobile;
  return showWebOverlayModal<void>(
    context: context,
    padding: const EdgeInsets.all(SDSSpacing.lg),
    builder: (_, close) => isMobile
        ? _MobileCompleteCard(onClose: close)
        : _DesktopCompleteCard(displayName: displayName, onClose: close),
  );
}

/// 스토어를 새 탭으로 연다. QR과 달리 버튼은 누른 기기에서 열리므로 OS로 분기한다.
Future<void> openAppStoreForCurrentPlatform() async {
  final raw = defaultTargetPlatform == TargetPlatform.iOS
      ? kAppStoreUrlIos
      : kAppStoreUrlAndroid;
  final uri = Uri.tryParse(raw);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// 본문에서 **`스노우라이브 앱`만** 파랗게 강조한다(사용자 확정).
/// 윗줄의 `스노우라이브를 시작하세요!`는 강조하지 않는다 — 한 팝업에 파란 글자가
/// 두 번 나오면 어디를 보라는 건지 흐려진다.
Widget _highlightedBody(String text) {
  const highlight = '스노우라이브 앱';
  // 웹 팝업 표준(comp_popup) 본문 — Regular 14 · 글줄 20 · gray600.
  final base = SDSTextStyle.regular.copyWith(
    fontSize: 14,
    height: 20 / 14,
    color: SDSColor.gray600,
  );
  final accent = base.copyWith(color: SDSColor.snowliveBlue);

  final spans = <TextSpan>[];
  var rest = text;
  while (true) {
    final at = rest.indexOf(highlight);
    if (at < 0) {
      if (rest.isNotEmpty) spans.add(TextSpan(text: rest, style: base));
      break;
    }
    if (at > 0) spans.add(TextSpan(text: rest.substring(0, at), style: base));
    spans.add(TextSpan(text: highlight, style: accent));
    rest = rest.substring(at + highlight.length);
  }

  return Text.rich(TextSpan(children: spans), textAlign: TextAlign.center);
}

class _DesktopCompleteCard extends StatelessWidget {
  final String displayName;
  final void Function([void result]) onClose;

  const _DesktopCompleteCard({
    required this.displayName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        // PC 카드만 팝업 표준(288)보다 넓은 390을 쓴다. QR이 한 장이 되고도
        // 좁히지 않는다 — 본문이 두 줄로 들어가고 QR 블록도 여유가 있어야 한다
        // (사용자 확정).
        constraints: const BoxConstraints(maxWidth: 390),
        child: Stack(
          children: [
            Padding(
              // 웹 팝업 표준 패딩 — 좌우 24 · 위 30 · 아래 24.
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '$displayName님 가입이 완료됐어요!',
                    // 웹 팝업 표준 타이틀 — Bold 16 · 글줄 24.
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 16,
                      height: 24 / 16,
                      color: SDSColor.gray900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SDSSpacing.sm),
                  _highlightedBody(
                    '지금 바로 로그인해 스노우라이브를 시작하세요!\n'
                    '아래 QR 코드를 스캔하면 스노우라이브 앱도 다운받을 수 있어요.',
                  ),
                  // 팝업 표준 — 본문 ↔ 다음 블록 30.
                  const SizedBox(height: 30),
                  // 딥링크 한 장이면 된다 — 스캔한 기기가 직접 접속하므로 그 기기의
                  // UA로 서버가 스토어를 가른다([kAppDeepLinkUrl]).
                  const Center(child: _AppDownloadQr()),
                  const SizedBox(height: 30),
                  _CompleteButton(label: '로그인 하기', onTap: onClose),
                ],
              ),
            ),
            // 닫기 X — 웹 팝업 공통(26 · gray900 50% · 우상단 16/16).
            WebPopupCloseButton(onTap: onClose),
          ],
        ),
      ),
    );
  }
}

/// 앱 설치 QR 한 장 + 아래 라벨 — **라벨까지 한 박스**로 묶는다(사용자 확정).
/// 박스는 gray100 라인 · 라운드 8 · 패딩 12.
///
/// 두 장일 때는 QR이 100이었다. 한 장이 되면서 카드 안쪽(390 − 좌우 24 = 342)에
/// 여유가 생겨 140으로 키운다 — 멀리서도 스캔이 잘 된다.
class _AppDownloadQr extends StatelessWidget {
  static const double _qrSize = 140;

  const _AppDownloadQr();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        border: Border.all(color: SDSColor.gray100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 박스 패딩 12이 QR의 여백(quiet zone) 역할도 한다 → QR 자체 패딩은 0.
          QrImageView(
            data: kAppDeepLinkUrl,
            size: _qrSize,
            padding: EdgeInsets.zero,
            backgroundColor: SDSColor.snowliveWhite,
          ),
          const SizedBox(height: SDSSpacing.sm),
          Text(
            // 라벨은 Regular 13 · gray500(사용자 확정).
            '앱 다운로드',
            style: SDSTextStyle.regular.copyWith(
              fontSize: 13,
              color: SDSColor.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileCompleteCard extends StatelessWidget {
  final void Function([void result]) onClose;

  const _MobileCompleteCard({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        // 모바일은 웹 팝업 표준 폭 288(PC 카드만 390을 쓴다).
        constraints: const BoxConstraints(maxWidth: kWebPopupWidth),
        child: Padding(
          // 웹 팝업 표준 패딩 — 좌우 24 · 위 30 · 아래 24.
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '가입 완료!',
                // 웹 팝업 표준 타이틀 — Bold 16 · 글줄 24.
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 16,
                  height: 24 / 16,
                  color: SDSColor.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SDSSpacing.sm),
              _highlightedBody(
                '지금 바로 로그인해\n스노우라이브를 시작하세요!\n스노우라이브 앱도 다운받을 수 있어요.',
              ),
              // 팝업 표준 — 본문 ↔ 버튼 30.
              const SizedBox(height: 30),
              _CompleteButton(label: '로그인하기', onTap: onClose),
              // 4로는 위 버튼에 붙어 보였다 → 8(사용자 확정).
              // TextButton이 세로 패딩을 더 가지므로 체감 간격은 이보다 넓다.
              const SizedBox(height: SDSSpacing.sm),
              TextButton(
                onPressed: openAppStoreForCurrentPlatform,
                child: Text(
                  '앱 다운로드',
                  // 위 `로그인하기`와 같은 Bold 16 — 나란히 놓인 두 버튼이라
                  // 글자 크기가 다르면 아래쪽이 덜 중요한 것처럼 보인다(사용자 확정).
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 16,
                    color: SDSColor.gray900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompleteButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CompleteButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // ⚠️ 높이는 SizedBox로 겉에서 못 박는다 — 웹 기본 visualDensity가 버튼을 깎는다.
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        // 액션·팝업 버튼 표준 — 라운드 5 · 높이 48 · Bold 16.
        // hover는 웹 공통(리플·그림자 없이 배경에 검정 10% 블렌드).
        style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(0),
          animationDuration: Duration.zero,
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.hovered)
                ? Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.1),
                    SDSColor.snowliveBlue,
                  )
                : SDSColor.snowliveBlue,
          ),
          minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 48)),
          visualDensity: VisualDensity.standard,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        child: Text(
          label,
          style: SDSTextStyle.bold.copyWith(
            fontSize: 16,
            height: 20 / 16,
            color: SDSColor.snowliveWhite,
          ),
        ),
      ),
    );
  }
}
