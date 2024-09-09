import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';
import '../api/api_friend.dart';
import '../model/m_bestFriendListModel.dart';
import '../model/m_requestFriendList.dart';

class FriendListViewModel extends GetxController {
  var isLoading = true.obs;
  var _friendList = <FriendListModel>[].obs;
  var _requestFriendList = <RequestFriendList>[].obs;

  List<FriendListModel> get friendList => _friendList;
  List<RequestFriendList> get requestFriendList => _requestFriendList;

  UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  void onInit() async{
    super.onInit();
  }

  Future<void> fetchFriendList() async {

    try {
      final response = await FriendAPI().fetchFriendList(userId: _userViewModel.user.user_id, bestFriend: false);

      if (response.success) {
        final friendListResponse = FriendListResponse.fromJson(response.data!);
        _friendList.value = friendListResponse.friends ?? [];
      } else {
        print('Failed to load data: ${response.error}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
    }

  }

  Future<void> fetchFriendRequestList() async {

    try {
      final response = await FriendAPI().fetchFriendRequests(receiveUserId: _userViewModel.user.user_id);

      if (response.success) {
        final requestFriendListResponse = RequestFriendListResponse.fromJson(response.data!);
        _requestFriendList.value = requestFriendListResponse.requests ?? [];
      } else {
        print('Failed to load data: ${response.error}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
    }
  }


}
