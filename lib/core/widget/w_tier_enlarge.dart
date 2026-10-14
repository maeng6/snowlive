import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 티어 이미지 확대 보기 다이얼로그.
/// 어두운 배경(딤) 어디를 눌러도 닫힌다(behavior: opaque + 전체화면 탭 캐처).
/// nameEng/nameKor가 있으면 이미지 아래에 등급명을 함께 보여준다.
void showTierEnlargeDialog(
  BuildContext context,
  String? imageUrl, {
  String? nameEng,
  String? nameKor,
}) {
  if (imageUrl == null || imageUrl.isEmpty) return;
  final width = MediaQuery.of(context).size.width - 72;
  final hasName = (nameEng ?? '').isNotEmpty || (nameKor ?? '').isNotEmpty;
  showDialog(
    barrierColor: Colors.black.withValues(alpha: 0.85),
    context: context,
    builder: (BuildContext context) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque, // 딤 배경 어디를 눌러도 닫히게
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width,
                child: ExtendedImage.network(imageUrl, cache: true),
              ),
              if (hasName)
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Column(
                    children: [
                      if ((nameEng ?? '').isNotEmpty)
                        Text(nameEng!,
                            style: GoogleFonts.bebasNeue(
                                color: SDSColor.snowliveWhite, fontSize: 36)),
                      if ((nameKor ?? '').isNotEmpty)
                        Text(nameKor!,
                            style: SDSTextStyle.bold.copyWith(
                                color: SDSColor.snowliveWhite.withValues(alpha: 0.5),
                                fontSize: 16)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
