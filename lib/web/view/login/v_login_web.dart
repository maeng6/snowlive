import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/onboarding/w_onboarding_scaffold_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_login_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 웹 로그인(=회원가입 진입) 화면. 온보딩 플로우의 0단계다.
///
/// LoginViewModelWeb은 팀원 소유(onInit 수정 불가)라 이 화면이 StatefulWidget으로
/// ever() 리스너를 1회 등록해 라우팅을 처리한다.
///
/// 목업의 소셜 버튼은 4개(구글·카카오·네이버·애플)지만 **구글·애플만 그린다** —
/// 카카오·네이버는 패키지·웹 SDK·Firebase 프로바이더가 전무해서 커스텀 토큰 발급용
/// 서버 작업이 선행돼야 한다.
class LoginViewWeb extends StatefulWidget {
  const LoginViewWeb({super.key});

  @override
  State<LoginViewWeb> createState() => _LoginViewWebState();
}

class _LoginViewWebState extends State<LoginViewWeb> {
  final LoginViewModelWeb vm = Get.find<LoginViewModelWeb>();
  Worker? _worker;

  /// 어느 버튼을 눌렀는지. 뷰모델은 "로딩 중"만 알려주고 어떤 제공자인지는 모르므로,
  /// 스피너를 누른 버튼 안에만 띄우기 위해 화면 로컬로 기억한다.
  String? _pendingProvider;

  @override
  void initState() {
    super.initState();
    _worker = ever<WebLoginStatus>(vm.statusRx, (status) {
      if (status == WebLoginStatus.success) {
        // 자동로그인 상태를 함께 갱신해야 한다. 이걸 안 하면 세션 중에 로그인해도
        // AuthCheckViewModelWeb이 unauthenticated에 머물러서, 그 값을 보는 화면들이
        // (키워드 알림 설정, 커뮤니티·중고거래 상세의 재조회 등) 로그인 전으로 남는다.
        Get.find<AuthCheckViewModelWeb>().markAuthenticated();
        // 로그인은 항상 다른 화면 위에서 push되므로, 로그인 전 보던 화면으로 복귀.
        Get.back();
      } else if (status == WebLoginStatus.needOnboarding) {
        Get.toNamed(WebRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;

    return OnboardingScaffoldWeb(
      onBack: () => Get.back(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: SDSSpacing.xxl),
          Center(
            child: Image.asset('assets/imgs/logos/snowliveLogo_main_new_blue.png', width: 140),
          ),
          const SizedBox(height: SDSSpacing.md),
          Text(
            '스노우라이브와 함께\n신나는 라이딩을',
            style: SDSTextStyle.extraBold.copyWith(
              fontSize: isMobile ? 22 : 24,
              color: SDSColor.gray900,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SDSSpacing.xs),
          Text(
            '지금 바로 함께 하세요',
            style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SDSSpacing.lg),
          Center(
            child: Image.asset(
              'assets/imgs/imgs/img_onboarding_1.png',
              width: isMobile ? 265 : 305,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: SDSSpacing.xl),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundSocialButton(
                    logoAsset: 'assets/imgs/logos/logos_google.png',
                    backgroundColor: SDSColor.snowliveWhite,
                    borderColor: SDSColor.gray200,
                    spinnerColor: SDSColor.gray900,
                    enabled: !vm.isLoading,
                    isLoading: vm.isLoading && _pendingProvider == 'google',
                    onTap: () {
                      setState(() => _pendingProvider = 'google');
                      vm.signInWithGoogle();
                    },
                  ),
                  const SizedBox(width: SDSSpacing.md),
                  _RoundSocialButton(
                    logoAsset: 'assets/imgs/logos/logos_apple.png',
                    backgroundColor: SDSColor.gray900,
                    // 에셋이 검정 글리프라 검정 원 위에 그대로 올리면 보이지 않는다.
                    logoTint: SDSColor.snowliveWhite,
                    spinnerColor: SDSColor.snowliveWhite,
                    enabled: !vm.isLoading,
                    isLoading: vm.isLoading && _pendingProvider == 'apple',
                    onTap: () {
                      setState(() => _pendingProvider = 'apple');
                      vm.signInWithApple();
                    },
                  ),
                ],
              )),
          Obx(() => vm.status == WebLoginStatus.error
              ? Padding(
                  padding: const EdgeInsets.only(top: SDSSpacing.md),
                  child: Text(
                    vm.errorMessage,
                    style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

/// 목업의 원형 소셜 로그인 버튼. 로딩 중에는 로고 자리에 스피너를 돌려서
/// 버튼 크기가 변하지 않게 한다.
class _RoundSocialButton extends StatelessWidget {
  static const double _size = 56;

  final String logoAsset;
  final Color backgroundColor;
  final Color? borderColor;
  final Color? logoTint;
  final Color spinnerColor;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _RoundSocialButton({
    required this.logoAsset,
    required this.backgroundColor,
    this.borderColor,
    this.logoTint,
    required this.spinnerColor,
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: CircleBorder(
        side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: _size,
          height: _size,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
                    ),
                  )
                : Image.asset(
                    logoAsset,
                    width: 24,
                    height: 24,
                    color: logoTint,
                  ),
          ),
        ),
      ),
    );
  }
}
