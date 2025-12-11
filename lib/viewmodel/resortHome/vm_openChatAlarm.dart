import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class OpenChatAlarmViewModel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 새 메시지 여부 (빨간점 표시용)
  RxBool hasNewMessage = false.obs;

  // Firestore 스트림 구독
  StreamSubscription<DocumentSnapshot>? _alarmSubscription;

  // 현재 유저 ID
  int? _myUserId;

  @override
  void onClose() {
    _alarmSubscription?.cancel();
    super.onClose();
  }

  /// 알람 스트림 구독 시작
  /// [userId] 현재 로그인한 유저의 ID
  void startListening(int userId) {
    _myUserId = userId;

    // 기존 구독 해제
    _alarmSubscription?.cancel();

    // Firestore 스트림 구독: openChat_alarm/alarm 문서
    _alarmSubscription = _firestore
        .collection('openChat_alarm')
        .doc('alarm')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final List<dynamic> userIds = data?['user_id'] ?? [];

        // 내 user_id가 배열에 없으면 새 메시지 있음 (빨간점 표시)
        hasNewMessage.value = !userIds.contains(_myUserId);

        print('🔔 오픈채팅 알람 상태: ${hasNewMessage.value ? "새 글 있음" : "읽음"}');
      } else {
        // 문서가 없으면 새 메시지 없음으로 처리
        hasNewMessage.value = false;
      }
    }, onError: (e) {
      print('❌ 오픈채팅 알람 스트림 오류: $e');
    });
  }

  /// 오픈채팅 읽음 처리 (내 user_id를 배열에 추가)
  Future<void> markAsRead() async {
    if (_myUserId == null) return;

    try {
      await _firestore
          .collection('openChat_alarm')
          .doc('alarm')
          .update({
        'user_id': FieldValue.arrayUnion([_myUserId]),
      });
      print('✅ 오픈채팅 읽음 처리 완료');
    } catch (e) {
      print('❌ 오픈채팅 읽음 처리 실패: $e');
    }
  }

  /// 새 글 작성 시 알람 초기화 (user_id 배열 비우기)
  /// 모든 유저에게 새 글 알림이 표시됨
  Future<void> clearAllReadStatus() async {
    try {
      await _firestore
          .collection('openChat_alarm')
          .doc('alarm')
          .set({'user_id': []});
      print('✅ 오픈채팅 알람 초기화 (새 글 작성)');
    } catch (e) {
      print('❌ 오픈채팅 알람 초기화 실패: $e');
    }
  }

  /// 새 글 작성 시 알람 초기화 + 본인은 읽음 처리
  /// 다른 유저에게만 새 글 알림이 표시됨
  Future<void> clearAndMarkMyself() async {
    if (_myUserId == null) return;

    try {
      await _firestore
          .collection('openChat_alarm')
          .doc('alarm')
          .set({'user_id': [_myUserId]});
      print('✅ 오픈채팅 알람 초기화 (본인 제외)');
    } catch (e) {
      print('❌ 오픈채팅 알람 초기화 실패: $e');
    }
  }
}
