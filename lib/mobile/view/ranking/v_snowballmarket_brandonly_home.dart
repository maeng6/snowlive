import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/core/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_snowball.dart';
import 'package:com.snowlive/mobile/routes/routes.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/core/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/mobile/viewmodel/ranking/vm_snowball.dart';
import 'package:com.snowlive/mobile/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SnowballMarketBrandOnlyHomeView extends StatefulWidget {
  @override
  State<SnowballMarketBrandOnlyHomeView> createState() => _SnowballMarketBrandOnlyHomeViewState();
}

class _SnowballMarketBrandOnlyHomeViewState extends State<SnowballMarketBrandOnlyHomeView> {
  SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();
  FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  UserViewModel _userViewModel = Get.find<UserViewModel>();

  bool _isRefreshing = false;
  Timer? _timer;
  String _days = '00';
  String _hours = '00';
  String _minutes = '00';
  DateTime? _currentEndTime;

  String generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

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
                  height: MediaQuery.of(context).size.height * 0.63, // ✅ 높이 지정
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: EdgeInsets.only(top: 16, bottom: 32),
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
                          SizedBox(height: 24),
                          // 기존 CarouselSlider 대신
                          SizedBox(
                            height: 360,
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
                                    scale: _currentShopIndex == index ? 1.0 : 0.9,
                                    child: GestureDetector(
                                      onTap: (){
                                        Navigator.of(context).pop();
                                        if (index == 0) {
                                          Get.toNamed(AppRoutes.snowballMarketBrandOnlyPremiumShop); // ✅ 프리미엄 상점
                                        } else {
                                          Get.toNamed(AppRoutes.snowballMarketBrandOnlyPublicShop);  // ✅ 일반 상점
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
                          SizedBox(height: 8), // 도트와 카드 사이 여백 줄임
                          AnimatedSmoothIndicator(
                            activeIndex: _currentShopIndex,
                            count: 2,
                            effect: SlideEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              spacing: 8,
                              radius: 8,
                              dotColor: Colors.grey.withOpacity(0.3),
                              activeDotColor: const Color(0xFF1D242E),
                            ),
                          ),
                          SizedBox(height: 18),
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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            child: Image.asset(
              image,
              fit: BoxFit.fill,
              height: 292,
              width: 220,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
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
            Color(0xFF1AC02F),
            Color(0xFF0C7519),
            Color(0xFF0C7519)
            // 아래쪽
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
              leading: Padding(
          padding: EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: SvgPicture.asset('assets/imgs/icons/icon_snowLive_back.svg', width: 26, height: 26, colorFilter: ColorFilter.mode(SDSColor.snowliveWhite, BlendMode.srcIn)),
            highlightColor: Colors.transparent,
          ),
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
              : Stack(
            children: [
              Positioned.fill(
                child: RefreshIndicator(
                  strokeWidth: 2,
                  edgeOffset: -40,
                  displacement: 40,
                  backgroundColor: Color(0xFF86ED3D),
                  color: SDSColor.snowliveWhite,
                  onRefresh: () async{
                    _snowballShopViewModel.loadingEntrance = true;
                    await _snowballShopViewModel.fetchSnowballHomeData();
                    await _snowballShopViewModel.getInfo_snowballMarket();
                    _snowballShopViewModel.loadingEntrance = false;
                    await _snowballShopViewModel.getInfo_snowballMarket_notice_gold();
                    await _snowballShopViewModel.fetchUserSnowballRecords();

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
                                    'assets/imgs/imgs/snowballShop/icon_snowballshop_brand_store.png',
                                    width: _size.width
                                ),
                              ],
                            ),
                          ),
                          //상단 일러 이미지 영역
                          Positioned(
                            top: 16, // 이미지 상단에서 얼마나 띄울지 (필요시 조정)
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Image.asset(
                                'assets/imgs/imgs/snowballShop/icon_snowballshop_brand_store_title.png',
                                height: 95, // 크기 조정
                              ),
                            ),
                          ),
                          //상단 눈송이 보유 현황
                          Positioned(
                            top: 118,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Text('휘닉스 파크에서 눈송이를 찾아라!',
                                style: SDSTextStyle.bold.copyWith(
                                    fontSize: 15,
                                    color: Colors.white
                                ),

                              ),
                            ),
                          ),
                          Positioned(
                            top: 154,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // ✅ 하얀 눈송이 박스
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFCAFFA2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(width: 1, color: SDSColor.snowliveWhite.withOpacity(0.2),),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                            color: Colors.black, // ✅ 투명도 70%
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${_snowballShopViewModel.summary[0].remaining}',
                                          style: SDSTextStyle.regular.copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 5), // 두 박스 사이 간격

                                  // ✅ 황금 눈송이 박스
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFCAFFA2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(width: 1, color: SDSColor.snowliveWhite.withOpacity(0.2),),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                            color: Colors.black, // ✅ 투명도 70%
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${_snowballShopViewModel.summary[1].remaining}',
                                          style: SDSTextStyle.regular.copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
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
                            child: Obx(() {
                              final data = _snowballShopViewModel.infoData_snowballShop_notice_gold.value;
                              if (data == null || data.isEmpty) {
                                return Center(
                                  child: Text(
                                    '황금 눈송이 소식이 아직 없네요..',
                                    style: SDSTextStyle.regular.copyWith(color: Colors.white, fontSize: 13),
                                  ),
                                );
                              }

                              final ment = data['ment'] ?? '';
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
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                        decoration: BoxDecoration(
                                          color: SDSColor.snowliveWhite,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          displayText,
                                          style: SDSTextStyle.bold.copyWith(color: SDSColor.snowliveBlack, fontSize: 13),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      SizedBox(height: 60,),
                      Column(
                        children: [
                          //브랜드 미션 이미지
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/imgs/imgs/snowballShop/anim_bs_logo.webp',
                                      width: 300,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  'assets/imgs/imgs/snowballShop/icon_snowballshop_home_bs_bg.png',
                                ),
                              ],
                            ),
                          ),
                          //눈송이 획득 실시간 현황
                          Column(
                            children: [
                              SizedBox(height: 80),
                              // 내가 획득한 눈송이_내용+바텀시트
                              Text('내가 획득한 눈송이',
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(height: 16),
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
                                        height: 54,
                                        width: _size.width-16,
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Color(0xFFCAFFA2)
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
                                              height: 54,
                                              width: _size.width-16,
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  color: Color(0xFFCAFFA2)
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
                                              height: 54,
                                              width: _size.width-16,
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  color: Color(0xFFCAFFA2)
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
                                            backgroundColor: const Color(0xFFFFFFFF), // ✅ 색상 고정
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: SizedBox(
                                            width: 56, // ✅ 고정 크기 (텍스트 기준)
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
                                                      color: SDSColor.snowliveBlack,
                                                      size: 15,
                                                    ),
                                                  ),
                                                )
                                                    : Text(
                                                  '새로고침',
                                                  key: const ValueKey('text'),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
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
                                                                  (_snowballShopViewModel.userSnowballRecords.length > 0)
                                                                      ? Expanded(
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
                                                                  )
                                                                      : Expanded(
                                                                    child: Center(
                                                                      child: Padding(
                                                                        padding: EdgeInsets.only(bottom: 100),
                                                                        child: Column(
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                          children: [
                                                                            Image.asset(
                                                                              'assets/imgs/imgs/snowballShop/icon_snb_nodata.png',
                                                                              width: 80,
                                                                              height: 80,
                                                                            ),
                                                                            SizedBox(
                                                                              height: 6,
                                                                            ),
                                                                            Text('아직 획득한 눈송이가 없어요',
                                                                              style: SDSTextStyle.regular.copyWith(
                                                                                  fontSize: 14,
                                                                                  color: SDSColor.gray600
                                                                              ),
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
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            elevation: 0,
                                            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 12),
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
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              Image.asset(
                                                'assets/imgs/imgs/snowballShop/icon_snowballshop_arrow.png',
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
                            ],
                          ),
                          //눈송이 상점 참여 방법
                          SizedBox(height: 96,),
                          Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text('눈송이 상점 참여 방법',
                              style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Container(
                              width: _size.width - 32,
                              decoration: BoxDecoration(
                                color: Color(0xFF000000).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png',
                                          height: 60,
                                        ),
                                        SizedBox(width: 6,),
                                        Image.asset(
                                          'assets/imgs/imgs/snowballShop/icon_snowballshop_goldball.png',
                                          height: 60,
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8, top: 16),
                                      child: Text('눈송이 모으기',
                                        style: SDSTextStyle.bold.copyWith(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8),
                                      child: Text('라이브를 켜고 휘닉스 파크에서 라이딩 시 일정 확률로\n하얀 눈송이 혹은 황금 눈송이를 획득할 수 있어요!',
                                        style: SDSTextStyle.regular.copyWith(
                                          color: Color(0xFFFFFFFF).withOpacity(0.8),
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8),
                                      child: Text('단, 황금 눈송이는 1시간에 한 번 랜덤으로 등장해요.\n황금 눈송이가 내리는 위치는 매 정각마다\n눈송이 상점에서 알려드릴게요.',
                                        style: SDSTextStyle.regular.copyWith(
                                          color: Color(0xFF86ED3D),
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ),
                          SizedBox(height: 16),
                          Container(
                              width: _size.width - 32,
                              decoration: BoxDecoration(
                                color: Color(0xFF000000).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/imgs/imgs/snowballShop/icon_snowballshop_store_banner.png',
                                      height: 100,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8, top: 16),
                                      child: Text('눈송이 상점 이용하기',
                                        style: SDSTextStyle.bold.copyWith(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8),
                                      child: Text('라이딩하면서 모아둔 하얀 눈송이와 황금 눈송이로\n교환하고 싶은 상품과 교환을 할 수 있어요.\n상품 수령을 위해 이름과 전화번호, 주소를 입력하면 신청 완료!\n만약 현장 수령을 원하시면, 호크 리프트 옆\n눈송이 상품 수령처에서 직접 수령도 가능해요.',
                                        style: SDSTextStyle.regular.copyWith(
                                          color: Color(0xFFFFFFFF).withOpacity(0.8),
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8),
                                      child: Text('상품 교환시 취소 및 변경이 불가능하니 신중하게 골라주세요!',
                                        style: SDSTextStyle.regular.copyWith(
                                          color: Color(0xFF86ED3D),
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ),
                          //눈송이 상점 이야기
                          SizedBox(height: 96),
                          Text('눈송이 상점 이야기',
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          Text('눈송이를 모아 스노빌리지 친구들이\n여름을 날 수 있도록 도와주세요!',
                            style: TextStyle(
                                color: Color(0xFFFFFFFF).withOpacity(0.6),
                                fontSize: 13
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/imgs/imgs/snowballShop/img_snowballshop_store_bottom_image3.png',
                                ),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 46, horizontal: 40),
                                    child: Text('안녕하세요?\n저는 전국에서 내리는 눈송이를 찾아\n유랑하는 상인 하람이에요.\n\n스노빌리지에서는 제가 눈송이를 가득 싣고 오기를 애타게 기다리고 있어요.\n\n눈송이가 왜 필요하냐구요?\n눈송이는 우리 스노 친구들이 더운 여름을 견디기위해 꼭 필요한 자원이랍니다. 그래서 저는 이번 겨울 최대한 많은 눈송이를 모으기 위해 여기저기 유랑하고 있답니다.\n특히 황금 눈송이는 스노빌리지에서 다양한 재화를 만들 수 있는 제일 중요한 자원이에요.\n\n그런데 주말동안 휘닉스 파크에서 눈송이가 내린다는 예보가 있지 뭐에요?\n제가 다양한 상품을 가지고 왔으니, 여러분이 힘을 합쳐 눈송이를 모아서 가져와주세요!\n\n눈송이 값은 섭섭치 않게 쳐드릴게요 :)',
                                      style: TextStyle(
                                          color: SDSColor.snowliveBlack,
                                          fontSize: 14
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
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
                          ),
                          SizedBox(height: 130),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // 하단 버튼
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Container(
                      width: _size.width,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,      // 위쪽(0%)
                          end: Alignment.bottomCenter,     // 아래쪽(100%)
                          colors: [
                            Color(0x000C7519),             // #030C19, opacity 0
                            Color(0xFF0C7519),             // #030C19, opacity 100
                          ],
                          stops: [0.0, 1.0],
                        ),
                      ),
                    ),
                    Container(
                      color: Color(0xFF0C7519),
                      padding: EdgeInsets.only(left: 16,right: 16,top: 10, bottom: 34),
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

                                  final randomString = generateRandomString(12);

                                  final qrData = "$randomString#${_userViewModel.user.user_id}#$eventDate";


                                  // 🔹 QR 표시 바텀시트
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: const Color(0xFF0C7519),
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
                                              color: Color(0xFF0C7519),
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
                                                  '눈송이 Pay QR 결제',
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
                                                    color: SDSColor.snowliveWhite.withOpacity(0.6),
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
                                backgroundColor: const Color(0xFFFFFFFF),
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
                                  color: Colors.black,
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
                                backgroundColor: Color(0xFF86ED3D),
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
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
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
