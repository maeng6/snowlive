import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_snowball.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
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
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SnowballMarketHomeView extends StatefulWidget {
  @override
  State<SnowballMarketHomeView> createState() => _SnowballMarketHomeViewState();
}

class _SnowballMarketHomeViewState extends State<SnowballMarketHomeView> {
  SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();
  FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  UserViewModel _userViewModel = Get.find<UserViewModel>();

  bool _isRefreshing = false;
  Timer? _timer;
  String _days = '00';
  String _hours = '00';
  String _minutes = '00';
  DateTime? _currentEndTime;

  //TODO: Select Store**************************************************
  int _currentShopIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  void _openSnowShopBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: GestureDetector(
                onTap: () {}, // 내부 터치시 닫히지 않게
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.74, // ✅ 높이 지정
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 16, bottom: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ 공간 균등 분배
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // 드래그 핸들
                          Container(
                            height: 4,
                            width: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 기존 CarouselSlider 대신
                          SizedBox(
                            height: 470, // 카드 높이 명시 (원래 400이었는데 살짝 줄여도 OK)
                            child: PageView.builder(
                              controller: PageController(viewportFraction: 0.65),
                              itemCount: 2,
                              onPageChanged: (index) {
                                setModalState(() {
                                  _currentShopIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final item = [
                                  {
                                    'title': '프리미엄 눈송이 상점',
                                    'subtitle': '랭킹 등급 골드 이상 이용 가능',
                                    'image': 'assets/imgs/imgs/snowballShop/img_snowballshop_store_premium.png',
                                },
                                  {
                                    'title': '일반 눈송이 상점',
                                    'subtitle': '누구나 이용 가능',
                                    'image': 'assets/imgs/imgs/snowballShop/img_snowballshop_store_public.png',
                                  },
                                ][index];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Transform.scale(
                                    scale: _currentShopIndex == index ? 1.0 : 0.92,
                                    child: GestureDetector(
                                      onTap: (){
                                        Navigator.of(context).pop();
                                        if (index == 0) {
                                          Get.toNamed(AppRoutes.snowballMarketPremiumShop); // ✅ 프리미엄 상점
                                        } else {
                                          Get.toNamed(AppRoutes.snowballMarketPublicShop);  // ✅ 일반 상점
                                        }
                                      },
                                      child: _buildShopCard(
                                        title: item['title']!,
                                        subtitle: item['subtitle']!,
                                        image: item['image']!,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8), // 도트와 카드 사이 여백 줄임
                          AnimatedSmoothIndicator(
                            activeIndex: _currentShopIndex,
                            count: 2,
                            effect: SlideEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              spacing: 6,
                              radius: 8,
                              dotColor: Colors.grey.withOpacity(0.3),
                              activeDotColor: const Color(0xFF1D242E),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () {
                              _snowballShopViewModel.fetchPurchaseHistory();
                              Get.toNamed(AppRoutes.snowballMarketBuyRecord);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFFFFF),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(
                                  color: Color(0xFFDDDDDD),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            child: const Text(
                              '경품 교환 목록',
                              style: TextStyle(
                                color: Color(0xFF000000),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
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
    );
  }


  Widget _buildShopCard({
    required String title,
    required String subtitle,
    required String image,
  }) {
    return Column(
      children: [
        ClipRRect(
          child: Image.asset(
            image,
            fit: BoxFit.cover,
            height: 400,
            width: double.infinity,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  //TODO: Select Store**************************************************




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

    return Obx(() => Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1D242E), // 위쪽
            Color(0xFF030C19), // 아래쪽
          ],
        ),
      ),
      child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent, // Scaffold 기본 배경 투명 처리
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: AppBar(
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
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
                    Get.toNamed(AppRoutes.snowballmarket);
                    await _snowballShopViewModel.getInfo_snowballMarket();
                    await _snowballShopViewModel.fetchSnowballShop();
                    await _snowballShopViewModel.getInfo_snowballMarket_notice_gold();
                    await _snowballShopViewModel.fetchUserSnowballRecords();
                    _snowballShopViewModel.loadingEntrance = false;

                  },
                  child: ListView(
                    padding: EdgeInsets.only(top: 16, bottom: 16),
                    children: [
                      SizedBox(height: kToolbarHeight), // 👈 AppBar 높이(44) + 여유 공간
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 220,
                          ),
                          Container(
                            child: Column(
                              children: [
                                Image.asset(
                                    'assets/imgs/imgs/snowballShop/icon_snowballshop_store.png',
                                    width: _size.width
                                ),
                              ],
                            ),
                          ),
                          //상단 일러 이미지 영역
                          Positioned(
                            top: 30, // 이미지 상단에서 얼마나 띄울지 (필요시 조정)
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Image.asset(
                                'assets/imgs/imgs/snowballShop/icon_snowballshop_store_title.png',
                                height: 95, // 크기 조정
                              ),
                            ),
                          ),
                          //상단 눈송이 보유 현황
                          Positioned(
                            top: 145,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // ✅ 하얀 눈송이 박스
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png',
                                          height: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '하얀 눈송이',
                                          style: SDSTextStyle.regular.copyWith(
                                            color: Colors.white.withOpacity(0.7), // ✅ 투명도 70%
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${_snowballShopViewModel.summary[0].remaining}',
                                          style: SDSTextStyle.regular.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 5), // 두 박스 사이 간격

                                  // ✅ 황금 눈송이 박스
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/imgs/imgs/snowballShop/icon_snowballshop_goldball.png',
                                          height: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '황금 눈송이',
                                          style: SDSTextStyle.regular.copyWith(
                                            color: Colors.white.withOpacity(0.7), // ✅ 투명도 70%
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${_snowballShopViewModel.summary[1].remaining}',
                                          style: SDSTextStyle.regular.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //상단 황금 눈송이 출몰 공지
                          Positioned(
                            bottom: -10,
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
                      SizedBox(height: 20,),
                      Column(
                        children: [
                          //브랜드 미션 이미지
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              children: [
                                SizedBox(height: 60,),
                                Text('브랜드 미션',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                                ),
                                Text('각 브랜드의 미션을 빠르게 완수하고,',
                                  style: TextStyle(
                                      color: Color(0xFFFFFFFF).withOpacity(0.6),
                                      fontSize: 13
                                  ),
                                ),
                                Text('단 하나뿐인 리워드의 주인공이 될 기회를 잡아라!',
                                  style: TextStyle(
                                      color: Color(0xFFFFFFFF).withOpacity(0.6),
                                      fontSize: 13
                                  ),
                                ),
                                SizedBox(height: 10,),
                                GestureDetector(
                                  onTap: (){
                                    Get.toNamed(AppRoutes.snowballMarketBrandShop);
                                  },
                                  child: Image.asset(
                                    'assets/imgs/imgs/snowballShop/icon_snowballshop_store_brand.png',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //눈송이 획득 실시간 현황
                          Column(
                            children: [
                              SizedBox(height: 60),
                              // 내가 획득한 눈송이_내용+바텀시트
                              Text('내가 획득한 눈송이',
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: [
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
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          image: const DecorationImage(
                                            image: AssetImage('assets/imgs/imgs/snowballShop/icon_snowballshop_store_box_1.png'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            if (_snowballShopViewModel.userSnowballRecords.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(right: 6),
                                                child: Image.asset(
                                                  _snowballShopViewModel.userSnowballRecords[0].color == '하얀'
                                                      ? 'assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png'
                                                      : 'assets/imgs/imgs/snowballShop/icon_snowballshop_goldball.png',
                                                  height: 20,
                                                ),
                                              ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _snowballShopViewModel.userSnowballRecords.isNotEmpty
                                                        ? '${_snowballShopViewModel.userSnowballRecords[0].slopeName}에서 ${_snowballShopViewModel.userSnowballRecords[0].color} 눈송이 1개 획득'
                                                        : '아직 획득한 눈송이가 없어요!',
                                                    style: SDSTextStyle.regular.copyWith(color: SDSColor.snowliveBlack, fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            (_snowballShopViewModel.userSnowballRecords.isNotEmpty)
                                                ? Text(
                                                  () {
                                                if (_snowballShopViewModel.userSnowballRecords.isNotEmpty) {
                                                  final passTimeString = _snowballShopViewModel.userSnowballRecords[0].passTime ?? DateTime.now().toIso8601String();
                                                  final datetime = DateTime.parse(passTimeString);
                                                  final formattedDatetime =
                                                      "${datetime.month.toString().padLeft(2, '0')}.${datetime.day.toString().padLeft(2, '0')} "
                                                      "${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}";
                                                  return formattedDatetime;
                                                } else {
                                                  return '';
                                                }
                                              }(),
                                              style: SDSTextStyle.regular.copyWith(color: SDSColor.snowliveBlack.withOpacity(0.4), fontSize: 12),
                                            )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if(_snowballShopViewModel.userSnowballRecords.length >1)
                                    Column(
                                      children: [
                                        SizedBox(height: 8,),
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
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              image: const DecorationImage(
                                                image: AssetImage('assets/imgs/imgs/snowballShop/icon_snowballshop_store_box_1.png'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                if (_snowballShopViewModel.userSnowballRecords.isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 6),
                                                    child: Image.asset(
                                                      _snowballShopViewModel.userSnowballRecords[1].color == '하얀'
                                                          ? 'assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png'
                                                          : 'assets/imgs/imgs/snowballShop/icon_snowballshop_goldball.png',
                                                      height: 20,
                                                    ),
                                                  ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        _snowballShopViewModel.userSnowballRecords.isNotEmpty
                                                            ? '${_snowballShopViewModel.userSnowballRecords[1].slopeName}에서 ${_snowballShopViewModel.userSnowballRecords[1].color} 눈송이 1개 획득'
                                                            : '아직 획득한 눈송이가 없어요!',
                                                        style: SDSTextStyle.regular.copyWith(color: SDSColor.snowliveBlack, fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                (_snowballShopViewModel.userSnowballRecords.isNotEmpty)
                                                    ? Text(
                                                      () {
                                                    if (_snowballShopViewModel.userSnowballRecords.isNotEmpty) {
                                                      final passTimeString = _snowballShopViewModel.userSnowballRecords[1].passTime ?? DateTime.now().toIso8601String();
                                                      final datetime = DateTime.parse(passTimeString);
                                                      final formattedDatetime =
                                                          "${datetime.month.toString().padLeft(2, '0')}.${datetime.day.toString().padLeft(2, '0')} "
                                                          "${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}";
                                                      return formattedDatetime;
                                                    } else {
                                                      return '';
                                                    }
                                                  }(),
                                                  style: SDSTextStyle.regular.copyWith(color: SDSColor.snowliveBlack.withOpacity(0.4), fontSize: 12),
                                                )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if(_snowballShopViewModel.userSnowballRecords.length >2)
                                    Column(
                                      children: [
                                        SizedBox(height: 8,),
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
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              image: const DecorationImage(
                                                image: AssetImage('assets/imgs/imgs/snowballShop/icon_snowballshop_store_box_1.png'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                if (_snowballShopViewModel.userSnowballRecords.isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 6),
                                                    child: Image.asset(
                                                      _snowballShopViewModel.userSnowballRecords[2].color == '하얀'
                                                          ? 'assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png'
                                                          : 'assets/imgs/imgs/snowballShop/icon_snowballshop_goldball.png',
                                                      height: 20,
                                                    ),
                                                  ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        _snowballShopViewModel.userSnowballRecords.isNotEmpty
                                                            ? '${_snowballShopViewModel.userSnowballRecords[2].slopeName}에서 ${_snowballShopViewModel.userSnowballRecords[2].color} 눈송이 1개 획득'
                                                            : '아직 획득한 눈송이가 없어요!',
                                                        style: SDSTextStyle.regular.copyWith(color: SDSColor.snowliveBlack, fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                (_snowballShopViewModel.userSnowballRecords.isNotEmpty)
                                                    ? Text(
                                                      () {
                                                    if (_snowballShopViewModel.userSnowballRecords.isNotEmpty) {
                                                      final passTimeString = _snowballShopViewModel.userSnowballRecords[2].passTime ?? DateTime.now().toIso8601String();
                                                      final datetime = DateTime.parse(passTimeString);
                                                      final formattedDatetime =
                                                          "${datetime.month.toString().padLeft(2, '0')}.${datetime.day.toString().padLeft(2, '0')} "
                                                          "${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}";
                                                      return formattedDatetime;
                                                    } else {
                                                      return '';
                                                    }
                                                  }(),
                                                  style: SDSTextStyle.regular.copyWith(color: SDSColor.snowliveBlack.withOpacity(0.4), fontSize: 12),
                                                )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // 새로고침 버튼
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (_isRefreshing) return; // 이미 로딩 중이면 무시 (onPressed null 아님)
                                            setState(() => _isRefreshing = true);
                                            try {
                                              await _snowballShopViewModel.fetchUserSnowballRecords();
                                            } finally {
                                              setState(() => _isRefreshing = false);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF7C899D), // ✅ 색상 고정
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: SizedBox(
                                            width: 70, // ✅ 고정 크기 (텍스트 기준)
                                            height: 18,
                                            child: Center(
                                              child: AnimatedSwitcher(
                                                duration: const Duration(milliseconds: 150),
                                                transitionBuilder: (child, anim) =>
                                                    FadeTransition(opacity: anim, child: child),
                                                child: _isRefreshing
                                                    ? SizedBox(
                                                  key: ValueKey('loading'),
                                                  width: 14,
                                                  height: 14,
                                                  child: Center(
                                                    child: LoadingAnimationWidget.waveDots(
                                                      color: SDSColor.snowliveWhite,
                                                      size: 15,
                                                    ),
                                                  ),
                                                )
                                                    : Text(
                                                  '새로고침',
                                                  key: const ValueKey('text'),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // 자세히 보기 버튼
                                        ElevatedButton(
                                          onPressed: () {
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
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '자세히 보기',
                                                style: SDSTextStyle.bold.copyWith(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              Image.asset(
                                                'assets/imgs/imgs/snowballShop/icon_snowballshop_arrow_b.png',
                                                width: 16,
                                                height: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )

                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                          //눈송이 상점 참여 방법
                          SizedBox(height: 60,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/imgs/imgs/snowballShop/img_snowballshop_store_bottom_image1.png',
                                ),
                              ],
                            ),
                          ),
                          //눈송이 상점 이야기
                          SizedBox(height: 60,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/imgs/imgs/snowballShop/img_snowballshop_store_bottom_image2.png',
                                ),
                              ],
                            ),
                          ),

                          //안내사항
                          SizedBox(height: 60,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              width: double.infinity, // ✅ 화면 전체 가로 차지
                              // width: 340,           // 또는 특정 픽셀값으로 고정 가능
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '안내사항',
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  Text(
                                    '· 교환이 완료된 상품은 취소나 변경이 불가합니다.',
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF).withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  Text(
                                    '· 앱에서 교환한 상품은 반드시 현장 행사부스에서 실물 상품으로 교환해야 합니다.',
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF).withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  Text(
                                    '· 당일 획득한 눈송이는 반드시 당일에 모두 사용해야 합니다.\n사용하지 않은 눈송이는 다음 날 자동으로 소멸되니 꼭 모두 사용해 주세요.',
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF).withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )

                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // 하단 버튼
              Container(
                  padding: EdgeInsets.only(left: 16,right: 16,top: 16, bottom: 34),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              // 🔹 Firestore에서 event_date 불러오기
                              final doc = await FirebaseFirestore.instance
                                  .collection('snowball_market')
                                  .doc('snowball_market')
                                  .get();

                              final eventDate = doc.data()?['event_date'] ?? 1;

                              // 🔹 QR 데이터 구성
                              final qrData = jsonEncode({
                                "user_id": _userViewModel.user.user_id,
                                "event_date": eventDate,
                              });

                              // 🔹 QR 표시 바텀시트
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: const Color(0xFF3D83ED),
                                builder: (context) {
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => Navigator.of(context).pop(),
                                    child: SafeArea(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                          color: Color(0xFF3D83ED),
                                        ),
                                        padding: const EdgeInsets.only(
                                            bottom: 16, right: 16, left: 16, top: 12),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // 핸들바
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
                                            const SizedBox(height: 32),
                                            // QR 이미지
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color(0xFF073819),
                                                  width: 6,
                                                ),
                                              ),
                                              child: QrImageView(
                                                data: qrData, // ✅ event_date 포함된 데이터
                                                version: QrVersions.auto,
                                                size: _size.width - 140,
                                                backgroundColor: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              '눈송이 pay QR 결제',
                                              style: SDSTextStyle.bold.copyWith(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '경품 수령처에서 QR 코드를 스캔하고\n현장 이벤트에 참여해 보세요!',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.normal,
                                                color: SDSColor.snowliveWhite,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 30),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } catch (e) {
                              print('❌ Firestore event_date 불러오기 실패: $e');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C899D),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            '눈송이 pay',
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
                            _openSnowShopBottomSheet(context);
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
                            '눈송이 상점',
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


            ],
          )
      ),
    ));
  }
}
