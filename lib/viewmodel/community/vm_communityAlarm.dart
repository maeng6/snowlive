import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CommunityAlarmViewModel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 새 커뮤니티 게시글 여부 (빨간점 + N뱃지 표시용)
  RxBool hasNewCommunity = false.obs;

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
    print('🔔 커뮤니티 알람 startListening 호출 - userId: $userId');

    // 기존 구독 해제
    _alarmSubscription?.cancel();

    // Firestore 스트림 구독: community/community 문서 (빨간점 + N뱃지)
    _alarmSubscription = _firestore
        .collection('community')
        .doc('community')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final List<dynamic> viewerIds = data?['viewer'] ?? [];

        // 내 user_id가 배열에 없으면 새 게시글 있음 (빨간점 + N뱃지 표시)
        hasNewCommunity.value = !viewerIds.contains(_myUserId);

        print('🔔 커뮤니티 알람 상태: ${hasNewCommunity.value ? "새 게시글 있음" : "읽음"} (viewerIds: $viewerIds, myUserId: $_myUserId)');
      } else {
        hasNewCommunity.value = false;
        print('🔔 커뮤니티 알람: community/community 문서가 존재하지 않음');
      }
    }, onError: (e) {
      print('❌ 커뮤니티 알람 스트림 오류: $e');
    });
  }

  /// 알람 스트림 구독 중지 (백그라운드 전환 시 호출)
  void stopListening() {
    _alarmSubscription?.cancel();
    _alarmSubscription = null;
  }

  /// 알람 스트림 재시작 (포어그라운드 복귀 시 호출)
  void resumeListening() {
    if (_myUserId != null && _alarmSubscription == null) {
      startListening(_myUserId!);
    }
  }

  /// 커뮤니티 읽음 처리 (내 user_id를 배열에 추가) - 빨간점 + N뱃지 해제
  Future<void> markAsRead() async {
    if (_myUserId == null) return;

    try {
      await _firestore
          .collection('community')
          .doc('community')
          .update({
        'viewer': FieldValue.arrayUnion([_myUserId]),
      });
      print('✅ 커뮤니티 읽음 처리 완료');
    } catch (e) {
      print('❌ 커뮤니티 읽음 처리 실패: $e');
    }
  }

  /// 새 게시글 등록 시 알람 초기화 (viewer 배열 비우기)
  /// 모든 유저에게 새 게시글 알림이 표시됨
  Future<void> clearAllReadStatus() async {
    try {
      await _firestore
          .collection('community')
          .doc('community')
          .set({'viewer': []});
      print('✅ 커뮤니티 알람 초기화 (새 게시글 등록)');
    } catch (e) {
      print('❌ 커뮤니티 알람 초기화 실패: $e');
    }
  }
}
