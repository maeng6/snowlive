import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_alarmcenter..dart';
import 'package:com.snowlive/core/model/m_alarmCenterList.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// 알림 종류(`alarminfo_id`). 서버 AlarmInfo 테이블과 같은 번호다.
class AlarmKind {
  static const int friendRequest = 1;
  static const int guestbook = 2;
  static const int crewApply = 3;
  static const int fleamarketComment = 4;
  static const int communityComment = 5;
  static const int reply = 6;
}

/// 알림을 눌렀을 때 할 일 — 이동할 라우트, 또는 이동 대신 띄울 안내.
/// 둘 다 null이면 읽음 처리만 한다(모르는 종류).
class AlarmTapTarget {
  final String? route;
  final String? message;

  const AlarmTapTarget.route(String this.route) : message = null;
  const AlarmTapTarget.message(String this.message) : route = null;
  const AlarmTapTarget.none()
      : route = null,
        message = null;
}

/// 알림 → 웹 이동 경로.
///
/// 앱은 댓글 알림을 **댓글 상세 화면**으로 보내는데 웹에는 그 화면이 없어 글 상세로
/// 보낸다(댓글은 상세 하단에 있다). 크루 가입 신청은 앱과 같은 판정 — 내가 그 크루의
/// 크루장일 때만 신청 목록으로 가고, 아니면 `권한이 없어요`.
AlarmTapTarget alarmTapTarget(
  AlarmCenterModel alarm, {
  required int? myUserId,
  required int? myCrewId,
}) {
  String fleaDetail(int id) => '${WebRoutes.fleamarketDetail}?id=$id';
  String communityDetail(int id) => '${WebRoutes.communityDetail}?id=$id';
  const deleted = AlarmTapTarget.message('삭제된 게시글이에요.');

  switch (alarm.alarmInfo.alarmInfoId) {
    case AlarmKind.friendRequest:
      return const AlarmTapTarget.route(WebRoutes.friendRequests);
    case AlarmKind.guestbook:
      if (myUserId == null) return const AlarmTapTarget.none();
      return AlarmTapTarget.route(
          '${WebRoutes.userProfile}?id=$myUserId&tab=${WebRoutes.userProfileTabGuestbook}');
    case AlarmKind.crewApply:
      final isLeader = myUserId != null && alarm.crewLeaderUserId == myUserId;
      if (!isLeader || myCrewId == null) {
        return const AlarmTapTarget.message('권한이 없어요.');
      }
      return AlarmTapTarget.route('${WebRoutes.crewApplications}?id=$myCrewId');
    case AlarmKind.fleamarketComment:
      final id = alarm.pkFleamarket;
      return id == null ? deleted : AlarmTapTarget.route(fleaDetail(id));
    case AlarmKind.communityComment:
      final id = alarm.pkCommunity;
      return id == null ? deleted : AlarmTapTarget.route(communityDetail(id));
    case AlarmKind.reply:
      // 답글은 어느 게시판의 답글인지를 `pk_reply_*` 중 채워진 쪽으로 가린다(앱과 같다).
      if (alarm.pkReplyCommunity != null && alarm.pkCommunity != null) {
        return AlarmTapTarget.route(communityDetail(alarm.pkCommunity!));
      }
      if (alarm.pkReplyFleamarket != null && alarm.pkFleamarket != null) {
        return AlarmTapTarget.route(fleaDetail(alarm.pkFleamarket!));
      }
      return deleted;
    default:
      return const AlarmTapTarget.none();
  }
}

/// 사이드바·드로어의 `알림` 빨간 점.
///
/// 앱과 같은 소스 — Firestore `notificationCenter`의 내 문서(`uid` 필드)의 `total`.
/// 친구 요청·크루 가입 신청 등을 보낸 쪽이 상대 문서를 `total: true`로 켜고,
/// 알림 화면에 들어오면 끈다.
class AlarmBadgeWeb {
  static const String _collection = 'notificationCenter';

  /// 안 읽은 알림이 있는지. Firestore를 못 쓰는 환경(테스트 등)에서는 항상 false.
  static Stream<bool> unreadStream(int uid) {
    try {
      return FirebaseFirestore.instance
          .collection(_collection)
          .where('uid', isEqualTo: uid)
          .snapshots()
          .map((snap) => snap.docs.isNotEmpty && snap.docs.first.data()['total'] == true)
          .handleError((Object e) => debugPrint('[AlarmBadge] 구독 실패: $e'));
    } catch (e) {
      debugPrint('[AlarmBadge] 구독 실패: $e');
      return Stream<bool>.value(false);
    }
  }

  /// 점을 끈다. 문서가 없으면 만든다(앱 `updateNotification`과 같다).
  static Future<void> clear(int uid) async {
    try {
      final col = FirebaseFirestore.instance.collection(_collection);
      final snap = await col.where('uid', isEqualTo: uid).get();
      if (snap.docs.isNotEmpty) {
        if (snap.docs.first.data()['total'] == true) {
          await snap.docs.first.reference.update({'total': false});
        }
      } else {
        await col.add({'uid': uid, 'total': false, 'friend': false, 'crew': false});
      }
    } catch (e) {
      debugPrint('[AlarmBadge] 끄기 실패: $e');
    }
  }
}

