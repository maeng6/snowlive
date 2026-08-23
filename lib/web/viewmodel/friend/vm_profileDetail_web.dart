import 'dart:convert';

import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_friendDetail.dart';
import 'package:com.snowlive/core/model/m_friendDetail.dart';
import 'package:com.snowlive/core/model/m_friendsTalk.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/ranking_season_web.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// 프로필 상세(라이딩 통계 · 방명록 · 시즌 기록실)용 웹 전용 뷰모델.
///
/// 코어 [FriendDetailViewModel]은 웹에서 쓸 수 없다 — 필드 이니셜라이저의
/// `Get.put(ImageController())` 한 줄 때문에 `dart:io`·`image_picker`·`image_cropper`가
/// 전이로 딸려오고, 뷰모델이 `Get.back()`·`Get.snackbar`·`CustomFullScreenDialog`를
/// 직접 부른다(`vm_friend_web.dart`와 같은 이유). 조회·쓰기 API만 여기서 감싼다.
///
/// 안내 문구는 띄우지 않는다 — 결과만 돌려주고 화면이 토스트를 띄운다(웹 관례).
class ProfileDetailViewModelWeb extends GetxController {
  final FriendDetailAPI _api = FriendDetailAPI();

  /// 기록실 응답은 `_recordRoom` 접미사 모델로 파싱되는데 필드 구성이 현재 시즌과
  /// 완전히 같다(실측). 위젯을 두 타입으로 나누지 않으려고 여기서는 직접 요청해
  /// [FriendDetailModel]로 파싱한다(크루 기록실과 같은 처리).
  static const String _baseUrl =
      'https://snowlive-api-c617725e2b78.herokuapp.com/api/friend-detail-page';

  UserViewModel get _userVM => Get.find<UserViewModel>();

  final Rxn<FriendDetailModel> _detail = Rxn<FriendDetailModel>();
  final Rxn<FriendDetailModel> _record = Rxn<FriendDetailModel>();
  final RxList<FriendsTalk> _talks = <FriendsTalk>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxBool _isRecordLoading = false.obs;
  final RxBool _isSubmitting = false.obs;
  final RxString _recordSeason = ''.obs;

  int? _userId;

  /// 현재 시즌 프로필(헤더·랭킹·통계·일간 캘린더가 이 응답 하나에서 나온다).
  FriendDetailModel? get detail => _detail.value;

  /// 기록실에서 고른 시즌의 프로필.
  FriendDetailModel? get record => _record.value;
  List<FriendsTalk> get talks => _talks;
  bool get isLoading => _isLoading.value;
  bool get isRecordLoading => _isRecordLoading.value;
  bool get hasError => _hasError.value;
  bool get isSubmitting => _isSubmitting.value;
  String get recordSeason => _recordSeason.value;
  int? get userId => _userId;

  int? get myUserId => _userVM.user.user_id;
  bool get isLoggedIn => myUserId != null;
  bool get isMe => myUserId != null && myUserId == _userId;
  bool get areWeFriend => _detail.value?.friendUserInfo.areWeFriend ?? false;

  /// 비공개 프로필. 내 프로필은 항상 보인다(앱과 동일).
  bool get isHidden => (_detail.value?.friendUserInfo.hideProfile ?? false) && !isMe;

  /// 방명록은 **친구만** 남길 수 있다(목업의 자물쇠 + 안내 문구). 내 방명록에는
  /// 내가 쓰지 않는다(앱과 동일 — 입력창 자체를 감춘다).
  bool get canWriteGuestbook => isLoggedIn && !isMe && areWeFriend && !isHidden;

  // ===== 조회 =====

  Future<void> load(int userId) async {
    _userId = userId;
    _isLoading.value = true;
    _hasError.value = false;
    _detail.value = null;
    _record.value = null;
    _talks.clear();
    try {
      final season = await fetchCurrentRankingSeason() ?? '';
      await Future.wait([
        _fetchDetail(userId: userId, season: season),
        _fetchTalks(userId),
      ]);
    } finally {
      _isLoading.value = false;
    }
  }

  /// GetxController에 같은 이름(`refresh`)이 있어 이름을 바꿔 둔다.
  Future<void> reload() async {
    final id = _userId;
    if (id != null) await load(id);
  }

