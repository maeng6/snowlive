import 'dart:async';

import 'package:flutter/gestures.dart';

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

/// 홈 최상단 히어로 캐러셀.
///
/// 데이터는 Firestore `banner/home`(운영 on/off·여러 장)에서 오고,
/// 화면은 히어로 레이아웃(radius 20 + 텍스트/버튼/로고 오버레이)으로 그린다.
///  - 2장 이상일 때만 5초 간격 자동 롤링([kHomeBannerInterval], 앱 배너와 동일).
///  - 이미지 전체 클릭은 없고 **버튼만** 동작한다(buttonUrl → landingUrl 폴백, 새 탭).
///  - 운영 배너가 하나도 없으면 기본 슬라이드(로컬 에셋 + 고정 문구)를 보여준다.
class HomeHeroWeb extends StatefulWidget {
  final List<HomeBanner> banners;

  /// Firestore 문서를 받았는지. 받기 전에는 스켈레톤으로 자리를 잡는다.
  final bool isLoaded;

  const HomeHeroWeb({super.key, required this.banners, required this.isLoaded});

  @override
  State<HomeHeroWeb> createState() => _HomeHeroWebState();
}

/// 운영 배너가 없을 때 쓰는 기본 슬라이드(로컬 에셋 + 고정 문구).
const HomeBanner _kDefaultSlide = HomeBanner(
  imageUrl: '',
  landingUrl: '',
  title: '스노우라이브와 함께하는\n짜릿한 겨울 시즌',
  subtitle: '라이딩 기록부터 커뮤니티까지, 스키장의 모든 것',
);

/// 모바일 히어로 높이(사용자 확정). PC 348 / 태블릿 248처럼 **고정 높이**로
/// 잡는다 — 비율로 두면 폰 폭에 따라 높이가 320~500까지 널뛰어서 문구 블록이
/// 들어갈 자리를 가늠할 수 없다.
///
/// 이미지는 `cover`라 폭에 맞춰 채우고 남는 위아래가 잘린다. 소재는 375폭 기준
/// 375×400(≈1:1.07) 근처 세로형이면 잘림이 가장 적다(권장 1080×1150 내외).
const double kHomeHeroMobileHeight = 400;

const String _kDefaultHeroAsset = 'assets/imgs/imgs/Main_Top_image.png';
const String _kDefaultHeroAssetMobile = 'assets/imgs/imgs/Main_Top_image_m.png';

class _HomeHeroWebState extends State<HomeHeroWeb> {
  /// 무한 스와이프용 시작 페이지 — 앞뒤 어느 방향으로도 한참 넘길 수 있게 중간값을 쓴다
  static const int _kInitialPage = 10000;

  // late + initState 초기화는 핫리로드 시 LateInitializationError가 나서
  // 선언과 동시에 초기화한다
  PageController _pageController = PageController(initialPage: _kInitialPage);
  int _index = 0;
  Timer? _timer;

  /// 이미 미리 받아둔 이미지 URL. PageView는 보이는 장만 만들어서, 이게 없으면
  /// 넘어가는 순간에야 다음 사진을 받기 시작해 한 박자 늦게 툭 나타난다.
  final Set<String> _precached = <String>{};

  /// **첫 장 사진까지** 준비됐는지. 문서만 받고 스켈레톤을 걷으면 빈 프레임이
  /// 한 박자 보였다가 사진이 툭 나타나서, 사진이 준비된 뒤에 걷는다(사용자 확정).
  /// 한 번 true가 되면 되돌리지 않는다 — 폭이 바뀌어 URL이 달라져도 이미 화면에
  /// 내용이 있으므로 다시 스켈레톤으로 돌아가면 더 어색하다.
  bool _firstImageReady = false;

  /// 사진이 느리거나 실패해도 스켈레톤을 무한정 붙잡지 않는다. 먼저 걷어도
  /// [WebNetworkImage]가 자기 셔머를 깔아줘서 빈 칸이 보이지는 않는다.
  static const Duration _kFirstImageTimeout = Duration(seconds: 3);

  List<HomeBanner> get _slides => widget.banners.isEmpty ? const [_kDefaultSlide] : widget.banners;

