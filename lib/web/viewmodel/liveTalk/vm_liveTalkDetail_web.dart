import 'package:com.snowlive/core/api/api_liveTalk.dart';
import 'package:com.snowlive/core/api/api_user.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// 웹 라이브톡 상세(사진 + 댓글) 뷰모델.
///
/// core의 [LiveTalkViewModel]은 dart:io·RepaintBoundary·무한스크롤이 한 덩어리라
/// 웹에서 컴파일되지 않는다. 여기서는 core의 **API/모델만** 쓴다.
///
/// 상세 응답에 댓글과 답글이 **중첩되어** 오므로 조회 1회로 전부 그린다.
class LiveTalkDetailViewModelWeb extends GetxController {
  final LiveTalkAPI _api = LiveTalkAPI();

  final Rxn<LiveTalk> _detail = Rxn<LiveTalk>();
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxBool _isSubmitting = false.obs;

  int? _livetalkId;
  int? _userId;

  LiveTalk? get detail => _detail.value;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  bool get isSubmitting => _isSubmitting.value;

  List<LiveTalkComment> get comments => _detail.value?.comments ?? const [];

  /// 서버의 comment_count는 **댓글 + 답글 합계**다(커뮤니티와 동일 규칙).
  /// 목업의 `댓글 N`은 이 값을 쓴다.
  int get commentCount => _detail.value?.commentCount ?? 0;

  /// 게스트면 쓰기(댓글·좋아요)를 막고 로그인 안내만 띄운다.
  bool get isGuest => _userId == null;

  bool get isAuthor =>
      _userId != null && _detail.value?.userId != null && _detail.value!.userId == _userId;

  bool isMyComment(int? commentUserId) =>
      _userId != null && commentUserId != null && commentUserId == _userId;

  Future<void> load({required int livetalkId, int? userId}) async {
    _livetalkId = livetalkId;
    _userId = userId;
    _isLoading.value = true;
    _hasError.value = false;
    try {
      final response = await _api.fetchDetail({
        'livetalk_id': livetalkId,
        // 게스트는 user_id를 아예 빼야 한다(목록과 같은 규칙).
        if (userId != null) 'user_id': userId,
      });
      if (response.success) {
        // Rx를 통째로 재할당한다. core VM처럼 내부만 뮤테이트하면 Obx가 못 감지한다.
        _detail.value = LiveTalk.fromJson(response.data as Map<String, dynamic>);
      } else {
        debugPrint('[LiveTalkDetail] 조회 실패: ${response.error}');
        _hasError.value = true;
      }
    } catch (e) {
      debugPrint('[LiveTalkDetail] 조회 예외: $e');
      _hasError.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 쓰기 액션 뒤 목록을 다시 받아 화면을 갱신한다.
  Future<void> refreshDetail() async {
    final id = _livetalkId;
    if (id == null) return;
    await load(livetalkId: id, userId: _userId);
  }

  /// 좋아요 토글. 응답의 {liked, like_count}로 즉시 반영한다.
  /// 성공하면 갱신된 글을 리턴해서 호출자(피드 목록)도 같은 값으로 맞출 수 있게 한다.
  Future<LiveTalk?> toggleLike() async {
    final id = _livetalkId;
    final userId = _userId;
    final current = _detail.value;
    if (id == null || userId == null || current == null) return null;

    try {
      final response = await _api.toggleLike({'livetalk_id': id, 'user_id': userId});
      if (!response.success) {
        debugPrint('[LiveTalkDetail] 좋아요 실패: ${response.error}');
        return null;
      }
      final parsed = LiveTalkLikeResponse.fromJson(response.data as Map<String, dynamic>);
      current
        ..isLiked = parsed.liked ?? !(current.isLiked ?? false)
        ..likeCount = parsed.likeCount ?? current.likeCount;
      // 같은 인스턴스를 다시 넣어도 Rxn은 반응하지 않는다 → refresh로 강제 통지.
      _detail.refresh();
      return current;
    } catch (e) {
      debugPrint('[LiveTalkDetail] 좋아요 예외: $e');
      return null;
    }
  }

  Future<bool> postComment(String content) async {
    final id = _livetalkId;
    final userId = _userId;
    if (id == null || userId == null) return false;
    return _write(() => _api.createComment({
          'livetalk_id': id,
          'user_id': userId,
          'content': content,
        }));
  }

  Future<bool> postReply({required int commentId, required String content}) async {
    final userId = _userId;
    if (userId == null) return false;
    return _write(() => _api.createReply({
          'comment_id': commentId,
          'user_id': userId,
          'content': content,
        }));
  }

  Future<bool> deleteComment(int commentId) async {
    final userId = _userId;
    if (userId == null) return false;
    return _write(() => _api.deleteComment({'comment_id': commentId, 'user_id': userId}));
  }

  Future<bool> deleteReply(int replyId) async {
    final userId = _userId;
    if (userId == null) return false;
    return _write(() => _api.deleteReply({'reply_id': replyId, 'user_id': userId}));
  }

  /// 쓰기 요청 → 성공 시 상세 재조회. 중복 제출을 [isSubmitting]으로 막는다.
  Future<bool> _write(Future<dynamic> Function() call) async {
    if (_isSubmitting.value) return false;
    _isSubmitting.value = true;
    try {
      final response = await call();
      if (response.success != true) {
        debugPrint('[LiveTalkDetail] 쓰기 실패: ${response.error}');
        return false;
      }
      await refreshDetail();
      return true;
    } catch (e) {
      debugPrint('[LiveTalkDetail] 쓰기 예외: $e');
      return false;
    } finally {
      _isSubmitting.value = false;
    }
  }

  // ── 신고 / 차단 ────────────────────────────────────────────────
  // core VM의 신고·차단은 내부에서 CustomFullScreenDialog.cancelDialog()(=Get.back())를
  // 호출해 열려 있는 오버레이를 닫아버린다. 그래서 API를 직접 부른다.

  Future<WebActionResult> reportPost() {
    final id = _livetalkId;
    final userId = _userId;
    return mapWebActionResponse(
        () => _api.report({'livetalk_id': id, 'user_id': userId}));
  }

  Future<WebActionResult> reportComment(int commentId) =>
      mapWebActionResponse(() => _api.reportComment({
            'comment_id': commentId,
            'user_id': _userId,
          }));

  Future<WebActionResult> reportReply(int replyId) =>
      mapWebActionResponse(() => _api.reportReply({
            'reply_id': replyId,
            'user_id': _userId,
          }));

  Future<WebActionResult> blockAuthor(int? targetUserId) =>
      mapWebActionResponse(() => UserAPI().blockUser({
            'user_id': _userId,
            'block_user_id': targetUserId,
          }));

  Future<bool> deletePost() async {
    final id = _livetalkId;
    final userId = _userId;
    if (id == null || userId == null) return false;
    try {
      final response = await _api.delete({'livetalk_id': id, 'user_id': userId});
      return response.success;
    } catch (e) {
      debugPrint('[LiveTalkDetail] 삭제 예외: $e');
      return false;
    }
  }
}
