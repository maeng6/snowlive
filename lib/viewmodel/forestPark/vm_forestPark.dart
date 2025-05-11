import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/api/api_forestPark.dart';
import 'package:com.snowlive/model/m_forestPark.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';

class ForestParkViewModel extends GetxController {
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  var isLoading = false.obs;
  var isLoading_checkParticipant = false.obs;

  // var _isLodaing_entrance = false.obs;
  // bool get loadingEntrance => _isLodaing_entrance.value;
  // // 포레스트파크 진입점 데이터 로딩 일괄 제어
  // set loadingEntrance(bool value) {
  //   _isLodaing_entrance.value = value;
  // }

  var leafItems = <LeafItem>[].obs;
  var buyRecords = <BuyRecord>[].obs;
  var leafRemain = LeafRemain().obs;
  var quizDetail = Quiz().obs;
  var answerResult = ''.obs;

  RxBool isForestParkOpen = false.obs;
  RxBool isForestParkOpen_toEveryone = false.obs;

  RxInt eventDate = 0.obs;
  StreamSubscription? _entranceStreamSub; // 🔁 스트림 중복 구독 방지용
  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> infoStream_forestPark_entrance = Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>>();

  // 현재 선택된 아이템 정보
  var selectedItem = LeafItem().obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    _entranceStreamSub?.cancel(); // ✅ 뷰모델 종료 시 리스너 해제
    super.onClose();
  }

  Future<void> getInfo_forestPark_entrance() async {
    final stream = FirebaseFirestore.instance
        .collection('forestPark')
        .doc('forestPark')
        .snapshots();

    infoStream_forestPark_entrance.value = stream; // ✅ 기존 StreamBuilder용 스트림 그대로 유지

    // 🔁 기존 리스너 제거 (중복 방지)
    _entranceStreamSub?.cancel();

    // ✅ open 필드 값을 Rx 상태로 저장
    _entranceStreamSub = stream.listen((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>?;
      isForestParkOpen.value = data?['open'] == true;
      isForestParkOpen_toEveryone.value = data?['to_everyone'] == true;
      eventDate.value = data?['eventDate'] ?? 0; // ✅ 여기에 저장
      print('🔥 open 상태 업데이트: ${isForestParkOpen.value}');
      print('🔥 open_crew 상태 업데이트: ${isForestParkOpen_toEveryone.value}');
      print('🔥 eventDate 업데이트: ${eventDate.value}');
    });
  }



  Future<bool> checkParticipant(int eventDate) async {
    try {
      isLoading_checkParticipant(true); // ✅ 로딩 시작
      final response = await ForestParkAPI().checkParticipant(
        _userViewModel.user.user_id.toString(),
        eventDate,
      );
      if (response.success) {
        final isRegistered = response.data['registered'] == true;
        print("✅ 참가 여부: $isRegistered");
        return isRegistered;
      } else {
        print("❌ API 오류: ${response.error}");
        return false;
      }
    } catch (e) {
      print("❗ 예외 발생: $e");
      return false;
    } finally {
      isLoading_checkParticipant(false); // ✅ 로딩 종료
    }
  }



  Future<bool> registerParticipant({
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
      return response.success; // ✅ 등록 성공 여부 반환
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
    required int eventDate
  }) async {
    final response = await ForestParkAPI().submitQuizAnswer({
      'user_id': _userViewModel.user.user_id,
      'quiz_id': quizId,
      'answer': answer,
      'event_date': eventDate,
    });

    if (response.success) {
      answerResult.value = response.data?['result'] ?? '';
    } else {
      answerResult.value = response.error?['result'] ?? '';
    }
  }



  Future<void> fetchLeafItems(int eventDate) async {
    final response = await ForestParkAPI().fetchLeafItems(eventDate);
    if (response.success) {
      leafItems.value = (response.data as List).map((e) => LeafItem.fromJson(e)).toList();
    }
  }

  Future<bool> tryBuyItem(int leafItemId, int eventDate) async {
    final response = await ForestParkAPI().tryBuyItem({
      'user_id': _userViewModel.user.user_id,
      'leaf_item_id': leafItemId,
      'event_date': eventDate
    });

    if (response.success) {
      print("교환 성공");
      return true;
    } else {
      print("교환 실패: ${response.error}");
      return false;
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

  /// 아이템 누르면 아이템 정보를 모델에 할당.(구매버튼 누르면 이 아이템의 id를 api에 보내려는 목적)
  void selectItem(LeafItem item) {
    selectedItem.value = item;
  }

}
