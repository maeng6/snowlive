import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ForestParkMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? mapImage = Get.arguments as String?;

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
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              color: SDSColor.snowliveWhite,
              scale: 4,
              width: 26,
              height: 26,
            ),
            onTap: () {
              Get.back();
            },
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
          child: ExtendedImage.network(
            mapImage ?? '',
            width: double.infinity,
            fit: BoxFit.cover,
            cache: true,
            loadStateChanged: (state) {
              if (state.extendedImageLoadState == LoadState.failed) {
                return Column(
                  children: [
                    Text('지도를 불러올 수 없습니다',
                      style: SDSTextStyle.regular.copyWith(
                          fontSize: 13,
                          color: SDSColor.snowliveWhite.withOpacity(0.5)
                      ),)
                  ],
                );
              }
              return null;
            },
          )
      ),
    );
  }
}

