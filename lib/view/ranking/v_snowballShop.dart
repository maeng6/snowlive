import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_snowball.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_snowball.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class SnowballShopView extends StatefulWidget {
  @override
  State<SnowballShopView> createState() => _SnowballShopViewState();
}

class _SnowballShopViewState extends State<SnowballShopView> {
  SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();
  FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  UserViewModel _userViewModel = Get.find<UserViewModel>();

  Timer? _timer;
  String _days = '00';
  String _hours = '00';
  String _minutes = '00';
  DateTime? _currentEndTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(DateTime endTime) {
    _timer?.cancel();
    _currentEndTime = endTime;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _updateRemainingTime(endTime);
      });
    });
  }

  void _updateRemainingTime(DateTime endTime) {
    final currentTime = DateTime.now();
    final difference = endTime.difference(currentTime);

    if (difference.isNegative) {
      _days = '00';
      _hours = '00';
      _minutes = '00';
      _timer?.cancel();
    } else {
      _days = _twoDigits(difference.inDays);
      _hours = _twoDigits(difference.inHours.remainder(24));
      _minutes = _twoDigits(difference.inMinutes.remainder(60));
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            '눈송이 상점',
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.ac_unit, color: Colors.blue, size: 18),
                      SizedBox(width: 4),
                      Text(
                        '${_snowballShopViewModel.snowballSummary.value.white}',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12),
                  Row(
                    children: [
                      Icon(Icons.circle, color: Colors.amber, size: 18),
                      SizedBox(width: 4),
                      Text(
                        '${_snowballShopViewModel.snowballSummary.value.gold}',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        body:
        _snowballShopViewModel.loadingEntrance == true

            ? Center(
          child: Container(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              backgroundColor: SDSColor.gray100,
              color: SDSColor.gray300.withOpacity(0.6),
            ),
          ),
        )
            : Column(
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
                  _snowballShopViewModel.loadingEntrance = true;
                  Get.toNamed(AppRoutes.snowballShop);
                  await _snowballShopViewModel.getInfo_snowballMarket();
                  await _snowballShopViewModel.fetchSnowballShopData();
                  await _snowballShopViewModel.getInfo_snowballMarket_notice_gold();
                  await _snowballShopViewModel.fetchUserSnowballRecords();
                  _snowballShopViewModel.loadingEntrance = false;

                },
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    SizedBox(height: 20),
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: _snowballShopViewModel.infoStream_snowballShop.value,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        if (snapshot.hasData) {
                          final data = snapshot.data!.data();
                          final DateTime endTime = (data?['end_time'] as Timestamp).toDate();

                          if (_currentEndTime == null || _currentEndTime != endTime) {
                            _startTimer(endTime);
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '눈송이 상점 오픈 남은 시간: $_days일 $_hours시간 $_minutes분',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          );
                        } else {
                          return Center(child: Text('No data available'));
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    //TODO: 내가 획득한 눈송이_타이틀
                    Text(
                      '내가 획득한 눈송이',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5),
                    //TODO: 내가 획득한 눈송이_내용+바텀시트
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          isDismissible: true,
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque, // 화면 바깥 클릭 감지
                              onTap: () {
                                Navigator.of(context).pop(); // 바텀시트 닫기
                              },
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {}, // 내부 터치는 닫히지 않게 처리
                                    child: DraggableScrollableSheet(
                                      initialChildSize: 0.66, // 화면 높이의 2/3
                                      maxChildSize: 0.9,
                                      minChildSize: 0.4,
                                      builder: (_, controller) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight: Radius.circular(16),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(16.0),
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
                                              SizedBox(height: 10,),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: Center(
                                                  child: Text(
                                                    '내가 획득한 눈송이',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 20,),
                                              Expanded(
                                                child: ListView.builder(
                                                  controller: controller,
                                                  itemCount: _snowballShopViewModel.userSnowballRecords.length,
                                                  itemBuilder: (context, index) {
                                                    final item = _snowballShopViewModel.userSnowballRecords[index];
                                                    final String passTimeString = item.passTime ?? DateTime.now().toIso8601String();
                                                    final DateTime datetime = DateTime.parse(passTimeString);

                                                    final formattedDatetime =
                                                        "${datetime.year.toString().padLeft(4, '0')}-${datetime.month.toString().padLeft(2, '0')}-${datetime.day.toString().padLeft(2, '0')} "
                                                        "${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}:${datetime.second.toString().padLeft(2, '0')}";

                                                    final color = item.color;
                                                    final slope = item.slopeName;

                                                    return Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(width: 12),
                                                          // 텍스트 정보
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  '$slope 에서 $color 눈송이 1개를 획득했습니다.',
                                                                  style: TextStyle(
                                                                    color: Colors.black87,
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                                SizedBox(height: 4),
                                                                Text(
                                                                  formattedDatetime,
                                                                  style: TextStyle(
                                                                    color: Colors.grey,
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                              ],
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
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    _snowballShopViewModel.userSnowballRecords.isNotEmpty
                                        ? '${_snowballShopViewModel.userSnowballRecords[0].slopeName} 슬로프에서\n${_snowballShopViewModel.userSnowballRecords[0].color} 눈송이를 1개를 획득했어요!'
                                        : '아직 획득한 눈송이가 없어요!',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  Expanded(child: SizedBox()),
                                  Text(
                                        () {
                                      if (_snowballShopViewModel.userSnowballRecords.isNotEmpty) {
                                        final passTimeString = _snowballShopViewModel.userSnowballRecords[0].passTime ?? DateTime.now().toIso8601String();
                                        final datetime = DateTime.parse(passTimeString);
                                        final formattedDatetime =
                                            "${datetime.year.toString().padLeft(4, '0')}-${datetime.month.toString().padLeft(2, '0')}-${datetime.day.toString().padLeft(2, '0')} "
                                            "${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}:${datetime.second.toString().padLeft(2, '0')}";
                                        return formattedDatetime;
                                      } else {
                                        return '시간 정보 없음';
                                      }
                                    }(),
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10,),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    //TODO: 황금 눈송이 출몰 공지
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: _snowballShopViewModel.infoStream_snowballShop_notice_gold.value,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        if (snapshot.hasData) {
                          final data = snapshot.data!.data(); // 문서의 데이터 접근
                          if (data == null || data.isEmpty) {
                            return Center(
                              child: Text(
                                'No data available',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          // slope_name 필드 가져오기
                          final slopeName = data['slope_name'] ?? '';

                          // 필드 값이 비었을 때와 아닐 때 처리
                          final displayText = slopeName.isEmpty
                              ? '황금 눈송이가 아직 없어요'
                              : '$slopeName 슬로프에 황금 눈송이가 나타났어요';

                          return Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    displayText,
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ),
                                Icon(Icons.arrow_forward, color: Colors.white),
                              ],
                            ),
                          );
                        } else {
                          return Center(
                            child: Text(
                              'No data available',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    //TODO: 황금 눈송이 상점
                    Center(
                      child: Text(
                        '황금 눈송이 전용 상점',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 2 / 3,
                      ),
                      itemCount: _snowballShopViewModel.goldShopItems.length,
                      itemBuilder: (context, index) {
                        final item = _snowballShopViewModel.goldShopItems[index];
                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () async{
                                if(item.count == 0){
                                  return ;
                                }

                                CustomFullScreenDialog.showDialog();
                                await _snowballShopViewModel.fetchSnowballShopData();
                                CustomFullScreenDialog.cancelDialog();

                                final updatedItem = _snowballShopViewModel.goldShopItems.firstWhere(
                                      (updated) => updated.snowballItemId == item.snowballItemId,
                                  orElse: () => SnowballShopItem(count: 0), // 기본값
                                );

                                if(updatedItem.count == 0){
                                  return ;
                                }

                                _snowballShopViewModel.selectItem(item);
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return GestureDetector(
                                      onTap: () => Navigator.of(context).pop(), // 바깥 클릭 시 닫기
                                      child: Container(
                                        color: Colors.transparent,
                                        child: DraggableScrollableSheet(
                                          initialChildSize: 0.6,
                                          maxChildSize: 0.9,
                                          minChildSize: 0.4,
                                          builder: (_, scrollController) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // 상단 닫기 버튼
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
                                                  Expanded(
                                                    child: SingleChildScrollView(
                                                      controller: scrollController,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            // 이미지 표시
                                                            ClipRRect(
                                                              borderRadius: BorderRadius.circular(16),
                                                              child: ExtendedImage.network(
                                                                item.imageUrl ?? '',
                                                                width: 150,
                                                                height: 150,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                            SizedBox(height: 16),
                                                            // 상품명
                                                            Text(
                                                              item.name ?? '상품 이름',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            SizedBox(height: 8),
                                                            // 설명 텍스트
                                                            Text(
                                                              item.description ?? '',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors.grey[700],
                                                              ),
                                                            ),
                                                            SizedBox(height: 16),
                                                            // 버튼들
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: ElevatedButton(
                                                                    onPressed: () {
                                                                      // 상세 정보 보기 로직
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: Colors.grey[800],
                                                                      padding: EdgeInsets.symmetric(vertical: 14),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(8),
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                      '상세 정보 보기',
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(width: 16),
                                                                Expanded(
                                                                  child: ElevatedButton(
                                                                    onPressed: () async{
                                                                      final int shortfallAmount = item.snowballCount! - _snowballShopViewModel.snowballSummary.value.gold!;

                                                                      if(_snowballShopViewModel.snowballSummary.value.white! < item.snowballCount!){
                                                                        showDialog(
                                                                          context: context,
                                                                          builder: (BuildContext context) {
                                                                            return AlertDialog(
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(8),
                                                                              ),
                                                                              title: Text(
                                                                                '수량 부족',
                                                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                              ),
                                                                              content: Text(
                                                                                '보유한 황금 눈송이 수량이 부족합니다.'
                                                                                    '\n교환하려면 황금 눈송이가 $shortfallAmount개 더 필요합니다.',
                                                                                style: TextStyle(fontSize: 14),
                                                                              ),
                                                                              actions: [
                                                                                TextButton(
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop(); // 팝업 닫기
                                                                                  },
                                                                                  child: Text(
                                                                                    '확인',
                                                                                    style: TextStyle(color: Colors.blue),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          },
                                                                        );
                                                                        return ;
                                                                      }
                                                                      Get.toNamed(AppRoutes.rewardExchangeView);
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: Colors.blue[800],
                                                                      padding: EdgeInsets.symmetric(vertical: 14),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(8),
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                      '교환하기',
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                        color: Colors.white,
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
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: ExtendedImage.network(
                                          item.imageUrl ?? '',
                                          enableMemoryCache: true,
                                          cacheHeight: 100,
                                          cacheWidth: 100,
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
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      item.name ?? '상품 이름',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '황금 눈송이 ${item.snowballCount ?? 0}개',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    if (item.count != 0)
                                      Text(
                                        '잔여 수량 ${item.count}개',
                                        style: TextStyle(fontSize: 12, color: Colors.blueAccent),
                                      ),
                                    if (item.count == 0)
                                      Text(
                                        '품절',
                                        style: TextStyle(fontSize: 12, color: Colors.red),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (item.active == false)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6), // 딤드 효과
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '교환완료',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 16),
                    //TODO: 하얀 눈송이 상점
                    Center(
                      child: Text(
                        '하얀 눈송이 상점',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 2 / 3,
                      ),
                      itemCount: _snowballShopViewModel.whiteShopItems.length,
                      itemBuilder: (context, index) {
                        final item = _snowballShopViewModel.whiteShopItems[index];
                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () async{
                                if(item.count == 0){
                                  return ;
                                }

                                CustomFullScreenDialog.showDialog();
                                await _snowballShopViewModel.fetchSnowballShopData();
                                CustomFullScreenDialog.cancelDialog();

                                final updatedItem = _snowballShopViewModel.whiteShopItems.firstWhere(
                                      (updated) => updated.snowballItemId == item.snowballItemId,
                                  orElse: () => SnowballShopItem(count: 0), // 기본값
                                );

                                if(updatedItem.count == 0){
                                  return ;
                                }
                                _snowballShopViewModel.selectItem(item);
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return GestureDetector(
                                      onTap: () => Navigator.of(context).pop(), // 바깥 클릭 시 닫기
                                      child: Container(
                                        color: Colors.transparent,
                                        child: DraggableScrollableSheet(
                                          initialChildSize: 0.6,
                                          maxChildSize: 0.9,
                                          minChildSize: 0.4,
                                          builder: (_, scrollController) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // 상단 닫기 버튼
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
                                                  Expanded(
                                                    child: SingleChildScrollView(
                                                      controller: scrollController,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            // 이미지 표시
                                                            ClipRRect(
                                                              borderRadius: BorderRadius.circular(16),
                                                              child: ExtendedImage.network(
                                                                item.imageUrl ?? '',
                                                                width: 150,
                                                                height: 150,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                            SizedBox(height: 16),
                                                            // 상품명
                                                            Text(
                                                              item.name ?? '상품 이름',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            SizedBox(height: 8),
                                                            // 설명 텍스트
                                                            Text(
                                                              item.description ?? '',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors.grey[700],
                                                              ),
                                                            ),
                                                            SizedBox(height: 16),
                                                            // 버튼들
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: ElevatedButton(
                                                                    onPressed: () {
                                                                      // 상세 정보 보기 로직
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: Colors.grey[800],
                                                                      padding: EdgeInsets.symmetric(vertical: 14),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(8),
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                      '상세 정보 보기',
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(width: 16),
                                                                Expanded(
                                                                  child: ElevatedButton(
                                                                    onPressed: () {

                                                                      final int shortfallAmount = item.snowballCount! - _snowballShopViewModel.snowballSummary.value.white!;

                                                                      if(_snowballShopViewModel.snowballSummary.value.white! < item.snowballCount!){
                                                                        showDialog(
                                                                          context: context,
                                                                          builder: (BuildContext context) {
                                                                            return AlertDialog(
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(8),
                                                                              ),
                                                                              title: Text(
                                                                                '수량 부족',
                                                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                              ),
                                                                              content: Text(
                                                                                '보유한 하얀 눈송이 수량이 부족합니다.'
                                                                                    '\n교환하려면 하얀 눈송이가 $shortfallAmount개 더 필요합니다.',
                                                                                style: TextStyle(fontSize: 14),
                                                                              ),
                                                                              actions: [
                                                                                TextButton(
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop(); // 팝업 닫기
                                                                                  },
                                                                                  child: Text(
                                                                                    '확인',
                                                                                    style: TextStyle(color: Colors.blue),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          },
                                                                        );
                                                                        return ;
                                                                      }
                                                                      Get.toNamed(AppRoutes.rewardExchangeView);
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: Colors.blue[800],
                                                                      padding: EdgeInsets.symmetric(vertical: 14),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(8),
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                      '교환하기',
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                        color: Colors.white,
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
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: ExtendedImage.network(
                                          item.imageUrl ?? '',
                                          enableMemoryCache: true,
                                          cacheHeight: 100,
                                          cacheWidth: 100,
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
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      item.name ?? '상품 이름',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '하얀 눈송이 ${item.snowballCount ?? 0}개',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    if (item.count != 0)
                                      Text(
                                        '잔여 수량 ${item.count}개',
                                        style: TextStyle(fontSize: 12, color: Colors.blueAccent),
                                      ),
                                    if (item.count == 0)
                                      Text(
                                        '품절',
                                        style: TextStyle(fontSize: 12, color: Colors.red),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (item.active == false)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6), // 딤드 효과
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '교환완료',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 16),
                    Center(
                      child: Text(
                        '함께 하는 브랜드',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemCount: _snowballShopViewModel.sponsors.length,
                      itemBuilder: (context, index) {
                        final sponsor = _snowballShopViewModel.sponsors[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ExtendedImage.network(
                                  sponsor.logoUrl ?? '',
                                  enableMemoryCache: true,
                                  cacheHeight: 100,
                                  cacheWidth: 100,
                                  fit: BoxFit.cover,
                                  loadStateChanged: (ExtendedImageState state) {
                                    switch (state.extendedImageLoadState) {
                                      case LoadState.loading:
                                        return Shimmer.fromColors(
                                          baseColor: SDSColor.gray200!,
                                          highlightColor: SDSColor.gray50!,
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
                              SizedBox(height: 8),
                              Text(
                                sponsor.name ?? '브랜드 이름',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            //TODO: 하단 버튼
            Container(
              padding: EdgeInsets.only(left: 16,right: 16,top: 20, bottom: 40),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // '눈송이 상점이란?' 버튼 클릭 로직
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '눈송이 상점이란?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async{
                        Get.toNamed(AppRoutes.snowballExchangeHistoryView);
                        await _snowballShopViewModel.fetchPurchaseHistory();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '교환한 목록',
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
            )

          ],
        )
    ));
  }
}
