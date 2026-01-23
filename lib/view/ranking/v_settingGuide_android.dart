import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AndroidSettingGuideView extends StatelessWidget {
  final ResortHomeViewModel _resortHomeViewModel = Get.find<ResortHomeViewModel>();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFF222222),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          leading: Padding(
          padding: EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: SvgPicture.asset('assets/imgs/icons/icon_snowLive_back.svg', width: 26, height: 26, colorFilter: ColorFilter.mode(SDSColor.snowliveWhite, BlendMode.srcIn)),
            highlightColor: Colors.transparent,
          ),
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
          width: _size.width, // 화면 가로 크기에 맞추어 설정
          child: ExtendedImage.network(
            _resortHomeViewModel.rankingGuideUrl_aos,
            cache: true,
            cacheWidth: 800,
            fit: BoxFit.cover, // 이미지를 부모 너비에 맞추어 조정
            loadStateChanged: (ExtendedImageState state) {
              switch (state.extendedImageLoadState) {
                case LoadState.loading:
                  return Shimmer.fromColors(
                    baseColor: SDSColor.gray200,
                    highlightColor: SDSColor.gray50,
                    child: Container(
                      width: double.infinity,
                      height: 300, // 로딩 중 기본 높이 설정
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
