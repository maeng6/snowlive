
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/api/api_friendDetail.dart';
import 'package:com.snowlive/model/m_friendDetail.dart';
import 'package:com.snowlive/model/m_friendsTalk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill_extensions/services/image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import '../api/ApiResponse.dart';
import '../api/api_friend.dart';
import 'vm_imageController.dart';

class FriendDetailViewModel extends GetxController {

  static const mainTabNameListConst = [
    '라이딩 통계',
    '방명록'
  ];

  static const ridingStatisticsTabNameListConst = [
    '누적 통계',
    '일간 통계'
  ];



  @override
  void onInit() async {
    super.onInit();
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
    print('프디페 끝');
  }

  late RxList<String> mainTabNameList;
  late RxList<String> ridingStatisticsTabNameList;
  late RxString _mainTabName;
  late RxString _ridingStatisticsTabName;

  var _friendDetailModel = FriendDetailModel().obs;
  RxList<FriendsTalk> _friendsTalk = <FriendsTalk>[].obs;

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
    await FriendDetailAPI().fetchFriendsTalkList(userId,friendUserId);
    if(response.success)
      _friendDetailModel.value = response.data as FriendDetailModel;
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
    if(response.success)
      Get.snackbar('친구신청 성공', '상대방이 수락하면 친구로 등록됩니다.');
    if(!response.success)
      Get.snackbar('앗!', '${response.error['error']}');
    isLoading(false);
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
    isLoading(true);
    ApiResponse response = await FriendAPI().toggleBestFriend(body);

    if(response.success) {
      _friendDetailModel.update((model) {
        model?.friendUserInfo.bestFriend = response.data['best_friend'];
      });
      Get.snackbar('등록 성공','친한친구로 등록되었습니다.');
    } else {
      Get.snackbar('등록 실패', '등록에 실패했습니다.');
    }
    isLoading(false);
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
      Get.snackbar('Error', '삭제 실패');
    isLoading(false);
  }

  Future<void> reportFriendsTalk(body) async {
    isLoading(true);
    ApiResponse response = await FriendDetailAPI().reportFriendsTalk(body);
    if(response.success)
      print('방명록 신고 완료');
    if(!response.success)
      Get.snackbar('Error', '신고 실패');
    isLoading(false);
  }

  Future<void> blockUser(body) async {
    isLoading(true);
    ApiResponse response = await FriendDetailAPI().blockUser(body);
    if(response.success)
      print('차단 완료');
    if(!response.success)
      Get.snackbar('Error', '차단 실패');
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




}

