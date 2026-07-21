import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_fleamarket.dart';
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
