import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_nav_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 태블릿/모바일 전용 드로어. 사이드바와 동일한 nav 구성을 공유한다.
class WebGnbDrawer extends StatelessWidget {
  const WebGnbDrawer({super.key});

  Future<void> _signOut(BuildContext context) async {
    Navigator.of(context).pop();
    await Get.find<AuthCheckViewModelWeb>().signOut();
    Get.find<UserViewModel>().resetUser();
    Get.offAllNamed(WebRoutes.fleamarketList);
  }

  @override
  Widget build(BuildContext context) {
    final UserViewModel userVM = Get.find<UserViewModel>();

    return Drawer(
      backgroundColor: SDSColor.snowliveWhite,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          children: [
            Obx(() {
              final user = userVM.user;
              final bool isLoggedIn = user != null && user.user_id != null;
              if (isLoggedIn) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${user.display_name ?? ''}님',
                        style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _signOut(context),
                      child: Text('로그아웃', style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray700)),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Get.toNamed(WebRoutes.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        // 호버/클릭 오버레이와 그림자를 끈다(데스크탑 상단바와 동일 처리).
                        shadowColor: Colors.transparent,
                        overlayColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text('로그인', style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Get.toNamed(WebRoutes.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SDSColor.gray900,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        overlayColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text('회원가입', style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.snowliveWhite)),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
            for (final item in kGnbPrimaryItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: GnbNavRow(item: item, onNavigate: () => Navigator.of(context).pop()),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: SDSColor.gray100, height: 1),
            ),
            for (final item in kGnbSecondaryItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: GnbNavRow(item: item, onNavigate: () => Navigator.of(context).pop()),
              ),
          ],
        ),
      ),
    );
  }
}
