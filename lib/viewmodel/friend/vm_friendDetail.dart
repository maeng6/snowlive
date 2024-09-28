import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_friend.dart';
import 'package:com.snowlive/api/api_friendDetail.dart';
import 'package:com.snowlive/model/m_friendDetail.dart';
import 'package:com.snowlive/model/m_friendsTalk.dart';
import 'package:com.snowlive/viewmodel/util/vm_imageController.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill_extensions/services/image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class FriendDetailViewModel extends GetxController {

  static const mainTabNameListConst = [
    '라이딩 통계',
    '방명록'
  ];

  static const ridingStatisticsTabNameListConst = [
    '누적 통계',
    '일간 통계'
  ];

  RxBool isSendButtonEnabled = false.obs;



  @override
  void onInit() async {
    super.onInit();

    textEditingController.addListener(() {
      if (textEditingController.text.trim().isNotEmpty) {
        isSendButtonEnabled(true);
      } else {
        isSendButtonEnabled(false);
      }
    });


    mainTabNameList = <String>[
      '라이딩 통계',
      '방명록'
    ].obs;

    ridingStatisticsTabNameList = <String>[
      '누적 통계',
      '일간 통계'
    ].obs;

    _mainTabName = mainTabNameList[0].obs;
    _ridingStatisticsTabName = ridingStatisticsTabNameList[0].obs;
    await getCurrentSeason();
  }

  late RxList<String> mainTabNameList;
  late RxList<String> ridingStatisticsTabNameList;
  late RxString _mainTabName;
  late RxString _ridingStatisticsTabName;

  var _friendDetailModel = FriendDetailModel().obs;
  RxList<FriendsTalk> _friendsTalk = <FriendsTalk>[].obs;
  var findFriendInfo = <int, Map<String, String>>{}.obs;

  final TextEditingController textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  RxBool _isEditing = false.obs;
  RxString _seasonDate = ''.obs;
  var isLoading = true.obs;
  Rx<XFile?> _imageFile = Rx<XFile?>(null);
  Rx<XFile?> _croppedFile = Rx<XFile?>(null);
  RxBool _profileImage = false.obs;
  RxString _profileImageUrl=''.obs;
  RxString _sendFriendResult=''.obs;
  RxString _seasonStartDate=''.obs;
  RxString _seasonEndDate=''.obs;
  RxString _friendsTalkInputText=''.obs;
  RxInt _selectedDailyIndex=0.obs;
  RxInt _friend_id=0.obs;
  RxMap<String, dynamic> _passCountData = <String, dynamic>{}.obs;
  RxMap<String, dynamic> _passCountTimeData = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> _barData = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> _barData2 = <Map<String, dynamic>>[].obs;

  final Rx<TextEditingController> _stateMsgController = TextEditingController().obs;
  final Rx<TextEditingController> _friendTalkController = TextEditingController().obs;
  final Rx<TextEditingController> _displayNameController = TextEditingController().obs;

  ApiResponse? response;

  final ImageController imageController = Get.put(ImageController());

  dynamic get friendDetailModel => _friendDetailModel.value;
  bool get isEditing => _isEditing.value;
  String get seasonDate => _seasonDate.value;
  TextEditingController get stateMsgController => _stateMsgController.value;
  TextEditingController get friendTalkController => _friendTalkController.value;
  TextEditingController get displayNameController => _displayNameController.value;
  XFile? get imageFile => _imageFile.value;
  XFile? get croppedFile => _croppedFile.value;
  bool get profileImage => _profileImage.value;
  String get profileImageUrl => _profileImageUrl.value;
  String get sendFriendResult => _sendFriendResult.value;
  String get mainTabName => _mainTabName.value;
  String get seasonStartDate => _seasonStartDate.value;
  String get seasonEndDate => _seasonEndDate.value;
  String get ridingStatisticsTabName => _ridingStatisticsTabName.value;
  String get friendsTalkInputText => _friendsTalkInputText.value;
  int get friend_id => _friend_id.value;
  int get selectedDailyIndex => _selectedDailyIndex.value;
  dynamic get friendsTalk => _friendsTalk.value;
  List<Map<String, dynamic>> get barData => _barData;
  List<Map<String, dynamic>> get barData2 => _barData2;
  Map<String, dynamic> get passCountData => _passCountData;
  Map<String, dynamic> get passCountTimeData => _passCountTimeData;



  void toggleIsEditing(){
    _isEditing.value = !_isEditing.value;
  }

  Future<void> fetchFriendDetailInfo({required int userId, required int friendUserId, required String season}) async {
    isLoading(true);
    ApiResponse response = await FriendDetailAPI().fetchFriendDetail(userId,friendUserId,season);
    ApiResponse response_talk = await FriendDetailAPI().fetchFriendsTalkList(userId,friendUserId);
    if(response.success)
      _friendDetailModel.value = response.data as FriendDetailModel;
    // 리스트 형식으로 변환
    List<FriendsTalk> talkList = (response_talk.data as List)
        .map((item) => FriendsTalk.fromJson(item))
        .toList();
    _friendsTalk.value = talkList;
    if(!response.success)
      Get.snackbar('Error', '데이터 로딩 실패');
    isLoading(false);
  }

  Future<void> fetchFriendsTalkList({required int userId, required int friendUserId}) async {
    isLoading(true);
    ApiResponse response_talk = await FriendDetailAPI().fetchFriendsTalkList(userId,friendUserId);
    if (response_talk.success) {
      // 리스트 형식으로 변환
      List<FriendsTalk> talkList = (response_talk.data as List)
          .map((item) => FriendsTalk.fromJson(item))
          .toList();
      _friendsTalk.value = talkList;
    } else {
      Get.snackbar('Error', '데이터 로딩 실패');
    }
    isLoading(false);
  }


  Future<void> fetchFriendsTalkList_afterFriendTalk({required int userId, required int friendUserId}) async {

    ApiResponse response_talk = await FriendDetailAPI().fetchFriendsTalkList(userId,friendUserId);
    if (response_talk.success) {
      // 리스트 형식으로 변환
      List<FriendsTalk> talkList = (response_talk.data as List)
          .map((item) => FriendsTalk.fromJson(item))
          .toList();
      _friendsTalk.value = talkList;
    } else {
      Get.snackbar('Error', '데이터 로딩 실패');
    }

  }


  Future<void> updateMyInfo(body) async {
    isLoading(true);
    ApiResponse response = await FriendDetailAPI().updateUser(body);
    if(response.success)
      print('수정성공');
    if(!response.success)
      Get.snackbar('Error', '데이터 로딩 실패');
    isLoading(false);
  }

  Future<void> uploadImage(ImageSource source) async {
    try {
      _imageFile.value = await imageController.getSingleImage(source);
      if(_imageFile.value != null)
        _croppedFile.value = await imageController.cropImage(_imageFile.value);
      if(_croppedFile.value != null)
        _profileImage.value = true;

    } catch (e) {
      // 에러 처리
      print('Image upload error: $e');
    }
  }

  void changeMainTab(int index)  {
    _mainTabName.value = mainTabNameList[index];
  }

  void changeRidingStaticTab(int index)  {
    _ridingStatisticsTabName.value = ridingStatisticsTabNameList[index];
  }

  Future<void> getImageUrl() async {
    if (_croppedFile.value != null) {
      try {
        _profileImageUrl.value = await imageController.setNewImage(_croppedFile.value!);
      } catch (e) {
        print('Profile image upload error: $e');
      }
    }
  }

  Future<void> sendFriendRequest(body) async {
    isLoading(true);
    ApiResponse response = await FriendAPI().addFriend(body);
    CustomFullScreenDialog.cancelDialog();
    if(response.success)
      Get.snackbar('친구신청 성공', '상대방이 수락하면 친구로 등록됩니다.');
    if(!response.success)
      Get.snackbar('잠시만요!','이미 친구이거나 친구 신청 중입니다');
    isLoading(false);
  }

  Future<void> acceptFriend(body) async {

    ApiResponse response = await FriendAPI().acceptFriend(body);
    CustomFullScreenDialog.cancelDialog();
    if(response.success)
      Get.snackbar('친구수락 성공', '상대방에게도 내가 친구로 등록됩니다.');
    if(!response.success)
      Get.snackbar('앗!', '잠시후 다시 시도해주세요.');

  }

  Future<void> checkFriendRelationship(body) async {
    isLoading(true);
    ApiResponse response = await FriendAPI().checkFriendRelationship(body);
    if(response.success)
      _friend_id.value = response.data['friend_id'];
    if(!response.success)
      _friend_id.value = 0;
      isLoading(false);
  }

  Future<void> toggleBestFriend(body) async {
    print(body);
    ApiResponse response = await FriendAPI().toggleBestFriend(body);

    if(response.success) {
      _friendDetailModel.update((model) {
        model?.friendUserInfo.bestFriend = response.data['best_friend'];
      });
      if(response.data['best_friend'] == true)
      print('친친등록완료');
      if(response.data['best_friend'] == false)
        print('친친해제완료');
    } else {

    }
  }

  Future<void> getCurrentSeason() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    FirebaseFirestore.instance.collection('seasonInfo').doc('seasonInfo');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    _seasonStartDate.value = documentSnapshot.get('startDate');
    _seasonEndDate.value = documentSnapshot.get('endDate');
    String seasonDate = "${_seasonStartDate.value}, ${_seasonEndDate.value}";
    _seasonDate.value = seasonDate;
    print('현재 시즌 : $seasonDate');
  }

  void updateSelectedDailyIndex(int index) {
    _selectedDailyIndex.value = index;
  }

  void changefriendsTalkInputText(value) {
    _friendsTalkInputText.value = value;
  }

  Future<void> deleteFriendsTalk({required int userId, required int friendsTalkId}) async {
    isLoading(true);
    ApiResponse response = await FriendDetailAPI().deleteFriendsTalk(userId,friendsTalkId);
    if(response.success)
      print('방명록 삭제 완료');
    if(!response.success)
      print('방명록 삭제 실패');
    isLoading(false);
  }

  Future<void> reportFriendsTalk(body) async {
    isLoading(true);
    ApiResponse response = await FriendDetailAPI().reportFriendsTalk(body);

    if (response.success) {
      if(response.data['message']=='Friends talk has been reported.') {
      }
      if(response.data['message']=='You have already reported this friends talk.'){
      }
    }
    isLoading(false);
  }



  Future<void> unblockUser(body) async {
    isLoading(true);
    ApiResponse response = await FriendDetailAPI().unblockUser(body);
    if(response.success)
      print('차단 해제 완료');
    if(!response.success)
      Get.snackbar('Error', '차단 해제 실패');
    isLoading(false);
  }

  Future<void> uploadFriendsTalk(body) async {
    isLoading(true);
    ApiResponse response = await FriendDetailAPI().createOrUpdateFriendsTalk(body);
    if(response.success)
      print('글 업로드 완료');
    if(!response.success)
      Get.snackbar('Error', '업로드 실패');
    isLoading(false);
  }

  // 각 유저의의 상세 정보를 불러와 로고 URL, 이름 저장
  Future<void> findFriendDetails(int userId, int friendUserId, String seasonDate) async {
    await fetchFriendDetailInfo(userId: userId, friendUserId: friendUserId, season: seasonDate);
    findFriendInfo[friendUserId] = {
      'displayName': _friendDetailModel.value.friendUserInfo.displayName,
      'profileImageUrlUser': _friendDetailModel.value.friendUserInfo.profileImageUrlUser ?? '',
    };
  }


}

