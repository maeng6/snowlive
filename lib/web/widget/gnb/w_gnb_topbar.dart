import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_nav_items.dart'
    show GnbLiveTalkDot, reloadToHomeWeb;
import 'package:com.snowlive/web/view/friend/w_friend_live_popup_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// 태블릿/모바일(<1024px) 전용 상단바: 로고 + (태블릿 로그인 시 프로필) + 햄버거.
/// 햄버거는 메뉴 패널 상태에 따라 X로 모프된다(AnimatedIcon).
class WebGnbTopbar extends StatelessWidget implements PreferredSizeWidget {
  /// 메뉴 패널 열림 진행도(0=햄버거, 1=X).
  final Animation<double> menuProgress;
  final VoidCallback onMenuTap;

  /// 로고 탭 시 (홈 이동 전에) 호출 — 셸이 열린 메뉴를 닫는 데 쓴다.
  final VoidCallback? onLogoTap;

  const WebGnbTopbar({
    super.key,
    required this.menuProgress,
    required this.onMenuTap,
    this.onLogoTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final UserViewModel userVM = Get.find<UserViewModel>();
    final bool isTablet = context.screenType == WebScreenType.tablet;

    return Container(
      height: preferredSize.height,
      // 우측: 모바일 12 / 태블릿 16 (좌측은 공통 16).
      padding: EdgeInsets.only(left: 16, right: isTablet ? 16 : 8),
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        border: Border(bottom: BorderSide(color: SDSColor.gray100)),
      ),
      child: Row(
        children: [
          // 로고 탭 → 홈 이동, 이미 홈이면 맨 위로 + 새로고침(데스크탑과 동일).
          // 메뉴가 열려 있으면 닫는다.
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                onLogoTap?.call();
                // 로고 탭 → 홈으로 **브라우저 전체 새로고침**(사용자 확정).
                reloadToHomeWeb();
              },
              child: SvgPicture.asset(
                'assets/imgs/logos/snowlive_logo_black_web.svg',
                height: 22,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Spacer(),
          // 프로필은 상단바에 두지 않는다 — **태블릿도 모바일과 같이** 드로어의
          // 프로필 블록이 담당한다(사용자 확정). 데스크탑만 상단바에 노출한다.
          // 햄버거 왼쪽 친구 아이콘(앱 리조트홈 친구 아이콘과 동일 역할).
          // 앱처럼 '라이브중인 친구' 그리드 + 위치정보 팝업을 띄운다.
          // **로그인 전에는 숨긴다**(사용자 확정) — 친구 목록이 없는 상태라
          // 눌러도 로그인 유도만 뜬다.
          Obx(() {
            final user = userVM.user;
            if (user == null || user.user_id == null) {
              return const SizedBox.shrink();
            }
            return IconButton(
              onPressed: () {
                onLogoTap?.call();
                showFriendLivePopupWeb(context);
              },
              tooltip: '친구',
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              style: const ButtonStyle(
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
              ),
              icon: Image.asset(
                'assets/imgs/icons/icon_friend_resortHome.png',
                width: 26,
                height: 26,
              ),
            );
          }),
          // 햄버거 아이콘 + 라이브톡 새 글 빨간점(메뉴 안에 새 글 알림이 있음을 표시).
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onMenuTap,
                // 탭 시 파란 리플(테마 기본색)이 비치지 않게 효과를 전부 끈다.
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                // Material3 IconButton은 위 색 대신 style의 overlayColor를 쓴다
                style: const ButtonStyle(
                  overlayColor: WidgetStatePropertyAll(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                ),
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: menuProgress,
                  color: SDSColor.gray900,
                ),
              ),
              const Positioned(
                right: 10,
                top: 10,
                child: GnbLiveTalkDot(padLeft: false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
