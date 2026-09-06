import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/util/web_external_links.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// 가입 완료 모달. 닫히는 방식과 무관하게(버튼·X·배경 탭) 항상 완료 처리로 본다 —
/// 계정은 이미 만들어졌으므로 프로필 화면에 남겨두면 안 된다. 호출자가 await 후
/// 홈으로 보낸다.
Future<void> showOnboardingCompleteModal(BuildContext context, {required String displayName}) {
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
  final raw = defaultTargetPlatform == TargetPlatform.iOS ? kAppStoreUrlIos : kAppStoreUrlAndroid;
  final uri = Uri.tryParse(raw);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// 본문의 `스노우라이브`만 파랗게 강조한다(목업).
Widget _highlightedBody(String text) {
  const highlight = '스노우라이브';
  final base = SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray600, height: 1.6);
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

  const _DesktopCompleteCard({required this.displayName, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(SDSSpacing.lg, SDSSpacing.md, SDSSpacing.lg, SDSSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  icon: Icon(Icons.close, size: 22, color: SDSColor.gray500),
                ),
              ),
              Text(
                '$displayName님 가입이 완료됐어요!',
                style: SDSTextStyle.extraBold.copyWith(fontSize: 17, color: SDSColor.gray900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SDSSpacing.sm),
              _highlightedBody(
                '지금 바로 로그인해 스노우라이브를 시작하세요!\n'
                '아래 QR 코드를 스캔하면 스노우라이브 앱도 다운받을 수 있어요.',
              ),
              const SizedBox(height: SDSSpacing.lg),
              // 스토어별로 QR을 따로 띄운다 — 스캔하는 기기가 화면을 띄운 기기와 달라서
              // 하나만 띄우고 OS로 분기하는 건 불가능하다.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final target in kAppDownloadQrTargets)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: SDSSpacing.sm),
                      child: _StoreQr(label: target.label, url: target.url),
                    ),
                ],
              ),
              const SizedBox(height: SDSSpacing.lg),
              _CompleteButton(label: '로그인 하기', onTap: onClose),
            ],
          ),
        ),
      ),
    );
  }
}

/// 스토어 QR 한 장 + 아래 라벨.
class _StoreQr extends StatelessWidget {
  static const double _qrSize = 124;

  final String label;
  final String url;

  const _StoreQr({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          color: SDSColor.snowliveWhite,
          child: QrImageView(
            data: url,
            size: _qrSize,
            padding: EdgeInsets.zero,
            backgroundColor: SDSColor.snowliveWhite,
          ),
        ),
        const SizedBox(height: SDSSpacing.xs),
        Text(
          label,
          style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.gray700),
        ),
      ],
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
        constraints: const BoxConstraints(maxWidth: 300),
        child: Padding(
          padding: const EdgeInsets.all(SDSSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '가입 완료!',
                style: SDSTextStyle.extraBold.copyWith(fontSize: 17, color: SDSColor.gray900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SDSSpacing.sm),
              _highlightedBody(
                '지금 바로 로그인해\n스노우라이브를 시작하세요!\n스노우라이브 앱도 다운받을 수 있어요.',
              ),
              const SizedBox(height: SDSSpacing.md),
              _CompleteButton(label: '로그인하기', onTap: onClose),
              const SizedBox(height: SDSSpacing.xs),
              TextButton(
                onPressed: openAppStoreForCurrentPlatform,
                child: Text(
                  '앱 다운로드',
                  style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
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
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: SDSColor.snowliveBlue,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.snowliveWhite),
      ),
    );
  }
}
