import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_desktop_topbar.dart';
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

  Future<void> _signOut() async {
    await Get.find<AuthCheckViewModelWeb>().signOut();
    Get.find<UserViewModel>().resetUser();
    Get.offAllNamed(WebRoutes.home);
  }

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
          // 로고 탭 → 홈 이동(데스크탑과 동일). 메뉴가 열려 있으면 닫는다.
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                onLogoTap?.call();
                Get.toNamed(WebRoutes.home);
              },
              child: SvgPicture.asset(
                'assets/imgs/logos/snowlive_logo_black_web.svg',
                height: 22,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Spacer(),
          // 태블릿에서는 로그인 시 프로필+아이디를 노출한다(데스크탑과 동일 드롭다운)
          // 모바일은 드로어의 프로필 블록이 담당하므로 상단바에는 두지 않는다.
          if (isTablet)
            Obx(() {
              final user = userVM.user;
              final bool isLoggedIn = user != null && user.user_id != null;
              if (!isLoggedIn) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GnbProfileMenuButton(
                  profileUrl: user.profile_image_url_user,
                  displayName: user.display_name ?? '',
                  userId: user.user_id,
                  onSignOut: _signOut,
                ),
              );
            }),
          IconButton(
            onPressed: onMenuTap,
            // 탭 시 파란 리플(테마 기본색)이 비치지 않게 효과를 전부 끈다
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            // Material3 IconButton은 위 색 대신 style의 overlayColor를 쓴다.
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
        ],
      ),
    );
  }
}
