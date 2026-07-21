import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ForestParkMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? mapImage = Get.arguments as String?;
    Size _size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          title: Text(
            '열매 지도',
            style: SDSTextStyle.extraBold.copyWith(
              color: SDSColor.snowliveWhite,
              fontSize: 18,
            ),
          ),
          leading: Padding(
          padding: EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: SvgPicture.asset('assets/imgs/icons/icon_snowLive_back.svg', width: 26, height: 26, colorFilter: ColorFilter.mode(SDSColor.snowliveWhite, BlendMode.srcIn)),
            highlightColor: Colors.transparent,
          ),
        ),
          backgroundColor: Color(0xFF12341E),
          surfaceTintColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          titleSpacing: 0,
        ),
      ),
      backgroundColor: Color(0xFF12341E),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    if (mapImage != null && mapImage!.isNotEmpty) {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "ImageZoom",
                        barrierColor: Color(0xFF12341E).withOpacity(0.85),
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Material(
                              color: Colors.transparent,
                              child: InteractiveViewer(
                                panEnabled: true,
                                minScale: 1,
                                maxScale: 5,
                                child: SizedBox.expand( // ✅ 전체 화면 기준으로 이미지 확대
                                  child: ExtendedImage.network(
                                    mapImage!,
                                    fit: BoxFit.contain,
                                    cache: true,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );

                    }
                  },
                  child: ExtendedImage.network(
                    mapImage ?? '',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cache: true,
                    loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          return Container(
                            width: double.infinity,
                            height: _size.width + 60,
                            color: Color(0xFF12341E),
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              strokeWidth: 4,
                              backgroundColor: Color.fromRGBO(0, 0, 0, 0.3),
                              color: Colors.white,
                            ),
                          );
                        case LoadState.failed:
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '지도를 불러올 수 없습니다',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 13,
                                  color: SDSColor.snowliveWhite.withOpacity(0.5),
                                ),
                              ),
                            ],
                          );
                        case LoadState.completed:
                        // 이미지 로드 완료 시엔 원본 이미지를 그대로
                          return null;
                      }
                    },
                  ),
              ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text('열매가 숨겨진 위치를 열매지도에서 확인해 보세요',
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 16,
                        color: SDSColor.snowliveWhite
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 100),
                    child: Text('지도를 클릭하면 확대해서 확인하실 수 있어요.',
                      style: SDSTextStyle.regular.copyWith(
                          fontSize: 13,
                          color: SDSColor.snowliveWhite.withOpacity(0.5)
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }
}

