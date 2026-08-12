import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_friend.dart';
import 'package:com.snowlive/core/api/api_friendDetail.dart';
import 'package:com.snowlive/core/model/m_friendDetail.dart';
import 'package:com.snowlive/core/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/ranking_season_web.dart';
import 'package:get/get.dart';

/// 웹 친구 기능의 쓰기 동작 + 프로필 조회.
///
/// **읽기는 코어 [FriendListViewModel]을 그대로 쓴다** — 그 뷰모델은 웹 금지 의존성이
/// 없고 내부에서 `Get.back()`/`Get.snackbar`도 부르지 않아 안전하다.
///
/// ⚠️ 반면 요청 보내기·수락·차단해제는 `FriendDetailViewModel`에 있는데 **그 클래스는
/// 웹에서 쓸 수 없다.** 필드 이니셜라이저 `Get.put(ImageController())` 한 줄 때문에
/// 인스턴스화만으로 `dart:io`·`image_cropper`·`flutter_image_compress`·`path_provider`가
/// 전이로 딸려오고, 뷰모델이 `Get.back()`·`Get.snackbar`·`CustomFullScreenDialog`를
/// 직접 부른다. 그래서 그 동작들만 여기서 API를 직접 호출한다.
///
/// 안내 문구는 여기서 띄우지 않는다 — `bool`만 돌려주고 화면이 토스트/다이얼로그를
/// 띄운다(웹 관례).
class FriendViewModelWeb extends GetxController {
  final FriendAPI _friendAPI = FriendAPI();
  final FriendDetailAPI _friendDetailAPI = FriendDetailAPI();

  UserViewModel get _userVM => Get.find<UserViewModel>();
  FriendListViewModel get _listVM => Get.find<FriendListViewModel>();

  int? get _myUserId => _userVM.user.user_id;

  final RxBool _isSubmitting = false.obs;
  bool get isSubmitting => _isSubmitting.value;

  // ===== 읽기 (코어 뷰모델 위임) =====

  /// 목록·요청·차단목록을 한 번에 새로 받는다. 화면마다 필요한 것만 부르면
  /// 설정 화면의 배지(받은 요청 개수)가 비는 등 어긋나므로 묶어서 갱신한다.
  Future<void> refreshAll() async {
    final userId = _myUserId;
    if (userId == null) return;
    await Future.wait([
      _listVM.fetchFriendList(),
      _listVM.fetchFriendRequestList(userId),
      _listVM.fetchBlockUserList(),
    ]);
  }

  Future<void> refreshFriendList() => _listVM.fetchFriendList();

  Future<void> refreshRequests() async {
    final userId = _myUserId;
    if (userId == null) return;
    await _listVM.fetchFriendRequestList(userId);
  }

  Future<void> refreshBlockList() => _listVM.fetchBlockUserList();

  // ===== 쓰기 =====

  /// 친구 **요청 보내기**. 성공은 201이다(다른 친구 API와 다르다).
  Future<bool> sendRequest(int friendUserId) async {
    final userId = _myUserId;
    if (userId == null) return false;

    return _run(() async {
      final res = await _friendAPI.addFriend({
        'user_id': userId,
        'friend_user_id': friendUserId,
      });
      if (!res.success) return false;
      // 상대방 앱의 알림 배지를 켜준다. 이게 없으면 요청을 받은 사람이 눈치채지 못한다.
      // 실패해도 요청 자체는 성공이므로 삼키고 로그만 남긴다(앱과 동일).
      await _markFriendNotification(friendUserId);
      return true;
    });
  }

  /// 받은 요청 수락. `friend_user_id`가 아니라 **요청 id(`friend_id`)** 를 넘긴다.
  Future<bool> acceptRequest(int friendId) =>
      _run(() async => (await _friendAPI.acceptFriend({'friend_id': friendId})).success);

  /// 받은 요청 거절 / 보낸 요청 취소 / 친구 삭제는 **서버에서 같은 엔드포인트**다
  /// (`delete-friend/`). 부르는 자리에서 의미가 갈리도록 이름만 나눠 둔다.
  Future<bool> rejectRequest(int friendId) => _deleteFriendRelation(friendId);
  Future<bool> cancelRequest(int friendId) => _deleteFriendRelation(friendId);
  Future<bool> removeFriend(int friendId) => _deleteFriendRelation(friendId);

  Future<bool> _deleteFriendRelation(int friendId) =>
      _run(() async => (await _friendAPI.deleteFriend({'friend_id': friendId})).success);

  /// 차단. 성공은 201이다.
  Future<bool> blockUser(int targetUserId) async {
    final userId = _myUserId;
    if (userId == null) return false;
    return _run(() async => (await _friendDetailAPI.blockUser({
          'user_id': userId,
          'block_user_id': targetUserId,
        }))
            .success);
  }

  /// 차단 해제.
  ///
  /// ⚠️ 이 API는 **body를 실은 DELETE**다. 브라우저는 이 조합에 프리플라이트를 보내므로
  /// 서버 CORS가 `DELETE` + `Content-Type`을 허용해야 통과한다. 막히면 예외가 나므로
  /// [_run]이 잡아서 false를 돌려준다.
  Future<bool> unblockUser(int blockUserId) async {
    final userId = _myUserId;
    if (userId == null) return false;
    return _run(() async => (await _friendDetailAPI.unblockUser({
          'user_id': userId,
          'block_user_id': blockUserId,
        }))
            .success);
  }

  // ===== 프로필 =====

  /// 프로필 팝업용 상세 조회. 친구 목록 응답에는 소속(리조트·크루)·상태메시지·
  /// 친구관계(`are_we_friend`)가 없어서 이걸 따로 받는다.
  Future<FriendDetailModel?> fetchProfile(int friendUserId) async {
    final userId = _myUserId;
    if (userId == null) return null;
    try {
      // 시즌 값은 랭킹과 같은 웹 전용 유틸로 계산한다(모바일은 FriendDetailViewModel에
      // 들어 있어 못 쓴다). 못 구하면 서버가 기본 시즌으로 처리하도록 빈 문자열을 보낸다.
      final season = await fetchCurrentRankingSeason() ?? '';
      final ApiResponse res = await _friendDetailAPI.fetchFriendDetail(userId, friendUserId, season);
      if (!res.success) return null;
      return FriendDetailModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      print('[Friend] 프로필 조회 실패: $e');
      return null;
    }
  }

  // ===== 내부 =====

  Future<bool> _run(Future<bool> Function() action) async {
    if (_isSubmitting.value) return false;
    _isSubmitting.value = true;
    try {
      return await action();
    } catch (e) {
      print('[Friend] 요청 실패: $e');
      return false;
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// 앱의 알림센터 배지용 Firestore 문서를 켠다(`vm_friendDetail.dart:275-297` 이식).
  Future<void> _markFriendNotification(int friendUserId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notificationCenter')
          .where('uid', isEqualTo: friendUserId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({'total': true, 'friend': true});
      } else {
        await FirebaseFirestore.instance.collection('notificationCenter').add({
          'uid': friendUserId,
          'total': true,
          'friend': true,
          'crew': false,
        });
      }
    } catch (e) {
      print('[Friend] 알림센터 갱신 실패(요청 자체는 성공): $e');
    }
  }
}
