import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_snowball.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Entrance_snowballShop extends StatefulWidget {
  @override
  _Entrance_snowballShopState createState() => _Entrance_snowballShopState();
}

class _Entrance_snowballShopState extends State<Entrance_snowballShop> {
  UserViewModel _userViewModel = Get.find<UserViewModel>();
  SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();

  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _snowballShopViewModel.getInfo_snowballMarket_entrance();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      isLoading.value = true;
    });

    await _snowballShopViewModel.fetchSnowballSummary();

    if (!mounted) return;
    setState(() {
      isLoading.value = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return StreamBuilder(
      stream: _snowballShopViewModel.infoStream_snowballShop_entrance.value,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        // 데이터 로드 중이라면
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
        }
        // 오류가 발생했다면
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        var data = snapshot.data?.data() as Map<String, dynamic>?;
        // open 필드가 true인지 확인
        bool isOpen = data?['open'] ?? false;

        // to_everyone 필드가 true인지 확인
        bool isToEveryone = data?['to_everyone'] ?? false;

        // crew_list 필드가 리스트인지 확인하고, 유저의 크루가 리스트에 포함되어 있는지 확인
        List<dynamic> crewList = data?['crew_list'] ?? [];
        bool isUserInCrewList = _userViewModel.user.crew_id != null && crewList.contains(_userViewModel.user.crew_id);


        if (isOpen == true && (isToEveryone || isUserInCrewList)) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () async {
                  _snowballShopViewModel.loadingEntrance = true;
                  Get.toNamed(AppRoutes.snowballShop);
                  await _snowballShopViewModel.getInfo_snowballMarket();
                  await _snowballShopViewModel.fetchSnowballShopData();
                  await _snowballShopViewModel.getInfo_snowballMarket_notice_gold();
                  await _snowballShopViewModel.fetchUserSnowballRecords();
                  _snowballShopViewModel.loadingEntrance = false;
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 8, bottom: 10, right: 16, left: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFF1D242E), // 배경색
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 86,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/imgs/imgs/snowballShop/img_snowballshop_text_1.png',
                            height: 22,
                          ),
                          Image.asset(
                            'assets/imgs/imgs/snowballShop/img_snowballshop_text_2.png',
                            height: 22,
                          ),
                          SizedBox(height: 4),
                          Padding(
                            padding: EdgeInsets.only(left: 2),
                            child: Container(
                              color: SDSColor.blue400.withOpacity(0.4),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                child: Text(
                                  'IN 휘닉스 파크',
                                  style: SDSTextStyle.bold.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
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
                                                '${_snowballShopViewModel.snowballSummary.value.white}', // 하얀 눈송이 개수
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
                                                '${_snowballShopViewModel.snowballSummary.value.gold}', // 황금 눈송이 개수
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
                              Get.toNamed(AppRoutes.snowballShop);
                              await _snowballShopViewModel.getInfo_snowballMarket();
                              await _snowballShopViewModel.fetchSnowballShopData();
                              await _snowballShopViewModel.getInfo_snowballMarket_notice_gold();
                              await _snowballShopViewModel.fetchUserSnowballRecords();
                              _snowballShopViewModel.loadingEntrance = false;
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
              // 이미지 영역
              Positioned(
                left: 6,
                top: 6,
                bottom: 6,
                child: GestureDetector(
                  onTap: () async {
                    _snowballShopViewModel.loadingEntrance = true;
                    Get.toNamed(AppRoutes.snowballShop);
                    await _snowballShopViewModel.getInfo_snowballMarket();
                    await _snowballShopViewModel.fetchSnowballShopData();
                    await _snowballShopViewModel.getInfo_snowballMarket_notice_gold();
                    await _snowballShopViewModel.fetchUserSnowballRecords();
                    _snowballShopViewModel.loadingEntrance = false;
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Image.asset(
                        'assets/imgs/imgs/snowballShop/icon_snowballshop_store_banner.png',
                        width: 86
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return SizedBox.shrink(); // banner 필드가 없거나 비어있으면 빈 공간 반환
        }

      },
    );
  }
}
