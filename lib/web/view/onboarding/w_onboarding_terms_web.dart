import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/util/web_external_links.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_onboarding_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

const String _kCheckOnAsset = 'assets/imgs/icons/icon_check_filled.png';
const String _kCheckOffAsset = 'assets/imgs/icons/icon_check_unfilled.png';

/// 약관 원문을 새 탭으로 연다.
///
/// 모바일 앱은 인앱 웹뷰(`webview_flutter`)로 띄우지만, 웹에서 iframe으로 감싸면
/// 구글 사이트가 거부할 수 있어 새 탭이 맞다. `http`/`https`만 연다(커뮤니티 본문
/// 링크 처리와 같은 규칙).
Future<void> openTermsDocument(String raw) async {
  final uri = Uri.tryParse(raw);
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// 온보딩 1단계 — 약관 동의. 서버로 보내는 값은 없고 다음 단계로 넘어가는 게이트다.
class OnboardingTermsStepWeb extends StatelessWidget {
  final OnboardingViewModelWeb vm;

  const OnboardingTermsStepWeb({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/imgs/icons/icon_onboarding.png',
          width: isMobile ? 36 : 48,
          height: isMobile ? 36 : 48,
        ),
        const SizedBox(height: SDSSpacing.md),
        Text(
          '스노우라이브 시작 전\n간단한 정보를 입력해주세요.',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: isMobile ? 22 : 24,
            color: SDSColor.gray900,
            height: 1.35,
          ),
        ),
        const SizedBox(height: SDSSpacing.xs),
        Text(
          '지금 바로 간단한 정보 입력 후 함께 하세요',
          style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray400),
        ),
        // 목업은 제목과 동의 블록 사이가 크게 비어 있다.
        SizedBox(height: isMobile ? 360 : 300),
        Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AgreeRow(
                  label: '전체 동의',
                  labelStyle: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                  checked: vm.agreedAll,
                  onToggle: vm.toggleAgreeAll,
                ),
                Divider(color: SDSColor.gray100, height: 1, thickness: 1),
                _AgreeRow(
                  label: '(필수) 스노우라이브 이용약관 동의',
                  labelStyle: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
                  checked: vm.agreedTos,
                  onToggle: vm.toggleTos,
                  onOpenDocument: () => openTermsDocument(kTermsOfServiceUrl),
                ),
                _AgreeRow(
                  label: '(필수) 개인정보 수집 및 이용동의',
                  labelStyle: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
                  checked: vm.agreedPrivacy,
                  onToggle: vm.togglePrivacy,
                  onOpenDocument: () => openTermsDocument(kPrivacyPolicyUrl),
                ),
              ],
            )),
      ],
    );
  }
}

/// 체크 아이콘 + 라벨 = 토글, 우측 `>` = 원문 열기. 두 히트 영역을 분리한다.
class _AgreeRow extends StatelessWidget {
  final String label;
  final TextStyle labelStyle;
  final bool checked;
  final VoidCallback onToggle;
  final VoidCallback? onOpenDocument;

  const _AgreeRow({
    required this.label,
    required this.labelStyle,
    required this.checked,
    required this.onToggle,
    this.onOpenDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Image.asset(checked ? _kCheckOnAsset : _kCheckOffAsset, width: 24, height: 24),
                    const SizedBox(width: SDSSpacing.sm),
                    Expanded(child: Text(label, style: labelStyle, maxLines: 1)),
                  ],
                ),
              ),
            ),
          ),
          if (onOpenDocument != null)
            IconButton(
              onPressed: onOpenDocument,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: Icon(Icons.chevron_right, size: 22, color: SDSColor.gray300),
            ),
        ],
      ),
    );
  }
}
