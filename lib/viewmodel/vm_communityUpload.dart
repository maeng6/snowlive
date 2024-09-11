import 'package:get/get.dart';
import '../api/api_community.dart';

class CommunityUploadViewModel extends GetxController {
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
  }

  // 커뮤니티 생성하기
  Future<void> createCommunityPost(Map<String, dynamic> postData) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().createCommunityPost(postData);

      if (response.success) {
        print('Community post created successfully');
      } else {
        print('Failed to create community post: ${response.error}');
      }
    } catch (e) {
      print('Error creating community post: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
