import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/forestPark/vm_forestPark.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_snowball.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Entrance_snowballMarket_Home extends StatefulWidget {
  @override
  _Entrance_snowballMarket_HomeState createState() => _Entrance_snowballMarket_HomeState();
}

class _Entrance_snowballMarket_HomeState extends State<Entrance_snowballMarket_Home> {

  UserViewModel _userViewModel = Get.find<UserViewModel>();
  SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();

  @override
  void initState() {
    super.initState();
    _snowballShopViewModel.getInfo_snowballMarket_entrance();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Obx(() {
      final data = _snowballShopViewModel.infoData_snowballShop_entrance.value;

      if (data == null) {
        return SizedBox.shrink();
      }

      bool isOpen = data['open'] ?? false;
      bool isToEveryone = data['to_everyone'] ?? false;
      bool isBrandOnly = data['brand_only'] ?? false;
      List<dynamic> crewList = data['crew_list'] ?? [];
      bool isUserInCrewList = _userViewModel.user.crew_id != null && crewList.contains(_userViewModel.user.crew_id);
      String entranceImage = data['mainImage'] ?? '';

          if (isOpen == true && (isToEveryone || isUserInCrewList) && isBrandOnly == false) {
            return GestureDetector(
              onTap: () async {
                _snowballShopViewModel.loadingEntrance = true;
                Get.toNamed(AppRoutes.snowballmarket);
                await _snowballShopViewModel.fetchSnowballHomeData();
                await _snowballShopViewModel.getInfo_snowballMarket();
                _snowballShopViewModel.loadingEntrance = false;
                await _snowballShopViewModel.getInfo_snowballMarket_notice_gold();
                await _snowballShopViewModel.fetchUserSnowballRecords();
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Container(
                  height: _size.width - 70,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ExtendedImage.network(
                          entranceImage,
                          width: double.infinity,
                          height: null, // 높이 비율 유지
                          fit: BoxFit.fitWidth,
                          loadStateChanged: (state) {
                            switch (state.extendedImageLoadState) {
                              case LoadState.loading:
                                return Container(
                                  height: _size.width - 70,
                                  color: Colors.grey.shade100,
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    color: Colors.black26,
                                  ),
                                );
                              case LoadState.failed:
                                return Container(
                                  height: _size.width - 70,
                                  color: Colors.grey.shade100,
                                  alignment: Alignment.center,
                                  child: Icon(Icons.error, color: Colors.red),
                                );
                              case LoadState.completed:
                                return null;
                            }
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: SDSColor.snowliveWhite
                            ),
                            width: 268,
                            height: 42,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('눈송이 상점 입장하기',
                                  style: SDSTextStyle.extraBold.copyWith(
                                      fontSize: 14,
                                      color: SDSColor.snowliveBlack
                                  ),),
                                Image.asset(
                                  'assets/imgs/icons/icon_arrow_round_black.png',
                                  fit: BoxFit.cover,
                                  width: 18,
                                  height: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
      } else {
        return SizedBox.shrink();
      }
    });
  }
}
