import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_snowball.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Entrance_snowballShop_ranking extends StatefulWidget {
  @override
  _Entrance_snowballShop_rankingState createState() => _Entrance_snowballShop_rankingState();
}

class _Entrance_snowballShop_rankingState extends State<Entrance_snowballShop_ranking> {
  UserViewModel _userViewModel = Get.find<UserViewModel>();
  SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();

  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _snowballShopViewModel.getInfo_snowballMarket_entrance_ranking();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      isLoading.value = true;
    });

    await _snowballShopViewModel.fetchSnowballSummaryOnly();

    if (!mounted) return;
    setState(() {
      isLoading.value = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Obx(() {
      final data = _snowballShopViewModel.infoData_snowballShop_entrance_ranking.value;

      if (data == null) {
        return SizedBox.shrink();
      }

      bool isOpen = data['open'] ?? false;
      bool isToEveryone = data['to_everyone'] ?? false;
      bool isBrandOnly = data['brand_only'] ?? false;
      List<dynamic> crewList = data['crew_list'] ?? [];
      bool isUserInCrewList = _userViewModel.user.crew_id != null && crewList.contains(_userViewModel.user.crew_id);




        if (isOpen == true && (isToEveryone || isUserInCrewList)) {
          return Container(
            decoration: BoxDecoration(
              color: isBrandOnly == false ? Color(0xFF1D242E) : Color(0xFF0C9F1E), // 배경색
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Stack(
              children: [
                // 이미지 영역
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () async {
                      _snowballShopViewModel.loadingEntrance = true;
                      if(isBrandOnly == true){
                        Get.toNamed(AppRoutes.snowballmarketBrandOnly);
                      }else{
                        Get.toNamed(AppRoutes.snowballmarket);
                      }
                      await _snowballShopViewModel.getInfo_snowballMarket();
                      await _snowballShopViewModel.fetchSnowballShop();
                      _snowballShopViewModel.loadingEntrance = false;
                      await _snowballShopViewModel.getInfo_snowballMarket_notice_gold();
                      await _snowballShopViewModel.fetchUserSnowballRecords();
                    },
                    child: Padding(
                        padding: EdgeInsets.only(top: 2),
                        child:
                        isBrandOnly == false
                            ? Image.asset(
                            'assets/imgs/imgs/snowballShop/img_rank_snb_src_1.png',
                            width: 105
                        )
                            : Image.asset(
                            'assets/imgs/imgs/snowballShop/img_rank_snb_src_brand_1.png',
                            width: 105
                        )
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    _snowballShopViewModel.loadingEntrance = true;
                    if(isBrandOnly == true){
                    Get.toNamed(AppRoutes.snowballmarketBrandOnly);
                    }else{
                      Get.toNamed(AppRoutes.snowballmarket);
                    }
                    await _snowballShopViewModel.fetchSnowballHomeData();
                    await _snowballShopViewModel.getInfo_snowballMarket();
                    _snowballShopViewModel.loadingEntrance = false;
                    await _snowballShopViewModel.getInfo_snowballMarket_notice_gold();
                    await _snowballShopViewModel.fetchUserSnowballRecords();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 8, bottom: 10, right: 16, left: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            isBrandOnly == false
                            ? Image.asset(
                              'assets/imgs/imgs/snowballShop/img_rank_snb_src_2.png',
                              height: 52,
                            )
                            : Image.asset(
                              'assets/imgs/imgs/snowballShop/img_rank_snb_src_brand_2.png',
                              height: 52,
                            ),
                            SizedBox(height: 4),
                            Padding(
                              padding: EdgeInsets.only(left: 2),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                child: Text(
                                  '휘닉스 파크에서 눈송이를 찾아라!',
                                  style: SDSTextStyle.bold.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(child: Container()),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: _fetchData,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  child: Row(
                                    children: [
                                      Obx(() => isLoading.value
                                          ? Container(
                                        width: 58,
                                        height: 19,
                                        child: Center(
                                          child: LoadingAnimationWidget.waveDots(
                                            color: SDSColor.snowliveWhite.withOpacity(0.5),
                                            size: 20,
                                          ),
                                        ),
                                      )
                                          : Container(
                                        height: 19,
                                        child: Row(
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(
                                                  'assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png',
                                                  height: 14,
                                                ),
                                                SizedBox(width: 3),
                                                Text(
                                                  '${_snowballShopViewModel.summary[0].remaining}', // 하얀 눈송이 개수
                                                  style: SDSTextStyle.regular.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 6),
                                            Row(
                                              children: [
                                                Image.asset(
                                                  'assets/imgs/imgs/snowballShop/icon_snowballshop_goldball.png',
                                                  height: 14,
                                                ),
                                                SizedBox(width: 3),
                                                Text(
                                                  '${_snowballShopViewModel.summary[1].remaining}', // 황금 눈송이 개수
                                                  style: SDSTextStyle.regular.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),
                                      SizedBox(width: 4),
                                      Icon(Icons.refresh, color: Colors.white, size: 20), // 새로고침 아이콘
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 2),
                            GestureDetector(
                              onTap: () async {
                                _snowballShopViewModel.loadingEntrance = true;
                                if(isBrandOnly == true){
                                  Get.toNamed(AppRoutes.snowballmarketBrandOnly);
                                }else{
                                  Get.toNamed(AppRoutes.snowballmarket);
                                }
                                await _snowballShopViewModel.getInfo_snowballMarket();
                                await _snowballShopViewModel.fetchSnowballShop();
                                _snowballShopViewModel.loadingEntrance = false;
                                await _snowballShopViewModel.getInfo_snowballMarket_notice_gold();
                                await _snowballShopViewModel.fetchUserSnowballRecords();
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Container(
                                  width: 90,
                                  height: 30,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '입장하기',
                                          style: SDSTextStyle.bold.copyWith(
                                              fontSize: 14,
                                              color: SDSColor.snowliveWhite
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 6),
                                          child: Image.asset(
                                            'assets/imgs/imgs/snowballShop/icon_snowballshop_arrow.png',
                                            width: 18,
                                            height: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
      } else {
        return SizedBox.shrink();
      }
    });
  }
}
