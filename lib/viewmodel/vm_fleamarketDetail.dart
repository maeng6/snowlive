import 'package:com.snowlive/model/m_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/ApiResponse.dart';
import '../api/api_fleamarket.dart';
import '../model/m_comment_flea.dart';
import '../util/util_1.dart';

class FleamarketDetailViewModel extends GetxController {
  var isLoading = true.obs;
  var _fleamarketDetail = FleamarketDetailModel().obs;
  var _commentsList = <CommentModel_flea>[].obs;
  var _nextPageUrl_comments = ''.obs;
  var _previousPageUrl_comments = ''.obs;
  RxInt _currentIndex = 0.obs;
  var fleaId = 0;
  RxString _fleamarketCommentsInputText=''.obs;
  RxBool isCommentButtonEnabled = false.obs;

  FleamarketDetailModel get fleamarketDetail => _fleamarketDetail.value;
  List<CommentModel_flea> get commentsList => _commentsList;
  String get nextPageUrl_comments => _nextPageUrl_comments.value;
  String get previousPageUrl_comments => _previousPageUrl_comments.value;
  int get currentIndex => _currentIndex.value;
  String get fleamarketCommentsInputText => _fleamarketCommentsInputText.value;


  UserViewModel _userViewModel = Get.find<UserViewModel>();

  final TextEditingController textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Fleamarket ID 설정
  void setFleaId(int id) {
    fleaId = id;
  }

  @override
  void onInit() async {
    await fetchFleamarketDetail(userId: _userViewModel.user.user_id ,fleamarketId: fleaId);
    await fetchFleamarketComments(fleaId: fleaId,userId: _userViewModel.user.user_id);

    textEditingController.addListener(() {
      if (textEditingController.text.trim().isNotEmpty) {
        isCommentButtonEnabled(true);
      } else {
        isCommentButtonEnabled(false);
      }
    });

    super.onInit();
  }

  @override
  void onClose() {
    textEditingController.dispose(); // 메모리 누수를 방지하기 위해 컨트롤러 해제
    super.onClose();
  }


  // Fleamarket detail 관련
  Future<void> fetchFleamarketDetail({
    required int fleamarketId,
    required int userId,
  }) async {
    isLoading(true);
    try {
      final response = await FleamarketAPI().detailFleamarket(fleamarketId: fleamarketId, userId: userId);
      if (response.success) {
        _fleamarketDetail.value = FleamarketDetailModel.fromJson(response.data!);
        print('user_id   :     ${_fleamarketDetail.value.userInfo}');
      } else {
        print('Failed to load data: ${response.error}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchFleamarketDetailForUpdateStatus({
    required int fleamarketId,
    required int userId,
  }) async {
    try {
      final response = await FleamarketAPI().detailFleamarket(fleamarketId: fleamarketId, userId: userId);
      if (response.success) {
        _fleamarketDetail.value = FleamarketDetailModel.fromJson(response.data!);
        print('user_id   :     ${_fleamarketDetail.value.userInfo}');
      } else {
        print('Failed to load data: ${response.error}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchFleamarketComments({
    required int fleaId,
    required int userId,
    String? url,
  }) async {
    isLoading(true);
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
      isLoading(false);
    }
  }

  Future<void> fetchFleamarketCommentsInDetailView({
    required int fleaId,
    required int userId,
    String? url,
  }) async {
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
    required String newStatus, // 새 상태를 파라미터로 받음
  }) async {

    try {
      // ViewModel에 저장된 기존의 플리마켓 상세 정보를 사용하여 body 생성
      FleamarketDetailModel existingDetail = fleamarketDetail;

      // 기존 데이터를 모두 포함한 body 생성, 새로운 상태값만 변경
      Map<String, dynamic> body = {
        "user_id": existingDetail.userInfo!.userId,
        "product_name": existingDetail.productName,
        "category_main": existingDetail.categoryMain,
        "category_sub": existingDetail.categorySub,
        "price": existingDetail.price,
        "negotiable": existingDetail.negotiable,
        "method": existingDetail.method,
        "spot": existingDetail.spot,
        "sns_url": existingDetail.snsUrl,
        "title": existingDetail.title,
        "description": existingDetail.description,
        "status": newStatus, // 새로운 상태값 설정
        "photos": existingDetail.photos!.map((photo) => {
          "display_order": photo.displayOrder,
          "url_flea_photo": photo.urlFleaPhoto,
        }).toList(), // 기존 사진 정보 포함
      };

      // updateFleamarket API 호출
      ApiResponse response = await FleamarketAPI().updateStatus(
        fleamarketId,
        body,
      );

      // 요청이 성공했는지 확인
      if (response.success) {
        print('상태 업데이트 완료');
        // 상태가 업데이트되면 ViewModel의 상태도 업데이트
        _fleamarketDetail.value = FleamarketDetailModel(
          fleaId: existingDetail.fleaId,
          productName: existingDetail.productName,
          categoryMain: existingDetail.categoryMain,
          categorySub: existingDetail.categorySub,
          price: existingDetail.price,
          negotiable: existingDetail.negotiable,
          method: existingDetail.method,
          spot: existingDetail.spot,
          snsUrl: existingDetail.snsUrl,
          title: existingDetail.title,
          description: existingDetail.description,
          status: newStatus, // 상태만 업데이트
          photos: existingDetail.photos,
          userInfo: existingDetail.userInfo,
        );
      } else {
        Get.snackbar('Error', '상태 업데이트 실패');
      }
    } catch (e) {
      // 예외 처리
      print('Error updating fleamarketStatus: $e');
      Get.snackbar('Error', '상태 업데이트 중 오류 발생');
    } finally {
    }
  }


  void updateCurrentIndex(int index) {
    _currentIndex.value = index;
  }

  Future<void> uploadFleamarketComments(body) async {
    ApiResponse response = await FleamarketAPI().createComment(body);
    if(response.success)
      print('글 업로드 완료');
    if(!response.success)
      Get.snackbar('Error', '업로드 실패');
  }

  void changeFleamarketCommentsInputText(value) {
    _fleamarketCommentsInputText.value = value;
  }



}
