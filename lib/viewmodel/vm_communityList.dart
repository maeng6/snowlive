import 'package:get/get.dart';
import '../api/api_community.dart';
import '../model/m_communityList.dart';

class CommunityListViewModel extends GetxController {
  var isLoading = true.obs;
  var communityList = <Community>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  // 커뮤니티 목록 불러오기
  Future<void> fetchCommunityList({
    String? categoryMain,
    String? categorySub,
    String? categorySub2,
    String? findUserId,
    String? searchQuery,
    String? userId,
  }) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().fetchCommunityList(
        categoryMain: categoryMain,
        categorySub: categorySub,
        categorySub2: categorySub2,
        findUserId: findUserId,
        searchQuery: searchQuery,
        userId: userId,
      );

      if (response.success) {
        final CommunityListResponse communityResponse = CommunityListResponse.fromJson(response.data);
        communityList.value = communityResponse.results ?? [];
      } else {
        print('Failed to load community list: ${response.error}');
      }
    } catch (e) {
      print('Error fetching community list: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