/// 웹 알림센터.
///
/// 앱 `AlarmCenterViewModel`은 `CustomFullScreenDialog`·`FriendDetailViewModel`을
/// 물고 있어 웹에서 쓸 수 없다 → 같은 API(`AlarmCenterAPI`)를 직접 부른다.
/// 토스트·이동은 화면이 담당한다(웹 관례).
class AlarmCenterViewModelWeb extends GetxController {
  AlarmCenterViewModelWeb({AlarmCenterAPI? api}) : _api = api ?? AlarmCenterAPI();

  final AlarmCenterAPI _api;

  UserViewModel get _userVM => Get.find<UserViewModel>();
  int? get myUserId => _userVM.user.user_id;
  int? get myCrewId => _userVM.user.crew_id;

  final RxList<AlarmCenterModel> _items = <AlarmCenterModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _isLoaded = false.obs;
  final RxBool _hasError = false.obs;
  String? _nextUrl;

  /// ⚠️ Rx 컬렉션 객체를 그대로 돌려주면 Obx가 의존성을 못 건다 → 복사본.
  List<AlarmCenterModel> get items => List<AlarmCenterModel>.from(_items);
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;

  /// 첫 페이지를 한 번이라도 받았는지(받기 전엔 스켈레톤).
  bool get isLoaded => _isLoaded.value;
  bool get hasError => _hasError.value;
  bool get hasMore => _nextUrl != null && _nextUrl!.isNotEmpty;

  /// 첫 페이지(30건)부터 다시 받는다.
  Future<void> refreshList() async {
    final uid = myUserId;
    if (uid == null || _isLoading.value) return;
    _isLoading(true);
    _hasError(false);
    try {
      final res = await _api.fetchAlarmCenterList(userId: uid);
      final page = _parse(res);
      if (page == null) {
        _hasError(true);
        return;
      }
      _items.assignAll(page.results ?? const []);
      _nextUrl = page.next;
      _isLoaded(true);
    } catch (e) {
      debugPrint('[AlarmCenter] 목록 실패: $e');
      _hasError(true);
    } finally {
      _isLoading(false);
    }
  }

  /// 다음 페이지(`next` URL). 스크롤 끝에서 부른다.
  Future<void> loadMore() async {
    final uid = myUserId;
    if (uid == null || !hasMore || _isLoadingMore.value || _isLoading.value) return;
    _isLoadingMore(true);
    try {
      final res = await _api.fetchAlarmCenterList(userId: uid, url: _nextUrl);
      final page = _parse(res);
      if (page == null) return;
      // 그 사이 새 알림이 들어오면 페이지 경계가 밀려 같은 알림이 또 올 수 있다.
      final seen = _items.map((a) => a.alarmCenterId).toSet();
      _items.addAll((page.results ?? const []).where((a) => !seen.contains(a.alarmCenterId)));
      _nextUrl = page.next;
    } catch (e) {
      debugPrint('[AlarmCenter] 다음 페이지 실패: $e');
    } finally {
      _isLoadingMore(false);
    }
  }

  /// 읽음 처리(`active: false`). 화면은 바로 흐려지고, 실패하면 되돌린다.
  Future<bool> markRead(AlarmCenterModel alarm) async {
    if (!alarm.active) return true;
    _setActive(alarm.alarmCenterId, false);
    try {
      final res = await _api.updateAlarmCenter(alarm.alarmCenterId, {'active': false});
      if (res.success) return true;
    } catch (e) {
      debugPrint('[AlarmCenter] 읽음 실패: $e');
    }
    _setActive(alarm.alarmCenterId, true);
    return false;
  }

  /// 삭제. 목록에서 바로 빼고, 실패하면 원래 자리에 되돌린다.
  Future<bool> delete(AlarmCenterModel alarm) async {
    final index = _items.indexWhere((a) => a.alarmCenterId == alarm.alarmCenterId);
    if (index < 0) return false;
    _items.removeAt(index);
    try {
      final res = await _api.deleteAlarmCenter(alarm.alarmCenterId);
      if (res.success) return true;
    } catch (e) {
      debugPrint('[AlarmCenter] 삭제 실패: $e');
    }
    _items.insert(index.clamp(0, _items.length), alarm);
    return false;
  }

  /// 사이드바 빨간 점 끄기 — 화면에 들어오면 부른다(앱과 같다).
  Future<void> clearBadge() async {
    final uid = myUserId;
    if (uid == null) return;
    await AlarmBadgeWeb.clear(uid);
  }

  void _setActive(int alarmCenterId, bool active) {
    final i = _items.indexWhere((a) => a.alarmCenterId == alarmCenterId);
    if (i < 0) return;
    _items[i].active = active;
    _items.refresh();
  }

  AlarmCenterResponse? _parse(ApiResponse res) {
    if (!res.success || res.data is! Map<String, dynamic>) return null;
    return AlarmCenterResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
