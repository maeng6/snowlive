import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/onboarding/w_onboarding_complete_modal_web.dart';
import 'package:com.snowlive/web/view/onboarding/w_onboarding_profile_web.dart';
import 'package:com.snowlive/web/view/onboarding/w_onboarding_scaffold_web.dart';
import 'package:com.snowlive/web/view/onboarding/w_onboarding_terms_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_onboarding_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 웹 온보딩(신규가입) 화면. 약관 동의 → 프로필 입력 두 단계를 **한 라우트 안에서**
/// 넘긴다 — GetX 라우트를 `/onboarding/terms` 처럼 중첩하면 `/onboarding`으로
/// 매칭돼버려서 하위 경로를 쓸 수 없다.
class OnboardingViewWeb extends StatefulWidget {
  const OnboardingViewWeb({super.key});

  @override
  State<OnboardingViewWeb> createState() => _OnboardingViewWebState();
}

class _OnboardingViewWebState extends State<OnboardingViewWeb> {
  final OnboardingViewModelWeb vm = Get.find<OnboardingViewModelWeb>();

  /// 0 = 약관 동의, 1 = 프로필 입력.
  int _step = 0;

  Worker? _worker;

  /// 완료 모달이 두 번 뜨지 않게 하는 가드.
  bool _completeShown = false;

  @override
  void initState() {
    super.initState();
    // 가입 성공 → 완료 모달 → 홈. 뷰모델이 직접 라우팅하지 않는다.
    _worker = ever<WebOnboardingStatus>(vm.statusRx, (status) {
      if (status != WebOnboardingStatus.success || _completeShown) return;
      _completeShown = true;
      // 가입이 끝나면 로그인된 상태다. 자동로그인 상태도 맞춰줘야 이 값을 보는
      // 화면들이 로그인 전으로 남지 않는다(로그인 화면과 같은 이유).
      Get.find<AuthCheckViewModelWeb>().markAuthenticated();
      _showComplete();
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  Future<void> _showComplete() async {
    // 버튼·X·배경 탭 어느 쪽으로 닫혀도 가입은 끝난 상태다 → 항상 홈으로 보낸다.
    await showOnboardingCompleteModal(context, displayName: vm.nickname.trim());
    Get.offAllNamed(WebRoutes.fleamarketList);
  }

  void _onBack() {
    if (_step > 0) {
      setState(() => _step -= 1);
      return;
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 0) {
      return Obx(() => OnboardingScaffoldWeb(
            onBack: _onBack,
            primaryLabel: '다음',
            onPrimary: vm.canProceedTerms ? () => setState(() => _step = 1) : null,
            child: OnboardingTermsStepWeb(vm: vm),
          ));
    }

    return Obx(() => OnboardingScaffoldWeb(
          onBack: _onBack,
          primaryLabel: '다음',
          onPrimary: vm.canSubmitProfile ? vm.submit : null,
          isSubmitting: vm.isSubmitting,
          child: OnboardingProfileStepWeb(vm: vm),
        ));
  }
}
