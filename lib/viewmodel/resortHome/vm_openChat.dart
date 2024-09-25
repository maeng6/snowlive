import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ChatViewModel extends GetxController {
  var chatDocs = <QueryDocumentSnapshot>[].obs;

  TextEditingController chatController = TextEditingController();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  RxBool isButtonEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    setupChatStream();
    chatController.addListener(() {
      if (chatController.text.trim().isNotEmpty) {
        isButtonEnabled.value = true;
      } else {
        isButtonEnabled.value = false;
      }
    });
  }

  void handleTextChange() {
    if (chatController.text.isNotEmpty) {
      isButtonEnabled.value = true;
    } else {
      isButtonEnabled.value = false;
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.isNotEmpty) {
      // 먼저 해당 유저가 보낸 마지막 메시지를 확인하여 숫자를 증가시킵니다.
      QuerySnapshot lastMessageSnapshot = await FirebaseFirestore.instance
          .collection('chat')
          .where('uid', isEqualTo: _userViewModel.user.user_id)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      int newChatIdSuffix = 1;  // 기본값 1

      if (lastMessageSnapshot.docs.isNotEmpty) {
        // 마지막 메시지가 존재하는 경우에만 chatId를 가져옵니다.
        var lastChatData = lastMessageSnapshot.docs.first.data() as Map<String, dynamic>?;  // null-safe 처리
        if (lastChatData != null && lastChatData.containsKey('chatId')) {
          var lastChatId = lastChatData['chatId'] as String;
          newChatIdSuffix = int.parse(lastChatId.replaceFirst('${_userViewModel.user.user_id}-', '')) + 1;  // uid를 제외한 숫자 부분을 추출하여 1 증가
        }
      }

      String newChatId = '${_userViewModel.user.user_id}-$newChatIdSuffix';  // 새로운 chatId 생성

      await FirebaseFirestore.instance.collection('chat').add({
        'chatId': newChatId,
        'text': message,
        'createdAt': Timestamp.now(),
        'uid': _userViewModel.user.user_id,
        'repoCount': 0
      });

    }
  }


  void setupChatStream() {
    Stream<QuerySnapshot> chatStream = FirebaseFirestore.instance
        .collection('chat')
        .orderBy('createdAt', descending: true)
        .limit(500)
        .snapshots();

    chatStream.listen((event) {
      chatDocs.value = event.docs;
    });
  }

  Future<void> reportMessage(String chatId) async {
    try {
      // chatId에 해당하는 문서를 찾기 위한 쿼리
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('chat')
          .where('chatId', isEqualTo: chatId)
          .limit(1) // 하나의 문서만 찾으면 충분하므로 limit 추가
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Chat message with given chatId does not exist!");
      }

      // 문서 참조 가져오기
      DocumentReference docRef = querySnapshot.docs.first.reference;

      // 트랜잭션을 사용하여 신고 카운트 증가
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);

        // 기존 repoCount 가져오기
        int newRepoCount = (snapshot.data() as Map<String, dynamic>)['repoCount'] ?? 0;
        newRepoCount += 1;

        // repoCount 업데이트
        transaction.update(docRef, {'repoCount': newRepoCount});
      });

      Get.snackbar('신고 완료', '신고가 성공적으로 접수되었습니다.');
    } catch (e) {
      Get.snackbar('신고 실패', '신고 중 오류가 발생했습니다: $e');
    }
  }


}
