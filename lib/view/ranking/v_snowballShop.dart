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
import 'package:loading_animation_widget/loading_animation_widget.dart';
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

    Size _size = MediaQuery.of(context).size;

    return Obx(() => Scaffold(
        backgroundColor: Color(0xFF1D242E),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(44),
          child: AppBar(
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Image.asset(
              'assets/imgs/imgs/snowballShop/img_snowballshop_text_2.png',
              height: 24,
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
                              '${_snowballShopViewModel.snowballSummary.value.white}', // 하얀 눈송이 개수
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
                  ),
                ),
              ),
            ],
          ),
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
                    Column(
                      children: [
                        SizedBox(height: 12),
                        // 내가 획득한 눈송이_내용+바텀시트
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
                                                  color: SDSColor.snowliveWhite,
                                                  borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))
                                              ),
                                              padding: EdgeInsets.only(top: 16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 20),
                                                    child: Center(
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
                                                  Center(
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          '내가 획득한 눈송이',
                                                          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                                        ),
                                                      ],
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
                                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              // 텍스트 정보
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        (item.color == '하얀')
                                                                        ? Image.asset(
                                                                          'assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png',
                                                                          height: 20,
                                                                        )
                                                                        : Image.asset(
                                                                          'assets/imgs/imgs/snowballShop/icon_snowballshop_goldball.png',
                                                                          height: 20,
                                                                        ),
                                                                        SizedBox(
                                                                          width: 4,
                                                                        ),
                                                                        Text(
                                                                          '$slope에서 $color 눈송이 1개를 획득했습니다.',
                                                                          style: SDSTextStyle.regular.copyWith(
                                                                            color: SDSColor.gray900,
                                                                            fontSize: 14,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Text(
                                                                      formattedDatetime,
                                                                      style: SDSTextStyle.regular.copyWith(
                                                                        color: SDSColor.gray500,
                                                                        fontSize: 13,
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
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                            decoration: BoxDecoration(
                              color: SDSColor.blue400.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _snowballShopViewModel.userSnowballRecords.isNotEmpty
                                            ? '${_snowballShopViewModel.userSnowballRecords[0].slopeName} 슬로프에서 ${_snowballShopViewModel.userSnowballRecords[0].color} 눈송이 1개 획득!'
                                            : '아직 획득한 눈송이가 없어요!',
                                        style: SDSTextStyle.bold.copyWith(color: Colors.white, fontSize: 13),
                                      ),
                                      (_snowballShopViewModel.userSnowballRecords.isNotEmpty)
                                      ? Text(
                                            () {
                                          if (_snowballShopViewModel.userSnowballRecords.isNotEmpty) {
                                            final passTimeString = _snowballShopViewModel.userSnowballRecords[0].passTime ?? DateTime.now().toIso8601String();
                                            final datetime = DateTime.parse(passTimeString);
                                            final formattedDatetime =
                                                "${datetime.month.toString().padLeft(2, '0')}월 ${datetime.day.toString().padLeft(2, '0')}일 "
                                                "${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}:${datetime.second.toString().padLeft(2, '0')}";
                                            return formattedDatetime;
                                          } else {
                                            return '';
                                          }
                                        }(),
                                        style: SDSTextStyle.regular.copyWith(color: SDSColor.snowliveWhite.withOpacity(0.4), fontSize: 12),
                                      )
                                      : Container(),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 4),
                                (_snowballShopViewModel.userSnowballRecords.isNotEmpty)
                                    ? Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Image.asset(
                                    'assets/imgs/imgs/snowballShop/icon_snowballshop_arrow_b.png',
                                    width: 18,
                                    height: 18,
                                  ),
                                )
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                    // 황금 눈송이 출몰 공지
                    Stack(
                      children: [
                        Container(
                          height: 220,
                        ),
                        Container(
                          child: Image.asset(
                            'assets/imgs/imgs/snowballShop/icon_snowballshop_store.png',
                            width: _size.width
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: _snowballShopViewModel.infoStream_snowballShop_notice_gold.value,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                  child: LoadingAnimationWidget.waveDots(
                                      color: SDSColor.blue500,
                                      size: 30
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    '황금 눈송이 소식이 아직 없네요..',
                                    style: SDSTextStyle.regular.copyWith(color: Colors.white, fontSize: 13),
                                  ),
                                );
                              }

                              if (snapshot.hasData) {
                                final data = snapshot.data!.data(); // 문서의 데이터 접근
                                if (data == null || data.isEmpty) {
                                  return Center(
                                    child: Text(
                                      '황금 눈송이 소식이 아직 없네요..',
                                      style: SDSTextStyle.regular.copyWith(color: Colors.white, fontSize: 13),
                                    ),
                                  );
                                }

                                // slope_name 필드 가져오기
                                final ment = data['ment'] ?? '';

                                // 필드 값이 비었을 때와 아닐 때 처리
                                final displayText = ment.isEmpty
                                    ? '황금 눈송이 소식이 아직 없네요..'
                                    : '$ment';

                                return Center(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 50),
                                        child: Image.asset(
                                            'assets/imgs/imgs/snowballShop/icon_snowballshop_bubble.png',
                                            width: 17
                                        ),
                                      ),
                                      IntrinsicWidth(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          decoration: BoxDecoration(
                                            color: SDSColor.snowliveWhite,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            displayText,
                                            style: SDSTextStyle.bold.copyWith(color: SDSColor.snowliveBlack, fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Center(
                                  child: Text(
                                    '황금 눈송이 소식이 아직 없네요..',
                                    style: SDSTextStyle.regular.copyWith(color: SDSColor.snowliveBlack, fontSize: 13),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(height: 48),
                        // 황금 눈송이 상점
                        Center(
                          child: Text(
                            '황금 눈송이 전용 상점',
                            style: SDSTextStyle.bold.copyWith(
                                fontSize: 20, color: SDSColor.snowliveWhite),
                          ),
                        ),
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: _snowballShopViewModel.infoStream_snowballShop.value,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: LoadingAnimationWidget.waveDots(
                                    color: SDSColor.blue500,
                                    size: 30
                                ),
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
                              return Center(
                                child: Text(
                                  '눈송이 상점 종료까지 $_days일 $_hours:$_minutes',
                                  style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.sBlue400),
                                ),
                              );
                            } else {
                              return Center(child: Text('종료까지 남은 시간을 확인중이에요',
                                style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.snowliveWhite.withOpacity(0.6)),));
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 10,
                            childAspectRatio: 11 / 20,
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
                                      isScrollControlled: false,
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
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                onPressed: () {
                                                                  // 상세 정보 보기 로직
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
                                                            ),
                                                            SizedBox(width: 10),
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                onPressed: () async{
                                                                  final int shortfallAmount = item.snowballCount! - _snowballShopViewModel.snowballSummary.value.gold!;

                                                                  if(_snowballShopViewModel.snowballSummary.value.gold! < item.snowballCount!){
                                                                    showDialog(
                                                                      context: context,
                                                                      builder: (BuildContext context) {
                                                                        return AlertDialog(
                                                                          backgroundColor: SDSColor.snowliveWhite,
                                                                          contentPadding: EdgeInsets.only(left: 28, right: 28, top: 36),
                                                                          elevation: 0,
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(16),
                                                                          ),
                                                                          buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                          content: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              Text(
                                                                                '황금 눈송이 수량이 부족해요',
                                                                                textAlign: TextAlign.center,
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    color: SDSColor.gray900,
                                                                                    fontSize: 16
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 6,
                                                                              ),
                                                                              Text('황금 눈송이가 $shortfallAmount개 더 필요합니다.',
                                                                                textAlign: TextAlign.center,
                                                                                style: SDSTextStyle.regular.copyWith(
                                                                                  color: SDSColor.gray500,
                                                                                  fontSize: 14,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 20,
                                                                              )
                                                                            ],
                                                                          ),
                                                                          actions: [
                                                                            Center(
                                                                              child: TextButton(
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop(); // 팝업 닫기
                                                                                  },
                                                                                  style: TextButton.styleFrom(
                                                                                    backgroundColor: Colors.transparent, // 배경색 투명
                                                                                    splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                  ),
                                                                                  child: Text('확인',
                                                                                    style: SDSTextStyle.bold.copyWith(
                                                                                      fontSize: 17,
                                                                                      color: SDSColor.snowliveBlue,
                                                                                    ),
                                                                                  )
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                    return ;
                                                                  }
                                                                  Navigator.pop(context);
                                                                  Get.toNamed(AppRoutes.rewardExchangeView);
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                                                                  splashFactory: InkRipple.splashFactory,
                                                                  elevation: 0,
                                                                  minimumSize: Size(100, 48),
                                                                  backgroundColor: SDSColor.snowliveBlue,
                                                                ),
                                                                child: Text(
                                                                  '교환하기',
                                                                  style: SDSTextStyle.bold.copyWith(
                                                                      color: SDSColor.snowliveWhite,
                                                                      fontSize: 16),
                                                                ),
                                                              ),
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
                                      borderRadius: BorderRadius.circular(8),
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
                                              if (item.active != false && item.count == 0)
                                                Positioned(
                                                  top: 0,
                                                  bottom: 0,
                                                  right: 0,
                                                  left: 0,
                                                  child: Container(
                                                    color: SDSColor.sBlue900.withOpacity(0.8),
                                                  ),
                                                ),
                                              if (item.active == false)
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: SDSColor.sBlue900.withOpacity(0.8), // 딤드 효과
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Center(
                                                      child: Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          '교환완료',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
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
                                        SizedBox(height: 1),
                                        Text(
                                          '황금 눈송이 ${item.snowballCount ?? 0}개',
                                          style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.snowliveWhite.withOpacity(0.5),),
                                        ),
                                        SizedBox(height: 2),
                                        if (item.count != 0)
                                          Text(
                                            '잔여 수량 ${item.count}개',
                                            style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.blue300),
                                          ),
                                        if (item.count == 0)
                                          Text(
                                            '품절',
                                            style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: 36),
                        // 하얀 눈송이 상점
                        Center(
                          child: Text(
                            '하얀 눈송이 상점',
                            style: SDSTextStyle.bold.copyWith(
                                fontSize: 20, color: SDSColor.snowliveWhite),
                          ),
                        ),
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: _snowballShopViewModel.infoStream_snowballShop.value,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: LoadingAnimationWidget.waveDots(
                                    color: SDSColor.blue500,
                                    size: 30
                                ),
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
                              return Center(
                                child: Text(
                                  '눈송이 상점 종료까지 $_days일 $_hours:$_minutes',
                                  style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.sBlue400),
                                ),
                              );
                            } else {
                              return Center(child: Text('종료까지 남은 시간을 확인중이에요',
                                style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.snowliveWhite.withOpacity(0.6)),));
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 10,
                            childAspectRatio: 11 / 20,
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
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                onPressed: () {
                                                                  // 상세 정보 보기 로직
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
                                                            ),
                                                            SizedBox(width: 10),
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                onPressed: () {

                                                                  final int shortfallAmount = item.snowballCount! - _snowballShopViewModel.snowballSummary.value.white!;

                                                                  if(_snowballShopViewModel.snowballSummary.value.white! < item.snowballCount!){
                                                                    showDialog(
                                                                      context: context,
                                                                      builder: (BuildContext context) {
                                                                        return AlertDialog(
                                                                          backgroundColor: SDSColor.snowliveWhite,
                                                                          contentPadding: EdgeInsets.only(left: 28, right: 28, top: 36),
                                                                          elevation: 0,
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(16),
                                                                          ),
                                                                          buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                          content: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              Text(
                                                                                '하얀 눈송이 수량이 부족해요',
                                                                                textAlign: TextAlign.center,
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    color: SDSColor.gray900,
                                                                                    fontSize: 16
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 6,
                                                                              ),
                                                                              Text('하얀 눈송이가 $shortfallAmount개 더 필요합니다.',
                                                                                textAlign: TextAlign.center,
                                                                                style: SDSTextStyle.regular.copyWith(
                                                                                  color: SDSColor.gray500,
                                                                                  fontSize: 14,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 20,
                                                                              )
                                                                            ],
                                                                          ),
                                                                          actions: [
                                                                            Center(
                                                                              child: TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop(); // 팝업 닫기
                                                                                },
                                                                                  style: TextButton.styleFrom(
                                                                                    backgroundColor: Colors.transparent, // 배경색 투명
                                                                                    splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                  ),
                                                                                  child: Text('확인',
                                                                                    style: SDSTextStyle.bold.copyWith(
                                                                                      fontSize: 17,
                                                                                      color: SDSColor.snowliveBlue,
                                                                                    ),
                                                                                  )
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                    return ;
                                                                  }
                                                                  Navigator.pop(context);
                                                                  Get.toNamed(AppRoutes.rewardExchangeView);
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                                                                  splashFactory: InkRipple.splashFactory,
                                                                  elevation: 0,
                                                                  minimumSize: Size(100, 48),
                                                                  backgroundColor: SDSColor.snowliveBlue,
                                                                ),
                                                                child: Text(
                                                                  '교환하기',
                                                                  style: SDSTextStyle.bold.copyWith(
                                                                      color: SDSColor.snowliveWhite,
                                                                      fontSize: 16),
                                                                ),
                                                              ),
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
                                              if (item.active != false && item.count == 0)
                                                Positioned(
                                                  top: 0,
                                                  bottom: 0,
                                                  right: 0,
                                                  left: 0,
                                                  child: Container(
                                                    color: SDSColor.sBlue900.withOpacity(0.8),
                                                  ),
                                                ),
                                              if (item.active == false)
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: SDSColor.sBlue900.withOpacity(0.75), // 딤드 효과
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Center(
                                                      child: Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: SDSColor.snowliveWhite,
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          '교환완료',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                            color: SDSColor.snowliveBlack,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
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
                                        SizedBox(height: 1),
                                        Text(
                                          '하얀 눈송이 ${item.snowballCount ?? 0}개',
                                          style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.snowliveWhite.withOpacity(0.5),),
                                        ),
                                        SizedBox(height: 2),
                                        if (item.count != 0)
                                          Text(
                                            '잔여 수량 ${item.count}개',
                                            style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.blue300),
                                          ),
                                        if (item.count == 0)
                                          Text(
                                            '품절',
                                            style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: 36),
                        Center(
                          child: Text(
                            '함께 하는 브랜드',
                            style: SDSTextStyle.bold.copyWith(
                                fontSize: 20, color: SDSColor.snowliveWhite),
                          ),
                        ),
                        SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1/0.9,
                          ),
                          itemCount: _snowballShopViewModel.sponsors.length,
                          itemBuilder: (context, index) {
                            final sponsor = _snowballShopViewModel.sponsors[index];
                            return Column(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: SDSColor.snowliveBlack.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ExtendedImage.network(
                                        sponsor.logoUrl ?? '',
                                        enableMemoryCache: true,
                                        fit: BoxFit.cover,
                                        cacheHeight: 120,
                                        cacheWidth: 173,
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
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  sponsor.name ?? '브랜드 이름',
                                  style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.snowliveWhite),
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
                        onPressed: () {
                          // '눈송이 상점이란?' 버튼 클릭 로직
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7C899D).withOpacity(0.4),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
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
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async{
                          Get.toNamed(AppRoutes.snowballExchangeHistoryView);
                          await _snowballShopViewModel.fetchPurchaseHistory();
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Color(0xFF649CF1).withOpacity(0.4),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
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
              ),
            )

          ],
        )
    ));
  }
}
