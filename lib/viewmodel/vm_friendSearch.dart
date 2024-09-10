import 'package:com.snowlive/api/api_friendDetail.dart';
import 'package:com.snowlive/model/m_friendDetail.dart';
import 'package:com.snowlive/model/m_friendsTalk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import '../api/ApiResponse.dart';
import '../api/api_friend.dart';
import '../model/m_friendCheck.dart';

class FriendSearchViewModel extends GetxController {

  var _friendDetailModel = FriendDetailModel().obs;
  var _checkFriendModel = CheckFriendModel().obs;

  final TextEditingController textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  RxString _seasonDate = ''.obs;
  var isLoading = true.obs;

  ApiResponse? response;


  dynamic get friendDetailModel => _friendDetailModel.value;
  dynamic get checkFriendModel => _checkFriendModel.value;
  String get seasonDate => _seasonDate.value;

  //TODO: 친구검색 텍스트로 닉네임검색으로 변경
  Future<void> fetchSearchFriend({required int userId, required int friendUserId, required String season}) async {
    isLoading(true);
    ApiResponse response = await FriendDetailAPI().fetchFriendDetail(userId,friendUserId,season);
    await FriendDetailAPI().fetchFriendsTalkList(userId,friendUserId);
    if(response.success)
      _friendDetailModel.value = response.data as FriendDetailModel;
    if(!response.success)
      Get.snackbar('Error', '데이터 로딩 실패');
    isLoading(false);
  }


  Future<void> sendFriendRequest(body) async {
    isLoading(true);
    ApiResponse response = await FriendAPI().addFriend(body);
    if(response.success)
      Get.snackbar('친구신청 성공', '상대방이 수락하면 친구로 등록됩니다.');
    if(!response.success)
      Get.snackbar('앗!', '${response.error['error']}');
    isLoading(false);
  }

  Future<void> checkFriendRelationship(dynamic body) async {
    isLoading(true);
    // API 호출
    ApiResponse response = await FriendAPI().checkFriendRelationship(body);
    // 응답이 성공적일 경우
    if (response.success) {
      // 응답 데이터를 CheckFriendModel에 매핑
      _checkFriendModel.value = CheckFriendModel.fromJson(response.data);
    } else {
      print('Failed to check friend relationship: ${response.error}');
    }
    // 로딩 상태 해제
    isLoading(false);
  }


}

