import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_forestPark.dart';
import 'package:com.snowlive/model/m_snowball.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/forestPark/vm_forestPark.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_snowball.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class SnowballMarketBrandShopView extends StatefulWidget {
  @override
  State<SnowballMarketBrandShopView> createState() => _SnowballMarketBrandShopViewState();
}

class _SnowballMarketBrandShopViewState extends State<SnowballMarketBrandShopView> {

  SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();
  UserViewModel _userViewModel = Get.find<UserViewModel>();



  bool _hasFetchedData = false;


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('snowball_market').doc('snowball_market').snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) return SizedBox();

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final int eventDate = data?['event_date'] ?? 0;

          // ✅ 최초 한 번만 실행
          if (!_hasFetchedData) {
            _snowballShopViewModel.fetchSnowballShop(isTierOnly: false, isForMission: true);
            _hasFetchedData = true;
          }

          return Obx(()=>Scaffold(
              backgroundColor: Color(0xFF1D242E),
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(44),
                child: AppBar(
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  title: Text('브랜드 미션',
                    style: SDSTextStyle.bold.copyWith(
                        color: SDSColor.snowliveWhite,
                        fontSize: 16
                    ),
                  ),
                  backgroundColor: Color(0xFF1D242E),
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
                ),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      strokeWidth: 2,
                      edgeOffset: -40,
                      displacement: 40,
                      backgroundColor: Color(0xFF3D83ED),
                      color: SDSColor.snowliveWhite,
                      onRefresh: () async{
                        await _snowballShopViewModel.fetchSnowballShop(isTierOnly: false, isForMission: true);
                      },
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text('획득한 눈송이는 당일에 사용하지 않으면 모두 사라집니다',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3D83ED)
                                  ),
                                ),
                              ),
                              //브랜드 미션 선택
                              SizedBox(height: 60),
                              //브랜드 미션 설명
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3D83ED), // 파란색 배경
                                            borderRadius: BorderRadius.circular(20), // 둥근 캡슐 형태
                                          ),
                                          child: const Text(
                                            '추첨 방법',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Text('14시까지 경품 수령처로 모여주세요!',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFFFFFF)
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15,),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF141F30),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(
                                        children: [
                                          // 내부 테두리 (안쪽으로 들어간 선)
                                          Positioned.fill(
                                            top: 12,  // ← 위쪽 여백
                                            bottom: 12,
                                            left: 12,
                                            right: 12, // ← 이렇게 여백을 주면 “안쪽에 들어간” 효과
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xFF324C73),
                                                  width: 1,
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),

                                          // 내용
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '브랜드 미션 응모를 완료하셨다면,\n'
                                                        '14시까지 경품 수령처로 모여주세요!\n'
                                                        '현장에서 직접 당첨자 추첨을 진행합니다!',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Text(
                                                    '상단에 표시된 추첨 번호를 확인해주세요',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 60),
                              //브랜드 미션 추가 경품 리스트
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    Text('브랜드 미션에 응모하시면,',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFFFFF)
                                      ),
                                    ),
                                    Text('추가 경품 당첨 기회가 주어집니다!',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFFFFF)
                                      ),
                                    ),
                                    SizedBox(height: 5,),
                                    Text('브랜드 미션 응모 시, 자동으로 응모됩니다.',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFFFFFFF).withOpacity(0.6)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              GridView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 11 / 19,
                                ),
                                itemCount: _snowballShopViewModel.shopItems.length,
                                itemBuilder: (context, index) {
                                  final item = _snowballShopViewModel.shopItems[index];
                                  return Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () async{
                                          if(item.itemCount == 0){
                                            return ;
                                          }

                                          CustomFullScreenDialog.showDialog();
                                          await _snowballShopViewModel.fetchSnowballShop(isTierOnly: false, isForMission: true);
                                          CustomFullScreenDialog.cancelDialog();

                                          final updatedItem = _snowballShopViewModel.shopItems.firstWhere(
                                                (updated) => updated.snowballItemId == item.snowballItemId,
                                            orElse: () => SnowballShopItem(itemCount: 0), // 기본값
                                          );

                                          if(updatedItem.itemCount == 0){
                                            return ;
                                          }
                                          _snowballShopViewModel.selectItem(item);
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Color(0xFF3D83ED),
                                            builder: (BuildContext context) {
                                              return GestureDetector(
                                                onTap: () => Navigator.of(context).pop(), // 바깥 클릭 시 닫기
                                                child: SafeArea(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                                      color: Color(0xFF3D83ED),
                                                    ),
                                                    padding: EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 12),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        // 상단 닫기 버튼
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 20),
                                                          child: Center(
                                                            child: Container(
                                                              width: 40,
                                                              height: 4,
                                                              decoration: BoxDecoration(
                                                                color: Colors.grey[300],
                                                                borderRadius: BorderRadius.circular(2),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            SizedBox(
                                                              height: 4,
                                                            ),
                                                            // 이미지 표시
                                                            Container(
                                                              width: 113,
                                                              height: 113,
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(4),
                                                                child: ExtendedImage.network(
                                                                  item.imageUrl ?? '',
                                                                  width: 120,
                                                                  height: 120,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 16),
                                                            // 상품명
                                                            Text(
                                                              item.name ?? '상품 이름',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 16,
                                                                  color: SDSColor.snowliveWhite
                                                              ),
                                                            ),
                                                            SizedBox(height: 8),
                                                            // 설명 텍스트
                                                            Text(
                                                              item.description ?? '',
                                                              textAlign: TextAlign.center,
                                                              style: SDSTextStyle.regular.copyWith(
                                                                fontSize: 12,
                                                                color: Colors.white.withOpacity(0.5),
                                                              ),
                                                            ),
                                                            SizedBox(height: 40),
                                                            // 버튼들
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                (item.landingUrl != null && item.landingUrl != "")
                                                                    ?Expanded(
                                                                  child: ElevatedButton(
                                                                    onPressed: () async {
                                                                      print(item.landingUrl);
                                                                      await otherShare(contents: '${item.landingUrl}');
                                                                    },
                                                                    style: TextButton.styleFrom(
                                                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                                                                        splashFactory: InkRipple.splashFactory,
                                                                        elevation: 0,
                                                                        minimumSize: Size(100, 48),
                                                                        backgroundColor: Color(0xFF1C3F70)
                                                                    ),
                                                                    child: Text(
                                                                      '상세 정보 보기',
                                                                      style: SDSTextStyle.bold.copyWith(
                                                                          color: SDSColor.snowliveWhite,
                                                                          fontSize: 16),
                                                                    ),
                                                                  ),
                                                                )
                                                                    :Container(),
                                                                (item.landingUrl != null && item.landingUrl != "")
                                                                    ? SizedBox(width: 10) : Container(),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      color: SDSColor.snowliveWhite,
                                                      child: ExtendedImage.network(
                                                        item.imageUrl ?? '',
                                                        enableMemoryCache: true,
                                                        fit: BoxFit.cover,
                                                        loadStateChanged: (ExtendedImageState state) {
                                                          switch (state.extendedImageLoadState) {
                                                            case LoadState.loading:
                                                              return Shimmer.fromColors(
                                                                baseColor: Colors.grey[200]!,
                                                                highlightColor: Colors.grey[50]!,
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                              );
                                                            case LoadState.completed:
                                                              return state.completedWidget;
                                                            case LoadState.failed:
                                                              return Image.asset(
                                                                'assets/imgs/imgs/img_flea_default.png',
                                                                fit: BoxFit.cover,
                                                              );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    if (item.itemCount == 0)
                                                      Positioned(
                                                        top: 0,
                                                        bottom: 0,
                                                        right: 0,
                                                        left: 0,
                                                        child: Container(
                                                          color: SDSColor.sBlue900.withOpacity(0.8),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                item.name ?? '상품 이름',
                                                style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.snowliveWhite,),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),

                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 하단 버튼
                  SafeArea(
                    child: Container(
                      padding: EdgeInsets.only(left: 16,right: 16,top: 16, bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async{
                                CustomFullScreenDialog.showDialog();
                                await _snowballShopViewModel.fetchPurchaseHistory();
                                CustomFullScreenDialog.cancelDialog();
                                Get.toNamed(AppRoutes.snowballMarketBuyRecord);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Color(0xFF3D83ED),
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                '브랜드 미션 응모하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )

                ],
              )
          ));
        }
    );
  }
}
