import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_forestPark.dart';
import 'package:com.snowlive/mobile/routes/routes.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/mobile/viewmodel/forestPark/vm_forestPark.dart';
import 'package:com.snowlive/core/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuizPageForestPark extends StatefulWidget {
  @override
  _QuizPageForestParkState createState() => _QuizPageForestParkState();
}

class _QuizPageForestParkState extends State<QuizPageForestPark> {
  final ForestParkViewModel _forestParkViewModel = Get.find<ForestParkViewModel>();
  int? _selectedIndex;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _forestParkViewModel.quizDetail.value = Quiz();
    final quizId = int.tryParse(Get.arguments ?? '') ?? 0;
    _forestParkViewModel.fetchQuizDetail(quizId).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _showCodeInputBottomSheet(int eventDate) {
    final TextEditingController _codeController = TextEditingController();
    final RxString _codeErrorMessage = ''.obs;

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

  Future<void> _submitAnswer() async {
    if (_selectedIndex == null) {
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
                  '정답을 선택해 주세요!',
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
                  '선택된 정답이 없습니다.\n정답을 선택해 주세요!',
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
                      Get.back();
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
        barrierDismissible: false,
      );
      return;
    }

    CustomFullScreenDialog.showDialog();

    final quiz = _forestParkViewModel.quizDetail.value;
    final selectedAnswer = [
      quiz.option1,
      quiz.option2,
      quiz.option3,
      quiz.option4
    ][_selectedIndex!];

    await _forestParkViewModel.submitQuizAnswer(
      quizId: quiz.quizId!,
      answer: selectedAnswer!,
      eventDate: _forestParkViewModel.eventDate.value,
    );

    CustomFullScreenDialog.cancelDialog();

    final result = _forestParkViewModel.answerResult.value.trim();

    if (result == '미참여') {
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
                  '참여코드를 등록해주세요',
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
                  '이벤트에 참여하려면\n참여코드를 먼저 등록해야 해요!',
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
                      _showCodeInputBottomSheet(_forestParkViewModel.eventDate.value); // 참여코드 입력창 띄우기
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
                      '참여코드 입력하기',
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
    } else if (result == '정답') {
      final colorKor = (quiz.leafColor == 'green')
          ? '초록열매'
          : (quiz.leafColor == 'gold')
          ? '황금열매'
          : '';

      Get.dialog(
        AlertDialog(
          backgroundColor: SDSColor.snowliveWhite,
          contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          content: Container(
            height: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '정답입니다!',
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
                  '$colorKor ${quiz.leafCount ?? 0}개를 획득했어요!',
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
                      _forestParkViewModel.fetchLeafRemain(quiz.eventDate!);
                      Get.back(); // 팝업 닫기
                      Get.back(); // 팝업 닫기
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
        barrierDismissible: false, // ✅ 여기 추가
      );

    } else if (result == '오답') {

      Get.dialog(
        AlertDialog(
          backgroundColor: SDSColor.snowliveWhite,
          contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          content: Container(
            height: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '아쉽게 오답이에요',
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
                  '정답을 다시 한 번 도전해 보세요!',
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
                      Get.back();
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

    } else if (result == '중복제출') {

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
                  '이미 참여한 퀴즈에요!',
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
                  '이미 제출한 퀴즈입니다.\n다른 퀴즈에 도전해 보세요!',
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
                      Get.back();
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
        barrierDismissible: false,
      );
    } else {

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
                  '알림',
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
                  result.isNotEmpty ? result : '서버로부터 응답을 받지 못했습니다.',
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
                      Get.back();
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
        barrierDismissible: false,
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = _forestParkViewModel.quizDetail.value;

    return Scaffold(
      backgroundColor: Color(0xFF12341E),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Color(0xFF12341E),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(
        strokeWidth: 4,
        backgroundColor: SDSColor.snowliveWhite.withOpacity(0.4),
        color: SDSColor.snowliveWhite,
      ))
          : (_forestParkViewModel.quizDetail.value.quizId == null ||
          (_forestParkViewModel.quizDetail.value.question?.isEmpty ?? true))
          ? Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 80),
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
              Text('퀴즈 정보를 불러올 수 없습니다.\n QR 코드를 다시 스캔해주세요.',
                style: SDSTextStyle.regular.copyWith(
                    fontSize: 14,
                    color: SDSColor.snowliveWhite
                ),
              ),
            ],
          ),
        ),
      )
          : SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6), // 내부 여백
                decoration: BoxDecoration(
                  color: Color(0xFF132A18), // 이미지 속 배경색 (진한 초록 계열)
                  borderRadius: BorderRadius.circular(40), // pill 형태로 둥글게
                ),
                child: Text(
                  '퀴즈',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (quiz.imgUrl != null && quiz.imgUrl!.isNotEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: ExtendedImage.network(
                      quiz.imgUrl ?? '',
                      cache: true,
                      fit: BoxFit.cover,
                      loadStateChanged: (ExtendedImageState state) {
                        switch (state.extendedImageLoadState) {
                          case LoadState.loading:
                            return Shimmer.fromColors(
                              baseColor: SDSColor.gray200,
                              highlightColor: SDSColor.gray50,
                              child: Container(
                                width: double.infinity,
                                height: 300, // 높이 고정
                                color: Colors.white,
                              ),
                            );
                          case LoadState.completed:
                            return state.completedWidget;
                          case LoadState.failed:
                            return Center(child: Text('Failed to load image'));
                        }
                      },
                    ),
                  ),
                ),
              ),
            if (quiz.imgUrl != null && quiz.imgUrl!.isNotEmpty)
              const SizedBox(height: 30),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  quiz.question ?? '',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.bold.copyWith(color: SDSColor.snowliveWhite, fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Text('아래 보기 중 정답을 선택 후 제출해 주세요!',
                style: SDSTextStyle.regular.copyWith(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(4, (index) {
              final option = [
                quiz.option1,
                quiz.option2,
                quiz.option3,
                quiz.option4
              ][index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: _selectedIndex == index
                          ? Color(0xFF127721)
                          : Color(0xFF0D2415),
                    ),
                    child: Text(
                      option ?? '',
                      style: TextStyle(
                          fontSize: 15,
                          color: SDSColor.snowliveWhite,
                          fontWeight: _selectedIndex == index
                              ? FontWeight.bold
                              : FontWeight.normal
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 25),
            if (quiz.imgUrlAd != null && quiz.imgUrlAd!.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    quiz.imgUrlAd!,
                    height: 90, // ✅ 띠배너 느낌
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                (quiz.hintUrl != null && quiz.hintUrl != "")
                    ?Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: ElevatedButton(
                      onPressed: () async {
                        print(quiz.hintUrl);
                        await otherShare(contents: '${quiz.hintUrl}');
                      },
                      style: TextButton.styleFrom(
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Color(0xFF127721)
                      ),
                      child: Text(
                        '힌트 보기',
                        style: SDSTextStyle.bold.copyWith(
                            color: SDSColor.snowliveWhite,
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
                    :Container(),
                (quiz.hintUrl != null && quiz.hintUrl != "")
                    ? SizedBox(width: 10) : Container(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: ElevatedButton(
                      onPressed: _submitAnswer,
                      child: const Text(
                        '정답 제출하기',
                        style: TextStyle(
                            color: Colors.black, // 글자색 검정
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // 버튼 배경 흰색
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), // 보더레디우스 5
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}