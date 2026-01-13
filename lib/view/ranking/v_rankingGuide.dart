import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class RankingGuideMainView extends StatelessWidget {
  final ResortHomeViewModel _resortHomeViewModel = Get.find<ResortHomeViewModel>();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: SDSColor.snowliveWhite,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              scale: 4,
              width: 26,
              height: 26,
            ),
            onTap: () {
              Get.back();
            },
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Text(
              '랭킹 가이드',
              style: SDSTextStyle.extraBold.copyWith(
                color: SDSColor.gray900,
                fontSize: 18,
              ),
            ),
          ),
          centerTitle: true,
          titleSpacing: 0,
          backgroundColor: SDSColor.snowliveWhite,
          foregroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: SDSColor.snowliveWhite,
                    child: ExtendedImage.network(
                      _resortHomeViewModel.rankingGuideUrl_main,
                      cache: true,
                      cacheWidth: 800,
                      width: _size.width,
                      fit: BoxFit.cover,
                      loadStateChanged: (ExtendedImageState state) {
                        switch (state.extendedImageLoadState) {
                          case LoadState.loading:
                            return Shimmer.fromColors(
                              baseColor: SDSColor.gray200,
                              highlightColor: SDSColor.gray50,
                              child: Container(
                                width: double.infinity,
                                height: 300, // 높이 고정
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
                  SizedBox(height: 80),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: _size.width,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.iosSettingGuide);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: SDSColor.gray50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'iOS 설정방법',
                                style: SDSTextStyle.bold.copyWith(
                                    color: SDSColor.gray700,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.androidSettingGuide);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: SDSColor.gray50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Android 설정방법',
                                style: SDSTextStyle.bold.copyWith(
                                  color: SDSColor.gray700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
