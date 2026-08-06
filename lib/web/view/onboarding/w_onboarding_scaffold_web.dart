import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';

/// 데스크탑 폼·버튼 폭. 목업 실측 354.
const double kOnboardingFormWidth = 360;

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

  const OnboardingScaffoldWeb({
    super.key,
    required this.child,
    required this.onBack,
    this.primaryLabel,
    this.onPrimary,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final horizontal = isDesktop ? SDSSpacing.xl : SDSSpacing.md;

    final backButton = Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onBack,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(Icons.arrow_back, size: 24, color: SDSColor.gray900),
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
        padding: EdgeInsets.fromLTRB(horizontal, SDSSpacing.lg, horizontal, SDSSpacing.xl),
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: kOnboardingCanvasWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  backButton,
                  const SizedBox(height: SDSSpacing.md),
                  Center(
                    child: SizedBox(
                      width: kOnboardingFormWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          child,
                          if (button != null) ...[
                            const SizedBox(height: SDSSpacing.xl),
                            button,
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

    // 태블릿·모바일: 버튼을 뷰포트 하단에 고정하고, 스크롤 영역을 그만큼 줄인다.
    const double barHeight = 76;
    final body = Container(
      color: SDSColor.snowliveWhite,
      padding: EdgeInsets.fromLTRB(horizontal, SDSSpacing.md, horizontal, SDSSpacing.lg),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            backButton,
            const SizedBox(height: SDSSpacing.md),
            child,
          ],
        ),
      ),
    );

    if (button == null) return body;

    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          Padding(padding: const EdgeInsets.only(bottom: barHeight), child: body),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: SDSColor.snowliveWhite,
              padding: EdgeInsets.fromLTRB(horizontal, SDSSpacing.sm, horizontal, SDSSpacing.md),
              child: button,
            ),
          ),
        ],
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
    return ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: SDSColor.snowliveBlue,
        disabledBackgroundColor: SDSColor.gray200,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(
              label,
              style: SDSTextStyle.bold.copyWith(
                fontSize: 16,
                color: enabled ? SDSColor.snowliveWhite : SDSColor.gray400,
              ),
            ),
    );
  }
}
