import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/forestPark/vm_forestPark.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_snowball.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart'; // 날짜 형식 변환을 위한 패키지
import 'package:flutter_svg/flutter_svg.dart';

class SnowballMarketBuyRecordView extends StatelessWidget {

  final SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();

  SnowballMarketBuyRecordView({Key? key}) : super(key: key);

  String _formatDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return '날짜 정보 없음';
    }
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('yyyy년 MM월 dd일').format(dateTime); // 원하는 형식으로 변환
    } catch (e) {
      return '잘못된 날짜 형식';
    }
  }

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          title: Text(
            '경품 교환 목록',
            style: SDSTextStyle.bold.copyWith(
                color: SDSColor.gray900,
                fontSize: 16
            ),
          ),
          backgroundColor: SDSColor.snowliveWhite,
          surfaceTintColor: Colors.transparent,
          elevation: 0.0,
          leading: Padding(
          padding: EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: SvgPicture.asset('assets/imgs/icons/icon_snowLive_back.svg', width: 26, height: 26),
            highlightColor: Colors.transparent,
          ),
        ),
        ),
      ),
      body: Obx(() {
        if (_snowballShopViewModel.purchaseHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/imgs/icons/icon_nodata.png',
                  scale: 4,
                  width: 73,
                  height: 73,
                ),
                SizedBox(
                  height: 6,
                ),
                Text('교환한 경품이 없어요',
                  style: SDSTextStyle.regular.copyWith(
                      fontSize: 14,
                      color: SDSColor.gray700
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          strokeWidth: 2,
          edgeOffset: -40,
          displacement: 40,
          backgroundColor: Color(0xFF12341E),
          color: SDSColor.snowliveWhite,
          onRefresh: () async{
            await _snowballShopViewModel.fetchPurchaseHistory();
          },
          child: ListView.builder(
            itemCount: _snowballShopViewModel.purchaseHistory.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final record = _snowballShopViewModel.purchaseHistory[index];
              return GestureDetector(
                onTap: (){
                  if(record.isReceived == true){
                    Get.snackbar(
                      '이미 수령한 상품이에요',
                      '새로운 상품을 교환 후 수령해주세요.',
                      snackPosition: SnackPosition.BOTTOM, // ⬇️ 아래쪽에 표시
                      backgroundColor: Colors.black.withOpacity(0.8),
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      borderRadius: 12,
                      duration: const Duration(seconds: 1),
                      titleText: Text(
                        '이미 수령한 상품이에요',
                        style: SDSTextStyle.bold.copyWith(fontSize: 14, color: Colors.white),
                      ),
                      messageText: Text(
                        '새로운 상품을 교환 후 수령해주세요.',
                        style: SDSTextStyle.regular.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                      ),
                    );
                  }else{
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Color(0xFF3D83ED),
                      builder: (context) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque, // 화면 바깥 클릭 감지
                          onTap: () {
                            Navigator.of(context).pop(); // 바텀시트 닫기
                          },
                          child: SafeArea(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                color: Color(0xFF3D83ED),
                              ),
                              padding: EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 드래그 핸들.
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 20),
                                      child: Container(
                                        height: 4,
                                        width: 36,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: SDSColor.snowliveWhite,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 32),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFF073819), // 테두리 색상
                                        width: 6,            // 테두리 두께
                                      ),
                                    ),
                                    child: QrImageView(
                                      data: record.recordId.toString(),
                                      version: QrVersions.auto,
                                      size: _size.width - 140,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    '상품 교환 QR',
                                    style: SDSTextStyle.bold.copyWith(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    '경품 수령처에서 QR 코드를 스캔하고\n경품을 수령해 주세요!',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                      color: SDSColor.snowliveWhite.withOpacity(0.5),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 60,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: ExtendedImage.network(
                                            record.imageUrl ?? '',
                                            enableMemoryCache: true,
                                            borderRadius: BorderRadius.circular(4),
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                            loadStateChanged: (ExtendedImageState state) {
                                              switch (state.extendedImageLoadState) {
                                                case LoadState.loading:
                                                // 로딩 중일 때 로딩 인디케이터를 표시
                                                  return Shimmer.fromColors(
                                                    baseColor: SDSColor.gray200!,
                                                    highlightColor: SDSColor.gray50!,
                                                    child: Container(
                                                      width: 48,
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                    ),
                                                  );
                                                case LoadState.completed:
                                                // 로딩이 완료되었을 때 이미지 반환
                                                  return state.completedWidget;
                                                case LoadState.failed:
                                                // 로딩이 실패했을 때 대체 이미지 또는 다른 처리
                                                  return Image.asset(
                                                    'assets/imgs/profile/img_profile_default_.png',
                                                    width: 48,
                                                    height: 48,
                                                    fit: BoxFit.cover,
                                                  );
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                record.itemName ?? '상품 이름',
                                                style: SDSTextStyle.bold.copyWith(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Row(children: [
                                                Text(
                                                  '하얀 눈송이 ${record.price![0].snowballCount ?? 0}개',
                                                  style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 13,
                                                    color: Colors.white.withOpacity(0.5),
                                                  ),
                                                ),
                                                Text(
                                                  ' / ',
                                                  style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 13,
                                                    color: Colors.white.withOpacity(0.5),
                                                  ),
                                                ),
                                                Text(
                                                  '황금 눈송이 ${record.price![1].snowballCount ?? 0}개',
                                                  style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 13,
                                                    color: Colors.white.withOpacity(0.5),
                                                  ),
                                                ),
                                              ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 이미지
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ExtendedImage.network(
                          record.imageUrl ?? '',
                          enableMemoryCache: true,
                          cacheHeight: 150,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: SDSColor.gray100),
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          loadStateChanged: (ExtendedImageState state) {
                            switch (state.extendedImageLoadState) {
                              case LoadState.loading:
                              // 로딩 중일 때 로딩 인디케이터를 표시
                                return Shimmer.fromColors(
                                  baseColor: SDSColor.gray200!,
                                  highlightColor: SDSColor.gray50!,
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              case LoadState.completed:
                              // 로딩이 완료되었을 때 이미지 반환
                                return state.completedWidget;
                              case LoadState.failed:
                              // 로딩이 실패했을 때 대체 이미지 또는 다른 처리
                                return Image.asset(
                                  'assets/imgs/profile/img_profile_default_circle.png',
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                );
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      // 텍스트 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              record.itemName ?? '상품 이름',
                              style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '하얀 눈송이 : ${record.price![0].snowballCount ?? 0}개',
                                  style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500,),
                                ),
                                Text(' / ',
                                  style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500,),
                                ),
                                Text(
                                  '황금 눈송이 : ${record.price![1].snowballCount ?? 0}개',
                                  style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500,),
                                ),
                              ],
                            ),

                            Text(
                              '${_formatDate(record.uploadTime)}',
                              style: SDSTextStyle.regular.copyWith(fontSize: 11, color: Color(0xFF3D83ED)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      // 주문 상세 버튼
                      if(record.isReceived == false)
                        Container(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Color(0xFF3D83ED),
                                builder: (context) {
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque, // 화면 바깥 클릭 감지
                                    onTap: () {
                                      Navigator.of(context).pop(); // 바텀시트 닫기
                                    },
                                    child: SafeArea(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                          color: Color(0xFF3D83ED),
                                        ),
                                        padding: EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 12),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // 드래그 핸들.
                                            Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(bottom: 20),
                                                child: Container(
                                                  height: 4,
                                                  width: 36,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10),
                                                    color: SDSColor.snowliveWhite,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 32),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xFF1956B2), // 테두리 색상
                                                  width: 6,            // 테두리 두께
                                                ),
                                              ),
                                              child: QrImageView(
                                                data: record.recordId.toString(),
                                                version: QrVersions.auto,
                                                size: _size.width - 140,
                                                backgroundColor: Colors.white,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 16,
                                            ),
                                            Text(
                                              '상품 교환 QR',
                                              style: SDSTextStyle.bold.copyWith(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                              height: 6,
                                            ),
                                            Text(
                                              '경품 수령처에서 QR 코드를 스캔하고\n경품을 수령해 주세요!',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.normal,
                                                color: SDSColor.snowliveWhite.withOpacity(0.5),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                              height: 60,
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.4),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(4),
                                                    child: ExtendedImage.network(
                                                      record.imageUrl ?? '',
                                                      enableMemoryCache: true,
                                                      borderRadius: BorderRadius.circular(4),
                                                      width: 48,
                                                      height: 48,
                                                      fit: BoxFit.cover,
                                                      loadStateChanged: (ExtendedImageState state) {
                                                        switch (state.extendedImageLoadState) {
                                                          case LoadState.loading:
                                                          // 로딩 중일 때 로딩 인디케이터를 표시
                                                            return Shimmer.fromColors(
                                                              baseColor: SDSColor.gray200!,
                                                              highlightColor: SDSColor.gray50!,
                                                              child: Container(
                                                                width: 48,
                                                                height: 48,
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.circular(4),
                                                                ),
                                                              ),
                                                            );
                                                          case LoadState.completed:
                                                          // 로딩이 완료되었을 때 이미지 반환
                                                            return state.completedWidget;
                                                          case LoadState.failed:
                                                          // 로딩이 실패했을 때 대체 이미지 또는 다른 처리
                                                            return Image.asset(
                                                              'assets/imgs/profile/img_profile_default_.png',
                                                              width: 48,
                                                              height: 48,
                                                              fit: BoxFit.cover,
                                                            );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          record.itemName ?? '상품 이름',
                                                          style: SDSTextStyle.bold.copyWith(
                                                            fontSize: 15,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Row(children: [
                                                          Text(
                                                            '하얀 눈송이 ${record.price![0].snowballCount ?? 0}개',
                                                            style: SDSTextStyle.regular.copyWith(
                                                              fontSize: 13,
                                                              color: Colors.white.withOpacity(0.5),
                                                            ),
                                                          ),
                                                          Text(
                                                            ' / ',
                                                            style: SDSTextStyle.regular.copyWith(
                                                              fontSize: 13,
                                                              color: Colors.white.withOpacity(0.5),
                                                            ),
                                                          ),
                                                          Text(
                                                            '황금 눈송이 ${record.price![1].snowballCount ?? 0}개',
                                                            style: SDSTextStyle.regular.copyWith(
                                                              fontSize: 13,
                                                              color: Colors.white.withOpacity(0.5),
                                                            ),
                                                          ),
                                                        ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              foregroundColor: SDSColor.snowliveWhite,
                              backgroundColor: Color(0xFF3D83ED),
                              side: BorderSide(
                                  color: SDSColor.gray100
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            ),
                            child: Text(
                              '수령하기',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      if(record.isReceived == true)
                        Container(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.snackbar(
                                '이미 수령한 상품이에요',
                                '새로운 상품을 교환 후 수령해주세요.',
                                snackPosition: SnackPosition.BOTTOM, // ⬇️ 아래쪽에 표시
                                backgroundColor: Colors.black.withOpacity(0.8),
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                borderRadius: 12,
                                duration: const Duration(seconds: 1),
                                titleText: Text(
                                  '이미 수령한 상품이에요',
                                  style: SDSTextStyle.bold.copyWith(fontSize: 14, color: Colors.white),
                                ),
                                messageText: Text(
                                  '새로운 상품을 교환 후 수령해주세요.',
                                  style: SDSTextStyle.regular.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              foregroundColor: SDSColor.snowliveWhite,
                              backgroundColor: Color(0xFF222222),
                              side: BorderSide(
                                  color: SDSColor.gray100
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            ),
                            child: Text(
                              '수령완료',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
