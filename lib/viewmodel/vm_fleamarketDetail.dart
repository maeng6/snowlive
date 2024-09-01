import 'package:com.snowlive/model/m_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
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
  var _time = ''.obs;
  RxInt _currentIndex = 0.obs;
  var fleaId = 0;

  FleamarketDetailModel get fleamarketDetail => _fleamarketDetail.value;
  List<CommentModel_flea> get commentsList => _commentsList;
  String get nextPageUrl_comments => _nextPageUrl_comments.value;
  String get previousPageUrl_comments => _previousPageUrl_comments.value;
  String get time => _time.value;
  int get currentIndex => _currentIndex.value;

  UserViewModel _userViewModel = Get.find<UserViewModel>();

  // Fleamarket ID 설정
  void setFleaId(int id) {
    fleaId = id;
  }

  @override
  void onInit() async {
    await fetchFleamarketDetail(userId: _userViewModel.user.user_id ,fleamarketId: fleaId);
    await fetchFleamarketComments(fleaId: fleaId,userId: _userViewModel.user.user_id);
    _time.value = GetDatetime().getAgoString(_fleamarketDetail.value.uploadTime!);
    super.onInit();
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
    } finally {
      isLoading(false);
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



}
