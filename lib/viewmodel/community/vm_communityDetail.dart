import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_community.dart';
import 'package:com.snowlive/model/m_comment_community.dart';
import 'package:com.snowlive/model/m_communityDetail.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class CommunityDetailViewModel extends GetxController {
  var isLoading = true.obs;
  var _communityDetail = CommunityDetailModel().obs;
  var repliesList = <Reply>[].obs; // 답글 목록
  var _commentsList = <CommentModel_community>[].obs;// 댓글 목록
  var _nextPageUrl_comments = ''.obs;
  var _previousPageUrl_comments = ''.obs;
  RxString _time = ''.obs;
  var isLoading_indicator = true.obs;
  ScrollController _scrollController = ScrollController();
  ScrollController _scrollController_comment = ScrollController();
  Rx<quill.QuillController>? _quillController;
  final formKey = GlobalKey<FormState>();
  final TextEditingController textEditingController = TextEditingController();
  RxString _communityCommentsInputText=''.obs;
  RxBool isCommentButtonEnabled = false.obs;


  CommunityDetailModel get communityDetail => _communityDetail.value;
  String get time => _time.value;
  List<CommentModel_community> get commentsList => _commentsList;
  String get nextPageUrl_comments => _nextPageUrl_comments.value;
  String get previousPageUrl_comments => _previousPageUrl_comments.value;
  ScrollController get scrollController => _scrollController;
  ScrollController get scrollController_comment => _scrollController_comment;
  quill.QuillController get quillController => _quillController!.value;
  String get communityCommentsInputText => _communityCommentsInputText.value;

  @override
  void onInit() {
    super.onInit();


    textEditingController.addListener(() {
      if (textEditingController.text.trim().isNotEmpty) {
        isCommentButtonEnabled(true);
      } else {
        isCommentButtonEnabled(false);
      }
    });
    _scrollController = ScrollController()
      ..addListener(_scrollListener);

  }

  Future<void> _scrollListener() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      //await fetchNextPage_total();
    }
  }

  // 커뮤니티 세부 사항 불러오기(목록에서)
  void fetchCommunityDetailFromList({
    required var community,
  }) {
    _communityDetail.value = CommunityDetailModel.fromCommunityModel(community);
    final document = _communityDetail.value.description;

    // 초기화 여부 확인 후 QuillController 생성
    if (_quillController == null) {
      _quillController = Rx<quill.QuillController>(quill.QuillController.basic());
    }

    _quillController!.value = quill.QuillController(
      document: document!,
      selection: TextSelection.collapsed(offset: 0),
      readOnly: true,
    );

    _time.value = GetDatetime().getAgoString(_communityDetail.value.uploadTime!);
  }

  // 커뮤니티 세부 사항 불러오기(API로)
  Future<void> fetchCommunityDetail(int communityId, int userId) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().fetchCommunityDetails(communityId, userId.toString());

      if (response.success) {
        _communityDetail.value = CommunityDetailModel.fromJson(response.data!);
        final document = _communityDetail.value.description;

        // 초기화 여부 확인 후 QuillController 생성
        if (_quillController == null) {
          _quillController = Rx<quill.QuillController>(quill.QuillController.basic());
        }

        _quillController!.value = quill.QuillController(
          document: document!,
          selection: TextSelection.collapsed(offset: 0),
        );
        _time.value = GetDatetime().getAgoString(_communityDetail.value.uploadTime!);

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
  Future<void> deleteCommunityPost(int communityId, int userId) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().deleteCommunity(communityId, userId.toString());
      await deleteFolder('community', communityId.toString());

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

  Future<void> addViewerCommunity(int communityId, Map<String, dynamic> userId) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().addView(communityId, userId);

      if (response.success) {
      } else {
        print('Failed to addview community post: ${response.error}');
      }
    } catch (e) {
      print('Error adding view community post: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 커뮤니티 신고하기
  Future<void> reportCommunity({required userId, required communityId}) async {
    isLoading(true);
    try {
      ApiResponse response = await CommunityAPI().reportCommunity({
        "user_id" : userId.toString(),    //필수 - 신고자(나)
        "community_id" : communityId.toString()    //필수 - 신고글id
      });

      if (response.success) {
        print('Report 완료');
      } else {
        Get.snackbar('Error', '리포트 실패');
      }
    } catch (e) {
      print('Error reporting fleamarket: $e');
      Get.snackbar('Error', '리포트 중 오류 발생');
    } finally {
      isLoading(false);
    }
  }

  // 댓글 생성하기
  Future<void> createComment(Map<String, dynamic> body) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().createComment(body);

      if (response.success) {
        final CommentResponseCommunity commentResponse = CommentResponseCommunity.fromJson_comment(response.data!);
        _commentsList.value = commentResponse.results??[];
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
  Future<void> fetchCommunityComments({
    required int communityId,
    required int userId,
    required bool? isLoading_indi,
    String? url,
  }) async {
    isLoading_indicator(isLoading_indi);
    try {
      final response = await CommunityAPI().fetchComments(
          userId: userId,
          communityId: communityId,
          url: url
      );

      if (response.success) {
        final CommentResponseCommunity commentResponse = CommentResponseCommunity.fromJson(response.data!);
        await addViewerCommunity(communityId, {
          "user_id":userId.toString()
        });
        if (url == null) {
          _commentsList.value = commentResponse.results ?? [];
        } else {
          _commentsList.addAll(commentResponse.results ?? []);
        }
        _nextPageUrl_comments.value = commentResponse.next ?? '';
        _previousPageUrl_comments.value = commentResponse.previous ?? '';
      } else {
        print('Failed to load comments: ${response.error}');
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }finally{
      isLoading_indicator(false);
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
  Future<void> deleteComment(int commentId, int userId) async {
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

  void changeCommunityCommentsInputText(value) {
    _communityCommentsInputText.value = value;
  }
}
