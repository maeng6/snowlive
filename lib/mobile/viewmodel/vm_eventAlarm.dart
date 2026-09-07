import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class EventAlarmViewModel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 새 이벤트 여부 (빨간점 표시용)
  RxBool hasNewEvent = false.obs;

  // 이벤트·소식 탭 N뱃지 여부
  RxBool hasNewEventTab = false.obs;

  // Firestore 스트림 구독
  StreamSubscription<DocumentSnapshot>? _alarmSubscription;
  StreamSubscription<DocumentSnapshot>? _eventTabSubscription;

  // 현재 유저 ID
  int? _myUserId;

  @override
  void onClose() {
    _alarmSubscription?.cancel();
    _eventTabSubscription?.cancel();
    super.onClose();
  }

  /// 알람 스트림 구독 시작
  /// [userId] 현재 로그인한 유저의 ID
  void startListening(int userId) {
    _myUserId = userId;

    // 기존 구독 해제
    _alarmSubscription?.cancel();
    _eventTabSubscription?.cancel();

    // Firestore 스트림 구독: event/viewer 문서 (빨간점)
    _alarmSubscription = _firestore
        .collection('event')
        .doc('viewer')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final List<dynamic> viewerIds = data?['viewer'] ?? [];

        // 내 user_id가 배열에 없으면 새 이벤트 있음 (빨간점 표시)
        hasNewEvent.value = !viewerIds.contains(_myUserId);

        print('🔔 이벤트 알람 상태: ${hasNewEvent.value ? "새 이벤트 있음" : "읽음"}');
      } else {
        hasNewEvent.value = false;
      }
    }, onError: (e) {
      print('❌ 이벤트 알람 스트림 오류: $e');
    });

    // Firestore 스트림 구독: eventTab_notice/notice 문서 (N뱃지)
    _eventTabSubscription = _firestore
        .collection('eventTab_notice')
        .doc('notice')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final List<dynamic> uidList = data?['uid'] ?? [];

        // 내 user_id가 배열에 없으면 N뱃지 표시
        hasNewEventTab.value = !uidList.contains(_myUserId);

        print('🔔 이벤트탭 N뱃지 상태: ${hasNewEventTab.value ? "새 소식 있음" : "읽음"}');
      } else {
        hasNewEventTab.value = false;
      }
    }, onError: (e) {
      print('❌ 이벤트탭 N뱃지 스트림 오류: $e');
    });
  }

  /// 알람 스트림 구독 중지 (백그라운드 전환 시 호출)
  void stopListening() {
    _alarmSubscription?.cancel();
    _alarmSubscription = null;
    _eventTabSubscription?.cancel();
    _eventTabSubscription = null;
  }

  /// 알람 스트림 재시작 (포어그라운드 복귀 시 호출)
  void resumeListening() {
    if (_myUserId != null && _alarmSubscription == null) {
      startListening(_myUserId!);
    }
  }

  /// 이벤트 읽음 처리 (내 user_id를 배열에 추가) - 빨간점용
  Future<void> markAsRead() async {
    if (_myUserId == null) return;

    try {
      await _firestore
          .collection('event')
          .doc('viewer')
          .update({
        'viewer': FieldValue.arrayUnion([_myUserId]),
      });
      print('✅ 이벤트 읽음 처리 완료');
    } catch (e) {
      print('❌ 이벤트 읽음 처리 실패: $e');
    }
  }

  /// 이벤트·소식 탭 읽음 처리 (내 user_id를 배열에 추가) - N뱃지용
  Future<void> markEventTabAsRead() async {
    if (_myUserId == null) return;

    try {
      await _firestore
          .collection('eventTab_notice')
          .doc('notice')
          .update({
        'uid': FieldValue.arrayUnion([_myUserId]),
      });
      print('✅ 이벤트탭 읽음 처리 완료');
    } catch (e) {
      print('❌ 이벤트탭 읽음 처리 실패: $e');
    }
  }

  /// 새 이벤트 등록 시 알람 초기화 (viewer 배열 비우기)
  /// 모든 유저에게 새 이벤트 알림이 표시됨
  Future<void> clearAllReadStatus() async {
    try {
      await _firestore
          .collection('event')
          .doc('viewer')
          .set({'viewer': []});
      print('✅ 이벤트 알람 초기화 (새 이벤트 등록)');
    } catch (e) {
      print('❌ 이벤트 알람 초기화 실패: $e');
    }
  }
}
