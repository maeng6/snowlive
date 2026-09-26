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

  /// 뒤로가기 노출 여부(설정처럼 데스크탑에선 사이드바가 있어 뒤로가기가 없는 화면).
  final bool showBack;

  /// false면 타이틀이 남은 폭을 차지하지 않는다 — 헤더 오른쪽에 검색바 등
  /// 다른 요소를 같은 줄에 이어 붙이는 화면(랭킹 기록실)용
  final bool expandTitle;

  const WebPageHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.actions = const [],
    this.showBack = true,
    this.expandTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final titleText = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: SDSTextStyle.bold.copyWith(
        fontSize: context.isDesktop ? 30 : 24,
        color: SDSColor.gray900,
      ),
    );

    return Row(
      mainAxisSize: expandTitle ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (showBack) ...[
          WebIconButton(
            onTap: onBack,
            // 좌측 히트 여백만 0 — 아이콘이 콘텐츠 좌측선에 붙는다.
            padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
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
