import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';
import '../api/api_friend.dart';
import '../model/m_bestFriendListModel.dart';
import '../model/m_blockUserList.dart';
import '../model/m_requestFriendList.dart';

class FriendListViewModel extends GetxController {
  var isLoading = true.obs;
  var _friendList = <FriendListModel>[].obs;
  var _friendsRequestList = <RequestFriendList>[].obs;
  var _myRequestList = <RequestFriendList>[].obs;
  var _blockUserList = <UserBlockList>[].obs;

  List<FriendListModel> get friendList => _friendList;
  List<RequestFriendList> get friendsRequestList => _friendsRequestList;
  List<RequestFriendList> get myRequestList => _myRequestList;
  List<UserBlockList> get blockUserList => _blockUserList;

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

  Future<void> fetchFriendRequestList(user_id) async {


    try {

      final response_friendsRequest = await FriendAPI().fetchFriendRequests(friend_user_id: user_id);
      final response_myRequest = await FriendAPI().fetchFriendRequests(my_user_id: user_id);

      if (response_friendsRequest.success) {
        final friendsRequestListResponse = RequestFriendListResponse.fromJson(response_friendsRequest.data!);
        _friendsRequestList.value = friendsRequestListResponse.requests ?? [];
      } else {
        print('Failed to load friendsRequest: ${response_friendsRequest.error}');
      }
      if (response_myRequest.success) {
        final myRequestListResponse = RequestFriendListResponse.fromJson(response_myRequest.data!);
        _myRequestList.value = myRequestListResponse.requests ?? [];
      } else {
        print('Failed to load myRequest: ${response_friendsRequest.error}');
      }
    } catch (e) {
      print('Error fetching data request: $e');
    } finally {
    }
  }

  Future<void> fetchBlockUserList() async {
    try {
      final response_request = await FriendAPI().fetchBlcokListRequests(user_id: _userViewModel.user.user_id);

      if (response_request.success) {
        // 응답 데이터가 List<dynamic> 형식으로 올바르게 전달되어야 함
        final List<dynamic> responseData = response_request.data as List<dynamic>;
        final userBlockListResponse = UserBlockListResponse.fromJson(responseData);
        _blockUserList.value = userBlockListResponse.blocks; // blocks를 직접 사용
      } else {
        print('Failed to load data: ${response_request.error}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }





}
