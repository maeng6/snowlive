import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_community.dart';
import 'package:com.snowlive/model/m_comment_community.dart';
import 'package:com.snowlive/model/m_communityList.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityCommentDetailViewModel extends GetxController {
  var isLoading = true.obs;
  var isLoading_indicator = true.obs;
  var _commentModel_community = CommentModel_community().obs;
  RxString _time = ''.obs;
  RxString _communityRepliesInputText=''.obs;
  RxBool isReplyButtonEnabled = false.obs;
  RxBool isCommentButtonEnabled = false.obs;
  ScrollController _scrollController = ScrollController();
  final TextEditingController textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  CommentModel_community get commentModel_community => _commentModel_community.value;
  String get time => _time.value;
  String get communityRepliesInputText => _communityRepliesInputText.value;
  ScrollController get scrollController => _scrollController;

  UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  void onInit() async {

    textEditingController.addListener(() {
      if (textEditingController.text.trim().isNotEmpty) {
        isCommentButtonEnabled(true);
      } else {
        isCommentButtonEnabled(false);
      }
    });
    _scrollController = ScrollController()
      ..addListener(_scrollListener);

    super.onInit();

  }

  Future<void> _scrollListener() async {}

  @override
  void onClose() {
    textEditingController.dispose(); // 메모리 누수를 방지하기 위해 컨트롤러 해제
    super.onClose();
  }

  Future<void> fetchCommunityCommentDetail({
    required int commentId
  }) async {
    isLoading(true);
    try {
      final response = await CommunityAPI().fetchCommentDetails(commentId);
      if (response.success) {
        _commentModel_community.value = CommentModel_community.fromJson(response.data!);
        _time.value = GetDatetime().getAgoString(_commentModel_community.value.uploadTime!);
        print("댓글 디테일 패치 완료");
      } else {
        print('Failed to load data: ${response.error}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchCommunityCommentDetailFromModel({
    required CommentModel_community commentModel_community
  }) async {
    try {
        _commentModel_community.value = CommentModel_community.fromJson_model(commentModel_community);
        _time.value = GetDatetime().getAgoString(_commentModel_community.value.uploadTime!);
        print("댓글 디테일 패치 완료");
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isLoading(false);
    }
  }


  Future<void> reportComment({required int userId, required int commentId}) async {
    isLoading(true);
    try {
      ApiResponse response = await CommunityAPI().reportComment(userId,commentId);

      if (response.success) {
        print('댓글 Report 완료');
      } else {
        Get.snackbar('Error', '댓글 Report 실패');
      }
    } catch (e) {
      print('Error reporting comment: $e');
      Get.snackbar('Error', '리포트 중 오류 발생');
    } finally {
      isLoading(false);
    }
  }

  Future<void> reportReply({required int userId, required int replyId}) async {

      ApiResponse response = await CommunityAPI().reportReply(userId: userId, replyId: replyId);
      CustomFullScreenDialog.cancelDialog();
      if (response.success) {
        if(response.data['message']=='Reply has been reported.') {
          Get.snackbar('신고 완료', '신고 내역이 접수되었습니다.');
        }
        if(response.data['message']=='You have already reported this reply.'){
          Get.snackbar('신고 중복', '이미 신고한 글입니다.');
        }
      }
  }

  Future<void> deleteComment({
    required int commentId,
    required int userId,
  }) async {
    isLoading(true);
      ApiResponse response = await CommunityAPI().deleteComment(
        commentId, userId
      );

      if (response.success) {
        print('댓글 삭제 완료');
      } else {
        Get.snackbar('Error', '댓글 삭제 실패');
      }
      isLoading(false);
  }

  Future<void> updateComment({
    required int commentId,
    required Map<String, dynamic> body,
  }) async {
    // 로딩 상태를 true로 설정
    isLoading(true);

    try {
      ApiResponse response = await CommunityAPI().updateComment(
        commentId,
        body
      );
      if (response.success) {
        print('Comment 업데이트 완료');
      } else {
        Get.snackbar('Error', 'Comment 업데이트 실패');
      }
    } catch (e) {
      print('Error updating Comment: $e');
      Get.snackbar('Error', 'Comment 업데이트 중 오류 발생');
    } finally {
      isLoading(false);
    }
  }

  Future<void> uploadCommunityReply(body) async {
    ApiResponse response = await CommunityAPI().createReply(body);
    if(response.success)
      _commentModel_community.value = CommentModel_community.fromJson(response.data!);
      print('답글 업로드 완료');
    if(!response.success)
      Get.snackbar('Error', '답글 업로드 실패');
  }

  Future<void> updateCommunityReply({required replyID, required body}) async {
    ApiResponse response = await CommunityAPI().updateReply(replyID, body);
    if(response.success)
      // _scrollController.jumpTo(0);
      print('답글 수정 완료');
    if(!response.success)
      Get.snackbar('Error', '답글 수정 실패');
  }

  Future<void> deleteCommunityReply({required replyID, required userID}) async {
    ApiResponse response = await CommunityAPI().deleteReply(replyID, userID);
    if(response.success)
      // _scrollController.jumpTo(0);
      print('답글 삭제 완료');
    if(!response.success)
      Get.snackbar('Error', '답글 삭제 실패');
  }

  void changeCommunityCommentDetailInputText(value) {
    _communityRepliesInputText.value = value;
  }


}