  @override
  void didUpdateWidget(HomeHeroWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _index = 0;
      // 컨트롤러는 재생성하지 않는다(붙어 있는 채로 dispose하면 상태가 깨진다)
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_kInitialPage);
      }
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// build마다 호출 — 어떤 경로로 슬라이드 수가 바뀌어도 타이머 상태를 맞춘다.
  /// (didUpdateWidget 감지에만 의존하면 초기 로드 타이밍에 따라 롤링이 안 걸릴 수 있다)
  void _ensureTimer(int slideCount) {
    final bool shouldRoll = slideCount > 1;
    final bool isActive = _timer?.isActive ?? false;
    if (shouldRoll && !isActive) {
      _restartTimer();
    } else if (!shouldRoll && isActive) {
      _timer?.cancel();
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    // 1장이면 롤링하지 않는다(앱 배너와 동일).
    if (_slides.length < 2) return;
    _timer = Timer.periodic(kHomeBannerInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;
      // 좌측으로 슬라이드하며 다음 장으로 넘어간다.
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  /// 그 폭에서 **실제로 그리는** URL(모바일은 세로 전용 이미지).
  /// [_buildImage]와 같은 규칙이어야 헛다리를 짚지 않는다.
  String _urlFor(HomeBanner slide, bool isMobile) =>
      isMobile ? (slide.imageUrlMobile ?? slide.imageUrl) : slide.imageUrl;

  /// 첫 장 사진이 준비되면 스켈레톤을 걷는다. 문서를 받기 전에는 아무것도 하지
  /// 않는다 — 그때의 `_slides`는 기본 슬라이드(로컬 에셋)라 바로 준비됐다고
  /// 판단해버려서, 정작 진짜 사진은 다시 셔머를 보게 된다.
  void _revealWhenFirstImageReady(bool isMobile) {
    if (_firstImageReady || !widget.isLoaded) return;
    final slides = _slides;
    final url = slides.isEmpty ? '' : _urlFor(slides[_index], isMobile);
    // 기본 슬라이드는 로컬 에셋이라 기다릴 게 없다.
    if (url.isEmpty) {
      setState(() => _firstImageReady = true);
      return;
    }
    _precached.add(url);
    precacheImage(
      NetworkImage(url),
      context,
    ).timeout(_kFirstImageTimeout).catchError((_) {}).whenComplete(() {
      if (mounted && !_firstImageReady) {
        setState(() => _firstImageReady = true);
      }
    });
  }

  /// 지금 장과 **다음 장**을 미리 받아둔다. 롤링을 따라가며 한 장씩 앞서 받으므로
  /// 배너가 몇 장이든 넘어갈 때는 이미 캐시에 있다.
  ///
  /// [WebNetworkImage]가 바이트 경로에서 `Image.network`를 쓰므로 여기서 채운
  /// [ImageCache]를 그대로 재사용한다(같은 URL이면 즉시 그려진다).
  void _precacheAround(bool isMobile) {
    final slides = _slides;
    if (slides.isEmpty) return;
    for (final i in <int>{_index, (_index + 1) % slides.length}) {
      final url = _urlFor(slides[i], isMobile);
      // 기본 슬라이드는 URL이 비어 있다(로컬 에셋이라 받을 게 없다).
      if (url.isEmpty) continue;
      // 폭이 바뀌면 URL도 바뀌므로 URL 기준으로 중복을 막는다.
      if (!_precached.add(url)) continue;
      // 실패해도 화면은 각자 폴백이 있다 — 여기서 막을 건 예외 전파뿐이다.
      precacheImage(NetworkImage(url), context).catchError((_) {});
    }
  }

  Future<void> _openButtonUrl(HomeBanner slide) async {
    final url = slide.buttonUrl ?? slide.landingUrl;
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;
    final bool isMobile = screenType == WebScreenType.mobile;
    final bool isTablet = screenType == WebScreenType.tablet;

    // 첫 프레임 뒤에 사진을 받는다 — build 중 이미지 캐시를 건드리면 안 된다.
    // 스켈레톤을 그리는 동안에도 돌아야 해서 조기 리턴보다 **앞**에 둔다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _revealWhenFirstImageReady(isMobile);
      // 첫 장이 뜨기 전에는 **다음 장 프리캐시를 미룬다** — 첫 페인트가 다음 장
      // 다운로드와 대역폭을 다투지 않게(첫 화면을 먼저 빠르게 보여준다).
      if (_firstImageReady) _precacheAround(isMobile);
    });

    // 문서 + **첫 장 사진**이 준비될 때까지 스켈레톤으로 자리만 잡는다
    // (레이아웃이 튀지 않게).
    if (!widget.isLoaded || !_firstImageReady) {
      return _frame(
        isMobile: isMobile,
        isTablet: isTablet,
        child: SkeletonShimmer(
          // 라운드는 프레임과 같은 값 — 모바일은 꽉 찬 사각(0), 그 외 20.
          // 프레임이 0으로 자르더라도 스켈레톤 자신이 둥글면 모서리가 비어 보인다.
          child: SkeletonBox(
            width: double.infinity,
            height: double.infinity,
            radius: isMobile ? 0 : 20,
          ),
        ),
      );
    }

    final slides = _slides;
    _ensureTimer(slides.length);

    return _frame(
      isMobile: isMobile,
      isTablet: isTablet,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 좌우 스와이프 + 좌로 슬라이드 애니메이션. 이미지와 문구가 같이 넘어간다.
          PageView.builder(
            controller: _pageController,
            // 웹은 기본 ScrollBehavior가 마우스 드래그를 막는다 → 마우스로도 스와이프되게 허용.
            scrollBehavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            physics: slides.length > 1
                ? const PageScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            onPageChanged: (page) {
              setState(() => _index = page % slides.length);
              // 새 현재 장 기준으로 그 다음 장을 미리 받는다.
              _precacheAround(isMobile);
              // 수동 스와이프 후 자동 롤링 타이머를 처음부터 다시 센다.
              _restartTimer();
            },
            itemBuilder: (context, page) {
              // 이미지만 좌로 슬라이드된다. 문구/버튼은 아래 고정 오버레이가
              // 별도 애니메이션(페이드+상승)으로 처리한다.
              final slide = slides[page % slides.length];
              return _buildImage(slide, isMobile);
            },
          ),
          // 밝은 이미지에서도 문구가 보이게 텍스트 영역 쪽에 은은한 딤을 깐다.
          // PC는 좌→우, 모바일은 상→하(문구 위치 기준). 스와이프를 막지 않게 IgnorePointer.
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: isMobile ? Alignment.topCenter : Alignment.centerLeft,
                  end: isMobile ? Alignment.bottomCenter : Alignment.centerRight,
                  colors: [Colors.black.withOpacity(0.35), Colors.transparent],
                  stops: const [0.0, 0.65],
                ),
              ),
            ),
          ),
          // 문구/버튼 — 등장: 타이틀→서브→버튼 순서대로 0.1초 간격 페이드+살짝 상승,
          // 퇴장: 전체가 한번에 페이드아웃.
          _HeroOverlay(
            slide: slides[_index.clamp(0, slides.length - 1)],
            isMobile: isMobile,
            isTablet: isTablet,
            onButtonTap: _openButtonUrl,
          ),
          // 로고와 인디케이터는 슬라이드와 무관하게 고정.
          _buildLogo(isMobile),
          if (slides.length > 1) _buildDots(slides.length, isMobile),
        ],
      ),
    );
  }

  /// 공통 프레임 — 모바일 400 / PC 348 / 태블릿 248 고정 높이 +
  /// 좌우 cover 마스킹(폭이 줄어도 높이가 유지된다). radius 20.
  Widget _frame({required bool isMobile, required bool isTablet, required Widget child}) {
    final framed = SizedBox(
      height: isMobile ? kHomeHeroMobileHeight : (isTablet ? 248 : 348),
      width: double.infinity,
      child: child,
    );
    // 모바일은 화면 끝까지 꽉 차므로 라운드를 주지 않는다 — 모서리만 둥글면
    // 화면 가장자리와 어긋나 보인다.
    return ClipRRect(borderRadius: BorderRadius.circular(isMobile ? 0 : 20), child: framed);
  }

  Widget _buildImage(HomeBanner slide, bool isMobile) {
    final String url = isMobile ? (slide.imageUrlMobile ?? slide.imageUrl) : slide.imageUrl;
    if (url.isEmpty) {
      // 기본 슬라이드(로컬 에셋).
      return Image.asset(
        isMobile ? _kDefaultHeroAssetMobile : _kDefaultHeroAsset,
        fit: BoxFit.cover,
      );
    }
    return WebNetworkImage(url: url, fit: BoxFit.cover, gaplessPlayback: true);
  }

  /// 스노우라이브 로고(헤더와 같은 SVG를 흰색으로 덧칠).
  /// PC: 우하단, 모바일: 하단 중앙 (피그마 기준)
  Widget _buildLogo(bool isMobile) {
    final logo = SvgPicture.asset(
      'assets/imgs/logos/snowlive_logo_black_web.svg',
      height: isMobile ? 18 : 22,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
    if (isMobile) {
      return Positioned(left: 0, right: 0, bottom: 30, child: Center(child: logo));
    }
    return Positioned(right: 50, bottom: 40, child: logo);
  }

  /// 페이지 인디케이터(기존 배너와 동일한 6px dot).
  Widget _buildDots(int count, bool isMobile) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _index
                      ? SDSColor.snowliveWhite
                      : SDSColor.snowliveWhite.withValues(alpha: 0.4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 문구/버튼 오버레이 애니메이터.
///
/// 등장: 타이틀 → 서브타이틀 → 버튼이 0.2초 간격으로 페이드인하며 아래에서
/// 살짝(12px) 올라온다. 퇴장: 전체가 한번에 짧게 페이드아웃된 뒤 다음 슬라이드
/// 문구가 등장한다.
class _HeroOverlay extends StatefulWidget {
  final HomeBanner slide;
  final bool isMobile;
  final bool isTablet;
  final void Function(HomeBanner slide) onButtonTap;

  const _HeroOverlay({
    required this.slide,
    required this.isMobile,
    required this.isTablet,
    required this.onButtonTap,
  });

  @override
  State<_HeroOverlay> createState() => _HeroOverlayState();
}

class _HeroOverlayState extends State<_HeroOverlay> with TickerProviderStateMixin {
  /// 등장 전체 길이 — 요소당 300ms, 0.1초(100ms) 간격 스태거 → 300+100+100=500ms.
  static const int _kEnterMs = 500;
  static const int _kItemMs = 300;
  static const int _kStaggerMs = 100;

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _kEnterMs),
  )..forward();
  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  /// 현재 화면에 그려지는 슬라이드(퇴장 애니메이션 동안은 이전 슬라이드를 유지).
  late HomeBanner _shown = widget.slide;

  @override
  void didUpdateWidget(_HeroOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.slide, widget.slide)) {
      // 한번에 페이드아웃 → 내용 교체 → 순서대로 등장.
      _exit.forward(from: 0).whenComplete(() {
        if (!mounted) return;
        setState(() => _shown = widget.slide);
        _exit.value = 0;
        _enter.forward(from: 0);
      });
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    _exit.dispose();
    super.dispose();
  }

  /// n번째(0부터) 요소의 등장 애니메이션 — 페이드 + 12px 상승.
  Widget _staggered(int order, Widget child) {
    final double start = (order * _kStaggerMs) / _kEnterMs;
    final double end = (order * _kStaggerMs + _kItemMs) / _kEnterMs;
    final animation = CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Opacity(
        opacity: animation.value,
        child: Transform.translate(offset: Offset(0, (1 - animation.value) * 12), child: child),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = widget.isMobile;
    final bool isTablet = widget.isTablet;
    final slide = _shown;
    final String? title = slide.title;
    final String? subtitle = slide.subtitle;
    final String? buttonLabel = slide.buttonLabel;

    // 피그마 기준 반응형 수치: PC / 태블릿 / 모바일.
    final double titleSize = isMobile ? 24 : (isTablet ? 24 : 32);
    // 서브타이틀: PC 15 / 태블릿 14(수동 조정) / 모바일 12(피그마).
    final double subtitleSize = isMobile ? 12 : (isTablet ? 14 : 15);
    final double buttonHeight = isMobile ? 41 : (isTablet ? 40 : 48);
    final double buttonFontSize = (isMobile || isTablet) ? 14 : 16;

    return Positioned.fill(
      child: FadeTransition(
        opacity: ReverseAnimation(_exit),
        child: Padding(
          padding: EdgeInsets.only(
            left: isMobile ? 20 : 50,
            right: isMobile ? 20 : 50,
            top: isMobile ? 30 : 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              if (title != null)
                // 타이틀: Bold 32(PC) / 22(태블릿) / 24(모바일), 화이트.
                _staggered(
                  0,
                  Text(
                    title,
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: titleSize,
                      color: SDSColor.snowliveWhite,
                      height: 1.3,
                    ),
                  ),
                ),
              if (subtitle != null) ...[
                // 타이틀↔서브 간격: PC 12 / 태블릿 4(수동 조정) / 모바일 10(피그마).
                SizedBox(height: isMobile ? 4 : (isTablet ? 4 : 12)),
                // 서브타이틀: Regular 15(PC) / 12(태블릿·모바일), 화이트.
                _staggered(
                  1,
                  Text(
                    subtitle,
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: subtitleSize,
                      color: SDSColor.snowliveWhite,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              if (buttonLabel != null) ...[
                // 버튼 위 간격: PC 24 / 태블릿·모바일 20.
                SizedBox(height: isMobile || isTablet ? 20 : 24),
                // 버튼: 화이트 배경 + gray100 1px 보더 + pill(40).
                // 높이 48(PC) / 40(태블릿) / 41(모바일), 폰트 16(PC) / 14 (피그마 기준).
                _staggered(
                  2,
                  ElevatedButton(
                    onPressed: () => widget.onButtonTap(slide),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.snowliveWhite,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      overlayColor: Colors.transparent,
                      side: BorderSide(color: SDSColor.gray100),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: Size(0, buttonHeight),
                      fixedSize: Size.fromHeight(buttonHeight),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                    ),
                    child: Text(
                      buttonLabel,
                      style: SDSTextStyle.extraBold.copyWith(
                        fontSize: buttonFontSize,
                        color: SDSColor.gray900,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
