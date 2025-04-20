import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/viewmodel/forestPark/vm_forestPark.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';

class ForestParkHome extends StatefulWidget {
  @override
  State<ForestParkHome> createState() => _ForestParkHomeState();
}

class _ForestParkHomeState extends State<ForestParkHome> {

  final ForestParkViewModel _forestParkViewModel = Get.find<ForestParkViewModel>();
  final TextEditingController _codeController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _showAppBarBackground = false;

  final RxString _codeErrorMessage = ''.obs;
  RxBool isParticipant = false.obs;

  bool _hasFetchedData = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final showBackground = _scrollController.offset > 50;
      if (showBackground != _showAppBarBackground) {
        setState(() {
          _showAppBarBackground = showBackground;
        });
      }
    });
  }


  void _showCodeInputPopup(BuildContext context, int eventDate) {
    _codeController.clear();
    _codeErrorMessage.value = '';

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Color(0xFF0B5E2A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.35, // ✅ 높이 확보
            ),
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16), // 🔼 top padding 줄임
            decoration: BoxDecoration(
              color: Color(0xFF0B5E2A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ⬆️ 상단 핸들
                Container(
                  width: 36,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFffffff),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // ⬆️ 타이틀
                Text(
                  '이벤트 참여 코드를 입력해주세요!',
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // ⬇️ 설명
                Text(
                  '구매하신 참여코드를 확인하여 입력하고\n포레스트 파크에서 모험을 시작해 보세요!',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 13,
                    color: SDSColor.snowliveWhite.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // ⌨️ 텍스트 입력
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF0D2415).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _codeController,
                    onChanged: (_) => _codeErrorMessage.value = '',
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '참여코드를 입력해 주세요',
                      hintStyle: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5)),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                Obx(() => _codeErrorMessage.value.isEmpty
                    ? SizedBox.shrink()
                    : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _codeErrorMessage.value,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                )),

                const SizedBox(height: 40),

                // ✅ 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final code = _codeController.text.trim();
                      if (code.isEmpty) {
                        _codeErrorMessage.value = '참여코드를 입력해주세요';
                        return;
                      }

                      CustomFullScreenDialog.showDialog();
                      final result = await _forestParkViewModel.registerParticipant(code: code, eventDate: eventDate);
                      CustomFullScreenDialog.cancelDialog();

                      if (result) {
                        CustomFullScreenDialog.showDialog();
                        final result = await _forestParkViewModel.checkParticipant(eventDate);
                        isParticipant.value = result;
                        CustomFullScreenDialog.cancelDialog();

                        // ✅ 참여 성공 다이얼로그
                        Get.dialog(
                          AlertDialog(
                            backgroundColor: SDSColor.snowliveWhite,
                            contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            content: Container(
                              height: 80,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '참여 완료',
                                    textAlign: TextAlign.center,
                                    style: SDSTextStyle.bold.copyWith(
                                        color: SDSColor.gray900,
                                        fontSize: 16
                                    ),
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    '이벤트 참여가 완료되었습니다!\n퀴즈를 풀고 황금열매를 모아보세요.',
                                    textAlign: TextAlign.center,
                                    style: SDSTextStyle.regular.copyWith(
                                      color: SDSColor.gray500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              Padding(
                                padding: EdgeInsets.only(top: 24),
                                child: SizedBox(
                                  child: Container(
                                    width: 240,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Get.back(); // 다이얼로그 닫기
                                        Get.back(); // 바텀시트 닫기
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Color(0xFF127721),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      child: Text(
                                        '확인',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      } else {
                        _codeErrorMessage.value = '유효하지 않은 참여코드입니다';
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    child: Text(
                      '포레스트 파크 시작하기',
                      style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.snowliveBlack),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
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
        final String backgroundImage_closed = data?['backgroundImage_closed'] ?? '';
        final String backgroundImage_open = data?['backgroundImage_open'] ?? '';

        // ✅ 최초 한 번만 실행
        if (!_hasFetchedData) {
          _forestParkViewModel.fetchLeafRemain(eventDate);
          _forestParkViewModel.checkParticipant(eventDate).then((result) {
            isParticipant.value = result;
          });
          _hasFetchedData = true;
        }



        return Scaffold(
          backgroundColor: Color(0xFF12341E),
          floatingActionButton: SizedBox(
            width: MediaQuery.of(context).size.width - 24,
            child: FloatingActionButton.extended(
              backgroundColor: Color(0xFF1B872B),
              onPressed: () {
                Get.toNamed(AppRoutes.qrScannerForestPark);
              },
              icon: Image.asset(
                'assets/imgs/imgs/img_forest_qr.png',
                width: 24,
                height: 24,
              ),
              label: Text(
                '퀴즈 QR 스캔하기',
                style: SDSTextStyle.bold.copyWith(
                    color: SDSColor.snowliveWhite,
                    fontSize: 16
                ),
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Color(0xFFFFAE00),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

          appBar: PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: AppBar(
              elevation: 0,
              titleSpacing: 16,
              surfaceTintColor: Colors.transparent,
              title: Text('황금숲의 전설 : 황금열매를 찾아서',
                style: SDSTextStyle.extraBold.copyWith(
                    color: SDSColor.snowliveWhite,
                    fontSize: 18),
              ),
              backgroundColor: _showAppBarBackground
                  ? Color(0xFF12341E) // 너가 쓰던 배경색과 비슷하게
                  : Colors.transparent,
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
          extendBodyBehindAppBar: true, // AppBar가 body 위에 겹쳐 보이도록
          body: RefreshIndicator(
            strokeWidth: 2,
            edgeOffset: 50,
            displacement: 40,
            backgroundColor: Color(0xFF12341E),
            color: SDSColor.snowliveWhite,
            onRefresh: () async{
              await _forestParkViewModel.fetchLeafRemain(eventDate);
              final result = await _forestParkViewModel.checkParticipant(eventDate);
              isParticipant.value = result;
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✅ 배경 이미지
                  Stack(
                    children: [
                      Obx(() {
                        final greenCount = _forestParkViewModel.leafRemain.value.remainGreen ?? 0;
                        final goldCount = _forestParkViewModel.leafRemain.value.remainGold ?? 0;
                        final imageUrl = greenCount > 0 || goldCount > 0 ? backgroundImage_open : backgroundImage_closed;
                        return ExtendedImage.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          cache: true,
                          loadStateChanged: (state) {
                            if (state.extendedImageLoadState == LoadState.failed) {
                              return Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 250,
                                    color: Colors.grey.shade300,
                                    child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                  ),
                                  Text('정보를 불러오지 못했어요! 다시 새로고침을 해주세요.',
                                  style: SDSTextStyle.regular.copyWith(
                                    fontSize: 13,
                                    color: SDSColor.snowliveWhite.withOpacity(0.5)
                                  ),)
                                ],
                              );
                            }
                            return null;
                          },
                        );
                      }),
                      // Container(
                      //   height: 160,
                      //   decoration: const BoxDecoration(
                      //     gradient: LinearGradient(
                      //       begin: Alignment.topCenter,
                      //       end: Alignment.bottomCenter,
                      //       colors: [
                      //         Color(0x40000000),
                      //         Color(0x00000000),
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      // ✅ 배경 위에 쌓을: 나뭇잎 현황 + 참여 버튼
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 52,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 28),
                              height: 52,
                              decoration: BoxDecoration(
                                color: Color(0xFF000000).withOpacity(0.65),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Obx(() {
                                final greenCount = _forestParkViewModel.leafRemain.value.remainGreen ?? 0;
                                final goldCount = _forestParkViewModel.leafRemain.value.remainGold ?? 0;

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // 초록 나뭇잎
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/imgs/imgs/img_forest_fruit_green.png',
                                          width: 22,
                                          height: 22,
                                        ),
                                        SizedBox(width: 8),
                                        Text('초록 열매', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                                        SizedBox(width: 24),
                                        Text('$greenCount', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),

                                    // 구분선
                                    Container(width: 1, height: 20, color: Color(0xFFffffff).withOpacity(0.2)),

                                    // 황금 나뭇잎
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/imgs/imgs/img_forest_fruit.png',
                                          width: 22,
                                          height: 22,
                                        ),
                                        SizedBox(width: 8),
                                        Text('황금 열매', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                                        SizedBox(width: 24),
                                        Text('$goldCount', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                );
                              }),
                            ),
                            SizedBox(height: 20),

                            Obx(() {
                              return isParticipant.value == false
                                  ? GestureDetector(
                                onTap: () => _showCodeInputPopup(context, eventDate),
                                child: Container(
                                  width: 152,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(45),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '이벤트 참여하기',
                                          style: SDSTextStyle.bold.copyWith(
                                            fontSize: 14,
                                            color: SDSColor.gray900,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Image.asset(
                                          'assets/imgs/icons/icon_arrow_round_black.png',
                                          width: 18,
                                          height: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                                  : GestureDetector(
                                onTap: () {}, // 눌렀을 때 동작
                                child: Container(
                                  width: 110,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(45),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '참여완료',
                                          style: SDSTextStyle.bold.copyWith(
                                            fontSize: 14,
                                            color: SDSColor.gray900,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Image.asset(
                                          'assets/imgs/icons/icon_check_filled_forest_park.png',
                                          width: 18,
                                          height: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ✅ 배경 이미지 아래 이어지는 콘텐츠
                  Container(
                    width: double.infinity,
                    color: Color(0xFF12341E),
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                    child: Column(
                      children: [
                        // ✅ 여기에 추가: 나뭇잎 지도 + 경품 교환소 버튼
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: (){

                                },
                                child: Container(
                                  height: 140,
                                  padding: EdgeInsets.only(top: 16, left: 16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF0B5E2A),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Color(0xFF27894A),
                                      width: 2, // ✅ 윤곽선 두께 2
                                    ),
                                  ),
                                  alignment: Alignment.topLeft, // ✅ 좌상단 정렬
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '황금열매 지도',
                                        style: SDSTextStyle.bold.copyWith(
                                            color: Colors.white,
                                            fontSize: 15,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(child: SizedBox()),
                                          Image.asset(
                                            'assets/imgs/imgs/img_forest_map.png',
                                            width: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: (){
                                  CustomFullScreenDialog.showDialog();
                                  _forestParkViewModel.fetchLeafItems(eventDate);
                                  CustomFullScreenDialog.cancelDialog();
                                  Get.toNamed(AppRoutes.forestParkShop);
                                },
                                child: Container(
                                  height: 140,
                                  padding: EdgeInsets.only(top: 16, left: 16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF0B5E2A),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Color(0xFF27894A),
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '열매 교환소',
                                        style: SDSTextStyle.bold.copyWith(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(child: SizedBox()),
                                          Image.asset(
                                            'assets/imgs/imgs/img_forest_shop.png',
                                            width: 120,
                                            fit: BoxFit.cover,
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
                        const SizedBox(height: 60),
                        Text(
                          '전설의 황금 열매를 모아\n진짜 황금의 주인공이 되세요!',
                          style: SDSTextStyle.bold.copyWith(fontSize: 20, color: SDSColor.snowliveWhite),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            '황금숲의 전설에 대한 소문과 이벤트 참여 방법을 확인하세요!',
                            style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.snowliveWhite.withOpacity(0.5)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: _size.width - 32,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/imgs/imgs/img_forest_storybg.png',
                                width: _size.width - 32,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                                child: Text(
                                  '''1995년, 휘닉스의 개장이 있던 해.
한 명의 숲지기가 황금의 씨앗을 묻었다.
그 씨앗은 시간이 지나 포레스트 파크라는 
푸른 숲이 되었다.

2025년 현재, 휘닉스 파크 30주년을 맞아
전설 속 황금의 씨앗이 열매를 맺는다는 
소식이 퍼진다.

황금열매는 포레스트 파크 곳곳에 흩어져 있고,
황금열매를 모은 자만이 
진짜 황금을 손에 넣을 수 있다!''',
                                  textAlign: TextAlign.center,
                                  style: SDSTextStyle.regular.copyWith(
                                    fontSize: 14,
                                    height: 1.6,
                                    color: SDSColor.snowliveWhite,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          '이벤트 참여 방법',
                          style: SDSTextStyle.bold.copyWith(fontSize: 18, color: SDSColor.snowliveWhite),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.only(top: 18, bottom: 24, left: 30, right: 30),
                          decoration: BoxDecoration(
                            color: Color(0xFF104122),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          width: _size.width - 32,
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/imgs/imgs/img_forest_step1.png',
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  '1. 이벤트 참여하기 버튼을 누르고,\n참여코드 입력',
                                  textAlign: TextAlign.center,
                                  style: SDSTextStyle.regular.copyWith(
                                    fontSize: 14,
                                    color: SDSColor.snowliveWhite,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Container(
                            padding: EdgeInsets.only(top: 18, bottom: 24, left: 30, right: 30),
                            decoration: BoxDecoration(
                              color: Color(0xFF104122),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            width: _size.width - 32,
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/imgs/imgs/img_forest_step2.png',
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    '2. 숨겨진 퀴즈를 찾아 QR 코드를 스캔한 후\n정답을 맞춰 초록/황금 열매를 획득',
                                    textAlign: TextAlign.center,
                                    style: SDSTextStyle.regular.copyWith(
                                      fontSize: 14,
                                      color: SDSColor.snowliveWhite,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Container(
                            padding: EdgeInsets.only(top: 18, bottom: 24, left: 30, right: 30),
                            decoration: BoxDecoration(
                              color: Color(0xFF104122),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            width: _size.width - 32,
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/imgs/imgs/img_forest_step3.png',
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    '3. 획득한 초록/황금 열매를 사용해\n원하는 경품을 교환 후 경품 수령처에서 경품 받기',
                                    textAlign: TextAlign.center,
                                    style: SDSTextStyle.regular.copyWith(
                                      fontSize: 14,
                                      color: SDSColor.snowliveWhite,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 140),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),




        );
      },
    );
  }
}
