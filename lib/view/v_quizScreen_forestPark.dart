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
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '참여코드를 입력해주세요',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              onChanged: (_) => _codeErrorMessage.value = '',
              decoration: const InputDecoration(
                hintText: '참여코드',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            Obx(() {
              if (_codeErrorMessage.value.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _codeErrorMessage.value,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final code = _codeController.text.trim();
                if (code.isEmpty) {
                  _codeErrorMessage.value = '참여코드를 입력해주세요';
                  return;
                }

                CustomFullScreenDialog.showDialog();
                final result = await _forestParkViewModel.registerParticipant(
                  code: code,
                  eventDate: eventDate,
                );
                CustomFullScreenDialog.cancelDialog();

                if (result) {
                  // ✅ 참여 성공 다이얼로그
                  Get.dialog(
                    AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: Text('참여 완료', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Text('이벤트 참여가 완료되었습니다!\n퀴즈를 풀고 황금열매를 모아보세요.'),
                      actions: [
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Get.back(); // 다이얼로그 닫기
                              Get.back(); // 바텀시트 닫기
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: SDSColor.snowliveBlue,
                            ),
                            child: Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                    barrierDismissible: false,
                  );
                } else {
                  _codeErrorMessage.value = '유효하지 않은 참여코드입니다';
                }
              },
              child: const Text('등록하기'),
            )
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
      Get.defaultDialog(
        title: '참여코드 필요',
        middleText: '이벤트에 참여하려면 참여코드를 먼저 등록해야 해요!',
        confirm: ElevatedButton(
          onPressed: () {
            Get.back(); // 닫기
            _showCodeInputBottomSheet(_forestParkViewModel.eventDate.value); // 참여코드 입력 창 띄우기
          },
          child: const Text('참여코드 입력하기'),
        ),
      );
    } else if (result == '정답') {
      Get.snackbar(
        '정답!',
        '${quiz.leafColor ?? ""} 나뭇잎 ${quiz.leafCount ?? 0}개가 지급되었습니다 🎉',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (result == '오답') {
      Get.snackbar(
        '아쉬워요',
        '오답입니다. 다시 도전해보세요!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (result == '중복제출') {
      Get.snackbar(
        '이미 참여한 퀴즈입니다.',
        '다른 퀴즈를 찾아 도전해보세요!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        '알림',
        result.isNotEmpty ? result : '서버로부터 응답을 받지 못했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = _forestParkViewModel.quizDetail.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('퀴즈'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_forestParkViewModel.quizDetail.value.quizId == null ||
          (_forestParkViewModel.quizDetail.value.question?.isEmpty ?? true))
          ? const Center(
        child: Text(
          '퀴즈 정보를 불러올 수 없습니다.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (quiz.imgUrlAd != null && quiz.imgUrlAd!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(quiz.imgUrlAd!),
            ),
          const SizedBox(height: 20),
          Text(
            quiz.question ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
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
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _selectedIndex == index
                      ? Colors.blue.shade100
                      : Colors.grey.shade100,
                  border: Border.all(
                    color: _selectedIndex == index
                        ? Colors.blue
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  option ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitAnswer,
            child: const Text('정답 제출'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}