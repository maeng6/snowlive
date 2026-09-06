import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

const double kGnbDesktopTopBarHeight = 72;

/// 데스크탑 전용 최상단 바: 로고(좌) + 로그인/회원가입 또는 로그인 상태(우).
/// 사이드바와 본문 콘텐츠 위에 전체 폭으로 걸쳐 있는 별도 영역이다.
class WebGnbDesktopTopBar extends StatelessWidget {
  const WebGnbDesktopTopBar({super.key});

  Future<void> _signOut() async {
    await Get.find<AuthCheckViewModelWeb>().signOut();
    Get.find<UserViewModel>().resetUser();
    Get.offAllNamed(WebRoutes.fleamarketList);
  }

  @override
  Widget build(BuildContext context) {
    final UserViewModel userVM = Get.find<UserViewModel>();

    return Container(
      height: kGnbDesktopTopBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        border: Border(bottom: BorderSide(color: SDSColor.gray100)),
      ),
      child: Row(
        children: [
          // 웹 전용 로고는 벡터(SVG)라 배율에 상관없이 선명하다. 에셋 자체가 이미
          // 검정이라 PNG 때처럼 srcIn으로 덧칠할 필요가 없다.
          SvgPicture.asset(
            'assets/imgs/logos/snowlive_logo_black_web.svg',
            height: 22,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
          ),
          const Spacer(),
          Obx(() {
            final user = userVM.user;
            final bool isLoggedIn = user != null && user.user_id != null;
            if (isLoggedIn) {
              return Row(
                children: [
                  Text(
                    '${user.display_name ?? ''}님',
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _signOut,
                    child: Text('로그아웃', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray700)),
                  ),
                ],
              );
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => Get.toNamed(WebRoutes.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    // 호버/클릭 시 깔리는 오버레이와 그림자를 끈다(필터 pill과 동일 처리).
                    shadowColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text('로그인', style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.snowliveBlack)),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: () => Get.toNamed(WebRoutes.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SDSColor.gray900,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
