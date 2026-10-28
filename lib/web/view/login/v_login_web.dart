import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/widget/w_fullScreenDialog.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/onboarding/w_onboarding_scaffold_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_login_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  /// 로그인 성공 후 돌아갈 화면. 로그인 화면에 **들어온 순간** 잡아둔다 —
  /// 성공 시점에는 이미 라우팅 상태가 바뀌어 있을 수 있다.
  /// 잡을 게 없으면 null이고, 그때만 홈으로 간다.
  String? _returnRoute;

  /// 어느 버튼을 눌렀는지. 뷰모델은 "로딩 중"만 알려주고 어떤 제공자인지는 모르므로,
  /// 스피너를 누른 버튼 안에만 띄우기 위해 화면 로컬로 기억한다.
  String? _pendingProvider;

  /// 로그인 화면으로 오기 직전에 보던 경로(쿼리 포함). 돌아가면 안 되는 곳
  /// — 로그인·온보딩 자신, 또는 URL 직접 진입이라 이전 경로가 없는 경우 — 은 null.
  String? _captureReturnRoute() {
    final previous = Get.previousRoute;
    if (previous.isEmpty) return null;
    final path = previous.split('?').first;
    if (path == WebRoutes.login || path == WebRoutes.onboarding) return null;
    return previous;
  }

  @override
  void initState() {
    super.initState();
    _returnRoute = _captureReturnRoute();
    _worker = ever<WebLoginStatus>(vm.statusRx, (status) {
      // 소셜 로그인 공백 로딩 다이얼로그는 '네비게이션 직전'에, 떠 있을 때만 닫는다.
      if (status == WebLoginStatus.success ||
          status == WebLoginStatus.needOnboarding ||
          status == WebLoginStatus.error) {
        if (Get.isDialogOpen ?? false) CustomFullScreenDialog.cancelDialog();
      }
      if (status == WebLoginStatus.success) {
        // 자동로그인 상태를 함께 갱신해야 한다. 이걸 안 하면 세션 중에 로그인해도
        // AuthCheckViewModelWeb이 unauthenticated에 머물러서, 그 값을 보는 화면들이
        // (키워드 알림 설정, 커뮤니티·중고거래 상세의 재조회 등) 로그인 전으로 남는다.
        Get.find<AuthCheckViewModelWeb>().markAuthenticated();
        // 보던 화면으로 돌려보낸다(없으면 홈). 상세에서 "로그인이 필요합니다"를
        // 보고 로그인한 사용자가 그 상세로 그대로 돌아오게 하는 흐름이다.
        Get.offAllNamed(_returnRoute ?? WebRoutes.home);
      } else if (status == WebLoginStatus.needOnboarding) {
        Get.toNamed(WebRoutes.onboarding);
      }
    });
    // 소셜 로그인(카카오/네이버) 리다이렉트로 돌아왔다면 URL의 토큰을 처리한다.
    WidgetsBinding.instance.addPostFrameCallback((_) => vm.consumeSocialRedirect());
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
                    // 글리프 무게가 아래로 쏠려 있다(무게중심이 bbox 중심보다
                    // 높이의 8.8% 아래) → 그만큼 올려야 가운데로 보인다.
                    logoOffsetY: -2,
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
                  const SizedBox(width: SDSSpacing.md),
                  _RoundSocialButton(
                    // PNG는 노란 배경이 꽉 찬 앱아이콘이라 둥근 버튼 위에
                    // 각진 사각형이 얹혔다 → 배경 없는 심볼 SVG를 쓴다.
                    logoAsset: 'assets/imgs/logos/kakao_logo.svg',
                    // 말풍선이 가로로 넓어(16:15) 24칸에서는 넷 중 혼자 커 보인다.
                    logoSize: 23,
                    // 몸통은 위, 꼬리만 아래라 무게중심이 bbox 중심보다 높이의
                    // 6.9% 위에 있다 → 그만큼 내려야 가운데로 보인다.
                    logoOffsetY: 1.5,
                    backgroundColor: const Color(0xFFFEE500), // 카카오 브랜드 옐로
                    logoTint: const Color(0xFF3C1E1E),        // 카카오 심볼 다크브라운
                    spinnerColor: const Color(0xFF3C1E1E),
                    enabled: !vm.isLoading,
                    isLoading: vm.isLoading && _pendingProvider == 'kakao',
                    onTap: () {
                      setState(() => _pendingProvider = 'kakao');
                      vm.signInWithKakao();
                    },
                  ),
                  const SizedBox(width: SDSSpacing.md),
                  _RoundSocialButton(
                    // 네이버 공식 가이드(NAVER_login_KR 4:82)에서 뽑은 심볼.
                    // PNG는 120x120 캔버스에 N이 55x69로만 있어 24칸에 맞추면
                    // 빈 여백까지 줄어들어 잉크가 11x13.8로 혼자 작았다.
                    logoAsset: 'assets/imgs/logos/naver_logo.svg',
                    // 가이드는 버튼 56에 N 20x20(여백 18)인데, 옆 로고들과 같이 놓으면
                    // N이 조금 커 보여 19로 줄였다(사용자 확정).
                    logoSize: 19,
                    // 가이드 변수 color-primary-background-default.
                    // 예전 브랜드 그린(#03C75A)보다 어둡다 — 가이드 기준으로 맞춘 값이다.
                    backgroundColor: const Color(0xFF03A94D),
                    logoTint: SDSColor.snowliveWhite,          // 흰색 N
                    spinnerColor: SDSColor.snowliveWhite,
                    enabled: !vm.isLoading,
                    isLoading: vm.isLoading && _pendingProvider == 'naver',
                    onTap: () {
                      setState(() => _pendingProvider = 'naver');
                      vm.signInWithNaver();
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

  /// 로고가 차지하는 칸. 기본은 [_logoBox]이고, 글리프가 유독 넓은 것만 줄인다.
  final double? logoSize;

  /// 시각 중심 보정(양수 = 아래로). 글리프 무게가 한쪽으로 쏠린 로고만 쓴다.
  final double logoOffsetY;

  final Color backgroundColor;
  final Color? borderColor;
  final Color? logoTint;
  final Color spinnerColor;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _RoundSocialButton({
    required this.logoAsset,
    this.logoSize,
    this.logoOffsetY = 0,
    required this.backgroundColor,
    this.borderColor,
    this.logoTint,
    required this.spinnerColor,
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  /// 로고가 차지하는 칸. 네 버튼이 같은 칸을 써야 서로 커 보이거나 작아 보이지 않는다.
  ///
  /// 잉크(실제로 칠해지는 크기)는 에셋 비율대로 이 칸 안에 맞춰진다 —
  /// 구글 23.6x24 · 애플 19.6x24 · 카카오 24x22.5(말풍선이 가로로 넓다).
  static const double _logoBox = 24;

  Widget _buildLogo() {
    final box = logoSize ?? _logoBox;
    final logo = logoAsset.endsWith('.svg')
        ? SvgPicture.asset(
            logoAsset,
            width: box,
            height: box,
            fit: BoxFit.contain,
            colorFilter: logoTint == null
                ? null
                : ColorFilter.mode(logoTint!, BlendMode.srcIn),
          )
        : Image.asset(logoAsset, width: box, height: box, color: logoTint);
    if (logoOffsetY == 0) return logo;
    // 스피너는 그대로 가운데 둔다 — 로고만 옮긴다.
    return Transform.translate(offset: Offset(0, logoOffsetY), child: logo);
  }

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
                : _buildLogo(),
          ),
        ),
      ),
    );
  }
}
