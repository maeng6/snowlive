import 'package:com.snowlive/core/api/api_community.dart';
import 'package:com.snowlive/core/api/api_user.dart';
import 'package:com.snowlive/core/model/m_communityDetail.dart';
import 'package:com.snowlive/core/model/m_communityList.dart';
import 'package:com.snowlive/web/widget/w_top_loading_bar_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart' show WebActionResult;
import 'package:get/get.dart';

/// 웹 전용 커뮤니티 상세 뷰모델.
///
/// core의 CommunityDetailViewModel을 쓰지 않는 이유:
///  - Rx를 재할당 없이 직접 뮤테이션해서 Obx가 갱신을 감지하지 못한다
///    (중고거래 웹이 이미 겪고 StatefulWidget + setState로 우회 중)
///  - reportCommunity/deleteCommunityPost가 VM 안에서 CustomFullScreenDialog와
///    Get.back()/Get.snackbar를 직접 호출해 웹 흐름과 충돌한다
///  - ScrollController/TextEditingController/formKey가 VM에 박혀 있어 모바일 화면
///    형태에 맞춰져 있다
/// 목록(vm_communityListPagination_web.dart)과 같이 웹 전용으로 분리한다.
class CommunityDetailViewModelWeb extends GetxController {
  final CommunityAPI _api = CommunityAPI();

  final Rxn<CommunityDetailModel> _detail = Rxn<CommunityDetailModel>();

  /// 댓글은 모델에 맡기지 않고 여기서 따로 들고 있는다(아래 _fetch 주석 참고).
  /// 쓰기 후에는 **항상 재할당**해서 Obx가 갱신을 감지하게 한다.
  final RxList<CommentModel_community> _comments = <CommentModel_community>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;

  int? _communityId;
  int? _userId;

  /// 조회수는 진입당 한 번만 올린다(리빌드/재조회로 중복 증가하지 않게).
  bool _viewCounted = false;

  CommunityDetailModel? get detail => _detail.value;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;

  /// 상세 응답에 댓글이 중첩되어 오므로 별도 조회가 필요 없다.
  List<CommentModel_community> get comments => _comments;

  /// 내가 쓴 글인지(작성자 전용 메뉴 판단).
  bool get isAuthor {
    final authorId = _detail.value?.userId;
    return authorId != null && _userId != null && authorId == _userId;
  }

  bool get isLoggedIn => _userId != null;

  /// 게시글 id를 받아 조회한다. 목록에서 VM을 미리 채우고 이동하는 방식이 아니라
  /// **URL의 id로 매번 조회**하므로 새로고침·링크 공유로 직접 들어와도 열린다.
  Future<void> load({required int communityId, int? userId}) async {
    _communityId = communityId;
    _userId = userId;
    _isLoading.value = true;
    beginPageLoading();
    try {
      await _fetch();
    } finally {
      _isLoading.value = false;
      endPageLoading();
    }
    if (!_hasError.value) await _increaseViewOnce();
  }

  /// 댓글/답글을 바꾼 뒤 다시 받아온다. 상세 응답 하나로 댓글·답글이 모두 갱신되고,
  /// Rx를 **통째로 재할당**하므로 Obx가 정상 동작한다.
  Future<void> refresh() => _fetch();

  Future<void> retry() async {
    if (_communityId == null) return;
    _isLoading.value = true;
    beginPageLoading();
    try {
      await _fetch();
    } finally {
      _isLoading.value = false;
      endPageLoading();
    }
  }

  Future<void> _fetch() async {
    final id = _communityId;
    if (id == null) return;
    try {
      // 게스트는 빈 문자열로 보내야 한다. 'null' 문자열을 보내면 서버가 500을 준다.
      final response = await _api.fetchCommunityDetails(id, _userId?.toString() ?? '');
      if (response.success) {
        // 댓글을 떼어내고 본문만 모델에 넘긴다. CommunityDetailModel.fromJson은
        // comments를 항목별 방어 없이 매핑하고 UserInfo.fromJson도 null 가드가
        // 없어서(탈퇴 회원 등) **댓글 한 건이 깨지면 글 전체가 실패**한다.
        final map = Map<String, dynamic>.from(response.data as Map);
        final rawComments = map.remove('comments');
        _detail.value = CommunityDetailModel.fromJson(map);
        _comments.value = _parseComments(rawComments);
        _hasError.value = false;
      } else {
        print('[CommunityDetail] 조회 실패: ${response.error}');
        _hasError.value = true;
      }
    } catch (e) {
      print('[CommunityDetail] 조회 예외: $e');
      _hasError.value = true;
    }
  }

