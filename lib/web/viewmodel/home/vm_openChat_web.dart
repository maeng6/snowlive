import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/core/api/api_resortHome.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:get/get.dart';

/// 홈 우측 하단 오픈 채팅.
///
/// 앱과 같은 소스다 — 읽기는 Firestore `chat` 컬렉션 스트림, 쓰기는 서버 API
/// (`POST /api/resort-home/chat/create/`)다. Firestore에 직접 쓰지 않는 이유는 앱과
/// 같다(서버가 chatId·검열·푸시를 함께 처리한다).
class OpenChatViewModelWeb extends GetxController {
  /// 앱과 같은 상한(메모리). 홈 위젯은 이보다 적게 보여줘도 된다.
  static const int _limit = 100;

  final RxList<OpenChatMessage> _messages = <OpenChatMessage>[].obs;
  final RxBool _isSending = false.obs;

  /// 새로 올라온 메시지. 말풍선(5초)으로 한 번 보여주고 비운다.
  final Rxn<OpenChatMessage> _latest = Rxn<OpenChatMessage>();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  /// 스트림 첫 응답은 "새 메시지"가 아니다(들어오자마자 말풍선이 뜨면 안 된다).
  bool _primed = false;

  /// 오래된 → 최신 순. 화면이 아래로 쌓아 그린다.
  List<OpenChatMessage> get messages => _messages;
  bool get isSending => _isSending.value;
  OpenChatMessage? get latest => _latest.value;

  /// 말풍선을 5초만 띄우려면 화면이 "새 메시지가 들어온 순간"을 알아야 한다
  /// → Rx 자체를 열어 `ever`로 감시하게 한다.
  Rxn<OpenChatMessage> get latestRx => _latest;

  UserViewModel get _userVM => Get.find<UserViewModel>();
  int? get myUserId => _userVM.user.user_id;
  bool get isLoggedIn => myUserId != null;

  @override
  void onInit() {
    super.onInit();
    start();
  }

  @override
  void onClose() {
    stop();
    super.onClose();
  }

  void start() {
    _sub?.cancel();
    _primed = false;
    _sub = FirebaseFirestore.instance
        .collection('chat')
        .orderBy('createdAt', descending: true)
        .limit(_limit)
        .snapshots()
        .listen(_onSnapshot, onError: (_) {});
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  void _onSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final parsed = [
      for (final doc in snapshot.docs) OpenChatMessage.fromDoc(doc.id, doc.data()),
    ].reversed.toList();

    final previousLast = _messages.isEmpty ? null : _messages.last.id;
    _messages.value = parsed;

    if (!_primed) {
      _primed = true;
      return;
    }
    // 마지막 메시지가 바뀌었을 때만 말풍선을 띄운다(수정·삭제로 스냅샷이 와도 조용히).
    final last = parsed.isEmpty ? null : parsed.last;
    if (last != null && last.id != previousLast) _latest.value = last;
  }

  /// 말풍선을 내린다(5초 타이머 종료 또는 채팅창을 펼쳤을 때).
  void clearLatest() => _latest.value = null;

  /// 전송. 로그인 안 했으면 false를 돌려주고 화면이 안내를 띄운다(웹 관례).
  Future<bool> send(String text) async {
    final message = text.trim();
    final userId = myUserId;
    if (message.isEmpty || userId == null) return false;

    _isSending(true);
    try {
      // chatId는 앱과 같은 규칙(`<uid>-<n>`)이다. 내 마지막 메시지의 번호를 이어 붙인다.
      final last = await FirebaseFirestore.instance
          .collection('chat')
          .where('uid', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      var suffix = 1;
      if (last.docs.isNotEmpty) {
        final raw = last.docs.first.data()['chatId'];
        if (raw is String) {
          final parsed = int.tryParse(raw.replaceFirst('$userId-', ''));
          if (parsed != null) suffix = parsed + 1;
        }
      }

      final res = await ResortHomeAPI().createChat(
        uid: userId,
        text: message,
        chatId: '$userId-$suffix',
      );
      return res.success;
    } catch (_) {
      return false;
    } finally {
      _isSending(false);
    }
  }
}

/// 오픈 채팅 메시지 하나.
class OpenChatMessage {
  final String id;
  final int? uid;
  final String text;
  final DateTime? createdAt;

  /// 입·퇴장 등 시스템 메시지. 가운데 회색 알약으로 그린다(앱과 동일).
  final bool isSystem;

  const OpenChatMessage({
    required this.id,
    required this.uid,
    required this.text,
    required this.createdAt,
    required this.isSystem,
  });

  factory OpenChatMessage.fromDoc(String id, Map<String, dynamic> data) {
    final created = data['createdAt'];
    return OpenChatMessage(
      id: id,
      uid: data['uid'] is int ? data['uid'] as int : int.tryParse('${data['uid']}'),
      text: data['text'] is String ? data['text'] as String : '',
      createdAt: created is Timestamp ? created.toDate() : null,
      isSystem: data['system_msg'] == true,
    );
  }

  bool isMine(int? myUserId) => myUserId != null && uid == myUserId;
}
