import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:flutter/material.dart';
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
          Image.asset(
            'assets/imgs/logos/snowliveLogo_main_new.png',
            height: 28,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            color: Colors.black,
            colorBlendMode: BlendMode.srcIn,
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
                TextButton(
                  onPressed: () => Get.toNamed(WebRoutes.login),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  child: Text('로그인', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray700)),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: () => Get.toNamed(WebRoutes.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SDSColor.gray900,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  child: Text('회원가입', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite)),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
