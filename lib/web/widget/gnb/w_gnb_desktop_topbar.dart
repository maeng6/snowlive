import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/web_profile_nav_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_nav_items.dart'
    show reloadToHomeWeb;
import 'package:com.snowlive/web/view/friend/w_friend_live_popup_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/util/web_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';

const double kGnbDesktopTopBarHeight = 56;

/// 데스크탑 상단바의 **글자 버튼** 공통 스타일(`로그인`).
/// 배경 없이 글자만, hover에서 LNB 메뉴와 같은 gray50 면이 깔린다 —
/// 리플·그림자·전환 애니메이션은 쓰지 않는다(웹 공통).
ButtonStyle _topBarTextButtonStyle() => ButtonStyle(
  elevation: const WidgetStatePropertyAll(0),
  shadowColor: const WidgetStatePropertyAll(Colors.transparent),
  overlayColor: const WidgetStatePropertyAll(Colors.transparent),
  splashFactory: NoSplash.splashFactory,
  animationDuration: Duration.zero,
  padding: const WidgetStatePropertyAll(
    EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  ),
  visualDensity: VisualDensity.standard,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
  backgroundColor: WidgetStateProperty.resolveWith(
    (states) => states.contains(WidgetState.hovered)
        ? SDSColor.gray50
        : Colors.transparent,
  ),
);

/// 데스크탑 전용 최상단 바: 로고(좌) + 로그인/회원가입 또는 로그인 상태(우).
/// 사이드바와 본문 콘텐츠 위에 전체 폭으로 걸쳐 있는 별도 영역이다.
class WebGnbDesktopTopBar extends StatelessWidget {
  const WebGnbDesktopTopBar({super.key});

  Future<void> _signOut() async {
    // signOut()이 세션·status·유저 모델을 모두 비운다.
    await Get.find<AuthCheckViewModelWeb>().signOut();
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
              // 로고 탭 → 홈으로 **브라우저 전체 새로고침**(사용자 확정).
              onTap: () => reloadToHomeWeb(),
              child: SvgPicture.asset(
                'assets/imgs/logos/snowlive_logo_black_web.svg',
                height: 22,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          const Spacer(),
          // PC는 아이콘 대신 **텍스트 버튼 `내 친구`**(사용자 확정) — 태블릿·모바일
          // 상단바는 앱처럼 친구 아이콘을 그대로 쓴다.
          // 내용은 동일 — 앱의 '라이브중인 친구' 그리드 + 위치정보 팝업.
          // **로그인 전에는 숨긴다**(사용자 확정).
          Obx(() {
            final user = userVM.user;
            if (user == null || user.user_id == null) {
              return const SizedBox.shrink();
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 친구 — **아이콘**으로 되돌림(사용자 확정). 크기는 프로필 이미지와
                // 같은 28. hover는 웹 공통 아이콘 규칙(60% 페이드)인 WebIconButton.
                WebIconButton(
                  onTap: () => showFriendLivePopupWeb(context),
                  tooltip: '내 친구',
                  // 아이콘 자리를 프로필 이미지와 같은 28로 맞추려고 여백은 0.
                  padding: EdgeInsets.zero,
                  icon: Image.asset(
                    'assets/imgs/icons/icon_friend_resortHome.png',
                    width: 28,
                    height: 28,
                  ),
                ),
                // 내 친구 ↔ 프로필 이미지 사이 **연한 구분선**(1×12 gray200).
                // 좌우 16씩 비워 글자↔선, 선↔이미지가 같은 간격이 된다(합 32).
                Container(
                  width: 1,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: SDSColor.gray200,
                ),
              ],
            );
          }),
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
                  style: _topBarTextButtonStyle(),
                  child: Text(
                    '로그인',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 13,
                      color: SDSColor.snowliveBlack,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: () => Get.toNamed(WebRoutes.login),
                  style: ButtonStyle(
                    elevation: const WidgetStatePropertyAll(0),
                    shadowColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    overlayColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    splashFactory: NoSplash.splashFactory,
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // hover 시 배경색 90% 불투명도
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.hovered)
                          ? SDSColor.gray900.withOpacity(0.8)
                          : SDSColor.gray900,
                    ),
                  ),
                  child: Text(
                    '회원가입',
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 13,
                      color: SDSColor.snowliveWhite,
                    ),
                  ),
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

/// 로그인 상태의 프로필 영역 — **아이디 + 프로필 이미지**(사용자 확정: 아이디가 왼쪽,
/// 이미지가 오른쪽). 누르면 공용 드롭다운(마이페이지/로그아웃)이 열린다.
/// 상단바에 프로필을 두는 건 데스크탑뿐이다(태블릿·모바일은 드로어가 담당).
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

    // 태블릿에서도 딤 시트가 아니라 PC와 같은 앵커 드롭다운을 쓴다.
    final selected = await showWebAnchoredDropdown<_ProfileMenuAction>(
      context: context,
      link: _link,
      builder: (_, close, anchorWidth) =>
          WebFilterDropdownPanel<_ProfileMenuAction>(
            title: null,
            // 멤버십은 기획 전이라 숨긴다(kWebMembershipEnabled).
            values: [
              for (final action in _ProfileMenuAction.values)
                if (kWebMembershipEnabled ||
                    action != _ProfileMenuAction.membership)
                  action,
            ],
            labelOf: labelOf,
            onPick: close,
            minWidth: anchorWidth,
          ),
    );
    switch (selected) {
      case _ProfileMenuAction.myPage:
        // 다른 상세 진입과 **같은 push 정책**(사용자 확정) — 스택을 리셋하면 탭 이동
        // 히스토리가 날아가 브라우저 뒤로가기가 먹통이 된다. 프로필 위에서 또 누르면
        // 교체되므로 중복으로 쌓이지 않는다.
        pushWebProfileRoute(widget.userId!);
      case _ProfileMenuAction.membership:
        // 화면이 아직 없어 준비 중 안내만 띄운다(드로어와 동일).
        showWebToast(context, '멤버십 업그레이드는 아직 준비 중이에요.', title: '준비 중입니다');
      case _ProfileMenuAction.logout:
        await widget.onSignOut();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? profileUrl = widget.profileUrl;

    // 프로필 이미지(원형). 아이디 텍스트를 뺀 대신 24 → 28로 키웠다(사용자 확정).
    // 이미지가 없거나 깨지면 기본 아이콘.
    const double size = 28;
    final Widget avatar = ClipOval(
      child: (profileUrl != null && profileUrl.isNotEmpty)
          ? Image.network(
              profileUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.account_circle,
                size: size,
                color: SDSColor.gray300,
              ),
            )
          : Icon(Icons.account_circle, size: size, color: SDSColor.gray300),
    );

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
              Text(
                widget.displayName,
                // 아이디 Regular 14 gray900.
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 14,
                  color: SDSColor.gray900,
                ),
              ),
              // 아이디 ↔ 프로필 이미지 10(사용자 확정 — 6은 붙어 보였다).
              const SizedBox(width: 10),
              avatar,
            ],
          ),
        ),
      ),
    );
  }
}
