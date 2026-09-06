import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_fleamarket.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:get/get.dart';

class FleamarketMyActivityItem {
  final int fleaId;
  final int userId;
  final String title;
  final int price;

  FleamarketMyActivityItem({
    required this.fleaId,
    required this.userId,
    required this.title,
    required this.price,
  });

  factory FleamarketMyActivityItem.fromJson(Map<String, dynamic> json) {
    return FleamarketMyActivityItem(
      fleaId: json['flea_id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      price: json['price'] ?? 0,
    );
  }
}

class FleamarketMyActivityViewModel extends GetxController {

  RxList<FleamarketMyActivityItem> recentViewed = <FleamarketMyActivityItem>[].obs;
  RxList<FleamarketMyActivityItem> favoriteList = <FleamarketMyActivityItem>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 로그인 없이는 개인 활동 이력이 없고, 백엔드도 user_id 없이는 400을 반환하므로
    // 비로그인 상태에서는 아예 조회하지 않는다(최근 본 상품/찜 목록 섹션은 빈 목록으로 자연히 숨겨짐).
    final int? userId = Get.find<UserViewModel>().user.user_id;
    if (userId != null) {
      fetchMyActivity(userId: userId);
    }

    // 새로고침 직후에는 AuthCheckViewModelWeb의 조용한 재로그인 확인이 아직 끝나지
    // 않아 위 시점엔 userId가 null일 수 있다. 인증 확인이 완료되는 순간을 기다렸다가
    // 다시 조회해서, 로그인 상태인데도 최근 본 상품/찜 목록이 빈 채로 남는 걸 막는다.
    final authVm = Get.find<AuthCheckViewModelWeb>();

    // 인증 확인이 아직 진행 중이면 조회를 시작할지조차 모르는 상태다. 이때 isLoading이
    // false면 화면이 "없어요"를 먼저 보여줬다가 데이터로 바뀌어 깜빡인다.
    // 확인이 끝날 때까지는 로딩으로 두고, 게스트로 확정되면 그때 내린다.
    if (authVm.status == WebAuthStatus.checking) {
      isLoading.value = true;
    }

    ever(authVm.statusRx, (status) {
      if (status == WebAuthStatus.checking) return;
      if (status == WebAuthStatus.authenticated) {
        final int? authedUserId = Get.find<UserViewModel>().user.user_id;
        if (authedUserId != null) {
          fetchMyActivity(userId: authedUserId);
          return;
        }
      }
      // 게스트 확정(또는 로그인됐지만 user_id가 없는 예외 상황) — 조회하지 않으므로
      // 여기서 로딩을 내려야 스켈레톤이 빈 상태로 넘어간다.
      isLoading.value = false;
    });
  }

  Future<void> fetchMyActivity({required int userId}) async {
    isLoading.value = true;

    try {
      ApiResponse response = await FleamarketAPI().fetchMyActivity(userId: userId);

      if (response.success) {
        final data = response.data as Map<String, dynamic>;

        recentViewed.value = (data['recent_viewed'] as List<dynamic>)
            .map((item) => FleamarketMyActivityItem.fromJson(item))
            .toList();

        favoriteList.value = (data['favorite_list'] as List<dynamic>)
            .map((item) => FleamarketMyActivityItem.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('[MyActivity] 조회 실패: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
