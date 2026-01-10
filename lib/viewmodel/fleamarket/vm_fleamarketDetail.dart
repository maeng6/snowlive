import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_fleamarket.dart';
import 'package:com.snowlive/model/m_comment_flea.dart';
import 'package:com.snowlive/model/m_fleamarket_bump.dart';
import 'package:com.snowlive/model/m_fleamarketDetail.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FleamarketDetailViewModel extends GetxController {
  var isLoading = true.obs;
  var isLoading_indicator = true.obs;
  var _fleamarketDetail = FleamarketDetailModel().obs;
  var _commentsList = <CommentModel_flea>[].obs;
  var _nextPageUrl_comments = ''.obs;
  var _previousPageUrl_comments = ''.obs;
  RxInt _currentIndex = 0.obs;
  var fleamarketResponse;
  RxString _fleamarketCommentsInputText=''.obs;
  RxBool isCommentButtonEnabled = false.obs;
  RxBool _isSecret = false.obs;
  RxString _time = ''.obs;

  FleamarketDetailModel get fleamarketDetail => _fleamarketDetail.value;
  List<CommentModel_flea> get commentsList => _commentsList;
  String get nextPageUrl_comments => _nextPageUrl_comments.value;
  String get previousPageUrl_comments => _previousPageUrl_comments.value;
  int get currentIndex => _currentIndex.value;
  String get fleamarketCommentsInputText => _fleamarketCommentsInputText.value;
  String get time => _time.value;
  bool get isSecret => _isSecret.value;
  ScrollController get scrollController => _scrollController;

  ScrollController _scrollController = ScrollController();

  UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FleamarketListViewModel _fleamarketListViewModel = Get.find<FleamarketListViewModel>();

  final TextEditingController textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Fleamarket ID 설정
  void SetfleamarketResponse(var fleamarketResponse) {
    this.fleamarketResponse = fleamarketResponse;
  }

  @override
  void onInit() async {

    textEditingController.addListener(_textEditingListener);
    _scrollController = ScrollController()
      ..addListener(_scrollListener);

    super.onInit();
  }

  void _textEditingListener() {
    if (textEditingController.text.trim().isNotEmpty) {
      isCommentButtonEnabled(true);
    } else {
      isCommentButtonEnabled(false);
    }
  }

  @override
  void onClose() {
    textEditingController.removeListener(_textEditingListener);
    textEditingController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.onClose();
  }

  Future<void> _scrollListener() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      //await fetchNextPage_total();
    }





  }


  Future<void> fetchFleamarketDetailandComment({
    required var fleamarketResponse,
    required int fleaId,
    required int userId,
    String? url,
  }) async {
    isLoading(true);
    fetchFleamarketDetailFromList(fleamarketResponse: fleamarketResponse,);
    isLoading(false);
    await fetchFleamarketComments(
        fleaId: fleaId,
        userId: userId,
        isLoading_indi: true);
  }

  void fetchFleamarketDetailFromList({
    required var fleamarketResponse
  }) {
    _fleamarketDetail.value = FleamarketDetailModel.fromFleamarketModel(fleamarketResponse);
    _time.value = GetDatetime().getAgoString(_fleamarketDetail.value.uploadTime!);
  }

  Future<void> fetchFleamarketDetailFromAPI({
    required int fleamarketId,
    required int userId,
  }) async {
    // isLoading(true);
    try {
      final response = await FleamarketAPI().detailFleamarket(fleamarketId: fleamarketId, userId: userId);
      if (response.success) {
        _fleamarketDetail.value = FleamarketDetailModel.fromJson(response.data!);
        _time.value = GetDatetime().getAgoString(_fleamarketDetail.value.uploadTime!);
      } else {
        print('Failed to load data: ${response.error}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      // isLoading(false);
    }
  }

  Future<void> addViewerFleamarket({
    required int fleamarketId,
    required int userId,
  }) async {
    // isLoading(true);
    try {
      final response = await FleamarketAPI().addView(fleamarketId: fleamarketId, body: {
        "user_id":userId
      });
      if (response.success) {
        print('조회수 업데이트완료');
      } else {
        print('Failed to load data: ${response.error}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      // isLoading(false);
    }
  }


  Future<void> fetchFleamarketComments({
    required int fleaId,
    required int userId,
    required bool? isLoading_indi,
    String? url,
  }) async {
    isLoading_indicator(isLoading_indi);
    try {
      final response = await FleamarketAPI().fetchComments(
        fleaId: fleaId,
        userId: userId,
        url: url,
      );
      if (response.success) {
        final commentResponse = CommentResponse_flea.fromJson(response.data!);


        if (url == null) {
          _fleamarketDetail.value.commentList = commentResponse.results ?? [];
        } else {
          _fleamarketDetail.value.commentList!.addAll(commentResponse.results ?? []);
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

  Future<void> reportFleamarket(Map<String, dynamic> body) async {
    // 로딩 상태를 true로 설정
    isLoading(true);
    try {
      // reportFleamarket API 호출
      ApiResponse response = await FleamarketAPI().reportFleamarket(body);

      // 요청이 성공했는지 확인
      if (response.success) {
        if(response.data['message']=='Report has been submitted.') {
          CustomFullScreenDialog.cancelDialog();
          Get.snackbar('신고 완료', '신고 내역이 접수되었습니다.');
        }
        if(response.data['message']=='You have already reported this community.'){
          CustomFullScreenDialog.cancelDialog();
          Get.snackbar('신고 중복', '이미 신고한 글입니다.');
        }
      } else {
        // 실패 시 오류 메시지 표시
        Get.snackbar('Error', '리포트 실패');
      }
    } catch (e) {
      // 예외 처리
      CustomFullScreenDialog.cancelDialog();
      print('Error reporting fleamarket: $e');
      Get.snackbar('Error', '리포트 중 오류 발생');
    } finally {
      // 로딩 상태를 false로 설정
      isLoading(false);
    }
  }

  Future<void> deleteFleamarket({
    required int fleamarketId,
    required int userId,
  }) async {
    // 로딩 상태를 true로 설정
    isLoading(true);

    // deleteFleamarket API 호출
    ApiResponse response = await FleamarketAPI().deleteFleamarket(
      fleamarketId: fleamarketId,
      userId: userId,
    );
    await deleteFolder('fleamarket',fleamarketId.toString());

    // 요청이 성공했는지 확인
    if (response.success) {
      print('Fleamarket 삭제 완료');
      Get.back();
    } else {
      // 실패 시 오류 메시지 표시
      print('게시물 삭제 실패');
    }
    isLoading(false);
  }

  Future<void> updateFleamarket({
    required int fleamarketId,
    required Map<String, dynamic> body,
    required List<Map<String, dynamic>> photos,
  }) async {
    // 로딩 상태를 true로 설정
    isLoading(true);

    try {
      // updateFleamarket API 호출
      ApiResponse response = await FleamarketAPI().updateFleamarket(
        fleamarketId,
        body,
        photos,
      );

      // 요청이 성공했는지 확인
      if (response.success) {
        print('Fleamarket 업데이트 완료');
        // 추가적인 작업이 필요하다면 여기에 추가
        // 예: 데이터 업데이트, 화면 갱신 등
      } else {
        // 실패 시 오류 메시지 표시
        Get.snackbar('Error', '게시물 업데이트 실패');
      }
    } catch (e) {
      // 예외 처리
      print('Error updating fleamarket: $e');
      Get.snackbar('Error', '게시물 업데이트 중 오류 발생');
    } finally {
      // 로딩 상태를 false로 설정
      isLoading(false);
    }
  }

  Future<void> updateStatus({
    required int fleamarketId,
    required Map<String, dynamic> body,
  }) async {
    // 로딩 상태를 true로 설정
    isLoading(true);

    try {
      // updateFleamarket API 호출
      ApiResponse response = await FleamarketAPI().updateStatus(
          fleamarketId,
          body
      );

      // 요청이 성공했는지 확인
      if (response.success) {
        _fleamarketDetail.value = FleamarketDetailModel.fromJson(response.data!);
        _time.value = GetDatetime().getAgoString(_fleamarketDetail.value.uploadTime!);
        print('상태 업데이트 완료');
      } else {
        print('상태 업데이트 실패');
      }
    } catch (e) {
      // 예외 처리
      print('Error updating fleamarketStatus: $e');
      print('상태 업데이트 중 오류 발생');
    } finally {
      // 로딩 상태를 false로 설정
      isLoading(false);
    }
  }


  void updateCurrentIndex(int index) {
    _currentIndex.value = index;
  }

  void changeSecret() {
    _isSecret.value = !_isSecret.value;
  }

  Future<void> addFavoriteFleamarket({required fleamarketID,required body}) async {
    ApiResponse response = await FleamarketAPI().addFavoriteFleamarket(fleamarketId: fleamarketID, body: body);
    if(response.success)
      await fetchFleamarketDetailFromAPI(fleamarketId: fleamarketID, userId: _userViewModel.user.user_id);

    print('찜 추가 완료');
    if(!response.success)
      Get.snackbar('Error', '찜 추가 실패');
  }

  Future<void> deleteFavoriteFleamarket({required fleamarketID,required body}) async {
    ApiResponse response = await FleamarketAPI().deleteFavoriteFleamarket(fleamarketId: fleamarketID, body: body);
    if(response.success)
      await fetchFleamarketDetailFromAPI(fleamarketId: fleamarketID, userId: _userViewModel.user.user_id);

    print('찜 삭제 완료');
    if(!response.success)
      Get.snackbar('Error', '찜 삭제 실패');
  }

  Future<void> uploadFleamarketComments(body) async {
    ApiResponse response = await FleamarketAPI().createComment(body);
    if(response.success) {
      final CommentResponse_flea commentResponse_flea = CommentResponse_flea.fromJson_comment(response.data!);
      _fleamarketDetail.value.commentList = commentResponse_flea.results ?? [];
      // _scrollController.jumpTo(0);
      print('글 업로드 완료');
    }
    else {
      print('댓글 업로드 실패');
    }
  }

  Future<void> updateFleamarketComments({required commentID, required body}) async {
    ApiResponse response = await FleamarketAPI().updateComment(commentId: commentID, body:  body);
    if(response.success)

      print('글 수정 완료');
    if(!response.success)
      Get.snackbar('Error', '수정 실패');
  }

  Future<void> deleteFleamarketComments({required user_id, required comment_id}) async {
    ApiResponse response = await FleamarketAPI().deleteComment(commentId: comment_id, userId: user_id);
    if(response.success)
      // _scrollController.jumpTo(0);
      print('글 삭제 완료');
    if(!response.success)
      print('글 삭제 실패');
  }

  Future<void> reportComment(Map<String, dynamic> body) async {
    // 로딩 상태를 true로 설정
    isLoading(true);
    try {
      // reportFleamarket API 호출
      ApiResponse response = await FleamarketAPI().reportComment(body);

      // 요청이 성공했는지 확인
      if (response.success) {
        if(response.data['message']=='Comment has been reported.') {
          CustomFullScreenDialog.cancelDialog();
          Get.snackbar('신고 완료', '신고 내역이 접수되었습니다.');
        }
        if(response.data['message']=='You have already reported this comment.'){
          CustomFullScreenDialog.cancelDialog();
          Get.snackbar('신고 중복', '이미 신고한 글입니다.');
        }
      }
    } catch (e) {
      // 예외 처리
      CustomFullScreenDialog.cancelDialog();
      print('Error reporting comment: $e');
      Get.snackbar('Error', '리포트 중 오류 발생');
    } finally {
      // 로딩 상태를 false로 설정
      isLoading(false);
    }
  }

  void changeIsFavorite(bool? bool){
    _fleamarketDetail.value.isFavorite = bool;
    print(_fleamarketDetail.value.isFavorite);
  }



  void changeFleamarketCommentsInputText(value) {
    _fleamarketCommentsInputText.value = value;
  }

  /// 게시글 끌어올리기
  Future<FleamarketBumpResponse?> bumpFleamarket({required int fleaId}) async {
    final userId = _userViewModel.user.user_id;
    if (userId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return null;
    }

    try {
      CustomFullScreenDialog.showDialog();
      final response = await FleamarketAPI().bumpFleamarket(
        userId: userId,
        fleaId: fleaId,
      );
      CustomFullScreenDialog.cancelDialog();

      final bumpResponse = FleamarketBumpResponse.fromJson(
        response.success ? response.data! : response.error!,
      );

      if (response.success) {
        // 성공 시 상세 정보 새로고침
        await fetchFleamarketDetailFromAPI(fleamarketId: fleaId, userId: userId);
        // 모든 리스트 새로고침 (끌올 반영)
        _fleamarketListViewModel.onRefresh_flea_total();
        _fleamarketListViewModel.onRefresh_flea_ski();
        _fleamarketListViewModel.onRefresh_flea_board();
        _fleamarketListViewModel.onRefresh_flea_my();
        _showBumpResultDialog(
          isSuccess: true,
          message: bumpResponse.message ?? '끌어올리기 완료',
          remainingToday: bumpResponse.remainingToday,
          remainingTotal: bumpResponse.remainingTotal,
        );
      } else {
        // 실패 시 에러 메시지 표시
        _showBumpResultDialog(
          isSuccess: false,
          message: bumpResponse.error ?? '끌어올리기에 실패했습니다.',
          bumpCount: bumpResponse.bumpCount,
          dailyBumpCount: bumpResponse.dailyBumpCount,
        );
      }

      return bumpResponse;
    } catch (e) {
      CustomFullScreenDialog.cancelDialog();
      print('Error bumping fleamarket: $e');
      Get.snackbar('오류', '끌어올리기 중 오류가 발생했습니다.');
      return null;
    }
  }

  void _showBumpResultDialog({
    required bool isSuccess,
    required String message,
    int? remainingToday,
    int? remainingTotal,
    int? bumpCount,
    int? dailyBumpCount,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.info_outline,
                color: isSuccess ? Colors.green : Colors.orange,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                isSuccess ? '끌어올리기 완료' : '알림',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              if (isSuccess) ...[
                _buildInfoRow('오늘 남은 횟수', '${remainingToday ?? 0}회'),
                SizedBox(height: 8),
                _buildInfoRow('총 남은 횟수', '${remainingTotal ?? 0}회'),
              ] else ...[
                if (bumpCount != null)
                  _buildInfoRow('일일 끌올 횟수', '${bumpCount}회'),
                if (dailyBumpCount != null) ...[
                  SizedBox(height: 8),
                  _buildInfoRow('오늘 사용 횟수', '${dailyBumpCount}회'),
                ],
              ],
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? Colors.green : Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}




