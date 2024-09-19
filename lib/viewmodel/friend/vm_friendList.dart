import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_friend.dart';
import 'package:com.snowlive/model/m_bestFriendListModel.dart';
import 'package:com.snowlive/model/m_blockUserList.dart';
import 'package:com.snowlive/model/m_requestFriendList.dart';
import 'package:com.snowlive/model/m_searchFriend.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class FriendListViewModel extends GetxController {
  var isLoading = true.obs;
  var _friendList = <FriendListModel>[].obs;
  var _friendsRequestList = <RequestFriendList>[].obs;
  var _myRequestList = <RequestFriendList>[].obs;
  var _blockUserList = <UserBlockList>[].obs;
  var _searchFriend = SearchFriend().obs;

  final TextEditingController textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  List<FriendListModel> get friendList => _friendList;
  List<RequestFriendList> get friendsRequestList => _friendsRequestList;
  List<RequestFriendList> get myRequestList => _myRequestList;
  List<UserBlockList> get blockUserList => _blockUserList;
  SearchFriend get searchFriend => _searchFriend.value;

  UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  void onInit() async{
    super.onInit();
  }

  Future<void> fetchFriendList() async {
    try {
      final response = await FriendAPI().fetchFriendList(userId: _userViewModel.user.user_id, bestFriend: false);

      if (response.success && response.data != null) {
        print('친구리스트 불러오기 성공 & 친구 1명 이상');
        final friendListResponse = FriendListResponse.fromJson(response.data!);
        _friendList.value = friendListResponse.friends!;
      } else {
        print('친구리스트 없을 경우');
        _friendList.value = []; // 빈 리스트로 처리
      }
    } catch (e) {
      print('Error fetching data: $e');
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

  Future<void> deleteFriend(body) async {
    isLoading(true);
    ApiResponse response = await FriendAPI().deleteFriend(body);
    if (response.success) {
      Get.snackbar('친구삭제 성공', '상대방에게도 내가 친구목록에서 제외됩니다.');
      await fetchFriendList();
    } else {
      Get.snackbar('앗!', '${response.error['error']}');
    }
    isLoading(false);
  }


  Future<void> searchUser(String displayName) async {
    try {
      // API 요청
      final response = await FriendAPI().searchUser({
        "display_name": displayName,
        "requesting_user_id": _userViewModel.user.user_id.toString()
      });

      if (response.success) {
        // 응답 데이터가 단일 객체라고 가정하고 처리
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

        print(responseData);
        // SeachFriend 모델에 데이터를 매핑

        // 여기서 _blockUserList 대신 적절한 상태 변수에 searchFriend 할당
        _searchFriend.value = SearchFriend.fromJson(responseData);
        print(_searchFriend.value.displayName);
      } else {
        print('Failed to load data: ${response.error}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> resetSearchFriend() async{
    _searchFriend.value = SearchFriend(); // 새로운 객체로 초기화
  }





}
