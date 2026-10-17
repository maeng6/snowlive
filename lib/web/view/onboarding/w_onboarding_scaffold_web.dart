import 'dart:math' as math;
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_back_icon_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:flutter/material.dart';

/// 데스크탑 폼·버튼이 서는 **캔버스 폭**. 목업(31:1858/31:1923) 실측 374~375.
/// 이 안에서 폼은 좌우 16, 버튼은 좌우 10 들여써서 342 / 355가 된다.
const double kOnboardingFormWidth = 374;

/// 캔버스 안쪽 들여쓰기 — 폼 16 / 버튼 10(목업).
const double kOnboardingFormInset = 16;
const double kOnboardingButtonInset = 10;

/// 뒤로가기 화살표가 붙는 바깥 캔버스 폭. 목업에서 화살표는 폼보다 훨씬 왼쪽에 있다.
const double kOnboardingCanvasWidth = 768;

/// 온보딩 3단계(소셜 로그인 / 약관 / 프로필)가 공유하는 골격.
///
/// 폭에 따라 달라지는 건 세 가지뿐이고 전부 여기 모여 있다:
///  - 데스크탑: 768 캔버스 좌상단 뒤로가기, 콘텐츠는 360 중앙, 버튼도 폭 360으로 컬럼 하단
///  - 태블릿·모바일: 좌상단 뒤로가기, 콘텐츠 전체폭, 버튼은 **화면 하단 고정 전체폭**
///
/// 하단 고정 버튼을 흰 [Container]로 감싸는 이유: 감싸지 않으면 셸의 surface tint가
/// 버튼 뒤로 새어 나와 라벤더 띠가 보인다(커뮤니티 작성 화면에서 겪은 문제).
class OnboardingScaffoldWeb extends StatelessWidget {
  /// 스크롤되는 본문. 폭 제한은 이 위젯이 걸어준다.
  final Widget child;

  /// 뒤로가기 화살표 탭.
  final VoidCallback onBack;

  /// 하단 주요 버튼 라벨. null이면 버튼을 그리지 않는다(소셜 로그인 단계).
  final String? primaryLabel;

  /// null이면 비활성(회색) 상태로 그린다.
  final VoidCallback? onPrimary;

  /// 버튼 자리에 스피너를 돌린다.
  final bool isSubmitting;

  /// 버튼 **바로 위**에 붙는 내용(약관 동의 블록).
  /// 태블릿·모바일 목업(31:3797 · 31:2730)은 약관과 버튼이 함께 **화면 하단**에
  /// 붙는다 — 본문은 위에 남고 가운데가 비는 구조라, 스크롤 안에서 위/아래로
  /// 나눠 배치해야 한다(데스크탑은 본문 흐름 그대로 이어 붙인다).
  final Widget? bottomContent;

