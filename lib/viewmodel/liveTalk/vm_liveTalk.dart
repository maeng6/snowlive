import 'package:com.snowlive/api/api_liveTalk.dart';
import 'package:com.snowlive/model/m_liveTalk.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class LiveTalkViewModel extends GetxController {
  final LiveTalkAPI _api = LiveTalkAPI();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  // ============================================
  // 로딩 상태
  // ============================================
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isLoadingMyList = false.obs;
  RxBool isLoadingMoreMyList = false.obs;
  RxBool isLoadingDetail = false.obs;
  RxBool isSubmitting = false.obs;

  // ============================================
  // 게시글 목록
  // ============================================
  RxList<LiveTalk> liveTalkList = <LiveTalk>[].obs;
  RxList<LiveTalk> myLiveTalkList = <LiveTalk>[].obs;

  // 페이지네이션
  RxnString nextPageUrl = RxnString(null);
  RxnString previousPageUrl = RxnString(null);
  RxnString myNextPageUrl = RxnString(null);
  RxnString myPreviousPageUrl = RxnString(null);

  // 총 개수
  RxInt totalCount = 0.obs;
  RxInt myTotalCount = 0.obs;

  // 스크롤 컨트롤러
  ScrollController scrollController = ScrollController();
  ScrollController myScrollController = ScrollController();

  // FAB 표시 여부
  RxBool showFab = true.obs;
  RxBool showMyFab = true.obs;

  // ============================================
  // 게시글 상세
  // ============================================
  Rxn<LiveTalk> liveTalkDetail = Rxn<LiveTalk>();
  RxList<LiveTalkComment> comments = <LiveTalkComment>[].obs;

  // ============================================
  // Lifecycle
  // ============================================
  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    myScrollController.addListener(_myScrollListener);
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    myScrollController.removeListener(_myScrollListener);
    myScrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    // FAB 숨기기/표시
    if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (showFab.value) showFab.value = false;
    } else if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!showFab.value) showFab.value = true;
    }

    // 무한 스크롤
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && nextPageUrl.value != null) {
        fetchNextPage();
      }
    }
  }

  void _myScrollListener() {
    // FAB 숨기기/표시
    if (myScrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (showMyFab.value) showMyFab.value = false;
    } else if (myScrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!showMyFab.value) showMyFab.value = true;
    }

    // 무한 스크롤
    if (myScrollController.position.pixels >= myScrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMoreMyList.value && myNextPageUrl.value != null) {
        fetchMyNextPage();
      }
    }
  }

  // ============================================
  // 1. 게시글 목록 관련
  // ============================================

  /// 전체 게시글 목록 조회
  Future<void> fetchLiveTalkList() async {
    isLoading.value = true;
    try {
      final response = await _api.fetchList({
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        final listResponse = LiveTalkListResponse.fromJson(response.data);
        liveTalkList.value = listResponse.results ?? [];
        nextPageUrl.value = listResponse.next;
        previousPageUrl.value = listResponse.previous;
        totalCount.value = listResponse.count ?? 0;
      } else {
        print('❌ LiveTalk 목록 조회 실패: ${response.error}');
      }
    } catch (e) {
      print('❌ LiveTalk 목록 조회 에러: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 다음 페이지 조회
  Future<void> fetchNextPage() async {
    if (nextPageUrl.value == null || isLoadingMore.value) return;

    isLoadingMore.value = true;
    try {
      final response = await _api.fetchList(
        {'user_id': _userViewModel.user.user_id},
        url: nextPageUrl.value,
      );

      if (response.success) {
        final listResponse = LiveTalkListResponse.fromJson(response.data);
        liveTalkList.addAll(listResponse.results ?? []);
        nextPageUrl.value = listResponse.next;
        previousPageUrl.value = listResponse.previous;
      }
    } catch (e) {
      print('❌ LiveTalk 다음 페이지 조회 에러: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 내 게시글 목록 조회
  Future<void> fetchMyLiveTalkList() async {
    isLoadingMyList.value = true;
    try {
      final response = await _api.fetchMyList({
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        final listResponse = LiveTalkListResponse.fromJson(response.data);
        myLiveTalkList.value = listResponse.results ?? [];
        myNextPageUrl.value = listResponse.next;
        myPreviousPageUrl.value = listResponse.previous;
        myTotalCount.value = listResponse.count ?? 0;
      } else {
        print('❌ 내 LiveTalk 목록 조회 실패: ${response.error}');
      }
    } catch (e) {
      print('❌ 내 LiveTalk 목록 조회 에러: $e');
    } finally {
      isLoadingMyList.value = false;
    }
  }

  /// 내 게시글 다음 페이지 조회
  Future<void> fetchMyNextPage() async {
    if (myNextPageUrl.value == null || isLoadingMoreMyList.value) return;

    isLoadingMoreMyList.value = true;
    try {
      final response = await _api.fetchMyList(
        {'user_id': _userViewModel.user.user_id},
        url: myNextPageUrl.value,
      );

      if (response.success) {
        final listResponse = LiveTalkListResponse.fromJson(response.data);
        myLiveTalkList.addAll(listResponse.results ?? []);
        myNextPageUrl.value = listResponse.next;
        myPreviousPageUrl.value = listResponse.previous;
      }
    } catch (e) {
      print('❌ 내 LiveTalk 다음 페이지 조회 에러: $e');
    } finally {
      isLoadingMoreMyList.value = false;
    }
  }

  /// 목록에서 게시글 삭제
  void removeFromList(int livetalkId) {
    liveTalkList.removeWhere((item) => item.livetalkId == livetalkId);
    myLiveTalkList.removeWhere((item) => item.livetalkId == livetalkId);
  }

  /// 목록 새로고침
  Future<void> refresh() async {
    await fetchLiveTalkList();
  }

  /// 내 목록 새로고침
  Future<void> refreshMyList() async {
    await fetchMyLiveTalkList();
  }

  void _updateLiveTalkInList(int livetalkId, bool? isLiked, int? likeCount) {
    // 전체 목록에서 업데이트
    final index = liveTalkList.indexWhere((item) => item.livetalkId == livetalkId);
    if (index != -1) {
      liveTalkList[index].isLiked = isLiked;
      liveTalkList[index].likeCount = likeCount;
      liveTalkList.refresh();
    }

    // 내 목록에서 업데이트
    final myIndex = myLiveTalkList.indexWhere((item) => item.livetalkId == livetalkId);
    if (myIndex != -1) {
      myLiveTalkList[myIndex].isLiked = isLiked;
      myLiveTalkList[myIndex].likeCount = likeCount;
      myLiveTalkList.refresh();
    }
  }

  // ============================================
  // 2. 게시글 상세/CRUD
  // ============================================

  /// 게시글 상세 조회
  Future<void> fetchDetail(int livetalkId) async {
    isLoadingDetail.value = true;
    try {
      final response = await _api.fetchDetail({
        'livetalk_id': livetalkId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        liveTalkDetail.value = LiveTalk.fromJson(response.data);
        comments.value = liveTalkDetail.value?.comments ?? [];
      } else {
        print('❌ LiveTalk 상세 조회 실패: ${response.error}');
      }
    } catch (e) {
      print('❌ LiveTalk 상세 조회 에러: $e');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// 게시글 작성
  Future<LiveTalk?> create({
    required String description,
    String? imageUrl,
  }) async {
    isSubmitting.value = true;
    try {
      final body = {
        'user_id': _userViewModel.user.user_id,
        'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
      };

      final response = await _api.create(body);

      if (response.success) {
        return LiveTalk.fromJson(response.data);
      } else {
        print('❌ LiveTalk 작성 실패: ${response.error}');
        return null;
      }
    } catch (e) {
      print('❌ LiveTalk 작성 에러: $e');
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 게시글 수정
  Future<bool> updatePost({
    required int livetalkId,
    required String description,
    String? imageUrl,
  }) async {
    isSubmitting.value = true;
    try {
      final body = {
        'livetalk_id': livetalkId,
        'user_id': _userViewModel.user.user_id,
        'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
      };

      final response = await _api.update(body);

      if (response.success) {
        liveTalkDetail.value = LiveTalk.fromJson(response.data);
        return true;
      } else {
        print('❌ LiveTalk 수정 실패: ${response.error}');
        return false;
      }
    } catch (e) {
      print('❌ LiveTalk 수정 에러: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 게시글 삭제
  Future<bool> deletePost(int livetalkId) async {
    isSubmitting.value = true;
    try {
      final response = await _api.delete({
        'livetalk_id': livetalkId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        removeFromList(livetalkId);
        return true;
      } else {
        print('❌ LiveTalk 삭제 실패: ${response.error}');
        return false;
      }
    } catch (e) {
      print('❌ LiveTalk 삭제 에러: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 게시글 좋아요 토글 (목록용)
  Future<bool> toggleLike(int livetalkId) async {
    try {
      final response = await _api.toggleLike({
        'livetalk_id': livetalkId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        final likeResponse = LiveTalkLikeResponse.fromJson(response.data);
        _updateLiveTalkInList(livetalkId, likeResponse.liked, likeResponse.likeCount);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ LiveTalk 좋아요 토글 에러: $e');
      return false;
    }
  }

  /// 게시글 좋아요 토글 (상세용)
  Future<bool> toggleDetailLike() async {
    if (liveTalkDetail.value == null) return false;

    try {
      final response = await _api.toggleLike({
        'livetalk_id': liveTalkDetail.value!.livetalkId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        final likeResponse = LiveTalkLikeResponse.fromJson(response.data);
        liveTalkDetail.value!.isLiked = likeResponse.liked;
        liveTalkDetail.value!.likeCount = likeResponse.likeCount;
        liveTalkDetail.refresh();
        // 목록에도 반영
        _updateLiveTalkInList(liveTalkDetail.value!.livetalkId!, likeResponse.liked, likeResponse.likeCount);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ LiveTalk 좋아요 토글 에러: $e');
      return false;
    }
  }

  /// 게시글 신고
  Future<bool> report(int livetalkId) async {
    try {
      final response = await _api.report({
        'livetalk_id': livetalkId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        return true;
      } else {
        print('❌ LiveTalk 신고 실패: ${response.error}');
        return false;
      }
    } catch (e) {
      print('❌ LiveTalk 신고 에러: $e');
      return false;
    }
  }

  // ============================================
  // 3. 댓글 관련
  // ============================================

  /// 댓글 목록 조회
  Future<void> fetchComments(int livetalkId) async {
    try {
      final response = await _api.fetchCommentList({
        'livetalk_id': livetalkId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        comments.value = (response.data as List)
            .map((item) => LiveTalkComment.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('❌ 댓글 목록 조회 에러: $e');
    }
  }

  /// 댓글 작성
  Future<bool> createComment(int livetalkId, String content) async {
    isSubmitting.value = true;
    try {
      final response = await _api.createComment({
        'livetalk_id': livetalkId,
        'user_id': _userViewModel.user.user_id,
        'content': content,
      });

      if (response.success) {
        final newComment = LiveTalkComment.fromJson(response.data);
        comments.add(newComment);
        // 댓글 수 증가
        if (liveTalkDetail.value != null) {
          liveTalkDetail.value!.commentCount = (liveTalkDetail.value!.commentCount ?? 0) + 1;
          liveTalkDetail.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 댓글 작성 에러: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 댓글 수정
  Future<bool> updateComment(int commentId, String content) async {
    isSubmitting.value = true;
    try {
      final response = await _api.updateComment({
        'comment_id': commentId,
        'user_id': _userViewModel.user.user_id,
        'content': content,
      });

      if (response.success) {
        final index = comments.indexWhere((c) => c.commentId == commentId);
        if (index != -1) {
          comments[index] = LiveTalkComment.fromJson(response.data);
          comments.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 댓글 수정 에러: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 댓글 삭제
  Future<bool> deleteComment(int commentId) async {
    try {
      final response = await _api.deleteComment({
        'comment_id': commentId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        comments.removeWhere((c) => c.commentId == commentId);
        // 댓글 수 감소
        if (liveTalkDetail.value != null) {
          liveTalkDetail.value!.commentCount = (liveTalkDetail.value!.commentCount ?? 1) - 1;
          liveTalkDetail.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 댓글 삭제 에러: $e');
      return false;
    }
  }

  /// 댓글 좋아요 토글
  Future<bool> toggleCommentLike(int commentId) async {
    try {
      final response = await _api.toggleCommentLike({
        'comment_id': commentId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        final likeResponse = LiveTalkLikeResponse.fromJson(response.data);
        final index = comments.indexWhere((c) => c.commentId == commentId);
        if (index != -1) {
          comments[index].isLiked = likeResponse.liked;
          comments[index].likeCount = likeResponse.likeCount;
          comments.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 댓글 좋아요 토글 에러: $e');
      return false;
    }
  }

  /// 댓글 신고
  Future<bool> reportComment(int commentId) async {
    try {
      final response = await _api.reportComment({
        'comment_id': commentId,
        'user_id': _userViewModel.user.user_id,
      });

      return response.success;
    } catch (e) {
      print('❌ 댓글 신고 에러: $e');
      return false;
    }
  }

  // ============================================
  // 4. 답글 관련
  // ============================================

  /// 답글 목록 조회
  Future<List<LiveTalkReply>> fetchReplies(int commentId) async {
    try {
      final response = await _api.fetchReplyList({
        'comment_id': commentId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        return (response.data as List)
            .map((item) => LiveTalkReply.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ 답글 목록 조회 에러: $e');
      return [];
    }
  }

  /// 답글 작성
  Future<bool> createReply(int commentId, String content) async {
    isSubmitting.value = true;
    try {
      final response = await _api.createReply({
        'comment_id': commentId,
        'user_id': _userViewModel.user.user_id,
        'content': content,
      });

      if (response.success) {
        final newReply = LiveTalkReply.fromJson(response.data);
        // 해당 댓글의 replies에 추가
        final commentIndex = comments.indexWhere((c) => c.commentId == commentId);
        if (commentIndex != -1) {
          comments[commentIndex].replies ??= [];
          comments[commentIndex].replies!.add(newReply);
          comments[commentIndex].replyCount = (comments[commentIndex].replyCount ?? 0) + 1;
          comments.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 답글 작성 에러: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 답글 수정
  Future<bool> updateReply(int replyId, String content) async {
    isSubmitting.value = true;
    try {
      final response = await _api.updateReply({
        'reply_id': replyId,
        'user_id': _userViewModel.user.user_id,
        'content': content,
      });

      if (response.success) {
        // 답글 업데이트
        for (var comment in comments) {
          final replyIndex = comment.replies?.indexWhere((r) => r.replyId == replyId) ?? -1;
          if (replyIndex != -1) {
            comment.replies![replyIndex] = LiveTalkReply.fromJson(response.data);
            comments.refresh();
            break;
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 답글 수정 에러: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 답글 삭제
  Future<bool> deleteReply(int commentId, int replyId) async {
    try {
      final response = await _api.deleteReply({
        'reply_id': replyId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        final commentIndex = comments.indexWhere((c) => c.commentId == commentId);
        if (commentIndex != -1) {
          comments[commentIndex].replies?.removeWhere((r) => r.replyId == replyId);
          comments[commentIndex].replyCount = (comments[commentIndex].replyCount ?? 1) - 1;
          comments.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 답글 삭제 에러: $e');
      return false;
    }
  }

  /// 답글 좋아요 토글
  Future<bool> toggleReplyLike(int replyId) async {
    try {
      final response = await _api.toggleReplyLike({
        'reply_id': replyId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        final likeResponse = LiveTalkLikeResponse.fromJson(response.data);
        // 답글 업데이트
        for (var comment in comments) {
          final replyIndex = comment.replies?.indexWhere((r) => r.replyId == replyId) ?? -1;
          if (replyIndex != -1) {
            comment.replies![replyIndex].isLiked = likeResponse.liked;
            comment.replies![replyIndex].likeCount = likeResponse.likeCount;
            comments.refresh();
            break;
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 답글 좋아요 토글 에러: $e');
      return false;
    }
  }

  /// 답글 신고
  Future<bool> reportReply(int replyId) async {
    try {
      final response = await _api.reportReply({
        'reply_id': replyId,
        'user_id': _userViewModel.user.user_id,
      });

      return response.success;
    } catch (e) {
      print('❌ 답글 신고 에러: $e');
      return false;
    }
  }

  // ============================================
  // 5. 유틸리티
  // ============================================

  /// 상세 상태 초기화
  void resetDetail() {
    liveTalkDetail.value = null;
    comments.clear();
    isLoadingDetail.value = false;
    isSubmitting.value = false;
  }

  /// 전체 상태 초기화
  void resetAll() {
    liveTalkList.clear();
    myLiveTalkList.clear();
    nextPageUrl.value = null;
    previousPageUrl.value = null;
    myNextPageUrl.value = null;
    myPreviousPageUrl.value = null;
    totalCount.value = 0;
    myTotalCount.value = 0;
    resetDetail();
  }
}
