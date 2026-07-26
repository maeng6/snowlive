import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_login_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 웹 로그인 화면. LoginViewModelWeb은 팀원 소유(onInit 수정 불가)라
/// 이 화면이 StatefulWidget으로 ever() 리스너를 1회 등록해 라우팅을 처리한다.
class LoginViewWeb extends StatefulWidget {
  const LoginViewWeb({super.key});

  @override
  State<LoginViewWeb> createState() => _LoginViewWebState();
}

class _LoginViewWebState extends State<LoginViewWeb> {
  final LoginViewModelWeb vm = Get.find<LoginViewModelWeb>();
  Worker? _worker;

  /// 어느 버튼을 눌렀는지. 뷰모델은 "로딩 중"만 알려주고 어떤 제공자인지는 모르므로,
  /// 스피너를 누른 버튼 안에만 띄우기 위해 화면 로컬로 기억한다
  /// (뷰모델은 팀원 소유라 건드리지 않는다).
  String? _pendingProvider;

  @override
  void initState() {
    super.initState();
    _worker = ever<WebLoginStatus>(vm.statusRx, (status) {
      if (status == WebLoginStatus.success) {
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
    return Scaffold(
      backgroundColor: SDSColor.gray50,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(SDSSpacing.xl),
            decoration: BoxDecoration(
              color: SDSColor.snowliveWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: SDSColor.gray200, blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset('assets/imgs/logos/snowliveLogo_main_new.png', height: 32),
                ),
                const SizedBox(height: SDSSpacing.lg),
                Text(
                  '로그인',
                  style: SDSTextStyle.extraBold.copyWith(fontSize: 22, color: SDSColor.gray900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SDSSpacing.sm),
                Text(
                  '간편하게 로그인하고 스노우라이브를 이용해보세요.',
                  style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SDSSpacing.xl),
                Obx(() => _SocialLoginButton(
                      label: 'Google로 계속하기',
                      logoAsset: 'assets/imgs/logos/logos_google.png',
                      backgroundColor: SDSColor.snowliveWhite,
                      textColor: SDSColor.gray900,
                      borderColor: SDSColor.gray200,
                      enabled: !vm.isLoading,
                      isLoading: vm.isLoading && _pendingProvider == 'google',
                      onPressed: () {
                        setState(() => _pendingProvider = 'google');
                        vm.signInWithGoogle();
                      },
                    )),
                const SizedBox(height: SDSSpacing.sm),
                Obx(() => _SocialLoginButton(
                      label: 'Apple로 계속하기',
                      logoAsset: 'assets/imgs/logos/logos_apple.png',
                      backgroundColor: SDSColor.gray900,
                      textColor: SDSColor.snowliveWhite,
                      borderColor: SDSColor.gray900,
                      enabled: !vm.isLoading,
                      isLoading: vm.isLoading && _pendingProvider == 'apple',
                      onPressed: () {
                        setState(() => _pendingProvider = 'apple');
                        vm.signInWithApple();
                      },
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
                // 로딩 스피너는 버튼 아래 별도로 두지 않고 누른 버튼 안에 인라인으로
                // 표시한다(온보딩 화면과 동일한 방식). 어떤 동작이 진행 중인지가
                // 버튼과 직접 연결돼 보이고, 레이아웃도 늘어나지 않는다.
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String label;
  final String logoAsset;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.label,
    required this.logoAsset,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.enabled,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      // 로고 자리를 스피너로 바꿔서 버튼 폭/높이가 변하지 않게 한다.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          else
            Image.asset(logoAsset, width: 20, height: 20),
          const SizedBox(width: SDSSpacing.sm),
          Text(label, style: SDSTextStyle.bold.copyWith(fontSize: 15, color: textColor)),
        ],
      ),
    );
  }
}
