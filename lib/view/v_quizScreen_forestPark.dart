import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_forestPark.dart';
import 'package:com.snowlive/viewmodel/forestPark/vm_forestPark.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              '구매하신 참여코드를 확인하여 입력하고\n포레스트 파크에서 모험을 시작해 보세요!',
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
                    // ✅ 참여 성공 다이얼로그
                    Get.dialog(
                      AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), // ✅ 보더레디우스 16
                        ),
                        title: Center(
                          child: Text(
                            '참여 완료',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        content: Text(
                          '이벤트 참여가 완료되었습니다!\n퀴즈를 풀고 황금열매를 모아보세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        actionsPadding: EdgeInsets.only(bottom: 16),
                        actions: [
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back(); // 다이얼로그 닫기
                                Get.back(); // 바텀시트 닫기
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF127721),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                minimumSize: Size(200, 44), // ✅ 버튼 사이즈
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

  Future<void> _submitAnswer() async {
    if (_selectedIndex == null) {
      Get.snackbar('알림', '보기를 선택해주세요.');
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // ✅ 보더레디우스 16
          ),
          title: Center(
            child: Text(
              '참여코드 필요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          content: Text(
            '이벤트에 참여하려면\n참여코드를 먼저 등록해야 해요!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
          actionsPadding: EdgeInsets.only(bottom: 16),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // 다이얼로그 닫기
                  _showCodeInputBottomSheet(_forestParkViewModel.eventDate.value); // 참여코드 입력창 띄우기
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF127721), // 너네 앱 색상
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(200, 44), // ✅ 버튼 넓이 고정
                ),
                child: Text(
                  '참여코드 입력하기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Center(
            child: Text(
              '정답입니다!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: Text(
            '$colorKor ${quiz.leafCount ?? 0}개를 획득했어요!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actionsPadding: EdgeInsets.only(bottom: 16),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // 팝업 닫기
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF127721),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(200, 44),
                ),
                child: Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    } else if (result == '오답') {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Center(
            child: Text(
              '아쉬워요!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: Text(
            '오답입니다. 다시 도전해 보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actionsPadding: EdgeInsets.only(bottom: 16),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF127721),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(200, 44),
                ),
                child: Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    } else if (result == '중복제출') {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Center(
            child: Text(
              '이미 참여한 퀴즈에요!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: Text(
            '이미 제출한 퀴즈입니다.\n다른 퀴즈에 도전해 보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actionsPadding: EdgeInsets.only(bottom: 16),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF127721),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(200, 44),
                ),
                child: Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Center(
            child: Text(
              '알림',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: Text(
            result.isNotEmpty ? result : '서버로부터 응답을 받지 못했습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actionsPadding: EdgeInsets.only(bottom: 16),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  minimumSize: Size(200, 44),
                ),
                child: Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_forestParkViewModel.quizDetail.value.quizId == null ||
          (_forestParkViewModel.quizDetail.value.question?.isEmpty ?? true))
          ? const Center(
        child: Text(
          '퀴즈 정보를 불러올 수 없습니다.\n QR 코드를 다시 스캔해주세요.',
          style: TextStyle(fontSize: 15, color: SDSColor.snowliveWhite),
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
                    child: Image.network(quiz.imgUrl!),
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
            const SizedBox(height: 40),
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
            Padding(
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
                    ],
                  ),
          ),
    );
  }
}