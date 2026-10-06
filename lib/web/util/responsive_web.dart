import 'package:flutter/material.dart';

/// 웹 반응형 브레이크포인트 기준값.
/// 데스크탑 >= [desktop], 태블릿 [tablet]~[desktop) 미만, 그 아래는 모바일.
/// [maxContentWidth] 이상에서는 콘텐츠가 더 커지지 않고 화면(배경)만 옆으로 늘어난다.
class WebBreakpoints {
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double maxContentWidth = 1440;
}

/// PC 목록(리스트) 콘텐츠 최대폭 — 홈·중고거래·커뮤니티 공통 1280.
/// 우측 사이드바가 있는 화면은 여기에 (간격 + 사이드바) 폭을 더한 블록 전체를
/// 가운데 정렬한다. 이 값이 화면마다 다르면 콘텐츠가 얼기 시작하는 화면 폭이
/// 달라져서, 넓은 화면에서 타이틀 좌측 여백이 페이지마다 어긋난다.
const double kWebDesktopListMaxWidth = 1280;

/// PC 우측 사이드바 공통 폭 220(2026-10-03 240에서 축소, 사용자 확정).
/// 중고거래·커뮤니티·랭킹·라이브톡·크루톡·라이브크루·크루홈이 모두 이 값을 쓴다 —
/// 화면마다 다르면 넓은 화면에서 본문 최대폭과 사이드바 시작선이 어긋나 눈에 띈다.
/// (목업 일부는 246이지만 전 화면 통일값을 쓴다.)
const double kWebSidebarWidth = 220;

/// 본문(목록·피드) ↔ 우측 사이드바 간격 40. 간격은 각 홈의 Row가 담당하고
/// 사이드바 내부에는 좌측 패딩이 없다.
const double kWebSidebarGap = 40;

/// 서브 페이지(상세·작성 폼·크루 가입/설정/시즌 랭킹 등) 한 열 콘텐츠 최대폭 800
/// (목업 실측 800~802). 넓히면 입력창·행만 길어지고 읽기 흐름이 나빠진다.
/// 중고거래 상세는 이 폭을 이미지 377 + 간격 30 + 정보 393으로 나눠 쓴다.
const double kWebSubPageMaxWidth = 800;

enum WebScreenType { mobile, tablet, desktop }

extension ResponsiveContext on BuildContext {
  WebScreenType get screenType {
    final width = MediaQuery.sizeOf(this).width;
    if (width >= WebBreakpoints.desktop) return WebScreenType.desktop;
    if (width >= WebBreakpoints.tablet) return WebScreenType.tablet;
    return WebScreenType.mobile;
  }

  bool get isDesktop => screenType == WebScreenType.desktop;

  bool get isTabletOrMobile => screenType != WebScreenType.desktop;
}

/// 홈(목록) 화면 타이틀 크기 — PC 32 / 태블릿 24 / **모바일 20**.
/// 스타일은 `SDSTextStyle.extraBold` + `SDSColor.gray900`이 공통이다.
/// 새 홈 화면은 숫자를 직접 쓰지 말고 이 함수를 쓸 것(값이 화면마다 갈리면
/// 타이틀 크기가 페이지마다 달라진다).
/// 서브 페이지 타이틀 크기 — PC 30 / 태블릿 24 / 모바일 20.
/// 뒤로가기와 함께 서는 헤더(`WebPageHeader`)와 크루홈 크루명이 같은 값을 쓴다.
double webSubPageTitleSize(BuildContext context) {
  switch (context.screenType) {
    case WebScreenType.desktop:
      return 30;
    case WebScreenType.tablet:
      return 24;
    case WebScreenType.mobile:
      return 20;
  }
}

double webHomeTitleSize(BuildContext context) {
  switch (context.screenType) {
    case WebScreenType.desktop:
      return 32;
    case WebScreenType.tablet:
      return 24;
    case WebScreenType.mobile:
      return 20;
  }
}

/// 사이드바·하단바 액션 버튼(comp_button) 높이 — **PC 44 / 태블릿·모바일 48**.
/// PC는 사이드바에서 48이 커 보여 낮췄다(사용자 확정, 2026-09-26).
/// 라운드·글자 크기는 화면마다 달라 각자 두고 높이만 이 함수로 맞춘다.
double webActionButtonHeight(BuildContext context) => context.isDesktop ? 44 : 48;

