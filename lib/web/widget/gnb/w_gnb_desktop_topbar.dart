import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

const double kGnbDesktopTopBarHeight = 56;

/// 데스크탑 전용 최상단 바: 로고(좌) + 로그인/회원가입 또는 로그인 상태(우).
/// 사이드바와 본문 콘텐츠 위에 전체 폭으로 걸쳐 있는 별도 영역이다.
class WebGnbDesktopTopBar extends StatelessWidget {
  const WebGnbDesktopTopBar({super.key});

  Future<void> _signOut() async {
    await Get.find<AuthCheckViewModelWeb>().signOut();
    Get.find<UserViewModel>().resetUser();
    Get.offAllNamed(WebRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final UserViewModel userVM = Get.find<UserViewModel>();

    return Container(
      height: kGnbDesktopTopBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        border: Border(bottom: BorderSide(color: SDSColor.gray100)),
      ),
      child: Row(
        children: [
          // 웹 전용 로고는 벡터(SVG)라 배율에 상관없이 선명하다. 에셋 자체가 이미
          // 검정이라 PNG 때처럼 srcIn으로 덧칠할 필요가 없다.
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Get.toNamed(WebRoutes.home),
              child: SvgPicture.asset(
                'assets/imgs/logos/snowlive_logo_black_web.svg',
                height: 22,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          const Spacer(),
          Obx(() {
            final user = userVM.user;
            final bool isLoggedIn = user != null && user.user_id != null;
            if (isLoggedIn) {
              return GnbProfileMenuButton(
                profileUrl: user.profile_image_url_user,
                displayName: user.display_name ?? '',
                userId: user.user_id,
                onSignOut: _signOut,
              );
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => Get.toNamed(WebRoutes.login),
                  style: ButtonStyle(
                    elevation: const WidgetStatePropertyAll(0),
                    shadowColor: const WidgetStatePropertyAll(Colors.transparent),
                    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                    shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                    // hover 시 LNB 메뉴와 동일한 배경(gray50).
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.hovered)
                          ? SDSColor.gray50
                          : Colors.transparent,
                    ),
                  ),
                  child: Text('로그인', style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.snowliveBlack)),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: () => Get.toNamed(WebRoutes.login),
                  style: ButtonStyle(
                    elevation: const WidgetStatePropertyAll(0),
                    shadowColor: const WidgetStatePropertyAll(Colors.transparent),
                    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                    shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                    // hover 시 배경색 90% 불투명도
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.hovered)
                          ? SDSColor.gray900.withOpacity(0.8)
                          : SDSColor.gray900,
                    ),
                  ),
                  child: Text('회원가입', style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.snowliveWhite)),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

enum _ProfileMenuAction { myPage, membership, logout }

/// 로그인 상태의 프로필 영역(아바타 24 + 아이디). 누르면 공용 드롭다운
/// (마이페이지/로그아웃)이 열린다. 데스크탑·태블릿 상단바가 공유한다.
class GnbProfileMenuButton extends StatefulWidget {
  final String? profileUrl;
  final String displayName;
  final dynamic userId;
  final Future<void> Function() onSignOut;

  const GnbProfileMenuButton({
    required this.profileUrl,
    required this.displayName,
    required this.userId,
    required this.onSignOut,
  });

  @override
  State<GnbProfileMenuButton> createState() => GnbProfileMenuButtonState();
}

class GnbProfileMenuButtonState extends State<GnbProfileMenuButton> {
  final LayerLink _link = LayerLink();

  Future<void> _open() async {
    String labelOf(_ProfileMenuAction v) => switch (v) {
          _ProfileMenuAction.myPage => '마이페이지',
          _ProfileMenuAction.membership => '멤버십 업그레이드',
          _ProfileMenuAction.logout => '로그아웃',
        };

    // 태블릿에서도 딤 시트가 아니라 PC와 같은 앵커 드롭다운을 쓴다(요청).
    final selected = await showWebAnchoredDropdown<_ProfileMenuAction>(
      context: context,
      link: _link,
      builder: (_, close, anchorWidth) => WebFilterDropdownPanel<_ProfileMenuAction>(
        title: null,
        values: _ProfileMenuAction.values,
        labelOf: labelOf,
        onPick: close,
        minWidth: anchorWidth,
      ),
    );
    switch (selected) {
      case _ProfileMenuAction.myPage:
        Get.toNamed('${WebRoutes.userProfile}?id=${widget.userId}');
      case _ProfileMenuAction.membership:
        // 화면이 아직 없어 준비 중 안내만 띄운다(드로어와 동일).
        Get.snackbar('준비 중입니다', '멤버십 업그레이드는 아직 준비 중이에요.');
      case _ProfileMenuAction.logout:
        await widget.onSignOut();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? profileUrl = widget.profileUrl;
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _open,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 프로필 이미지(원형 24x24). 이미지가 없으면 기본 아이콘.
              ClipOval(
                child: (profileUrl != null && profileUrl.isNotEmpty)
                    ? Image.network(
                        profileUrl,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.account_circle, size: 24, color: SDSColor.gray300),
                      )
                    : Icon(Icons.account_circle, size: 24, color: SDSColor.gray300),
              ),
              const SizedBox(width: 6),
              Text(
                widget.displayName,
                // 아이디: PC 14 / 태블릿 13.
                style: SDSTextStyle.regular.copyWith(
                  fontSize:
                      context.screenType == WebScreenType.tablet ? 13 : 14,
                  color: SDSColor.gray900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
