import 'package:get/get.dart';
import '../api/api_community.dart';
import '../model/m_comment_community.dart';
import '../model/m_communityDetail.dart';
import '../util/util_1.dart';

class CommunityDetailViewModel extends GetxController {
  var isLoading = true.obs;
  var _communityDetail = CommunityDetail().obs;
  var commentsList = <CommentModelCommunity>[].obs; // 댓글 목록
  var repliesList = <Reply>[].obs; // 답글 목록
  RxString _time = ''.obs;

  CommunityDetail get communityDetail => _communityDetail.value;
  String get time => _time.value;

  @override
  void onInit() {
    super.onInit();
  }

  void fetchCommunityDetailFromList({
    required var communityDetail
  }) {
    _communityDetail.value = CommunityDetail.fromCommunityModel(communityDetail);
    _time.value = GetDatetime().getAgoString(_communityDetail.value.uploadTime!);
  }


  // 커뮤니티 세부 사항 불러오기
  Future<void> fetchCommunityDetail(int communityId, {String? userId}) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().fetchCommunityDetails(communityId, userId: userId);

      if (response.success) {
        _communityDetail.value = CommunityDetail.fromJson(response.data!);
      } else {
        print('Failed to load community detail: ${response.error}');
      }
    } catch (e) {
      print('Error fetching community detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 커뮤니티 업데이트
  Future<void> updateCommunityPost(int communityId, Map<String, dynamic> updateData) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().updateCommunity(communityId, updateData);

      if (response.success) {
        print('Community post updated successfully');
      } else {
        print('Failed to update community post: ${response.error}');
      }
    } catch (e) {
      print('Error updating community post: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 커뮤니티 삭제하기
  Future<void> deleteCommunityPost(int communityId, String userId) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().deleteCommunity(communityId, userId);

      if (response.success) {
        print('Community post deleted successfully');
      } else {
        print('Failed to delete community post: ${response.error}');
      }
    } catch (e) {
      print('Error deleting community post: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 댓글 생성하기
  Future<void> createComment(Map<String, dynamic> commentData) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().createComment(commentData);

      if (response.success) {
        print('Comment created successfully');
      } else {
        print('Failed to create comment: ${response.error}');
      }
    } catch (e) {
      print('Error creating comment: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 댓글 목록 불러오기
  Future<void> fetchComments(int communityId, {String? userId}) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().fetchComments(communityId, userId: userId);

      if (response.success) {
        final CommentResponseCommunity commentResponse = CommentResponseCommunity.fromJson(response.data!);
        commentsList.value = commentResponse.results ?? [];
      } else {
        print('Failed to load comments: ${response.error}');
      }
    } catch (e) {
      print('Error fetching comments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 댓글 수정하기
  Future<void> updateComment(int commentId, Map<String, dynamic> updateData) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().updateComment(commentId, updateData);

      if (response.success) {
        print('Comment updated successfully');
      } else {
        print('Failed to update comment: ${response.error}');
      }
    } catch (e) {
      print('Error updating comment: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 댓글 삭제하기
  Future<void> deleteComment(int commentId, String userId) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().deleteComment(commentId, userId);

      if (response.success) {
        print('Comment deleted successfully');
        commentsList.removeWhere((comment) => comment.commentId == commentId);
      } else {
        print('Failed to delete comment: ${response.error}');
      }
    } catch (e) {
      print('Error deleting comment: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 답글 생성하기
  Future<void> createReply(Map<String, dynamic> replyData) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().createReply(replyData);

      if (response.success) {
        print('Reply created successfully');
      } else {
        print('Failed to create reply: ${response.error}');
      }
    } catch (e) {
      print('Error creating reply: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 답글 목록 불러오기
  Future<void> fetchReplies(int commentId, {String? userId}) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().fetchReplies(commentId, userId: userId);

      if (response.success) {
        final List<Reply> fetchedReplies = (response.data as List<dynamic>)
            .map((reply) => Reply.fromJson(reply))
            .toList();
        repliesList.value = fetchedReplies;
      } else {
        print('Failed to load replies: ${response.error}');
      }
    } catch (e) {
      print('Error fetching replies: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 답글 수정하기
  Future<void> updateReply(int replyId, Map<String, dynamic> updateData) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().updateReply(replyId, updateData);

      if (response.success) {
        print('Reply updated successfully');
      } else {
        print('Failed to update reply: ${response.error}');
      }
    } catch (e) {
      print('Error updating reply: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 답글 삭제하기
  Future<void> deleteReply(int replyId, String userId) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().deleteReply(replyId, userId);

      if (response.success) {
        print('Reply deleted successfully');
        repliesList.removeWhere((reply) => reply.replyId == replyId);
      } else {
        print('Failed to delete reply: ${response.error}');
      }
    } catch (e) {
      print('Error deleting reply: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
