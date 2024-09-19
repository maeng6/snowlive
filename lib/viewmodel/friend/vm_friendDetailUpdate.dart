import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_login.dart';
import 'package:com.snowlive/api/api_user.dart';
import 'package:com.snowlive/model/m_resortModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.snowlive/viewmodel/util/vm_imageController.dart';

class FriendDetailUpdateViewModel extends GetxController {
  final TextEditingController textEditingController_displayName = TextEditingController();
  final TextEditingController textEditingController_stateMsg = TextEditingController();
  final TextEditingController textEditingControllerYYYY = TextEditingController();
  final TextEditingController textEditingControllerMM = TextEditingController();
  final TextEditingController textEditingControllerDD = TextEditingController();
  final formKey = GlobalKey<FormState>();
  RxString _displayName = ''.obs;
  RxBool _isCheckedDisplayName = false.obs;
  RxBool _profileImage = false.obs;
  RxBool _activeCheckDisplaynameButton = false.obs;
  RxBool _hideProfile = false.obs;
  Rx<XFile?> _imageFile = Rx<XFile?>(null);
  Rx<XFile?> _croppedFile = Rx<XFile?>(null);
  RxString _profileImageUrl = ''.obs;
  RxString _selectedResortName = ''.obs;
  RxInt _selectedResortIndex = 99.obs;
  RxString _selectedSkiOrBoard = ''.obs;
  RxString _selectedSex = ''.obs;
  var _startSnowliveReturn;

  String get displayName => _displayName.value;
  bool get isCheckedDisplayName => _isCheckedDisplayName.value;
  bool get profileImage => _profileImage.value;
  bool get activeCheckDisplaynameButton => _activeCheckDisplaynameButton.value;
  bool get hideProfile => _hideProfile.value;
  XFile? get imageFile => _imageFile.value;
  XFile? get croppedFile => _croppedFile.value;
  String get profileImageUrl => _profileImageUrl.value;
  String get selectedResortName => _selectedResortName.value;
  String get selectedSkiOrBoard => _selectedSkiOrBoard.value;
  String get selectedSex => _selectedSex.value;
  int get selectedResortIndex => _selectedResortIndex.value;
  dynamic get startSnowliveReturn => _startSnowliveReturn;

  ImageController imageController = Get.find<ImageController>();

  // Setter for croppedFile
  void setCroppedFile(XFile? file) {
    _croppedFile.value = file;
    _profileImage.value = file != null; // Update profileImage based on croppedFile existence
  }

  // Setter for profileImageUrl
  void setProfileImageUrl(String url) {
    _profileImageUrl.value = url;
  }

  // Method to reset the image selection (cancel selected image)
  void cancelSelectedImage() {
    _profileImage.value = false;
    _croppedFile.value = null;
    _profileImageUrl.value = ''; // Also reset the profile image URL
  }

  Future<void> fetchFriendDetailUpdateData({
    required displayName,
    required state_msg,
    required profileImageUrl,
    required selectedResortName,
    required selectedResortIndex,
    required selectedSkiOrBoard,
    required selectedSex,
    required bool hideProfile
  }) async {
    // Update text controllers and selected values
    this.textEditingController_displayName.text = displayName;
    this.textEditingController_stateMsg.text = state_msg;
    this._displayName.value = displayName;
    this._profileImageUrl.value = profileImageUrl;
    this._selectedResortName.value = selectedResortName;
    this._selectedResortIndex.value = selectedResortIndex;
    this._selectedSkiOrBoard.value = selectedSkiOrBoard;
    this._selectedSex.value = selectedSex;
    this._hideProfile.value = hideProfile;
    this._isCheckedDisplayName.value = true;
  }

  FriendDetailUpdateViewModel() {
    textEditingController_displayName.addListener(() {
      _isCheckedDisplayName.value = false;
    });
  }

  Future<void> uploadImage(ImageSource source) async {
    try {
      _imageFile.value = await imageController.getSingleImage(source);
      if (_imageFile.value != null) _croppedFile.value = await imageController.cropImage(_imageFile.value);
      if (_croppedFile.value != null) _profileImage.value = true;
    } catch (e) {
      // 에러 처리
      print('Image upload error: $e');
    }
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

  void toggleCheckDisplayname(bool active) {
    _activeCheckDisplaynameButton.value = active;
  }

  void toggleIsCheckedDisplayName(bool active) {
    _isCheckedDisplayName.value = active;
  }

  void selectResortInfo(int selectedIndex) {
    _selectedResortIndex.value = selectedIndex;
    _selectedResortName.value = resortNameList[selectedIndex]!;
  }

  void selectSkiOrBoard(String selected) {
    _selectedSkiOrBoard.value = selected;
  }

  void selectSex(String selected) {
    _selectedSex.value = selected;
  }

  void toggleHideProfile(bool value) {
    _hideProfile.value = value;
  }


  Future<void> checkDisplayName(body) async {
    ApiResponse response = await LoginAPI().checkDisplayName(body);
    if (response.success) {
      print(response.data['message']);
      _isCheckedDisplayName.value = true;
      _displayName.value = textEditingController_displayName.text;
    } else {
      _isCheckedDisplayName.value = false;
    }
  }

  Future<void> updateFriendDetail(body) async {
    ApiResponse response = await UserAPI().updateUserInfo(body);
    if (response.success) {
      print('유저 정보 수정완료');
    } else {
      print('유저 정보 수정실패');
    }
  }
}

