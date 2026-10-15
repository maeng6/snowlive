import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_back_icon_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:flutter/material.dart';

/// 서브 페이지 공통 헤더 — 뒤로가기(PC·태블릿 30 / 모바일 24, hover 페이드) +
/// 간격 3 + 타이틀 bold PC 30 / 태블릿·모바일 24,
/// 우측에 액션(버튼 등)을 붙일 수 있다. 중고거래 폼(피그마 62:98906)에서 확정한
/// 구성을 전 화면 표준으로 쓴다.
class WebPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  /// 타이틀 오른쪽 끝에 붙는 위젯들(등록/저장 버튼 등). 비우면 타이틀만.
  final List<Widget> actions;

  /// 뒤로가기 노출 여부 — **태블릿·모바일 기준**이다.
  /// PC에서는 기본적으로 숨긴다: GNB 사이드바와 브라우저 뒤로가기가 있어
  /// 화면 안 뒤로가기가 중복이다(사용자 확정).
  final bool showBack;

  /// PC에서도 뒤로가기를 남긴다.
  /// 사이드바에 진입점이 없어 새 탭·새로고침으로 들어오면 돌아갈 길이 막히는
  /// 화면(크루 설정 계열)만 켠다.
  final bool showBackOnDesktop;

  /// false면 타이틀이 남은 폭을 차지하지 않는다 — 헤더 오른쪽에 검색바 등
  /// 다른 요소를 같은 줄에 이어 붙이는 화면(랭킹 기록실)용
  final bool expandTitle;

  /// 사이드바 최상위 화면(친구·알림·설정)은 서브 페이지가 아니라 **목록 홈**이라
  /// 홈과 같은 타이틀을 쓴다 — extraBold, `webHomeTitleSize`(PC 32 / 24 / 20).
  /// 기본값은 서브 페이지 표준(bold, `webSubPageTitleSize` — PC 30 / 24 / 20).
  final bool useHomeTitle;

  const WebPageHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.actions = const [],
    this.showBack = true,
    this.expandTitle = true,
    this.useHomeTitle = false,
    this.showBackOnDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final titleText = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: (useHomeTitle ? SDSTextStyle.extraBold : SDSTextStyle.bold).copyWith(
        // 서브 페이지는 PC 30 / 태블릿 24 / 모바일 20 — 모바일은 목록 화면
        // 타이틀(webHomeTitleSize)과 같은 20으로 맞췄다(서브 페이지 전체 공통).
        fontSize: useHomeTitle ? webHomeTitleSize(context) : webSubPageTitleSize(context),
        color: SDSColor.gray900,
      ),
    );

    // PC는 사이드바·브라우저 뒤로가기가 있어 화면 안 뒤로가기를 두지 않는다
    // ([showBackOnDesktop]을 켠 화면만 예외).
    final showBackIcon = showBack && (!context.isDesktop || showBackOnDesktop);

    return Row(
      mainAxisSize: expandTitle ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (showBackIcon) ...[
          WebIconButton(
            onTap: onBack,
            // 좌측 히트 여백은 0 — 아이콘이 콘텐츠 좌측선에 붙는다.
            // ⚠️ 세로 여백도 0 — 4를 주면 줄 높이가 아이콘(30)+8 = 38이 되어
            // 타이틀이 내려앉고 아래 요소가 전부 밀린다(목업 줄 높이는 텍스트 기준).
            padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
            icon: WebBackIcon(size: isMobile ? 24 : 30),
          ),
          const SizedBox(width: 3),
        ],
        if (expandTitle) Expanded(child: titleText) else titleText,
        ...actions,
      ],
    );
  }
}
