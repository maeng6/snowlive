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
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.35, // ✅ 높이 확보
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32), // 🔼 top padding 줄임
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
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // ⬆️ 타이틀
            Text(
              '이벤트 참여 코드를 입력해주세요!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // ⬇️ 설명
            Text(
              '모험키트에서 참여코드를 확인하여 입력하고\n포레스트 파크에서 모험을 시작해 보세요!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

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

            const SizedBox(height: 45),

            // ✅ 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
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
                    await _forestParkViewModel.fetchLeafRemain(eventDate);
                    final result = await _forestParkViewModel.checkParticipant(eventDate);
                    isParticipant.value = result;
                    CustomFullScreenDialog.cancelDialog();
                    Get.back();
                    Get.snackbar('성공', '참여코드가 등록되었습니다');
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }


  @override
  Widget build(BuildContext context) {
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
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: FloatingActionButton.extended(
                backgroundColor: Color(0xFF219432),
                onPressed: () {
                  Get.toNamed(AppRoutes.qrScannerForestPark);
                },
                icon: Icon(Icons.qr_code_scanner),
                label: Text(
                  '퀴즈 QR 스캔하기',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: SDSColor.snowliveWhite,
                      fontSize: 16
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),

                ),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

          appBar: PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: AppBar(
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              title: Text('황금숲의 전설 : 황금열매를 찾아서',
                style: TextStyle(
                    color: SDSColor.snowliveWhite,
                    fontWeight: FontWeight.bold
                ),
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
            backgroundColor: SDSColor.snowliveBlue,
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
                              return Container(
                                width: double.infinity,
                                height: 250,
                                color: Colors.grey.shade300,
                                child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                              );
                            }
                            return null;
                          },
                        );
                      }),

                      // ✅ 배경 위에 쌓을: 나뭇잎 현황 + 참여 버튼
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 60,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 36),
                              height: 52,
                              decoration: BoxDecoration(
                                color: Color(0xFF000000).withOpacity(0.3),
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
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.greenAccent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text('초록열매', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                                        SizedBox(width: 20),
                                        Text('$greenCount', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),

                                    // 구분선
                                    Container(width: 1, height: 20, color: Color(0xFF000000).withOpacity(0.2)),

                                    // 황금 나뭇잎
                                    Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.amberAccent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text('황금열매', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                                        SizedBox(width: 20),
                                        Text('$goldCount', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                );
                              }),
                            ),
                            SizedBox(height: 20),
                            SizedBox(height: 20),

                            Obx(() {
                              return isParticipant.value == false
                                  ? GestureDetector(
                                onTap: () => _showCodeInputPopup(context, eventDate),
                                child: Container(
                                  width: 168,
                                  height: 48,
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
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF1D1000),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Icon(
                                          Icons.arrow_circle_right,
                                          size: 18,
                                          color: Color(0xFF1D1000),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                                  : GestureDetector(
                                onTap: () {}, // 눌렀을 때 동작
                                child: Container(
                                  width: 122,
                                  height: 48,
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
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF1D1000),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Icon(
                                          Icons.check_circle,
                                          size: 18,
                                          color: Color(0xFF1D1000),
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
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: Column(
                      children: [
                        // ✅ 여기에 추가: 나뭇잎 지도 + 경품 교환소 버튼
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 140,
                                padding: EdgeInsets.all(16), // ✅ 좌상단 정렬 위한 패딩
                                decoration: BoxDecoration(
                                  color: Color(0xFF0B5E2A),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Color(0xFF27894A),
                                    width: 2, // ✅ 윤곽선 두께 2
                                  ),
                                ),
                                alignment: Alignment.topLeft, // ✅ 좌상단 정렬
                                child: Text(
                                  '황금열매 지도',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF0B5E2A),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Color(0xFF27894A),
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '경품 교환소',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Text(
                          '전설의 황금 열매를 모아\n진짜 황금의 주인공이 되세요!',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width - 32, // ✅ 고정 너비 (예: 전체 너비 - 좌우 20씩 마진)
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                          decoration: BoxDecoration(
                            color: Color(0xFF0D2415),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '''1995년, 휘닉스의 개장이 있던 해.
한 명의 숲지기가 황금의 씨앗을 묻었다.
그 씨앗은 시간이 지나 포레스트 파크라는 푸른 숲이 되었다.

2025년 현재, 휘닉스 파크 30주년을 맞아
전설 속 황금의 씨앗이 열매를 맺는다는 소식이 퍼진다.

황금열매는 포레스트 파크 곳곳에 흩어져 있고,
황금열매를  모은 자만이 진짜 황금을 손에 넣을 수 있다!''',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center, // ✅ 중앙 정렬 추가
                          ),
                        ),
                        SizedBox(height: 150),
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