  const OnboardingScaffoldWeb({
    super.key,
    required this.child,
    required this.onBack,
    this.primaryLabel,
    this.onPrimary,
    this.isSubmitting = false,
    this.bottomContent,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    // 좌우 여백 — **웹 페이지 여백 표준**(태블릿 20 / 모바일 16)을 따른다.
    // 목업은 태블릿 60이지만 가운데 좁은 기둥처럼 보여 표준으로 맞춘다(사용자 확정).
    // 데스크탑은 캔버스가 가운데 정렬이라 바깥 여백만 둔다.
    final isMobile = context.screenType == WebScreenType.mobile;
    final horizontal = isDesktop ? SDSSpacing.xl : (isMobile ? 16.0 : 20.0);

    final backButton = Align(
      alignment: Alignment.centerLeft,
      // 공통 헤더 표준 뒤로가기(30, hover 페이드).
      // 좌측 히트 여백만 0 — 아이콘이 콘텐츠 좌측선에 붙는다.
      child: WebIconButton(
        onTap: onBack,
        padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
        icon: const WebBackIcon(size: 30),
      ),
    );

    final button = primaryLabel == null
        ? null
        : OnboardingPrimaryButton(
            label: primaryLabel!,
            onTap: onPrimary,
            isSubmitting: isSubmitting,
          );

    if (isDesktop) {
      return Container(
        color: SDSColor.snowliveWhite,
        child: SingleChildScrollView(
          // ⚠️ 여백은 **스크롤 영역 안쪽**(웹 공통) — 바깥에 주면 스크롤바가
          // 브라우저 우측 끝이 아니라 여백 안쪽에 뜬다.
          padding: EdgeInsets.fromLTRB(
            horizontal,
            SDSSpacing.lg,
            horizontal,
            SDSSpacing.xl,
          ),
          child: Center(
            child: SizedBox(
              width: kOnboardingCanvasWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  backButton,
                  // 목업 — 뒤로가기 아이콘 바닥 96 → 본문 시작 192 = 96.
                  // (약관 31:1633 · 프로필 31:1903 둘 다 같은 값이다.)
                  const SizedBox(height: 96),
                  Center(
                    child: SizedBox(
                      width: kOnboardingFormWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: kOnboardingFormInset,
                            ),
                            child: bottomContent == null
                                ? child
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [child, bottomContent!],
                                  ),
                          ),
                          if (button != null) ...[
                            // 목업 — 본문 바닥 → 버튼 30.
                            const SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: kOnboardingButtonInset,
                              ),
                              child: button,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 태블릿·모바일 — 목업(31:3797 · 31:2730)은 본문이 위, **약관 + 버튼이 아래**로
    // 갈라져 가운데가 빈다. 화면이 짧으면 그대로 스크롤되도록 `spaceBetween`을
    // 쓰는 스크롤 골격(`WebStickyFooterScroll`과 같은 방식)으로 그린다.
    //
    // 좌우 여백: 본문은 태블릿 60 / 모바일 16(목업), **버튼만 10**이다.
    final bottomGroup = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (bottomContent != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            child: bottomContent!,
          ),
          // 목업 — 약관 블록 바닥 982 → 버튼 블록 1012 = 30.
          const SizedBox(height: 30),
        ],
        if (button != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kOnboardingButtonInset,
            ),
            child: button,
          ),
      ],
    );

    return Container(
      color: SDSColor.snowliveWhite,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minHeight = constraints.hasBoundedHeight
              ? math.max(0.0, constraints.maxHeight - kOnboardingButtonInset)
              : 0.0;
          return SingleChildScrollView(
            // 여백은 스크롤 영역 안쪽(웹 공통 — 스크롤바를 브라우저 끝에 붙인다).
            // 바닥 10은 목업의 버튼 아래 여백.
            padding: const EdgeInsets.only(bottom: kOnboardingButtonInset),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 목업 — 뒤로가기 줄 높이 50(아이콘 좌 16 · 위 16),
                      // 그 아래 본문까지 20.
                      SizedBox(
                        height: 50,
                        child: Padding(
                          // 뒤로가기도 본문과 같은 좌측선에 선다(모바일 16 / 태블릿 10).
                          padding: EdgeInsets.fromLTRB(horizontal, 16, 0, 0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: backButton,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontal),
                        child: child,
                      ),
                    ],
                  ),
                  bottomGroup,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 온보딩의 파란 주요 버튼. 비활성은 `gray200` 배경 + `gray400` 텍스트(목업).
class OnboardingPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSubmitting;

  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isSubmitting;
    // 목업(31:1670 비활성 / 31:1924 활성) — 높이 48 · 라운드 5 · Bold 16 글줄 20,
    // 활성 파랑 + 흰 글자 / **비활성 gray200 + 흰 글자**(웹 비활성 버튼 공통).
    // ⚠️ 높이는 SizedBox로 겉에서 못 박는다 — 웹 기본 visualDensity(compact)가
    // 버튼 높이를 8 깎아서 48이 40으로 그려진다.
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        // hover는 웹 공통 — 리플·그림자·전환 없이 배경에 검정 블렌드
        // (파란 버튼 10% / 연회색 4%).
        style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(0),
          animationDuration: Duration.zero,
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return SDSColor.gray200;
            if (!states.contains(WidgetState.hovered))
              return SDSColor.snowliveBlue;
            return Color.alphaBlend(
              Colors.black.withValues(alpha: 0.1),
              SDSColor.snowliveBlue,
            );
          }),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 48)),
          visualDensity: VisualDensity.standard,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                // 비활성에도 **흰 글자**(목업) — 회색 글자로 두면 다른 화면의
                // 비활성 버튼과 달라 보인다.
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
