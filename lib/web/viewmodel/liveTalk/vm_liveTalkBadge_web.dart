import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 웹 라이브톡 "새 글" 빨간 점 뷰모델 (Firestore 실시간 신호 방식).
///
/// 서버는 새 글을 만들 때 Firestore `livetalk/meta.latest_id`만 갱신한다. 클라이언트는
/// 이 **문서 1개만 실시간 구독**하므로 폴링이 없다(서버 트래픽·배터리 부담 거의 0).
///
/// 읽음 기준선(lastSeen)은 **유저별로** SharedPreferences에 저장한다. 같은 브라우저에서
/// 계정을 바꿔도 서로 독립적으로 동작한다. 저장된 적이 없으면 0으로 보므로, 아직 한 번도
/// 라이브톡을 열지 않은 유저에겐 "새 글 있음" 점이 뜬다(라이브톡에 들어가면 꺼진다).
class LiveTalkBadgeWeb extends GetxController {
  static LiveTalkBadgeWeb get to => Get.find<LiveTalkBadgeWeb>();

  /// 서버 최신 글 id(Firestore 신호). 변하면 점 위젯이 다시 계산된다.
  final RxInt latestId = 0.obs;

  /// markSeen 후 점 위젯이 prefs를 다시 읽도록 하는 트리거.
  final RxInt seenRev = 0.obs;

  SharedPreferences? _prefs;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _boot();
  }

  Future<void> _boot() async {
    _prefs = await SharedPreferences.getInstance();
    seenRev.refresh(); // prefs 준비되면 한 번 재계산
    _sub = FirebaseFirestore.instance
        .collection('livetalk')
        .doc('meta')
        .snapshots()
        .listen(_onSnapshot, onError: (_) {});
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void _onSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final v = snap.data()?['latest_id'];
    latestId.value = (v is int) ? v : int.tryParse('$v') ?? 0;
  }

  int? get _uid {
    if (!Get.isRegistered<UserViewModel>()) return null;
    final id = Get.find<UserViewModel>().user.user_id;
    if (id is int) return id;
    return int.tryParse('$id');
  }

  String _key(int? uid) => 'livetalk_last_seen_id_${uid ?? 'guest'}';

  /// 해당 유저가 마지막으로 본 글 id(없으면 0).
  int seenFor(int? uid) => _prefs?.getInt(_key(uid)) ?? 0;

  /// 해당 유저 기준 안 읽은 새 글이 있는지.
  bool hasUnreadFor(int? uid) => latestId.value > seenFor(uid);

  /// 라이브톡 진입/열람 시 읽음 처리 — 현재 유저 기준으로 점을 끈다.
  Future<void> markSeen() async {
    await _prefs?.setInt(_key(_uid), latestId.value);
    seenRev.value++;
  }
}
