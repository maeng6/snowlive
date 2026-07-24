import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double kGnbDesktopTopBarHeight = 72;

/// 데스크탑 전용 최상단 바: 로고(좌) + 로그인/회원가입(우).
/// 사이드바와 본문 콘텐츠 위에 전체 폭으로 걸쳐 있는 별도 영역이다.
class WebGnbDesktopTopBar extends StatelessWidget {
  const WebGnbDesktopTopBar({super.key});

  @override
  Widget build(BuildContext context) {
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
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Get.snackbar('준비 중입니다', '로그인 기능은 준비 중이에요.'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            child: Text('로그인', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray700)),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: () => Get.snackbar('준비 중입니다', '회원가입 기능은 준비 중이에요.'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SDSColor.gray900,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            child: Text('회원가입', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite)),
          ),
        ],
      ),
    );
  }
}
