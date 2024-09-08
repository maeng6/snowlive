import 'package:com.snowlive/model/m_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketList.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/ApiResponse.dart';
import '../api/api_fleamarket.dart';
import '../model/m_comment_flea.dart';
import '../util/util_1.dart';

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

  Future<void> _scrollListener() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      //await fetchNextPage_total();
    }





  }

  @override
  void onClose() {
    textEditingController.dispose(); // 메모리 누수를 방지하기 위해 컨트롤러 해제
    super.onClose();
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
        final commentResponse = CommentResponse.fromJson(response.data!);

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

  Future<void> reportFleamarket(Map<String, dynamic> body) async {
    // 로딩 상태를 true로 설정
    isLoading(true);
    try {
      // reportFleamarket API 호출
      ApiResponse response = await FleamarketAPI().reportFleamarket(body);

      // 요청이 성공했는지 확인
      if (response.success) {
        print('Report 완료');
      } else {
        // 실패 시 오류 메시지 표시
        Get.snackbar('Error', '리포트 실패');
      }
    } catch (e) {
      // 예외 처리
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

      // 요청이 성공했는지 확인
      if (response.success) {
        print('Fleamarket 삭제 완료');
      } else {
        // 실패 시 오류 메시지 표시
        Get.snackbar('Error', '게시물 삭제 실패');
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
        print('상태 업데이트 완료');
      } else {
        Get.snackbar('Error', '상태 업데이트 실패');
      }
    } catch (e) {
      // 예외 처리
      print('Error updating fleamarketStatus: $e');
      Get.snackbar('Error', '상태 업데이트 중 오류 발생');
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
      await _fleamarketListViewModel.fetchFleamarketData_total(userId: _userViewModel.user.user_id);
      await _fleamarketListViewModel.fetchFleamarketData_ski(userId: _userViewModel.user.user_id, categoryMain:'스키');
      await _fleamarketListViewModel.fetchFleamarketData_board(userId: _userViewModel.user.user_id, categoryMain:'스노보드');
      await _fleamarketListViewModel.fetchFleamarketData_my(userId: _userViewModel.user.user_id, myflea: true);
      await _fleamarketListViewModel.fetchFleamarketData_favorite(userId: _userViewModel.user.user_id, favorite_list: true);
      print('찜 추가 완료');
    if(!response.success)
      Get.snackbar('Error', '찜 추가 실패');
  }

  Future<void> deleteFavoriteFleamarket({required fleamarketID,required body}) async {
    ApiResponse response = await FleamarketAPI().deleteFavoriteFleamarket(fleamarketId: fleamarketID, body: body);
    if(response.success)
      await fetchFleamarketDetailFromAPI(fleamarketId: fleamarketID, userId: _userViewModel.user.user_id);
      await _fleamarketListViewModel.fetchFleamarketData_total(userId: _userViewModel.user.user_id);
      await _fleamarketListViewModel.fetchFleamarketData_ski(userId: _userViewModel.user.user_id, categoryMain:'스키');
      await _fleamarketListViewModel.fetchFleamarketData_board(userId: _userViewModel.user.user_id, categoryMain:'스노보드');
      await _fleamarketListViewModel.fetchFleamarketData_my(userId: _userViewModel.user.user_id, myflea: true);
      await _fleamarketListViewModel.fetchFleamarketData_favorite(userId: _userViewModel.user.user_id, favorite_list: true);
      print('찜 삭제 완료');
    if(!response.success)
      Get.snackbar('Error', '찜 삭제 실패');
  }

  Future<void> uploadFleamarketComments(body) async {
    ApiResponse response = await FleamarketAPI().createComment(body);
    if(response.success)
      // _scrollController.jumpTo(0);
      print('글 업로드 완료');
    if(!response.success)
      Get.snackbar('Error', '업로드 실패');
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
      Get.snackbar('Error', '삭제 실패');
  }

  void changeFleamarketCommentsInputText(value) {
    _fleamarketCommentsInputText.value = value;
  }
}




