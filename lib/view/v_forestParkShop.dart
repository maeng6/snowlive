import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_forestPark.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/forestPark/vm_forestPark.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ForestParkShop extends StatefulWidget {
  @override
  State<ForestParkShop> createState() => _ForestParkShopState();
}

class _ForestParkShopState extends State<ForestParkShop> {

  final ForestParkViewModel _forestParkViewModel = Get.find<ForestParkViewModel>();

  bool _hasFetchedData = false;


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('forestPark').doc('forestPark').snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) return SizedBox();

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final int eventDate = data?['eventDate'] ?? 0;

          // ✅ 최초 한 번만 실행
          if (!_hasFetchedData) {
            _forestParkViewModel.fetchLeafItems(eventDate);
            _forestParkViewModel.fetchLeafRemain(eventDate);
            _hasFetchedData = true;
          }

          return Obx(()=>Scaffold(
              backgroundColor: Color(0xFF12341E),
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(44),
                child: AppBar(
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  title: Text('열매 상점',
                    style: TextStyle(
                        color: SDSColor.snowliveWhite
                    ),
                  ),
                  backgroundColor: Color(0xFF12341E),
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
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png',
                                    height: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '${_forestParkViewModel.leafRemain.value.remainGreen}',
                                    style: SDSTextStyle.regular.copyWith(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 8),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/imgs/imgs/snowballShop/icon_snowballshop_goldball.png',
                                    height: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '${_forestParkViewModel.leafRemain.value.remainGold}',
                                    style: SDSTextStyle.regular.copyWith(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
                      backgroundColor: SDSColor.snowliveBlue,
                      color: SDSColor.snowliveWhite,
                      onRefresh: () async{
                        await _forestParkViewModel.fetchLeafItems(eventDate);
                        await _forestParkViewModel.fetchLeafRemain(eventDate);
                      },
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 48),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 11 / 20,
                                ),
                                itemCount: _forestParkViewModel.leafItems.length,
                                itemBuilder: (context, index) {
                                  final item = _forestParkViewModel.leafItems[index];
                                  return Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () async{
                                          if(item.leafItemCount == 0){
                                            return ;
                                          }

                                          CustomFullScreenDialog.showDialog();
                                          await _forestParkViewModel.fetchLeafItems(eventDate);
                                          CustomFullScreenDialog.cancelDialog();

                                          final updatedItem = _forestParkViewModel.leafItems.firstWhere(
                                                (updated) => updated.leafItemId == item.leafItemId,
                                            orElse: () => LeafItem(leafItemCount: 0), // 기본값
                                          );

                                          if(updatedItem.leafItemCount == 0){
                                            return ;
                                          }
                                          _forestParkViewModel.selectItem(item);
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (BuildContext context) {
                                              return GestureDetector(
                                                onTap: () => Navigator.of(context).pop(), // 바깥 클릭 시 닫기
                                                child: Container(
                                                  color: Colors.transparent,
                                                  child: SafeArea(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                                        color: SDSColor.snowliveWhite,
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
                                                                width: 120,
                                                                height: 120,
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(color: SDSColor.gray100),
                                                                  borderRadius: BorderRadius.circular(8),
                                                                ),
                                                                child: ClipRRect(
                                                                  borderRadius: BorderRadius.circular(8),
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
                                                                    color: SDSColor.gray900
                                                                ),
                                                              ),
                                                              SizedBox(height: 6),
                                                              // 설명 텍스트
                                                              Text(
                                                                item.description ?? '',
                                                                textAlign: TextAlign.center,
                                                                style: SDSTextStyle.regular.copyWith(
                                                                  fontSize: 14,
                                                                  color: SDSColor.gray500,
                                                                ),
                                                              ),
                                                              SizedBox(height: 40),
                                                              // 버튼들
                                                              Row(
                                                                children: [
                                                                  (item.landingUrl != null && item.landingUrl != "")
                                                                      ? Expanded(
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
                                                                          backgroundColor: SDSColor.sBlue500
                                                                      ),
                                                                      child: Text(
                                                                        '상세 정보 보기',
                                                                        style: SDSTextStyle.bold.copyWith(
                                                                            color: SDSColor.snowliveWhite,
                                                                            fontSize: 16),
                                                                      ),
                                                                    ),
                                                                  )
                                                                      : Container(),
                                                                  (item.landingUrl != null && item.landingUrl != "")
                                                                      ? SizedBox(width: 10)
                                                                      : Container(),
                                                                  Expanded(
                                                                      child: ElevatedButton(
                                                                        onPressed: () async {
                                                                          final userGreen = _forestParkViewModel.leafRemain.value.remainGreen ?? 0;
                                                                          final userGold = _forestParkViewModel.leafRemain.value.remainGold ?? 0;

                                                                          final needGreen = item.leafKind1Count ?? 0;
                                                                          final needGold = item.leafKind2Count ?? 0;

                                                                          final greenShort = userGreen < needGreen ? needGreen - userGreen : 0;
                                                                          final goldShort = userGold < needGold ? needGold - userGold : 0;

                                                                          final isNotEnough = greenShort > 0 || goldShort > 0;

                                                                          if (isNotEnough) {
                                                                            String shortfallMessage = '교환에 필요한 열매가 부족해요\n';
                                                                            if (greenShort > 0) shortfallMessage += '・ 초록열매 ${greenShort}개 부족\n';
                                                                            if (goldShort > 0) shortfallMessage += '・ 황금열매 ${goldShort}개 부족';

                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (_) => AlertDialog(
                                                                                backgroundColor: SDSColor.snowliveWhite,
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                                content: Column(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    Text('열매가 부족해요!', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
                                                                                    SizedBox(height: 10),
                                                                                    Text(shortfallMessage, style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500), textAlign: TextAlign.center),
                                                                                  ],
                                                                                ),
                                                                                actions: [
                                                                                  Center(
                                                                                    child: TextButton(
                                                                                      onPressed: () => Navigator.of(context).pop(),
                                                                                      style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
                                                                                      child: Text('확인', style: SDSTextStyle.bold.copyWith(color: SDSColor.snowliveBlue, fontSize: 17)),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                            return;
                                                                          }

                                                                          Navigator.pop(context); // 바텀시트 닫기
                                                                          CustomFullScreenDialog.showDialog();
                                                                          final result = await _forestParkViewModel.tryBuyItem(item.leafItemId!);
                                                                          await _forestParkViewModel.fetchLeafRemain(eventDate);
                                                                          await _forestParkViewModel.fetchLeafItems(eventDate);
                                                                          CustomFullScreenDialog.cancelDialog();

                                                                          if (result) {
                                                                            // ✅ 성공 팝업
                                                                            Get.dialog(
                                                                              AlertDialog(
                                                                                backgroundColor: Colors.white,
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                                title: Text('교환 완료!', style: TextStyle(fontWeight: FontWeight.bold)),
                                                                                content: Text('상품 교환이 성공적으로 완료되었습니다.\n경품 수령처에서 경품을 수령해 주세요.'),
                                                                                actions: [
                                                                                  Center(
                                                                                    child: TextButton(
                                                                                      onPressed: () => Get.back(),
                                                                                      child: Text('확인', style: TextStyle(fontWeight: FontWeight.bold, color: SDSColor.snowliveBlue)),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              barrierDismissible: false,
                                                                            );
                                                                          } else {
                                                                            // ❌ 실패 팝업 (에러 메시지 보여주기)
                                                                            Get.dialog(
                                                                              AlertDialog(
                                                                                backgroundColor: Colors.white,
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                                title: Text('교환 실패', style: TextStyle(fontWeight: FontWeight.bold)),
                                                                                content: Text(
                                                                                  '일시적인 오류로 교환에 실패했어요.\n다시 시도해 주세요.',
                                                                                  style: TextStyle(fontSize: 14),
                                                                                ),
                                                                                actions: [
                                                                                  Center(
                                                                                    child: TextButton(
                                                                                      onPressed: () => Get.back(),
                                                                                      child: Text('확인', style: TextStyle(fontWeight: FontWeight.bold, color: SDSColor.snowliveBlue)),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              barrierDismissible: false,
                                                                            );
                                                                          }
                                                                        },
                                                                        style: ElevatedButton.styleFrom(
                                                                          shape: const RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                          ),
                                                                          splashFactory: InkRipple.splashFactory,
                                                                          elevation: 0,
                                                                          minimumSize: Size(100, 48),
                                                                          backgroundColor: SDSColor.snowliveBlue,
                                                                        ),
                                                                        child: Text(
                                                                          '교환하기',
                                                                          style: SDSTextStyle.bold.copyWith(
                                                                            color: SDSColor.snowliveWhite,
                                                                            fontSize: 16,
                                                                          ),
                                                                        ),
                                                                      )

                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
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
                                                    if (item.leafItemCount == 0)
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
                                              SizedBox(width: 1),
                                              Row(children: [
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      'assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png',
                                                      height: 12,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      '${item.leafKind1Count ?? 0}',
                                                      style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.snowliveWhite.withOpacity(0.6),),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(width: 5,),
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      'assets/imgs/imgs/snowballShop/icon_snowballshop_goldball.png',
                                                      height: 12,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      '${item.leafKind2Count ?? 0}',
                                                      style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.snowliveWhite.withOpacity(0.6),),
                                                    ),
                                                  ],
                                                ),
                                              ],),
                                              SizedBox(height: 2),
                                              if (item.leafItemCount != 0)
                                                Text(
                                                  '잔여 수량 ${item.leafItemCount}개',
                                                  style: SDSTextStyle.regular.copyWith(fontSize: 12, color: Color(0xFF10B028)),
                                                ),
                                              if (item.leafItemCount == 0)
                                                Text(
                                                  '품절',
                                                  style: SDSTextStyle.regular.copyWith(fontSize: 12, color: Color(0xFFD70015)),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              SizedBox(
                                height: 20,
                              )
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
                                await _forestParkViewModel.fetchBuyRecords();
                                CustomFullScreenDialog.cancelDialog();
                                Get.toNamed(AppRoutes.forestParkExchangeHistory);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Color(0xFF127721),
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                '경품 교환 목록',
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
