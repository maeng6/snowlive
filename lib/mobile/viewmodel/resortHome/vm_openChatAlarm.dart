import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 오픈채팅 "새 글" 빨간점 — **기기(앱 설치) 단위**로 동작한다(계정 무관).
///
/// 기존엔 Firestore `openChat_alarm/alarm` 문서의 `user_id` 배열로 **계정 단위**
/// 공유였지만, 웹과 동일하게 "이 기기에서 마지막으로 본 이후 새 글이 있나"로 바꿨다.
/// 읽음 기준선(lastSeen)은 SharedPreferences에 **uid 없이** 저장하므로, 같은 기기면
/// 어떤 계정이든/로그아웃이든 읽음이 유지된다. 판정: `최신글 시각(ms) > 저장된 읽음 시각`.
class OpenChatAlarmViewModel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 새 메시지 여부 (빨간점 표시용)
  RxBool hasNewMessage = false.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _alarmSubscription;

  SharedPreferences? _prefs;

  /// 기기 단위 고정 키(계정 무관). 웹과 같은 의미.
  static const String _seenKey = 'openchat_last_seen_ms';

  /// 최신 메시지 createdAt(ms).
  int _latestMs = 0;

  /// 첫 스냅샷은 "새 글"이 아니다 — 처음 켠 기기엔 기존 글로 점을 띄우지 않는다.
  bool _primed = false;

  @override
  void onClose() {
    _alarmSubscription?.cancel();
    super.onClose();
  }

  int _seenMs() => _prefs?.getInt(_seenKey) ?? 0;
  void _recompute() => hasNewMessage.value = _latestMs > _seenMs();

  /// 알람 스트림 구독 시작. [userId]는 호환용으로 받되 **사용하지 않는다**(기기 단위).
  Future<void> startListening([int? userId]) async {
    _alarmSubscription?.cancel();
    _primed = false;
    _prefs ??= await SharedPreferences.getInstance();
    _recompute();

    // 오픈채팅 메시지는 Firestore `chat` 컬렉션(웹과 같은 소스). 최신 1건만 구독.
    _alarmSubscription = _firestore
        .collection('chat')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      final ts = snapshot.docs.isEmpty
          ? null
          : snapshot.docs.first.data()['createdAt'];
      if (ts is Timestamp) _latestMs = ts.millisecondsSinceEpoch;

      if (!_primed) {
        _primed = true;
        // 이 기기에서 처음(저장값 없음)이면 지금 최신을 '봤다'로 프라임 → 기존 글엔 점 없음.
        if (_prefs != null && !_prefs!.containsKey(_seenKey)) {
          _prefs!.setInt(_seenKey, _latestMs);
        }
      }
      _recompute();
    }, onError: (e) {
      print('❌ 오픈채팅 알람 스트림 오류: $e');
    });
  }

  /// 알람 스트림 구독 중지 (백그라운드 전환 시 호출)
  void stopListening() {
    _alarmSubscription?.cancel();
    _alarmSubscription = null;
  }

  /// 알람 스트림 재시작 (포어그라운드 복귀 시 호출)
  void resumeListening() {
    if (_alarmSubscription == null) startListening();
  }

  /// 오픈채팅 읽음 처리 — 이 기기의 읽음 기준선을 최신으로 올린다.
  Future<void> markAsRead() async {
    await _prefs?.setInt(_seenKey, _latestMs);
    hasNewMessage.value = false;
  }

  /// 새 글 작성 후: 작성자 본인은 읽음 처리(다른 기기는 최신글 시각이 올라가 자동으로 점).
  Future<void> clearAndMarkMyself() async => markAsRead();

  /// (레거시 호환) 기기 단위 모델에선 "모두 안읽음으로"가 필요 없다 — no-op.
  Future<void> clearAllReadStatus() async {}
}