  /// 기록실 탭. 시즌을 처음 열 때는 [season]을 넘기고, 이후 드롭다운에서 바꿀 때도
  /// 같은 메서드를 쓴다.
  Future<void> loadRecord(String season) async {
    final id = _userId;
    if (id == null) return;
    _recordSeason.value = season;
    _isRecordLoading.value = true;
    _record.value = null;
    try {
      // 이 API도 `user_id`가 필수인데 응답에 개인화된 값은 친구 관계뿐이라, 비로그인
      // 방문자는 **보고 있는 유저의 id로 채워** 호출한다(실측 200).
      final uri = Uri.parse('$_baseUrl/recordroom/').replace(queryParameters: {
        'user_id': '${myUserId ?? id}',
        'friend_user_id': '$id',
        'selected_season': season,
      });
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        debugPrint('[Profile] 기록실 조회 실패(${res.statusCode}): ${utf8.decode(res.bodyBytes)}');
        return;
      }
      _record.value =
          FriendDetailModel.fromJson(json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[Profile] 기록실 조회 예외: $e');
    } finally {
      _isRecordLoading.value = false;
    }
  }

  Future<void> _fetchDetail({required int userId, required String season}) async {
    try {
      // 비로그인이면 보고 있는 유저의 id를 그대로 넣는다(위 loadRecord와 같은 이유).
      final ApiResponse res = await _api.fetchFriendDetail(myUserId ?? userId, userId, season);
      if (!res.success) {
        debugPrint('[Profile] 프로필 조회 실패: ${res.error}');
        _hasError.value = true;
        return;
      }
      _detail.value = res.data as FriendDetailModel;
    } catch (e) {
      debugPrint('[Profile] 프로필 조회 예외: $e');
      _hasError.value = true;
    }
  }

  Future<void> _fetchTalks(int userId) async {
    try {
      final ApiResponse res = await _api.fetchFriendsTalkList(myUserId ?? userId, userId);
      if (!res.success) {
        debugPrint('[Profile] 방명록 조회 실패: ${res.error}');
        return;
      }
      final list = res.data as List<dynamic>;
      _talks.assignAll(list.map((e) => FriendsTalk.fromJson(e as Map<String, dynamic>)));
    } catch (e) {
      debugPrint('[Profile] 방명록 조회 예외: $e');
    }
  }

  Future<void> refreshTalks() async {
    final id = _userId;
    if (id != null) await _fetchTalks(id);
  }

  // ===== 방명록 쓰기 =====

  /// 작성. ⚠️ 서버 엔드포인트가 `create-or-update`라 **한 사람이 두 번 쓰면 이전 글이
  /// 갱신될 수 있다**(앱도 이 엔드포인트로 작성·수정을 함께 처리한다).
  Future<bool> postGuestbook(String content) async {
    final id = _userId;
    final me = myUserId;
    if (id == null || me == null) return false;
    return _run(() async {
      final res = await _api.createOrUpdateFriendsTalk({
        'author_user_id': me,
        'friend_user_id': id,
        'content': content,
      });
      return res.success;
    });
  }

  /// 삭제. 서버는 `user_id`로 권한을 판단하므로 **작성자 id**를 보낸다(앱과 동일).
  Future<bool> deleteGuestbook({required int talkId, required int authorUserId}) =>
      _run(() async => (await _api.deleteFriendsTalk(authorUserId, talkId)).success);

  /// 신고. 이 API는 정상 접수(201)와 중복(400)을 **둘 다 success로** 주고 구분이
  /// 응답 message에만 있어서, 화면이 `mapWebActionResponse`로 감쌀 수 있게 응답을
  /// 그대로 돌려준다. `user_id`는 앱과 같이 문자열로 보낸다(`v_friendDetail.dart:1808`).
  Future<ApiResponse> reportGuestbook(int talkId) async {
    final me = myUserId;
    if (me == null) return ApiResponse.error({'message': 'login required'});
    try {
      return await _api.reportFriendsTalk({
        'user_id': me.toString(),
        'friends_talk_id': talkId,
      });
    } catch (e) {
      debugPrint('[Profile] 방명록 신고 실패: $e');
      return ApiResponse.error({'message': 'failed'});
    }
  }

  Future<bool> _run(Future<bool> Function() action) async {
    if (_isSubmitting.value) return false;
    _isSubmitting.value = true;
    try {
      return await action();
    } catch (e) {
      debugPrint('[Profile] 방명록 요청 실패: $e');
      return false;
    } finally {
      _isSubmitting.value = false;
    }
  }
}
