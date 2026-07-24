import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 좌하단 고정 앱 다운로드 유도 배너 (데스크탑 전용, 페이지 무관 정적 카드).
class AppDownloadBannerWeb extends StatelessWidget {
  const AppDownloadBannerWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SDSColor.gray900,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/imgs/logos/snowliveLogo_main_white.png',
            width: 60,
            height: 20,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              '스노우라이브 앱 다운 받아,\n라이딩에 재미를 더하세요',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.snowliveWhite, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
