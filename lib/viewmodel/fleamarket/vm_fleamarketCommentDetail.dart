import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_fleamarket.dart';
import 'package:com.snowlive/model/m_comment_flea.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FleamarketCommentDetailViewModel extends GetxController {
  var isLoading = true.obs;
  var isLoading_indicator = true.obs;
  var _commentModel_flea = CommentModel_flea().obs;
  RxString _fleamarketRepliesInputText=''.obs;
  RxBool isReplyButtonEnabled = false.obs;
  RxString _time = ''.obs;
  RxBool _isSecret = false.obs;
  RxBool isCommentButtonEnabled = false.obs;

  CommentModel_flea get commentModel_flea => _commentModel_flea.value;
  String get fleamarketCommentsInputText => _fleamarketRepliesInputText.value;
  String get time => _time.value;
  bool get isSecret => _isSecret.value;

  ScrollController get scrollController => _scrollController;
  ScrollController _scrollController = ScrollController();

  UserViewModel _userViewModel = Get.find<UserViewModel>();

  final TextEditingController textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

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

  Future<void> fetchFleamarketCommentDetail({
    required int commentId
  }) async {
    isLoading(true);
    try {
      final response = await FleamarketAPI().fetchComment(commentId: commentId);
      if (response.success) {
        _commentModel_flea.value = CommentModel_flea.fromJson(response.data!);
        _time.value = GetDatetime().getAgoString(_commentModel_flea.value.uploadTime!);
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

  Future<void> reportComment(Map<String, dynamic> body) async {
    // 로딩 상태를 true로 설정
    isLoading(true);
    try {
      // reportFleamarket API 호출
      ApiResponse response = await FleamarketAPI().reportComment(body);

      // 요청이 성공했는지 확인
      if (response.success) {
        print('댓글 Report 완료');
      } else {
        // 실패 시 오류 메시지 표시
        Get.snackbar('Error', '댓글 Report 실패');
      }
    } catch (e) {
      // 예외 처리
      print('Error reporting comment: $e');
      Get.snackbar('Error', '리포트 중 오류 발생');
    } finally {
      // 로딩 상태를 false로 설정
      isLoading(false);
    }
  }

  Future<void> reportReply(Map<String, dynamic> body) async {
    // 로딩 상태를 true로 설정
    isLoading(true);
    try {
      ApiResponse response = await FleamarketAPI().reportReply(body);

      if (response.success) {
        if(response.data['message']=='Reply has been reported.') {
          CustomFullScreenDialog.cancelDialog();
          Get.snackbar('신고 완료', '신고 내역이 접수되었습니다.');
        }
        if(response.data['message']=='You have already reported this reply.'){
          CustomFullScreenDialog.cancelDialog();
          Get.snackbar('신고 중복', '이미 신고한 글입니다.');
        }
      }
    } catch (e) {
      // 예외 처리
      CustomFullScreenDialog.cancelDialog();
      print('Error reporting reply: $e');
      Get.snackbar('Error', '리포트 중 오류 발생');
    } finally {
      // 로딩 상태를 false로 설정
      isLoading(false);
    }
  }

  Future<void> deleteComment({
    required int commentId,
    required int userId,
  }) async {
    // 로딩 상태를 true로 설정
    isLoading(true);
      ApiResponse response = await FleamarketAPI().deleteComment(
        userId: userId,
        commentId: commentId,
      );

      // 요청이 성공했는지 확인
      if (response.success) {
        print('Fleamarket 삭제 완료');
      } else {
        // 실패 시 오류 메시지 표시
        Get.snackbar('Error', '게시물 삭제 실패');
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
      ApiResponse response = await FleamarketAPI().updateComment(
        body: body,
        commentId: commentId,
      );
      // 요청이 성공했는지 확인
      if (response.success) {
        print('Comment 업데이트 완료');
        // 추가적인 작업이 필요하다면 여기에 추가
        // 예: 데이터 업데이트, 화면 갱신 등
      } else {
        // 실패 시 오류 메시지 표시
        Get.snackbar('Error', 'Comment 업데이트 실패');
      }
    } catch (e) {
      // 예외 처리
      print('Error updating Comment: $e');
      Get.snackbar('Error', 'Comment 업데이트 중 오류 발생');
    } finally {
      // 로딩 상태를 false로 설정
      isLoading(false);
    }
  }

  Future<void> uploadFleamarketReply(body) async {
    ApiResponse response = await FleamarketAPI().createReply(body);
    if(response.success)
      _commentModel_flea.value = CommentModel_flea.fromJson(response.data!);
      print('답글 업로드 완료');
    if(!response.success)
      Get.snackbar('Error', '답글 업로드 실패');
  }

  Future<void> updateFleamarketReply({required replyID, required body}) async {
    ApiResponse response = await FleamarketAPI().updateReply(replyID, body);
    if(response.success)
      // _scrollController.jumpTo(0);
      print('답글 수정 완료');
    if(!response.success)
      Get.snackbar('Error', '답글 수정 실패');
  }

  Future<void> deleteFleamarketReply({required replyID, required userID}) async {
    ApiResponse response = await FleamarketAPI().deleteReply(replyID, userID);
    if(response.success)
      // _scrollController.jumpTo(0);
      print('답글 삭제 완료');
    if(!response.success)
      Get.snackbar('Error', '답글 삭제 실패');
  }

  void changeFleamarketCommentDetailInputText(value) {
    _fleamarketRepliesInputText.value = value;
  }

  void changeSecret() {
    _isSecret.value = !_isSecret.value;
  }


}




