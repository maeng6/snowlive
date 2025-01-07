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
      appBar: AppBar(
        title: Text(
          '내가 교환한 목록',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
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
          return Center(child: Text('교환 내역이 없습니다.'));
        }
        return ListView.builder(
          itemCount: _snowballShopViewModel.purchaseHistory.length,
          padding: EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final record = _snowballShopViewModel.purchaseHistory[index];
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지
                  ExtendedImage.network(
                    record.imageUrl!,
                    enableMemoryCache: true,
                    cacheHeight: 150,
                    borderRadius: BorderRadius.circular(8),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                        // 로딩 중일 때 로딩 인디케이터를 표시
                          return Shimmer.fromColors(
                            baseColor: SDSColor.gray200!,
                            highlightColor: SDSColor.gray50!,
                            child: Container(
                              width: 60,
                              height: 60,
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
                            width: 32,
                            height: 32,
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
                      children: [
                        Text(
                          record.itemName ?? '상품 이름',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${record.color} 눈송이 ${record.count ?? 0}개',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${_formatDate(record.uploadTime)} 교환 확정',
                          style: TextStyle(fontSize: 12, color: Colors.blueAccent),
                        ),
                      ],
                    ),
                  ),
                  // 주문 상세 버튼

                  ElevatedButton(
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
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: (){},
                                  child: DraggableScrollableSheet(
                                    initialChildSize: 0.66, // 바텀시트 초기 높이
                                    maxChildSize: 0.9, // 최대 높이
                                    minChildSize: 0.4, // 최소 높이
                                    builder: (_, controller) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                        ),
                                        child: ListView(
                                          controller: controller,
                                          padding: EdgeInsets.all(16),
                                          children: [
                                            // 드래그 핸들
                                            Center(
                                              child: Container(
                                                width: 40,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 16),
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
                                                color: Colors.black,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  ExtendedImage.network(
                                                    record.imageUrl!,
                                                    enableMemoryCache: true,
                                                    cacheHeight: 150,
                                                    borderRadius: BorderRadius.circular(8),
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                    loadStateChanged: (ExtendedImageState state) {
                                                      switch (state.extendedImageLoadState) {
                                                        case LoadState.loading:
                                                        // 로딩 중일 때 로딩 인디케이터를 표시
                                                          return Shimmer.fromColors(
                                                            baseColor: SDSColor.gray200!,
                                                            highlightColor: SDSColor.gray50!,
                                                            child: Container(
                                                              width: 40,
                                                              height: 40,
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
                                                            width: 32,
                                                            height: 32,
                                                            fit: BoxFit.cover,
                                                          );
                                                      }
                                                    },
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          record.itemName ?? '상품 이름',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          '${record.color ?? ''} 눈송이 ${record.count ?? 0}개',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.white70,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            // 주문 정보
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    '주문자명',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
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
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    '경품 수령 주소',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
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
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    '전화번호',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
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
                                            Divider(height: 32, thickness: 1, color: Colors.grey[300]),
                                            // 교환 상세 정보
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    '교환 상품명',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
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
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    '눈송이 가격',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
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
                                            Divider(height: 32, thickness: 1, color: Colors.grey[300]),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                              child: Text(
                                                '수집된 개인 정보는 상품 발송 후 일주일 뒤에 바로 삭제됩니다.',
                                                style: TextStyle(fontSize: 12, color: Colors.grey),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: Text(
                      '주문 상세',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
