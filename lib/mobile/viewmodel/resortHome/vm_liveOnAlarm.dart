import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class LiveOnAlarmViewModel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 친구가 라이브온 중인지 여부 (빨간점 표시용)
  RxBool hasFriendLiveOn = false.obs;

  // 현재 라이브온 중인 친구들의 user_id 목록
  RxList<int> liveOnFriendIds = <int>[].obs;

  // Firestore 스트림 구독
  StreamSubscription<DocumentSnapshot>? _alarmSubscription;

  // 현재 유저 ID
  int? _myUserId;

  // 마지막으로 알림을 보낸 친구 목록 (liveOff 시 제거용)
  List<int> _lastNotifiedFriendIds = [];

  @override
  void onClose() {
    _alarmSubscription?.cancel();
    super.onClose();
  }

  /// 내 문서 스트림 구독 시작
  /// [userId] 현재 로그인한 유저의 ID
  void startListening(int userId) {
    _myUserId = userId;

    // 기존 구독 해제
    _alarmSubscription?.cancel();

    // Firestore 스트림 구독: liveOn_alarm/{내 user_id}
    _alarmSubscription = _firestore
        .collection('liveOn_alarm')
        .doc(userId.toString())
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final List<dynamic> friendIds = data?['liveOn_friend_user_id'] ?? [];

        // 라이브온 중인 친구 목록 업데이트
        liveOnFriendIds.value = friendIds.cast<int>();

        // 배열에 누군가 있으면 빨간점 표시
        hasFriendLiveOn.value = friendIds.isNotEmpty;

        print('🔔 라이브온 알람: ${friendIds.length}명의 친구가 라이브온 중');
      } else {
        liveOnFriendIds.clear();
        hasFriendLiveOn.value = false;
      }
    }, onError: (e) {
      print('❌ 라이브온 알람 스트림 오류: $e');
    });
  }

  /// 라이브온 시 친구들에게 알림 등록
  /// [myUserId] 내 user_id
  /// [friendUserIds] 친구들의 user_id 목록
  Future<void> notifyFriendsLiveOn({
    required int myUserId,
    required List<int> friendUserIds,
  }) async {
    _myUserId = myUserId;
    _lastNotifiedFriendIds = friendUserIds;

    for (int friendId in friendUserIds) {
      // 본인 ID는 제외
      if (friendId == myUserId) {
        print('⏭️ 본인 ID($myUserId)는 스킵');
        continue;
      }

      try {
        final docRef = _firestore
            .collection('liveOn_alarm')
            .doc(friendId.toString());

        await docRef.set({
          'liveOn_friend_user_id': FieldValue.arrayUnion([myUserId]),
        }, SetOptions(merge: true));

        print('✅ 친구 $friendId에게 라이브온 알림 등록');
      } catch (e) {
        print('❌ 친구 $friendId 알림 등록 실패: $e');
      }
    }

    print('📢 총 ${friendUserIds.where((id) => id != myUserId).length}명의 친구에게 라이브온 알림 완료');
  }

  /// 라이브오프 시 친구들에게서 알림 제거
  Future<void> removeLiveOnNotification() async {
    if (_myUserId == null) return;

    for (int friendId in _lastNotifiedFriendIds) {
      try {
        final docRef = _firestore
            .collection('liveOn_alarm')
            .doc(friendId.toString());

        await docRef.update({
          'liveOn_friend_user_id': FieldValue.arrayRemove([_myUserId]),
        });

        print('✅ 친구 $friendId에서 라이브온 알림 제거');
      } catch (e) {
        print('❌ 친구 $friendId 알림 제거 실패: $e');
      }
    }

    print('📢 라이브오프 알림 제거 완료');
    _lastNotifiedFriendIds.clear();
  }

  /// 빨간점 확인 후 초기화 (친구 목록 열었을 때)
  Future<void> clearMyAlarm() async {
    if (_myUserId == null) return;

    try {
      await _firestore
          .collection('liveOn_alarm')
          .doc(_myUserId.toString())
          .set({'liveOn_friend_user_id': []});

      print('✅ 내 라이브온 알람 초기화');
    } catch (e) {
      print('❌ 라이브온 알람 초기화 실패: $e');
    }
  }
}