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
        // 목업(31:1633) — 아이콘 73. 모바일 목업은 아직 없어 기존 36을 둔다.
        Image.asset(
          'assets/imgs/icons/icon_onboarding.png',
          width: isMobile ? 36 : 73,
          height: isMobile ? 36 : 73,
        ),
        // 목업(31:1630) — 아이콘 ↔ 제목 10, 제목 ↔ 부제 10.
        const SizedBox(height: 10),
        Text(
          '스노우라이브 시작 전\n간단한 정보를 입력해주세요.',
          // 목업(31:1631) — ExtraBold 24, 글줄 1.36, #111.
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: isMobile ? 22 : 24,
            color: SDSColor.gray900,
            height: 1.36,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '지금 바로 간단한 정보 입력 후 함께 하세요',
          // 목업(31:1632) — Regular 14, #111 40%.
          style: SDSTextStyle.regular.copyWith(
            fontSize: 14,
            color: SDSColor.gray900.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

/// 약관 동의 블록. **태블릿·모바일은 화면 하단**에 붙고(목업 31:3797 · 31:2730),
/// 데스크탑은 제목 아래 흐름에 그대로 이어진다 → 스캐폴드의 `bottomContent`로 넘긴다.
class OnboardingTermsAgreementsWeb extends StatelessWidget {
  final OnboardingViewModelWeb vm;

  const OnboardingTermsAgreementsWeb({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 데스크탑만 제목과 블록 사이가 크게 빈다(31:1632 바닥 367 → 31:1642 692).
        if (context.isDesktop) const SizedBox(height: 325),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 목업(31:1642) — `전체 동의`도 아래 행과 **같은 Regular 14**다.
              _AgreeRow(
                label: '전체 동의',
                labelStyle: SDSTextStyle.regular.copyWith(
                  fontSize: 14,
                  color: SDSColor.gray900,
                ),
                checked: vm.agreedAll,
                onToggle: vm.toggleAgreeAll,
              ),
              // 구분선 위아래 20(목업 31:1647). 색은 목업이 gray50(#F5F5F5)이지만
              // **연회색 라인은 gray100으로 통일**한다(웹 공통 규칙, 사용자 확정).
              const SizedBox(height: 20 - _kAgreeRowPadding),
              Divider(color: SDSColor.gray100, height: 1, thickness: 1),
              const SizedBox(height: 20 - _kAgreeRowPadding),
              _AgreeRow(
                label: '(필수) 스노우라이브 이용약관 동의',
                labelStyle: SDSTextStyle.regular.copyWith(
                  fontSize: 14,
                  color: SDSColor.gray900,
                ),
                checked: vm.agreedTos,
                onToggle: vm.toggleTos,
                onOpenDocument: () => openTermsDocument(kTermsOfServiceUrl),
              ),
              // 목업(31:1648) — 필수 두 행 사이 22.
              const SizedBox(height: 22 - _kAgreeRowPadding * 2),
              _AgreeRow(
                label: '(필수) 개인정보 수집 및 이용동의',
                labelStyle: SDSTextStyle.regular.copyWith(
                  fontSize: 14,
                  color: SDSColor.gray900,
                ),
                checked: vm.agreedPrivacy,
                onToggle: vm.togglePrivacy,
                onOpenDocument: () => openTermsDocument(kPrivacyPolicyUrl),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 체크 행이 누르기 좋으라고 갖는 **상하 히트 여백**. 목업 간격(20/22)은 글줄
/// 기준이므로, 행 사이 SizedBox에서 이만큼을 빼야 눈에 보이는 간격이 목업과 같아진다.
const double _kAgreeRowPadding = 8;

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
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: _kAgreeRowPadding),
              child: Row(
                children: [
                  // 목업(31:1644) — 체크 24 + 간격 10 + 라벨(글줄 24).
                  Image.asset(
                    checked ? _kCheckOnAsset : _kCheckOffAsset,
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: labelStyle.copyWith(
                        height: 24 / labelStyle.fontSize!,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onOpenDocument != null)
          // 목업(31:1653) — 꺾쇠 24, gray300. 라벨 묶음과 17 떨어진다.
          Padding(
            padding: const EdgeInsets.only(left: 17),
            child: SizedBox(
              width: 24,
              height: 24,
              child: IconButton(
                onPressed: onOpenDocument,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: SDSColor.gray300,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
