import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class IosSettingGuideView extends StatelessWidget {
  final ResortHomeViewModel _resortHomeViewModel = Get.find<ResortHomeViewModel>();

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
            child: Text(
              '설정 가이드',
              style: SDSTextStyle.extraBold.copyWith(
                color: SDSColor.snowliveWhite,
                fontSize: 18,
              ),
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
            _resortHomeViewModel.rankingGuideUrl_ios,
            cache: true,
            cacheWidth: 800,
            fit: BoxFit.cover,
            loadStateChanged: (ExtendedImageState state) {
              switch (state.extendedImageLoadState) {
                case LoadState.loading:
                  return Shimmer.fromColors(
                    baseColor: SDSColor.gray200,
                    highlightColor: SDSColor.gray50,
                    child: Container(
                      width: double.infinity,
                      height: 300, // 로딩 시 임시 높이 설정
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