  /// 댓글을 **한 건씩** 파싱해서 깨진 항목만 건너뛴다(목록 VM의 _parseResults와 같은 이유).
  List<CommentModel_community> _parseComments(Object? raw) {
    if (raw is! List) return [];
    final parsed = <CommentModel_community>[];
    var skipped = 0;
    for (final item in raw) {
      try {
        parsed.add(CommentModel_community.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        skipped++;
      }
    }
    if (skipped > 0) print('[CommunityDetail] 파싱 실패로 건너뛴 댓글 $skipped건');
    return parsed;
  }

  Future<void> _increaseViewOnce() async {
    // 비로그인(게스트)도 조회수는 올라간다 → user_id 없으면 빼고 보낸다(서버가 익명 처리).
    if (_viewCounted || _communityId == null) return;
    _viewCounted = true;
    try {
      final body = <String, dynamic>{};
      if (_userId != null) body['user_id'] = _userId.toString();
      await _api.addView(_communityId!, body);
    } catch (e) {
      print('[CommunityDetail] 조회수 증가 실패: $e');
    }
  }

  Future<bool> postComment(String content) async {
    final id = _communityId;
    if (id == null || _userId == null) return false;
    final trimmed = content.trim();
    if (trimmed.isEmpty) return false;
    try {
      final response = await _api.createComment({
        'community_id': id,
        'content': trimmed,
        'user_id': _userId,
      });
      if (!response.success) return false;
      await refresh();
      return true;
    } catch (e) {
      print('[CommunityDetail] 댓글 작성 실패: $e');
      return false;
    }
  }

  Future<bool> postReply(int commentId, String content) async {
    if (_userId == null) return false;
    final trimmed = content.trim();
    if (trimmed.isEmpty) return false;
    try {
      final response = await _api.createReply({
        'comment_id': commentId,
        'content': trimmed,
        'user_id': _userId,
      });
      if (!response.success) return false;
      await refresh();
      return true;
    } catch (e) {
      print('[CommunityDetail] 답글 작성 실패: $e');
      return false;
    }
  }

  Future<bool> deleteComment(int commentId) async {
    if (_userId == null) return false;
    try {
      final response = await _api.deleteComment(commentId, _userId!);
      if (!response.success) return false;
      await refresh();
      return true;
    } catch (e) {
      print('[CommunityDetail] 댓글 삭제 실패: $e');
      return false;
    }
  }

  Future<bool> deleteReply(int replyId) async {
    if (_userId == null) return false;
    try {
      // 답글 삭제만 DELETE + body 형태다(경로도 생성/조회와 다르다).
      final response = await _api.deleteReply(replyId, {'user_id': _userId});
      if (!response.success) return false;
      await refresh();
      return true;
    } catch (e) {
      print('[CommunityDetail] 답글 삭제 실패: $e');
      return false;
    }
  }

  /// 내 글 삭제. core VM의 deleteCommunityPost는 내부에서 Get.back()을 두 번 부르고
  /// Firebase 폴더까지 지우므로 쓰지 않고 API만 직접 호출한다(화면 이동은 뷰가 결정).
  Future<bool> deletePost() async {
    final id = _communityId;
    if (id == null || _userId == null) return false;
    try {
      final response = await _api.deleteCommunity(id, _userId.toString());
      return response.success;
    } catch (e) {
      print('[CommunityDetail] 게시글 삭제 실패: $e');
      return false;
    }
  }

  Future<WebActionResult> reportPost() async {
    final id = _communityId;
    if (id == null || _userId == null) return WebActionResult.failed;
    return _report(() => _api.reportCommunity({'user_id': _userId, 'community_id': id}));
  }

  Future<WebActionResult> reportCommentById(int commentId) =>
      _report(() => _api.reportComment(_userId!, commentId));

  Future<WebActionResult> reportReplyById(int replyId) =>
      _report(() => _api.reportReply(userId: _userId!, replyId: replyId));

  /// 신고 API는 정상 등록(201)과 중복 신고(400)를 **모두 success로** 돌려주고
  /// 구분은 응답 message 문자열에만 있다.
  Future<WebActionResult> _report(Future<dynamic> Function() call) async {
    if (_userId == null) return WebActionResult.failed;
    try {
      final response = await call();
      if (!response.success) return WebActionResult.failed;
      final message = (response.data is Map) ? '${(response.data as Map)['message'] ?? ''}' : '';
      return message.toLowerCase().contains('already')
          ? WebActionResult.duplicated
          : WebActionResult.done;
    } catch (e) {
      print('[CommunityDetail] 신고 실패: $e');
      return WebActionResult.failed;
    }
  }

  /// 이 회원의 모든 글 숨기기.
  ///
  /// `UserViewModel.block_user`를 쓰지 않는다 — 그 메서드가 내부에서
  /// `CustomFullScreenDialog.cancelDialog()`(= `Get.back()`)를 **무조건** 호출해서
  /// 전역 로딩 다이얼로그가 떠 있지 않으면 **상세 라우트가 pop 된다.**
  /// 웹은 그 다이얼로그(`Get.dialog` 기반, 금지)를 쓰지 않으므로 API를 직접 부른다.
  ///
  /// 서버가 user_id 기준으로 목록을 걸러주므로 차단 후에는 목록을 다시 조회해야 반영된다.
  Future<WebActionResult> blockUser(int blockUserId) async {
    if (_userId == null) return WebActionResult.failed;
    return _report(() => UserAPI().blockUser({
          'user_id': _userId,
          'block_user_id': blockUserId,
        }));
  }
}
