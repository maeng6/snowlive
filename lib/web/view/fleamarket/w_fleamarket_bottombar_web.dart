import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double kFleamarketBottomBarHeight = 64;

/// 태블릿/모바일 전용 하단 고정 2버튼 바.
class FleamarketBottomBarWeb extends StatelessWidget {
  const FleamarketBottomBarWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kFleamarketBottomBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: SDSSpacing.md, vertical: SDSSpacing.sm),
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        border: Border(top: BorderSide(color: SDSColor.gray100)),
      ),
      child: Row(
        children: [
          // Expanded(
          //   child: OutlinedButton(
          //     onPressed: () => Get.toNamed(WebRoutes.fleamarketAlert),
          //     style: OutlinedButton.styleFrom(
          //       side: BorderSide(color: SDSColor.gray200),
          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          //     ),
          //     child: Text('키워드 알림 설정', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
          //   ),
          // ),
          // const SizedBox(width: SDSSpacing.sm),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Get.toNamed(WebRoutes.fleamarketUpload),
              style: ElevatedButton.styleFrom(
                backgroundColor: SDSColor.snowliveBlue,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text('중고거래 물품 올리기', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.snowliveWhite)),
            ),
          ),
        ],
      ),
    );
  }
}
