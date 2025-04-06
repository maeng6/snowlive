import 'package:com.snowlive/api/api_forestPark.dart';
import 'package:com.snowlive/model/m_forestPark.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';

class ForestParkViewModel extends GetxController {
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  var isLoading = false.obs;

  var leafItems = <LeafItem>[].obs;
  var buyRecords = <BuyRecord>[].obs;
  var leafRemain = LeafRemain().obs;
  var quizDetail = Quiz().obs;
  var answerResult = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> checkParticipant(int eventDate) async {
    try {
      isLoading(true);
      final response = await ForestParkAPI().checkParticipant(
        _userViewModel.user.user_id,
        eventDate,
      );
      if (response.success) {
        print("참가 여부: ${response.data}");
      } else {
        print("에러: ${response.error}");
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> registerParticipant({
    required String code,
    required int eventDate,
  }) async {
    try {
      isLoading(true);
      final response = await ForestParkAPI().registerParticipant({
        'user_id': _userViewModel.user.user_id,
        'code': code,
        'event_date': eventDate,
      });
      if (response.success) {
        print("등록 완료: ${response.data}");
      } else {
        print("등록 실패: ${response.error}");
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchQuizDetail(int quizId) async {
    final response = await ForestParkAPI().fetchQuizDetail({'quiz_id': quizId});
    if (response.success) {
      quizDetail.value = Quiz.fromJson(response.data!);
    }
  }

  Future<void> submitQuizAnswer({
    required int quizId,
    required String answer,
  }) async {
    final response = await ForestParkAPI().submitQuizAnswer({
      'user_id': _userViewModel.user.user_id,
      'quiz_id': quizId,
      'answer': answer,
    });

    if (response.success) {
      answerResult.value = response.data?['result'] ?? '';
    }
  }

  Future<void> fetchLeafItems(int eventDate) async {
    final response = await ForestParkAPI().fetchLeafItems(eventDate);
    if (response.success) {
      leafItems.value = (response.data as List).map((e) => LeafItem.fromJson(e)).toList();
    }
  }

  Future<void> tryBuyItem(int leafItemId) async {
    final response = await ForestParkAPI().tryBuyItem({
      'user_id': _userViewModel.user.user_id,
      'leaf_item_id': leafItemId,
    });
    if (response.success) {
      print("교환 성공");
    } else {
      print("교환 실패: ${response.error}");
    }
  }

  Future<void> fetchBuyRecords() async {
    final response = await ForestParkAPI().fetchBuyRecords(_userViewModel.user.user_id.toString());
    if (response.success) {
      buyRecords.value = (response.data as List).map((e) => BuyRecord.fromJson(e)).toList();
    }
  }

  Future<void> fetchLeafRemain(int eventDate) async {
    final response = await ForestParkAPI().fetchLeafRemain(
      _userViewModel.user.user_id.toString(),
      eventDate,
    );
    if (response.success) {
      leafRemain.value = LeafRemain.fromJson(response.data!);
    }
  }
}
