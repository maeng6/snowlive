import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/mobile/routes/routes.dart';
import 'package:com.snowlive/mobile/viewmodel/forestPark/vm_forestPark.dart';
import 'package:com.snowlive/mobile/viewmodel/ranking/vm_snowball.dart';
import 'package:com.snowlive/mobile/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/mobile/viewmodel/themeStore/vm_themeStore.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Entrance_Themestore_Home extends StatefulWidget {
  @override
  _Entrance_Themestore_HomeState createState() => _Entrance_Themestore_HomeState();
}

class _Entrance_Themestore_HomeState extends State<Entrance_Themestore_Home> {

  UserViewModel _userViewModel = Get.find<UserViewModel>();
  SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();
  ThemeStoreViewModel _themeStoreViewModel = Get.find<ThemeStoreViewModel>();

  @override
  void initState() {
    super.initState();
    _snowballShopViewModel.getInfo_themestore_resortHome_entrance();
    print('기획전 진입점 스트림 구독_리조트홈');
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Obx(() {
      final data = _snowballShopViewModel.infoData_themestore_entrance_resortHome.value;

      if (data == null) {
        return SizedBox.shrink();
      }

      // open 필드가 true인지 확인
      bool isOpen = data['open'] ?? false;

      // to_everyone 필드가 true인지 확인
      bool isToEveryone = data['to_everyone'] ?? false;

      // crew_list 필드가 리스트인지 확인하고, 유저의 크루가 리스트에 포함되어 있는지 확인
      List<dynamic> crewList = data['crew_list'] ?? [];
      bool isUserInCrewList = _userViewModel.user.crew_id != null && crewList.contains(_userViewModel.user.crew_id);
      String entranceImage = data['mainImage'] ?? '';

      if (isOpen == true && (isToEveryone || isUserInCrewList)) {
            return GestureDetector(
              onTap: () async {
                Get.toNamed(AppRoutes.themestoreHome);
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Container(
                  child: ClipRRect(
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
                              height: _size.width / 3,
                              color: Colors.transparent,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                color: Colors.black26,
                              ),
                            );
                          case LoadState.failed:
                            return Container(
                              height: _size.width / 3,
                              color: Colors.transparent,
                              alignment: Alignment.center,
                              child: Icon(Icons.error, color: Colors.red),
                            );
                          case LoadState.completed:
                            return null;
                        }
                      },
                    ),
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
