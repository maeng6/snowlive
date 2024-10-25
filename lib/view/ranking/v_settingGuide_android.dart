import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class AndroidSettingGuideView extends StatelessWidget {

  ResortHomeViewModel _resortHomeViewModel = Get.find<ResortHomeViewModel>();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFF222222),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              scale: 4,
              width: 26,
              height: 26,
              color: SDSColor.snowliveWhite,
            ),
            onTap: () {
              Get.back();
            },
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Column(
              children: [
                Text(
                  '설정 가이드',
                  style: SDSTextStyle.extraBold.copyWith(
                      color: SDSColor.snowliveWhite,
                      fontSize: 18),
                ),
              ],
            ),
          ),
          centerTitle: true,
          titleSpacing: 0,
          backgroundColor: Color(0xFF222222),
          foregroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: ExtendedImage.network(
            _resortHomeViewModel.rankingGuideUrl_aos,
            cache: true,
            scale: 1,
            width: _size.width, // 화면의 가로 전체를 차지하게 설정
            loadStateChanged: (ExtendedImageState state) {
              switch (state.extendedImageLoadState) {
                case LoadState.loading:
                  return Shimmer.fromColors(
                    baseColor: SDSColor.gray200,
                    highlightColor: SDSColor.gray50,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.white,
                    ),
                  );
                case LoadState.completed:
                  return state.completedWidget;
                case LoadState.failed:
                  return Center(child: Text('Failed to load image'));
              }
            },
          ),
        ),
      ),
    );
  }
}
