import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_snowball.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // 날짜 형식 변환을 위한 패키지

class SnowballExchangeHistoryView extends StatelessWidget {
  final SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();

  SnowballExchangeHistoryView({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          title: Text(
            '내가 교환한 목록',
            style: SDSTextStyle.extraBold.copyWith(
                color: SDSColor.gray900,
                fontSize: 18),
          ),
          backgroundColor: SDSColor.snowliveWhite,
          surfaceTintColor: Colors.transparent,
          elevation: 0.0,
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
        ),
      ),
      body: Obx(() {
        if (_snowballShopViewModel.isLoading.value) {
          return Center(
            child: Container(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                backgroundColor: SDSColor.gray100,
                color: SDSColor.gray300.withOpacity(0.6),
              ),
            ),
          );
        }
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
                Text('교환한 상품이 없어요',
                  style: SDSTextStyle.regular.copyWith(
                      fontSize: 14,
                      color: SDSColor.gray700
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: _snowballShopViewModel.purchaseHistory.length,
          padding: EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final record = _snowballShopViewModel.purchaseHistory[index];
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 이미지
                  ExtendedImage.network(
                    record.imageUrl!,
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
                        Text(
                          '${record.color} 눈송이 ${record.count ?? 0}개',
                          style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500,),
                        ),
                        Text(
                          '${_formatDate(record.uploadTime)} 교환 확정',
                          style: SDSTextStyle.regular.copyWith(fontSize: 11, color: SDSColor.blue400,),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  // 주문 상세 버튼
                  Container(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
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
                                    color: SDSColor.snowliveWhite,
                                  ),
                                  padding: EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 12),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 드래그 핸들
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 20),
                                          child: Container(
                                            height: 4,
                                            width: 36,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: SDSColor.gray200,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 제목
                                      Text(
                                        '주문 상세 내역',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 16),
                                      // 상단 상품 정보 박스
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF1D242E),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: ExtendedImage.network(
                                                record.imageUrl!,
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
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    record.itemName ?? '상품 이름',
                                                    style: SDSTextStyle.bold.copyWith(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${record.color ?? ''} 눈송이 ${record.count ?? 0}개',
                                                    style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 12,
                                                      color: Colors.white.withOpacity(0.5),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      // 주문 정보
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '주문자명',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 14,
                                                color: SDSColor.gray500,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: Text(
                                                record.userName ?? '',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '경품 수령 주소',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 14,
                                                color: SDSColor.gray500,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: Text(
                                                record.address ?? '',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '전화번호',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 14,
                                                color: SDSColor.gray500,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: Text(
                                                record.phoneNumber ?? '',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(height: 32, thickness: 1, color: SDSColor.gray100),
                                      // 교환 상세 정보
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '교환 상품명',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 14,
                                                color: SDSColor.gray500,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: Text(
                                                record.itemName ?? '',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '눈송이 가격',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 14,
                                                color: SDSColor.gray500,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${record.color ?? ''} 눈송이 ${record.count ?? 0}개',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(height: 32, thickness: 1, color: SDSColor.gray100),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Text(
                                          '수집된 개인 정보는 상품 발송 후 일주일 뒤에 바로 삭제됩니다.',
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
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
                        foregroundColor: SDSColor.gray900,
                        backgroundColor: SDSColor.gray100,
                        side: BorderSide(
                            color: SDSColor.gray100
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      ),
                      child: Text(
                        '주문 상세',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