/// 마지막 콘텐츠 ↔ 공통 푸터(HomeFooterWeb) 간격 — PC 120 / 태블릿·모바일 80.
/// 콘텐츠가 짧아도 이 값 그대로다(최소값).
double webFooterTopGap(BuildContext context) => context.isDesktop ? 120 : 80;

/// 작성 폼: 헤더 줄(← 제목 · 버튼) ↔ 첫 필드 — PC 40(피그마 62:98906) /
/// 태블릿·모바일 26(피그마 62:98390). 중고거래 올리기·수정·알림 설정, 커뮤니티 글쓰기 공통.
double webFormHeaderGap(BuildContext context) => context.isDesktop ? 40 : 26;

/// 목록 화면: 타이틀·검색 영역 ↔ 탭/필터 줄 — PC 30 / 태블릿 24 / 모바일 20
/// (중고거래 피그마 32:19273, 커뮤니티·랭킹·각종소식 공통).
double webTitleToFilterGap(BuildContext context) {
  switch (context.screenType) {
    case WebScreenType.desktop:
      return 30;
    case WebScreenType.tablet:
      return 24;
    case WebScreenType.mobile:
      return 20;
  }
}

/// 피드(라이브톡·크루톡) 맨 아래 여백 — PC 100 / 태블릿·모바일 40.
/// 태블릿·모바일은 하단 바 높이만큼 스크롤 여백이 이미 있어 덜 준다.
double webFeedBottomGap(BuildContext context) => context.isDesktop ? 100 : 40;

/// 홈(목록) 화면 공통 페이지 패딩 — 중고거래 홈 기준.
/// 좌우: PC 40 / 태블릿 20 / 모바일 16. 상단: PC 58 / 태블릿 20 / **모바일 16**.
/// 하단 기본 32.
///
/// ⚠️ 모바일 상단은 서브 페이지(12)보다 크다 — 목록은 상단바 바로 아래에 큰
/// 타이틀이 오는 구조라 12에서는 붙어 보인다(20에서 16으로 조정, 2026-09-26 확정).
EdgeInsets webHomePagePadding(BuildContext context, {double bottom = 32}) {
  switch (context.screenType) {
    case WebScreenType.desktop:
      return EdgeInsets.fromLTRB(40, 58, 40, bottom);
    case WebScreenType.tablet:
      return EdgeInsets.fromLTRB(20, 20, 20, bottom);
    case WebScreenType.mobile:
      return EdgeInsets.fromLTRB(16, 16, 16, bottom);
  }
}

/// 서브 페이지(뒤로가기 헤더가 있는 화면) 공통 페이지 패딩 — 중고거래 상세·폼 기준.
/// 좌우: PC 40 / 태블릿 20 / 모바일 16.
/// 상단: **PC 58 · 태블릿 20 · 모바일 16** — 세 폭 모두 홈·목록 화면과 같다
/// (PC 2026-10-01, 태블릿·모바일 2026-10-02 사용자 확정. 모바일은 한때 12였는데
/// 서브 페이지만 위가 떠 보여 홈과 같은 16으로 되돌렸다).
EdgeInsets webSubPagePadding(BuildContext context, {double bottom = 32}) {
  switch (context.screenType) {
    case WebScreenType.desktop:
      return EdgeInsets.fromLTRB(40, 58, 40, bottom);
    case WebScreenType.tablet:
      return EdgeInsets.fromLTRB(20, 20, 20, bottom);
    case WebScreenType.mobile:
      return EdgeInsets.fromLTRB(16, 16, 16, bottom);
  }
}

/// 1440px 초과 시 콘텐츠를 고정폭(1440)으로 얼리고 화면 중앙에 배치해서,
/// 초과분이 좌우 양쪽에 균등한 배경 여백으로 남도록 하는 래퍼.
class FrozenWidthCanvas extends StatelessWidget {
  final Widget child;

  const FrozenWidthCanvas({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: WebBreakpoints.maxContentWidth),
        child: child,
      ),
    );
  }
}
