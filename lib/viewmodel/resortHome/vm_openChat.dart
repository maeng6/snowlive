import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/api/api_resortHome.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatViewModel extends GetxController {
  var chatDocs = <QueryDocumentSnapshot>[].obs;

  TextEditingController chatController = TextEditingController();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  // 🛡️ 메모리 누수 방지: 스트림 구독 저장
  StreamSubscription<QuerySnapshot>? _chatStreamSubscription;

  RxBool isButtonEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 🛡️ 메모리 최적화: onInit에서 스트림 시작하지 않음
    // 채팅 화면 진입 시 startChatStream() 호출 필요
    chatController.addListener(() {
      if (chatController.text.trim().isNotEmpty) {
        isButtonEnabled.value = true;
      } else {
        isButtonEnabled.value = false;
      }
    });
  }

  /// 채팅 화면 진입 시 호출 - 스트림 구독 시작
  void startChatStream() {
    if (_chatStreamSubscription != null) return; // 이미 구독 중이면 스킵
    setupChatStream();
  }

  /// 채팅 화면 이탈 시 호출 - 스트림 구독 중지 및 메모리 해제
  void stopChatStream() {
    _chatStreamSubscription?.cancel();
    _chatStreamSubscription = null;
    chatDocs.clear(); // 🛡️ 메모리 해제
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
      final userId = _userViewModel.user.user_id;
      if (userId == null) return;

      // 먼저 해당 유저가 보낸 마지막 메시지를 확인하여 숫자를 증가시킵니다.
      QuerySnapshot lastMessageSnapshot = await FirebaseFirestore.instance
          .collection('chat')
          .where('uid', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      int newChatIdSuffix = 1;  // 기본값 1

      if (lastMessageSnapshot.docs.isNotEmpty) {
        // 마지막 메시지가 존재하는 경우에만 chatId를 가져옵니다.
        var lastChatData = lastMessageSnapshot.docs.first.data() as Map<String, dynamic>?;  // null-safe 처리
        if (lastChatData != null && lastChatData.containsKey('chatId')) {
          var lastChatId = lastChatData['chatId'] as String;
          newChatIdSuffix = int.parse(lastChatId.replaceFirst('$userId-', '')) + 1;  // uid를 제외한 숫자 부분을 추출하여 1 증가
        }
      }

      String newChatId = '$userId-$newChatIdSuffix';  // 새로운 chatId 생성

      // API 호출로 채팅 전송 (Firebase 직접 등록 대신)
      final response = await ResortHomeAPI().createChat(
        uid: userId,
        text: message,
        chatId: newChatId,
      );

      if (!response.success) {
        // 403 에러 (블락 유저) 또는 기타 에러 처리
        final errorMessage = response.error?['error'] ?? '메시지 전송에 실패했습니다.';
        _showBlockedDialog(errorMessage);
      }
    }
  }

  /// 블락 유저 또는 에러 다이얼로그 표시
  void _showBlockedDialog(String message) {
    Get.dialog(
      AlertDialog(
        backgroundColor: SDSColor.snowliveWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 30),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '알림',
              style: SDSTextStyle.bold.copyWith(fontSize: 18, color: SDSColor.gray900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SDSColor.snowliveBlue,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  '확인',
                  style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.snowliveWhite),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      barrierDismissible: true,
    );
  }


  void setupChatStream() {
    // 기존 구독 해제
    _chatStreamSubscription?.cancel();

    Stream<QuerySnapshot> chatStream = FirebaseFirestore.instance
        .collection('chat')
        .orderBy('createdAt', descending: true)
        .limit(100)  // 🛡️ 메모리 최적화: 500 → 100
        .snapshots();

    // 🛡️ 구독 저장하여 나중에 해제 가능하도록
    _chatStreamSubscription = chatStream.listen((event) {
      chatDocs.value = event.docs;
    });
  }

  @override
  void onClose() {
    // 🛡️ 메모리 누수 방지: 리소스 해제
    _chatStreamSubscription?.cancel();
    _chatStreamSubscription = null;
    chatController.dispose();
    super.onClose();
  }

  Future<void> reportMessage(String chatId) async {
    try {
      final myUserId = _userViewModel.user.user_id;
      if (myUserId == null) {
        Get.snackbar('신고 실패', '로그인 정보를 확인해주세요.');
        return;
      }

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

      // 트랜잭션을 사용하여 repo_list 업데이트 및 block 처리
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // 기존 repo_list 가져오기
        List<dynamic> repoList = List<dynamic>.from(data['repo_list'] ?? []);

        // 이미 신고한 경우 중복 방지
        if (repoList.contains(myUserId)) {
          throw Exception('이미 신고한 메시지입니다.');
        }

        // 내 유저 ID 추가
        repoList.add(myUserId);

        // 업데이트할 데이터
        Map<String, dynamic> updateData = {
          'repo_list': repoList,
        };

        // 신고 후 repo_list가 정확히 3개가 되면 block, system_msg를 true로 설정하고 텍스트 변경
        if (repoList.length == 3) {
          updateData['block'] = true;
          updateData['system_msg'] = true;
          updateData['text'] = '블라인드 처리된 글입니다.';
        }

        transaction.update(docRef, updateData);
      });

      Get.snackbar('신고 완료', '신고가 성공적으로 접수되었습니다.');
    } catch (e) {
      if (e.toString().contains('이미 신고한 메시지입니다')) {
        Get.snackbar('알림', '이미 신고한 메시지입니다.');
      } else {
        Get.snackbar('신고 실패', '신고 중 오류가 발생했습니다: $e');
      }
    }
  }


}
