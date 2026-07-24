import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_nav_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 태블릿/모바일 전용 드로어. 사이드바와 동일한 nav 구성을 공유한다.
class WebGnbDrawer extends StatelessWidget {
  const WebGnbDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: SDSColor.snowliveWhite,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Get.snackbar('준비 중입니다', '로그인 기능은 준비 중이에요.');
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: SDSColor.gray200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text('로그인', style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Get.snackbar('준비 중입니다', '회원가입 기능은 준비 중이에요.');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.gray900,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    child: Text('회원가입', style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.snowliveWhite)),
                  ),
                ),
              ],
            ),
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
